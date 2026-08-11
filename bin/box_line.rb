#!/usr/bin/env ruby
# frozen_string_literal: true

# box_line — mechanical boxing for reading lines (M19-1, retro rec 1).
# Hand-boxing against a mental taught-set was phase 18's single most
# error-prone step (five gate catches); this instrument does it from
# the curriculum queue instead. Give it a raw witness line and a
# chapter number; it returns the ▢-rendered line, the untaught list
# (with Unihan pinyin from the frequency table), the box share judged
# against the chapter's cap — same counting as script/lint.rb's
# box-share rule, whose han?() it reuses — and a paste-ready
# reading-line skeleton.
#
# Usage: ruby bin/box_line.rb LINE --chapter N [--school sinographs]
#   e.g. ruby bin/box_line.rb "道生一，一生二。" --chapter 12

require "yaml"
require "set"
require_relative "../script/lint"

module Edubba
  module BoxLine
    module_function

    # Per-school registry: queue (chapter = teaching chapter) and the
    # frequency table carrying the Unihan pinyin column. Other schools
    # join when they gain a character-grain queue.
    SCHOOLS = {
      "sinographs" => {
        queue: "site/_data/sinographs101_queue.yml",
        freq: "assets-src/data/char-freq-kanripo.tsv"
      }
    }.freeze

    BOX = "▢"

    def taught_set(queue_path, chapter)
      rows = YAML.safe_load_file(queue_path).fetch("signs")
      rows.select { |r| r.fetch("chapter") <= chapter }
          .map { |r| r.fetch("char") }.to_set
    end

    def han?(char) = Edubba::Lint.han?(char.ord)

    # Untaught Han characters become ▢; everything else (taught
    # characters, punctuation, spacing) passes through verbatim.
    def box(line, taught)
      line.each_char.map { |c| han?(c) && !taught.include?(c) ? BOX : c }.join
    end

    def untaught(line, taught)
      line.each_char.select { |c| han?(c) && !taught.include?(c) }.uniq
    end

    # Box share, counted exactly as the lint counts it: boxes vs
    # boxes + remaining Han characters; punctuation is outside the
    # denominator. Returns nil for a line with no countable text.
    def share(boxed)
      boxes = boxed.count(BOX)
      han = boxed.each_char.count { |c| han?(c) }
      return nil if (boxes + han).zero?

      { boxes: boxes, han: han, share: 100.0 * boxes / (boxes + han) }
    end

    # The cap law (sinographs §5): max(25, 50 − 5·⌊ch/5⌋).
    def cap_for(chapter) = [25, 50 - 5 * (chapter / 5)].max

    # ON the cap passes — untaught may never OUTNUMBER the cap's
    # allowance, and the lint's own comparison is share <= cap.
    def verdict(share, cap) = share <= cap ? "PASS" : "OVER"

    def pinyin_table(freq_path)
      File.foreach(freq_path, encoding: "UTF-8").with_object({}) do |ln, h|
        next if ln.start_with?("#") || ln.start_with?("rank\t")

        cols = ln.chomp.split("\t")
        h[cols[1]] = cols[5].to_s.empty? ? nil : cols[5] if cols[1]
      end
    end

    def skeleton(boxed)
      %(    <div class="reading-line"><span class="script">#{boxed}</span>) +
        %(<span class="translit pinyin">TODO</span>) +
        %(<span class="gloss">"TODO" — TODO</span></div>)
    end

    def report(line, chapter, school: "sinographs")
      paths = SCHOOLS.fetch(school)
      taught = taught_set(paths[:queue], chapter)
      boxed = box(line, taught)
      missing = untaught(line, taught)
      pinyin = missing.empty? ? {} : pinyin_table(paths[:freq])
      s = share(boxed)

      out = ["boxed:    #{boxed}"]
      out << if missing.empty?
               "untaught: none"
             else
               "untaught: " + missing.map { |c| "#{c} (#{pinyin[c] || '?'})" }.join("  ")
             end
      if s
        cap = cap_for(chapter)
        out << format("share:    %d box / %d han+box = %.1f%% vs cap %d%% (ch. %d) — %s",
                      s[:boxes], s[:boxes] + s[:han], s[:share], cap, chapter,
                      verdict(s[:share], cap))
      else
        out << "share:    no Han text in the line"
      end
      out << "paste:"
      out << skeleton(boxed)
      out.join("\n")
    end
  end
end

if $PROGRAM_NAME == __FILE__
  line = ARGV.find { |a| !a.start_with?("--") && !a.match?(/\A\d+\z/) }
  chapter = ARGV[ARGV.index("--chapter") + 1].to_i if ARGV.include?("--chapter")
  school = ARGV.include?("--school") ? ARGV[ARGV.index("--school") + 1] : "sinographs"
  abort "usage: box_line.rb LINE --chapter N [--school sinographs]" unless line && chapter

  puts Edubba::BoxLine.report(line, chapter, school: school)
end
