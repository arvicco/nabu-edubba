#!/usr/bin/env ruby
# frozen_string_literal: true

# S101 curriculum compiler (M15-4, rulebook §5/§7): reads the curated
# pool (assets-src/data/pool-s101.yml), merges the committed Kanripo
# frequency table (rank, counts, strokes, Unihan pinyin, IDS),
# validates the chapter-dial law (5–6 fresh characters per
# chapter, §5), the keyword law (unique school-wide) and the pinyin
# display law (tone diacritics, never numbers — cross-checked
# against Unihan kMandarin), computes cumulative corpus coverage per
# chapter, and writes site/_data/sinographs101_queue.yml —
# additive-only once published (CLAUDE.md rule 5).
#
# Usage: ruby bin/sino_curriculum.rb

require "yaml"
require "date"

POOL = "assets-src/data/pool-s101.yml"
FREQ = "assets-src/data/char-freq-kanripo.tsv"
OUT = "site/_data/sinographs101_queue.yml"

module Edubba
  module SinoCurriculum
    module_function

    PINYIN_FOLD = {
      "ā" => "a", "á" => "a", "ǎ" => "a", "à" => "a",
      "ē" => "e", "é" => "e", "ě" => "e", "è" => "e",
      "ī" => "i", "í" => "i", "ǐ" => "i", "ì" => "i",
      "ō" => "o", "ó" => "o", "ǒ" => "o", "ò" => "o",
      "ū" => "u", "ú" => "u", "ǔ" => "u", "ù" => "u",
      "ǖ" => "u", "ǘ" => "u", "ǚ" => "u", "ǜ" => "u", "ü" => "u"
    }.freeze

    # Codex identity (rulebook §8, owner ruling 2026-08-11): the
    # KEYWORD is the slug — unique by law, tone-proof, homophone-
    # proof (person, humane, not-yet), where pinyin slugs were
    # neither.
    def slug_of(row)
      row["slug"] ||
        row["keyword"].to_s.downcase.gsub(/[^a-z0-9]+/, "-")
                      .gsub(/\A-|-\z/, "")
    end

    # char => {rank:, count:, docs:, strokes:, pinyin:, ids:} from the
    # committed table; total corpus tokens from the header comment.
    def freq_table(lines)
      total = nil
      rows = {}
      lines.each do |line|
        total ||= line[/^# (\d+) character tokens/, 1]&.to_i
        next if line.start_with?("#", "rank\t")

        rank, char, count, docs, strokes, pinyin, ids = line.chomp.split("\t")
        rows[char] = { "rank" => rank.to_i, "count" => count.to_i,
                       "docs" => docs.to_i, "strokes" => strokes.to_i,
                       "pinyin" => pinyin.to_s, "ids" => ids.to_s }
      end
      [rows, total]
    end

    # 5–6 fresh characters per chapter (owner ruling 2026-08-10 —
    # the site-wide 1–3 is the floor law; this school dials up).
    FRESH = (5..6)

    def validate!(pool, freq)
      pool.group_by { |s| s["chapter"] }.each do |ch, signs|
        abort "sino_curriculum: unpinned row #{signs.map { |s| s['char'] }.join(',')}" if ch.nil?
        next if FRESH.cover?(signs.size)

        abort "sino_curriculum: ch #{ch} pins #{signs.size} characters — the law says " \
              "#{FRESH.min}-#{FRESH.max} (owner ruling 2026-08-10)"
      end
      # Components-first law (owner ruling 2026-08-10, the 時=日+寺
      # lesson): a compound's every part is taught in an earlier
      # chapter, or earlier in the same chapter's own table.
      seen = []
      pool.each do |s|
        Array(s["parts"]).each do |part|
          next if seen.include?(part)

          abort "sino_curriculum: #{s['char']} (ch #{s['chapter']}) is built from " \
                "#{part}, which is not yet taught — components before compounds " \
                "(owner ruling 2026-08-10)"
        end
        seen << s["char"]
      end
      dup = pool.map { |s| s["char"] }.tally.select { |_, n| n > 1 }
      abort "sino_curriculum: duplicate rows #{dup.keys.join(',')}" unless dup.empty?
      kw = pool.map { |s| s["keyword"] }.tally.select { |_, n| n > 1 }
      abort "sino_curriculum: keyword taken twice: #{kw.keys.join(',')} (rulebook §3)" unless kw.empty?
      slugs = pool.map { |s| slug_of(s) }.tally.select { |_, n| n > 1 }
      abort "sino_curriculum: codex slug collision #{slugs.keys.join(',')} — give the " \
            "colliding rows explicit slug: entries (rulebook §8)" unless slugs.empty?
      pool.each do |s|
        row = freq[s["char"]]
        abort "sino_curriculum: #{s['char']} not in the frequency table" unless row
        abort "sino_curriculum: #{s['char']} pinyin '#{s['pinyin']}' carries a tone " \
              "number — diacritics only (rulebook §2)" if s["pinyin"].to_s.match?(/\d/)
        next if row["pinyin"].empty? || row["pinyin"].split.include?(s["pinyin"])
        next if s["pinyin_divergence"] # recorded, deliberate

        abort "sino_curriculum: #{s['char']} pinyin '#{s['pinyin']}' does not match " \
              "Unihan kMandarin '#{row['pinyin']}' — typo, or record the divergence"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  pool = YAML.safe_load_file(POOL)["signs"]
  freq, total = Edubba::SinoCurriculum.freq_table(File.foreach(FREQ))
  abort "sino_curriculum: no token total in #{FREQ} header" unless total
  Edubba::SinoCurriculum.validate!(pool, freq)

  signs = pool.map do |s|
    row = freq[s["char"]]
    { "char" => s["char"],
      "glyph" => s["char"],
      "name" => Edubba::SinoCurriculum.slug_of(s),
      "codepoint" => format("%04X", s["char"].codepoints.first),
      "keyword" => s["keyword"],
      "pinyin" => s["pinyin"],
      "meaning" => s["meaning"],
      "category" => s["category"],
      "certainty" => s["certainty"],
      "strokes" => row["strokes"],
      "ids" => row["ids"],
      "rank" => row["rank"],
      "count_kanripo" => row["count"],
      "docs" => row["docs"],
      "chapter" => s["chapter"],
      "parts" => s["parts"],
      "note" => s["note"] }.compact
  end

  running = 0
  batches = signs.group_by { |s| s["chapter"] }.sort.map do |ch, batch|
    running += batch.sum { |s| s["count_kanripo"] }
    { "chapter" => ch,
      "signs" => batch.map { |s| s["char"] },
      "coverage_pct" => (100.0 * running / total).round(1) }
  end

  header = <<~HEADER
    # GENERATED by bin/sino_curriculum.rb from assets-src/data/pool-s101.yml
    # + char-freq-kanripo.tsv — do not edit by hand. S101 character
    # queue: chapter = the S101 chapter that teaches the character.
    # Contract: additive changes only once published (CLAUDE.md rule 5).
  HEADER
  doc = {
    "provenance" => "Generated by bin/sino_curriculum.rb; coverage = share of " \
                    "the #{total} Kanripo character tokens covered by the " \
                    "cumulative inventory (a floor).",
    "signs" => signs, "batches" => batches
  }
  File.write(OUT, header + doc.to_yaml.sub(/\A---\n/, ""))
  puts "sino_curriculum: #{signs.size} characters, #{batches.size} batches, " \
       "coverage #{batches.last['coverage_pct']}% -> #{OUT}"
end
