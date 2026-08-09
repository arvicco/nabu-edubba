# frozen_string_literal: true

require "yaml"

# value-coverage (cuneiform rulebook §9, owner report 2026-08-09:
# "WHY is this IGI read as 'lim'? Where is it taught?"): the
# untaught-sign gate guards GLYPHS, but a reading can still speak a
# VALUE the course never taught — a-wi-lim rode the eye-sign as lim
# for eight chapters with only [ši] on the books. This check closes
# that hole: every syllabic token in an Akkadian reading
# transliteration must be a value taught, by that chapter, for a
# sign actually present in the line's script.
#
# Mechanics:
# - taught values come from the registries: sign_teaching.yml and
#   cuneiform102_queue.yml are the ambient base (available from
#   103 ch00 — the student owns those courses); cuneiform103_queue
#   rows teach at their chapter:, and a row's value_seats: map
#   defers individual values to a later chapter (IGI: ši at ch03,
#   lim at ch10).
# - matching is index-blind (§9 strips homophone indexes from
#   display): registry su₂/pi2 and token su/pi compare equal.
# - logogram stretches (span class "logo") are governed by the
#   voice-marking law and skipped here; determinatives {d}/{diš}
#   are unspoken; each ▢ in the script pardons one unmatched token
#   (the box IS the honest device for an untaught sign — its word
#   is still spoken).
module Edubba
  module ValueCheck
    Violation = Struct.new(:file, :rule, :detail)

    CUNEI = /[\u{12000}-\u{123FF}\u{12400}-\u{1247F}]/
    LOGO = %r{<span class="logo">[^<]*</span>}
    LINE = %r{<span class="script">(?<script>(?:[^<]|<span[^>]*>[^<]*</span>)*)</span><span class="translit">(?<translit>(?:[^<]|<span[^>]*>[^<]*</span>)*)</span>}

    # Known debt: values read but not yet taught, tolerated in
    # exactly the listed chapters until their teaching lands; a NEW
    # use of a listed value elsewhere still fails. The check's first
    # run (2026-08-09) found sixteen; all were paid the same day
    # (D14-b — veteran rows, bracket widenings, one glyph
    # correction). A future entry may only be added by owner ruling,
    # dated, and is paid by teaching the value and deleting its row.
    KNOWN_DEBT = {}.freeze

    # Rebus spellings taught as NAME units, not per-sign values: the
    # token is the whole written complex's voice, licensed once its
    # spelling is taught in prose. suen: 𒂗𒍪 read backwards as the
    # moon-god (C103 ch12, "two signs … fused by convention"; the
    # fuller EN.ZU story in ch17).
    REBUS = {
      "suen" => { glyphs: %w[𒂗 𒍪], chapter: 12 }
    }.freeze

    module_function

    def fold(text)
      text.gsub("š", "sz").gsub("ṣ", "s,").gsub("ṭ", "t,").gsub("ḫ", "h")
          .gsub("ŋ", "j").gsub(/[₀-₉]+/, "").gsub(/\d+/, "")
    end

    # value => { glyph => first chapter it is taught for that glyph }
    def taught_values(data_dir)
      taught = Hash.new { |h, k| h[k] = {} }
      ambient = lambda do |values, glyph|
        values.each { |v| taught[v][glyph] ||= 0 }
      end
      signs = lambda do |file|
        path = File.join(data_dir, file)
        File.exist?(path) ? Array(YAML.safe_load_file(path)["signs"]) : []
      end

      signs.call("sign_teaching.yml").each do |s|
        next unless s["glyph"]
        vals = s["value"].to_s.gsub(/\([^)]*\)/, " ")
                 .split(%r{[,;/]\s*}).map { |v| fold(v).strip }.reject(&:empty?)
        ambient.call(vals, s["glyph"])
      end
      signs.call("cuneiform102_queue.yml").each do |s|
        next unless s["glyph"]
        ambient.call(ascii_values(s["value"]), s["glyph"])
      end
      signs.call("cuneiform103_queue.yml").each do |s|
        next unless s["glyph"] && s["chapter"]
        # value_seats keys are written in registry ASCII (qi2, at,);
        # matching is index-blind, so normalize them the same way.
        seats = (s["value_seats"] || {}).transform_keys { |k| k.to_s.gsub(/\d+/, "") }
        ascii_values(s["value"]).each do |v|
          seat = (seats[v] || s["chapter"]).to_i
          cur = taught[v][s["glyph"]]
          taught[v][s["glyph"]] = seat if cur.nil? || seat < cur
        end
      end
      taught
    end

    # queue ASCII: values separated by comma-space; s,/t, keep
    # their comma (as, az, as, == [as az aṣ]); indexes stripped
    # (matching is index-blind).
    def ascii_values(field)
      field.to_s.split(/,\s+/).map { |v| v.gsub(/\d+/, "").strip }.reject(&:empty?)
    end

    def violations(site_dir, data_dir = File.join(site_dir, "_data"))
      taught = taught_values(data_dir)
      registry_violations(data_dir) +
        Dir.glob(File.join(site_dir, "cuneiform", "103", "*.md")).sort.flat_map do |path|
          text = File.read(path, encoding: "UTF-8")
          chapter = text[/^chapter: (\d+)/, 1]&.to_i
          chapter ? check_text(path, text, chapter, taught) : []
        end
    end

    # ambient-veteran guard (§9 owner ruling 2026-08-06, enforced
    # 2026-08-09 after ch17 re-taught KI as plain [ki]): a veteran
    # row must GAIN something — at least one value that is not
    # already the sign's Sumerian inventory. A sign whose value
    # crosses the border unchanged (A, MU, GI, TA …) keeps its
    # 101/102 teaching and never re-enters the queue.
    def registry_violations(data_dir)
      exists = ->(f) { File.exist?(File.join(data_dir, f)) }
      return [] unless exists.call("cuneiform103_queue.yml")

      sux = Hash.new { |h, k| h[k] = [] }
      if exists.call("sign_teaching.yml")
        Array(YAML.safe_load_file(File.join(data_dir, "sign_teaching.yml"))["signs"]).each do |s|
          next unless s["glyph"]
          vals = s["value"].to_s.gsub(/\([^)]*\)/, " ")
                   .split(%r{[,;/]\s*}).map { |v| fold(v).strip.gsub(/\d+/, "") }
          sux[s["glyph"]].concat(vals.reject(&:empty?))
        end
      end
      if exists.call("cuneiform102_queue.yml")
        Array(YAML.safe_load_file(File.join(data_dir, "cuneiform102_queue.yml"))["signs"]).each do |s|
          next unless s["glyph"]
          sux[s["glyph"]].concat(ascii_values(s["value"]))
        end
      end

      Array(YAML.safe_load_file(File.join(data_dir, "cuneiform103_queue.yml"))["signs"]).filter_map do |s|
        next unless s["veteran"] && s["glyph"]

        gained = ascii_values(s["value"]) - sux[s["glyph"]]
        next unless gained.empty?

        Violation.new(File.join(data_dir, "cuneiform103_queue.yml"), "value-coverage",
                      "#{s['name']} (ch#{s['chapter']}) re-enters as a veteran but gains NOTHING — " \
                      "its values #{s['value'].inspect} are its Sumerian inventory unchanged; ambient " \
                      "veterans keep their 101/102 teaching and never re-enter (§9)")
      end
    end

    def check_text(path, text, chapter, taught)
      found = []
      base = File.basename(path, ".md")
      text.lines.each_with_index do |line, i|
        next unless line.include?("reading-line")
        m = LINE.match(line) or next

        glyphs = m[:script].gsub(LOGO, " ").scan(CUNEI)
        pardons = m[:script].scan("▢").size
        bare = m[:translit].gsub(LOGO, " ").gsub(/<[^>]+>/, " ")
                           .gsub(/\{[a-zš]+\}/, " ")
        bare.split(/[\s\-]+/).each do |tok|
          next if tok.empty? || tok =~ /\A[[:punct:]0-9()▢.…]+\z/ || tok.include?("(")

          value = fold(tok)
          seats = taught[value] || {}
          next if seats.any? { |g, ch| glyphs.include?(g) && ch <= chapter }
          next if Array(KNOWN_DEBT[value]).include?(base)
          if (rebus = REBUS[value]) && rebus[:chapter] <= chapter &&
             rebus[:glyphs].all? { |g| glyphs.include?(g) }
            next
          end

          if pardons.positive?
            pardons -= 1
            next
          end
          taught_at = seats.select { |g, _| glyphs.include?(g) }.values.min
          hint = taught_at ? "its sign teaches it only at ch#{format('%02d', taught_at)}" :
                             "no sign in this line is taught that value"
          found << Violation.new(path, "value-coverage",
                                 "reading speaks #{tok.inspect} in ch#{format('%02d', chapter)} but #{hint} — " \
                                 "teach the value (veteran row or bracket widening + registry + codex) before it is read (§9)")
        end
      end
      found
    end
  end
end
