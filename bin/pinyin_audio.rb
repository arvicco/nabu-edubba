#!/usr/bin/env ruby
# frozen_string_literal: true

# Syllable-audio acquisition pipeline (rulebook §2, owner request
# 2026-08-11: the course will need ever more pinyin as it grows).
# Reads the hand-curated manifest (pinyin-audio-sources.yml), and
# for every slug without a committed mp3:
#
#   resolve  — Commons API: direct URL + license + author; anything
#              that is not CC BY / CC BY-SA is REFUSED (never NC);
#   fetch    — paced download with exponential backoff (Wikimedia
#              rate-limits bursts hard);
#   cut      — for word recordings, silence-segment and take the
#              manifest's Nth syllable;
#   verify   — measure the pitch contour (pure-Ruby autocorrelation
#              over ffmpeg-decoded PCM) and check it against the
#              tone the queue's pinyin declares — a recording that
#              does not sing its tone does not ship;
#   encode   — mono 64k mp3 under the codex slug (no tone digits in
#              filenames — the display law holds in URLs);
#   credit   — regenerate CREDITS-syllables.txt (GENERATED block).
#
# The gap report (manifest `absent:` + any queue slug not covered)
# prints on every run. Requires ffmpeg. Network at authoring time
# only; outputs are committed.
#
# Usage: ruby bin/pinyin_audio.rb            # build what's missing
#        ruby bin/pinyin_audio.rb --report   # gaps only, no network

require "yaml"
require "json"
require "net/http"
require "uri"
require "fileutils"

MANIFEST = "assets-src/data/pinyin-audio-sources.yml"
QUEUES = ["site/_data/sinographs101_queue.yml",
          "site/_data/sinographs102_queue.yml"].freeze
OUT_DIR = "site/assets/audio/pinyin"
CREDITS = File.join(OUT_DIR, "CREDITS-syllables.txt")
CACHE = ENV.fetch("PINYIN_AUDIO_CACHE", File.expand_path("~/.cache/edubba-pinyin-audio"))
UA = "EdubbaBot/1.0 (edubba.ac; educational vendoring; github.com/arvicco/nabu-edubba)"
API = "https://commons.wikimedia.org/w/api.php"

