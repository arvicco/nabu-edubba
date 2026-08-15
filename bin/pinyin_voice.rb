#!/usr/bin/env ruby
# frozen_string_literal: true

# The standard-voice pipeline (rulebook §2, owner ruling 2026-08-15):
# ALL course audio — syllable citations and classical reading lines —
# is synthesized in ONE pinned voice (ElevenLabs), replacing the
# uneven human-clip patchwork. Modus operandi (owner-designed):
#
#   batch      — agent-run: read the plan (voice-plan.yml) and the
#                ledger of already-built clips (voice-ledger.yml),
#                write the pending work to voice-batch.json.
#   synth      — HUMAN-run, never the agent (golden rule 3: network-
#                mutating; golden rule 8: the key never enters the
#                repo). Reads env: ELEVENLABS_API_KEY (required),
#                ELEVENLABS_VOICE_ID, ELEVENLABS_MODEL_ID,
#                ELEVENLABS_OUTPUT_FORMAT (env overrides plan).
#                Synthesizes each batch item into staging/.
#   integrate  — agent-run: QA every staged clip (trim silence;
#                syllables pitch-verified against the declared tone
#                and span-checked, exactly as the old pipeline
#                demanded of human clips; lines duration-checked
#                with a syllable-count report), loudness-normalize
#                to −20 dB mean / −1 dB peak, encode mono 64k mp3
#                into the site, record in the ledger, regenerate
#                credits. A clip that fails QA does not ship; the
#                next batch re-requests it.
#   voices     — HUMAN-run helper: list the account's voices.
#
# Requires ffmpeg. Network only in the two HUMAN subcommands.
#
# Usage: ruby bin/pinyin_voice.rb batch [--all]
#        ruby bin/pinyin_voice.rb synth
#        ruby bin/pinyin_voice.rb integrate [--force id ...]
#        ruby bin/pinyin_voice.rb voices

require "yaml"
require "json"
require "net/http"
require "uri"
require "fileutils"
require_relative "pinyin_audio"

PLAN    = "assets-src/data/voice-plan.yml"
LEDGER  = "assets-src/data/voice-ledger.yml"
BATCH   = "assets-src/audio/voice-batch.json"
STAGING = "assets-src/audio/staging"
OUT_SYL = "site/assets/audio/pinyin"
OUT_LIN = "site/assets/audio/lines"
API_BASE = "https://api.elevenlabs.io"

module Edubba
  module PinyinVoice
    module_function

    # Engine config: the plan carries the pinned defaults; env
    # overrides each field (the owner's working contract). The API
    # key is env-only, by law.
    def resolve_engine(plan_engine, env)
      e = (plan_engine || {}).dup
      e["voice_id"] = env["ELEVENLABS_VOICE_ID"] if env["ELEVENLABS_VOICE_ID"].to_s != ""
      e["model_id"] = env["ELEVENLABS_MODEL_ID"] if env["ELEVENLABS_MODEL_ID"].to_s != ""
      e["output_format"] = env["ELEVENLABS_OUTPUT_FORMAT"] if env["ELEVENLABS_OUTPUT_FORMAT"].to_s != ""
      e["model_id"] ||= "eleven_multilingual_v2"
      e["output_format"] ||= "mp3_44100_128"
      e
    end

    def out_path(id, kind)
      kind == "line" ? File.join(OUT_LIN, "#{id}.mp3") : File.join(OUT_SYL, "#{id}.mp3")
    end

    # Pending work: every plan item not yet in the ledger (or all of
    # them with all: true — the wholesale regeneration mode).
    def pending_items(plan, ledger, all: false)
      built = ledger.fetch("built", {})
      items = []
      (plan["syllables"] || {}).each do |id, s|
        next if !all && built.key?(id)

        items << { "id" => id, "kind" => s["kind"] || "syllable",
                   "text" => s["text"], "pinyin" => s["pinyin"],
                   "verify" => s["verify"] || "tone",
                   "out" => out_path(id, "syllable") }
      end
      (plan["lines"] || {}).each do |id, l|
        next if !all && built.key?(id)

        items << { "id" => id, "kind" => "line",
                   "text" => l["text"], "pinyin" => l["pinyin"],
                   "verify" => l["verify"] || "line",
                   "out" => out_path(id, "line") }
      end
      items
    end

    # Syllable count a line's pinyin declares (for the hump report).
    def syllable_count(pinyin)
      pinyin.to_s.split(/[\s,，。？！?!:：]+/).reject(&:empty?).size
    end
  end
end