module Edubba
  module PinyinAudio
    module_function

    TONE_MARKS = {
      level: "āēīōūǖ", rise: "áéíóúǘ", dip: "ǎěǐǒǔǚ", fall: "àèìòùǜ"
    }.freeze

    # The tone a pinyin syllable declares, from its diacritic.
    def tone_of(pinyin)
      TONE_MARKS.each { |tone, marks| return tone if pinyin.chars.any? { |c| marks.include?(c) } }
      :neutral
    end

    # Trimmed median-of-thirds features over a pitch track. Onset
    # and offset glides (and final creak) are not the tone, so 15%
    # is dropped from each end before measuring.
    def features(track, smooth: true)
      return nil if track.empty?

      trim = (track.length * 0.15).floor
      core = track[trim...(track.length - trim)]
      core = track if core.nil? || core.length < 3
      if smooth
        # Fricatives and creak track at wild, jumpy frequencies; the
        # vowel is the longest SMOOTH run (each step within 10%).
        runs = core.slice_when { |a, b| (b - a).abs > a * 0.10 }.to_a
        best = runs.max_by(&:length)
        core = best if best && best.length >= 4
      end
      third = [1, core.length / 3].max
      med = ->(a) { s = a.sort; s[s.length / 2] }
      { a: med.call(core.first(third)).to_f,
        m: med.call(core[third...(core.length - third)] || core).to_f,
        b: med.call(core.last(third)).to_f }
    end

    # Acceptance per declared tone, tolerant of real citation-form
    # variation (tone 2 onset dips, tone 3 low-flat, tone 4 creak)
    # while still refusing gross mislabels — the level/fall and
    # dip/rise confusions that would misteach. Both views are
    # consulted: the smooth vowel run (immune to fricative junk)
    # and the raw trimmed track (a steep fall fragments the run).
    def tone_ok?(expected, track)
      return true if expected == :neutral

      [features(track), features(track, smooth: false)].compact.any? do |f|
        a, m, b = f[:a], f[:m], f[:b]
        case expected
        when :level then b.between?(a * 0.85, a * 1.18) && m <= [a, b].max * 1.18
        when :rise  then b > a * 1.08 || b > m * 1.15
        when :dip   then !(b > a * 1.15 && m >= a * 0.95)
        when :fall  then b < a * 0.90 || b < m * 0.88
        end
      end
    end

    # Coarse label for logs.
    def classify(track)
      f = features(track)
      return :silent unless f

      a, m, b = f[:a], f[:m], f[:b]
      return :dip if m < [a, b].min * 0.90
      return :rise if b > a * 1.12
      return :fall if b < a * 0.85

      :level
    end

    # Cut QA (M19-3, retro rec 4): the tone check reads pitch, not
    # span — a cut carrying a neighbor syllable's onset (yuē rode
    # 会's onset, 2026-08-11) still verified "level ✓". Two span
    # checks close the gap: a single cut syllable's voiced span
    # lives inside 0.15–0.85 s, and its smoothed energy envelope is
    # one hump — a second hump is another syllable riding the cut
    # (except the citation third tone's glottal closure; see
    # cut_ok?).
    FRAME = 400 # 25 ms at 16 kHz
    SPAN = (0.15..0.85) # seconds; tuned so all 79 committed cuts pass
    HUMP_FLOOR = 0.15 # a valley below 15% of peak separates humps

    # Non-overlapping 25 ms RMS frames, 3-frame moving average.
    def envelope(pcm)
      samples = pcm.unpack("s<*")
      raw = (0...(samples.length / FRAME)).map do |i|
        w = samples[i * FRAME, FRAME]
        Math.sqrt(w.sum { |x| x * x } / w.length.to_f)
      end
      raw.each_index.map do |i|
        a = [i - 1, 0].max
        b = [i + 1, raw.length - 1].min
        raw[a..b].sum / (b - a + 1)
      end
    end

    # Maxima separated by sub-floor valleys, counted as runs of ≥2
    # frames (≥50 ms) above the floor — clicks don't count, breathy
    # onsets below the floor don't split the vowel's hump. A valley
    # must itself be ≥2 frames (≥50 ms) of sub-floor to split: a
    # fricative onset ramping across the floor flickers under it for
    # a single frame (the shū case, 2026-08-11), while a real
    # inter-syllable gap is wide.
    def humps(env)
      peak = env.max.to_f
      return 0 if peak <= 0

      env.map { |e| e >= peak * HUMP_FLOOR }
         .slice_when { |a, b| a != b }
         .reject { |run| !run.first && run.length < 2 } # 1-frame dips join
         .chunk_while { |a, b| a.first == b.first }     # re-merge neighbors
         .count { |runs| runs.first.first && runs.sum(&:length) >= 2 }
    end

    # First-to-last voiced frame, valleys included — a cut that goes
    # quiet in the middle is still that wide.
    def voiced_span(env)
      peak = env.max.to_f
      idx = env.each_index.select { |i| env[i] >= peak * HUMP_FLOOR } if peak.positive?
      return 0.0 if idx.nil? || idx.empty?

      (idx.last - idx.first + 1) * FRAME / 16_000.0
    end

    # => [ok, reason-if-refused]. The citation third tone may close
    # the glottis completely mid-dip — kě and bǎi drop to ~2% RMS in
    # dedicated single-syllable recordings — so :dip is allowed a
    # second hump; every other tone is one syllable, one hump.
    def cut_ok?(pcm, tone: nil, span: SPAN)
      env = envelope(pcm)
      got = voiced_span(env)
      unless span.cover?(got)
        return [false, format("voiced span %.2f s outside %.2f–%.2f s", got, span.min, span.max)]
      end

      h = humps(env)
      allowed = tone == :dip ? 2 : 1
      if h > allowed
        return [false, "#{h} energy humps (#{allowed} allowed for this tone) — " \
                       "another syllable rides the cut"]
      end

      [true, nil]
    end

    # Pure-Ruby pitch track over 16 kHz mono s16le PCM.
    def pitch_track(pcm)
      sr = 16_000
      frame = 640
      hop = 320
      samples = pcm.unpack("s<*")
      # Adaptive energy gate: 2% of the loudest frame, floored — so
      # quiet cut syllables still track.
      peak = 0.0
      (0..(samples.length - frame)).step(hop) do |off|
        w = samples[off, frame]
        e = w.sum { |x| x * x } / frame.to_f
        peak = e if e > peak
      end
      @gate = [peak * 0.02, 1e4].max
      track = []
      (0..(samples.length - frame)).step(hop) do |off|
        w = samples[off, frame]
        energy = w.sum { |x| x * x } / frame.to_f
        next if energy < @gate

        best = nil
        best_v = 0.0
        ((sr / 350)..(sr / 70)).step(1) do |lag|
          s = 0
          i = 0
          while i < frame - lag
            s += w[i] * w[i + lag]
            i += 4
          end
          if s > best_v
            best_v = s
            best = lag
          end
        end
        track << (sr.to_f / best).round if best
      end
      # De-octave: creak halves the period, so autocorrelation reads
      # a doubled frequency. Snap any 1.6x+ jump back onto its
      # neighbor's octave when the halved value fits the contour.
      (1...track.length).each do |i|
        prev = track[i - 1]
        if track[i] > prev * 1.6 && (track[i] / 2 - prev).abs < prev * 0.35
          track[i] /= 2
        elsif track[i] < prev * 0.6 && (track[i] * 2 - prev).abs < prev * 0.35
          track[i] *= 2
        end
      end
      track
    end
  end