if $PROGRAM_NAME == __FILE__
  cmd = ARGV.shift or abort "usage: pinyin_voice.rb batch|synth|integrate|voices"
  plan = YAML.safe_load_file(PLAN)
  ledger = File.exist?(LEDGER) ? YAML.safe_load_file(LEDGER) : { "built" => {} }
  engine = Edubba::PinyinVoice.resolve_engine(plan["engine"], ENV)

  case cmd
  when "batch"
    items = Edubba::PinyinVoice.pending_items(plan, ledger, all: ARGV.include?("--all"))
    if items.empty?
      puts "voice batch: nothing pending — plan fully built (use --all to regenerate)"
      exit 0
    end
    FileUtils.mkdir_p(File.dirname(BATCH))
    File.write(BATCH, JSON.pretty_generate(
                        "engine" => engine.reject { |k, _| k == "api_key" },
                        "items" => items
                      ))
    puts "voice batch: #{items.size} item(s) -> #{BATCH}"
    puts "  syllables: #{items.count { |i| i['kind'] != 'line' }}, lines: #{items.count { |i| i['kind'] == 'line' }}"
    puts "Owner: run  ELEVENLABS_API_KEY=... [ELEVENLABS_VOICE_ID=...] rake voice:synth"

  when "synth"
    key = ENV["ELEVENLABS_API_KEY"].to_s
    abort "voice synth: ELEVENLABS_API_KEY not set — this is the owner-run step" if key.empty?
    abort "voice synth: no batch file (run rake voice:batch first)" unless File.exist?(BATCH)
    batch = JSON.parse(File.read(BATCH))
    eng = batch["engine"].merge(Edubba::PinyinVoice.resolve_engine(batch["engine"], ENV))
    abort "voice synth: no voice id — set ELEVENLABS_VOICE_ID or engine.voice_id in #{PLAN}" if eng["voice_id"].to_s.empty?
    FileUtils.mkdir_p(STAGING)
    done = 0
    skipped = 0
    failures = []
    batch["items"].each do |item|
      staged = File.join(STAGING, "#{item['id']}.mp3")
      if File.exist?(staged)
        skipped += 1
        next
      end
      uri = URI("#{API_BASE}/v1/text-to-speech/#{eng['voice_id']}?output_format=#{eng['output_format']}")
      body = { "text" => item["text"], "model_id" => eng["model_id"] }
      body["language_code"] = eng["language"] if eng["language"].to_s != ""
      req = Net::HTTP::Post.new(uri, "xi-api-key" => key, "Content-Type" => "application/json")
      req.body = JSON.generate(body)
      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, read_timeout: 120) { |h| h.request(req) }
      if res.code == "400" && body.key?("language_code") && res.body.include?("language_code")
        # model without language enforcement — retry without it
        req.body = JSON.generate(body.reject { |k, _| k == "language_code" })
        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, read_timeout: 120) { |h| h.request(req) }
      end
      if res.code == "200"
        File.binwrite(staged, res.body)
        done += 1
        puts "synth #{item['id']} (#{res.body.bytesize} bytes)"
      else
        failures << "#{item['id']}: HTTP #{res.code} #{res.body[0, 200]}"
      end
      sleep 0.4
    end
    puts "voice synth: #{done} synthesized, #{skipped} already staged, #{failures.size} failed"
    failures.each { |f| puts "  FAIL #{f}" }
    puts "Next: rake voice:integrate (agent-run QA + site encode)" if failures.empty?
    exit(failures.empty? ? 0 : 1)

  when "integrate"
    abort "voice integrate: ffmpeg not found" if `which ffmpeg`.empty?
    abort "voice integrate: no batch file" unless File.exist?(BATCH)
    batch = JSON.parse(File.read(BATCH))
    force = ARGV.reject { |a| a.start_with?("--") }
    built = 0
    failures = []
    tmp = File.join(STAGING, "_work")
    FileUtils.mkdir_p(tmp)
    batch["items"].each do |item|
      id = item["id"]
      staged = File.join(STAGING, "#{id}.mp3")
      next unless File.exist?(staged)
      next if ledger["built"].key?(id) && !ARGV.include?("--force") && !force.include?(id)

      # Trim leading/trailing silence, decode a QA copy.
      trimmed = File.join(tmp, "#{id}.wav")
      system("ffmpeg", "-v", "quiet", "-y", "-i", staged,
             "-af", "silenceremove=start_periods=1:start_threshold=-40dB:start_silence=0.05," \
                    "areverse,silenceremove=start_periods=1:start_threshold=-40dB:start_silence=0.05,areverse",
             trimmed)
      unless File.exist?(trimmed) && File.size(trimmed) > 1000
        failures << "#{id}: trim produced nothing usable"
        next
      end
      pcm_f = File.join(tmp, "#{id}.pcm")
      system("ffmpeg", "-v", "quiet", "-y", "-i", trimmed, "-f", "s16le", "-ac", "1", "-ar", "16000", pcm_f)
      pcm = File.binread(pcm_f)
      dur = pcm.bytesize / 2.0 / 16_000

      case item["verify"]
      when "tone"
        track = Edubba::PinyinAudio.pitch_track(pcm)
        expected = Edubba::PinyinAudio.tone_of(item["pinyin"].to_s)
        unless Edubba::PinyinAudio.tone_ok?(expected, track)
          got = Edubba::PinyinAudio.classify(track)
          failures << "#{id}: pitch says #{got}, pinyin #{item['pinyin']} expects #{expected} — refused"
          next
        end
        cut_pass, why = Edubba::PinyinAudio.cut_ok?(pcm, tone: expected)
        unless cut_pass
          failures << "#{id}: #{why} — refused"
          next
        end
      when "line"
        unless dur.between?(0.8, 20.0)
          failures << "#{id}: duration #{dur.round(2)}s outside 0.8–20s — refused"
          next
        end
        want = Edubba::PinyinVoice.syllable_count(item["pinyin"])
        got = Edubba::PinyinAudio.humps(Edubba::PinyinAudio.envelope(pcm))
        puts "  #{id}: #{dur.round(2)}s, #{got} energy humps for #{want} syllables (report only)"
      else # "loudness" — neutral tone, tone sequences: no contour law
        unless dur.between?(0.1, 20.0)
          failures << "#{id}: duration #{dur.round(2)}s implausible — refused"
          next
        end
      end

      out = item["out"]
      FileUtils.mkdir_p(File.dirname(out))
      det = `ffmpeg -i #{trimmed.inspect} -af volumedetect -f null - 2>&1`
      mean = det[/mean_volume: (-?[\d.]+) dB/, 1].to_f
      peak = det[/max_volume: (-?[\d.]+) dB/, 1].to_f
      gain = [-20.0 - mean, -1.0 - peak].min
      system("ffmpeg", "-v", "quiet", "-y", "-i", trimmed, "-ac", "1", "-ar", "44100",
             "-af", format("volume=%.1fdB", gain),
             "-codec:a", "libmp3lame", "-b:a", "64k", out)
      ledger["built"][id] = { "date" => Time.now.strftime("%Y-%m-%d"),
                              "voice_id" => batch["engine"]["voice_id"] || ENV["ELEVENLABS_VOICE_ID"],
                              "model_id" => batch["engine"]["model_id"],
                              "text" => item["text"], "pinyin" => item["pinyin"] }
      built += 1
      puts "built #{File.basename(out)} (#{item['verify']} ✓)"
    end

    unless built.zero?
      File.write(LEDGER, "# GENERATED by bin/pinyin_voice.rb integrate — the record of\n" \
                         "# every synthesized clip: when, which voice, what text.\n" +
                         YAML.dump(ledger))
      eng_line = "ElevenLabs #{ledger['built'].values.map { |b| b['model_id'] }.compact.uniq.join('/')}" \
                 " · voice #{ledger['built'].values.map { |b| b['voice_id'] }.compact.uniq.join('/')}"
      syl = ledger["built"].select { |id, _| File.exist?(File.join(OUT_SYL, "#{id}.mp3")) }
      lin = ledger["built"].select { |id, _| File.exist?(File.join(OUT_LIN, "#{id}.mp3")) }
      File.write(File.join(OUT_SYL, "CREDITS-syllables.txt"), <<~TXT)
        Per-syllable audio credits
        ==========================
        GENERATED by bin/pinyin_voice.rb — do not edit by hand.
        All syllable audio is SYNTHESIZED in one standard voice
        (#{eng_line}), then pitch-verified against the declared tone
        and loudness-normalized (mono 64 kbps mp3). The rulebook
        (docs/courses/sinographs.md §2) records the ruling: no native
        speakers of the classical language exist; one consistent
        conventional voice teaches best.
        #{syl.keys.sort.map { |id| "#{id}.mp3" }.join("\n")}
      TXT
      unless lin.empty?
        FileUtils.mkdir_p(OUT_LIN)
        File.write(File.join(OUT_LIN, "CREDITS-lines.txt"), <<~TXT)
          Reading-line audio credits
          ==========================
          GENERATED by bin/pinyin_voice.rb — do not edit by hand.
          All line audio is SYNTHESIZED in the same standard voice as
          the syllable citations (#{eng_line}); modern Mandarin
          readings of classical text, duration-checked and
          loudness-normalized.
          #{lin.keys.sort.map { |id| "#{id}.mp3" }.join("\n")}
        TXT
      end
    end
    puts "voice integrate: #{built} built, #{failures.size} failed"
    failures.each { |f| puts "  FAIL #{f}" }
    puts "Failures stay staged for inspection; fix the plan and re-batch." unless failures.empty?
    exit(failures.empty? ? 0 : 1)

  when "voices"
    key = ENV["ELEVENLABS_API_KEY"].to_s
    abort "voice voices: ELEVENLABS_API_KEY not set — this is the owner-run step" if key.empty?
    uri = URI("#{API_BASE}/v1/voices")
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |h|
      h.request(Net::HTTP::Get.new(uri, "xi-api-key" => key))
    end
    abort "voice voices: HTTP #{res.code} — #{res.body.to_s[0, 300]}" unless res.code == "200"
    JSON.parse(res.body).fetch("voices", []).each do |v|
      puts format("%-24s %s (%s)", v["voice_id"], v["name"], (v["labels"] || {}).values.join(", "))
    end

  else
    abort "pinyin_voice: unknown subcommand #{cmd.inspect}"
  end
end