end

if $PROGRAM_NAME == __FILE__
  manifest = YAML.safe_load_file(MANIFEST)
  queue = QUEUES.flat_map { |q| YAML.safe_load_file(q)["signs"] }
  sources = manifest["sources"] || {}
  voices = manifest["voices"] || {}
  absent = (manifest["absent"] || []).map { |a| a["slug"] }

  covered = voices.keys + absent
  gaps = queue.map { |s| s["name"] } - covered
  puts "GAPS (no manifest entry): #{gaps.join(', ')}" unless gaps.empty?
  puts "ABSENT (no clean recording known): #{absent.join(', ')}" unless absent.empty?
  exit 0 if ARGV.include?("--report")

  abort "pinyin_audio: ffmpeg not found" if `which ffmpeg`.empty?
  FileUtils.mkdir_p(CACHE)
  FileUtils.mkdir_p(OUT_DIR)

  api_get = lambda do |params|
    uri = URI(API)
    uri.query = URI.encode_www_form(params.merge(format: "json"))
    req = Net::HTTP::Get.new(uri)
    req["User-Agent"] = UA
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |h| h.request(req) }
    JSON.parse(res.body)
  rescue JSON::ParserError, SystemCallError, Net::OpenTimeout, Net::ReadTimeout
    nil # rate-limit HTML page or transient network trouble — caller backs off
  end

  meta_cache_path = File.join(CACHE, "meta.json")
  meta_cache = File.exist?(meta_cache_path) ? JSON.parse(File.read(meta_cache_path)) : {}

  credits = []
  built = 0
  skipped = 0
  failures = []

  sources.each do |slug, src|
    out_mp3 = File.join(OUT_DIR, "#{slug}.mp3")
    title = "File:#{src['file']}"

    if (m = meta_cache[title])
      license = m["license"]
      artist = m["artist"]
      url = m["url"]
    else
      info = nil
      4.times do |i|
        d = api_get.call(action: "query", titles: title,
                         prop: "imageinfo", iiprop: "url|extmetadata")
        page = d&.dig("query", "pages")&.values&.first || {}
        info = page["imageinfo"]&.first
        break if info

        sleep 30 * (i + 1)
      end
      unless info
        failures << "#{slug}: #{title} unresolvable (not found, or API rate-limited) — rerun later"
        next
      end
      meta = info["extmetadata"] || {}
      license = meta.dig("LicenseShortName", "value").to_s
      artist = meta.dig("Artist", "value").to_s.gsub(/<[^>]+>/, "").strip
      url = info["url"]
      meta_cache[title] = { "license" => license, "artist" => artist, "url" => url }
      File.write(meta_cache_path, JSON.pretty_generate(meta_cache))
      sleep 6 # pace the API too
    end
    unless license.match?(/\ACC (BY|BY-SA)\b/i)
      failures << "#{slug}: license #{license.inspect} refused (BY/BY-SA only)"
      next
    end

    if File.exist?(out_mp3) && !ARGV.include?("--force")
      skipped += 1
      credits << [slug, src, license, artist]
      next
    end

    ext = File.extname(src["file"])
    cached = File.join(CACHE, slug + ext)
    unless File.exist?(cached) && `file -b #{cached.inspect}`.match?(/Ogg data|WAVE|RIFF/)
      got = false
      4.times do |attempt|
        system("curl", "-sL", "-m", "60", "-A", UA, "-o", cached, url)
        if `file -b #{cached.inspect}`.match?(/Ogg data|WAVE|RIFF/)
          got = true
          break
        end
        sleep 60 * (attempt + 1) # Wikimedia backoff: 1, 2, 3 minutes
      end
      sleep 25 # base pacing between fetches
      unless got
        failures << "#{slug}: download kept failing (rate limit?) — rerun later"
        next
      end
    end

    work = cached
    if src["start"] && src["end"]
      # Explicit hand-measured window (the last resort a human sets
      # after listening/measuring; still pitch-verified below).
      work = File.join(CACHE, "#{slug}-cut.wav")
      s0 = src["start"].to_f
      e0 = src["end"].to_f
      system("ffmpeg", "-v", "quiet", "-y",
             "-ss", format("%.3f", s0), "-to", format("%.3f", e0), "-i", cached,
             "-af", "afade=t=out:st=#{format('%.3f', e0 - s0 - 0.04)}:d=0.04", work)
    elsif (n = src["syllable"])
      # Silence-segment the word and take the Nth syllable.
      noise = src["noise"] || "-35dB"
      det = `ffmpeg -i #{cached.inspect} -af silencedetect=noise=#{noise}:d=0.10 -f null - 2>&1`
      starts = det.scan(/silence_end: ([\d.]+)/).flatten.map(&:to_f)
      ends = det.scan(/silence_start: ([\d.]+)/).flatten.map(&:to_f)
      dur = `ffprobe -v quiet -show_entries format=duration -of csv=p=0 #{cached.inspect}`.to_f
      seg_starts = [0.0] + starts
      seg_ends = ends + [dur]
      segs = seg_starts.zip(seg_ends).select { |s, e| e - s > 0.12 }
      if segs.length < n && segs.length == 1 && (total = src["of"])
        # Connected speech with no internal silences: split the one
        # voiced span evenly by the word's declared syllable count.
        s1, e1 = segs.first
        step = (e1 - s1) / total
        segs = (0...total).map { |k| [s1 + k * step, s1 + (k + 1) * step] }
      end
      if segs.length < n
        failures << "#{slug}: expected ≥#{n} syllable segments, found #{segs.length}"
        next
      end
      s0, e0 = segs[n - 1]
      work = File.join(CACHE, "#{slug}-cut.wav")
      system("ffmpeg", "-v", "quiet", "-y",
             "-ss", format("%.3f", [s0 - 0.02, 0].max), "-to", format("%.3f", e0 + 0.02), "-i", cached,
             "-af", "afade=t=out:st=#{format('%.3f', e0 - s0 - 0.04)}:d=0.05", work)
    end

    # Pitch-verify against the declared tone.
    pcm_f = File.join(CACHE, "#{slug}.pcm")
    system("ffmpeg", "-v", "quiet", "-y", "-i", work, "-f", "s16le", "-ac", "1", "-ar", "16000", pcm_f)
    track = Edubba::PinyinAudio.pitch_track(File.binread(pcm_f))
    expected = Edubba::PinyinAudio.tone_of(src["pinyin"].to_s)
    unless Edubba::PinyinAudio.tone_ok?(expected, track)
      got = Edubba::PinyinAudio.classify(track)
      failures << "#{slug}: pitch says #{got}, pinyin #{src['pinyin']} expects #{expected} — refused"
      next
    end

    # Span-verify the cut (M19-3) — tone can pass on a wrong span.
    cut_pass, why = Edubba::PinyinAudio.cut_ok?(File.binread(pcm_f), tone: expected)
    unless cut_pass
      failures << "#{slug}: #{why} — refused"
      next
    end

    # Loudness-normalize (owner report 2026-08-11: sources span
    # three voices at very different levels): gain each clip to a
    # −20 dB mean, capped so peaks stay under −1 dB.
    det = `ffmpeg -i #{work.inspect} -af volumedetect -f null - 2>&1`
    mean = det[/mean_volume: (-?[\d.]+) dB/, 1].to_f
    peak = det[/max_volume: (-?[\d.]+) dB/, 1].to_f
    gain = [-20.0 - mean, -1.0 - peak].min
    system("ffmpeg", "-v", "quiet", "-y", "-i", work, "-ac", "1", "-ar", "44100",
           "-af", format("volume=%.1fdB", gain),
           "-codec:a", "libmp3lame", "-b:a", "64k", out_mp3)
    built += 1
    credits << [slug, src, license, artist]
    puts "built #{slug}.mp3 (#{expected} ✓, #{license})"
  end

  unless credits.empty?
    lines = credits.sort_by(&:first).map do |slug, src, license, artist|
      cut = src["syllable"] ? " (syllable #{src['syllable']} cut from the word)" : ""
      format("%-14s — \"%s\"%s · %s · %s", "#{slug}.mp3", src["file"], cut, artist, license)
    end
    File.write(CREDITS, <<~HEADER + lines.join("\n") + "\n")
      Per-syllable audio credits
      ==========================
      GENERATED by bin/pinyin_audio.rb — do not edit by hand.
      Recordings from Wikimedia Commons, converted to mp3 (mono,
      64 kbps); word recordings cut to the named syllable and
      pitch-verified against the declared tone at build time.
      Source pages: commons.wikimedia.org/wiki/File:<source file>

    HEADER
  end

  puts "pinyin_audio: #{built} built, #{skipped} already present, #{failures.length} failed"
  failures.each { |f| puts "  FAIL #{f}" }
  exit(failures.empty? ? 0 : 1)
end
