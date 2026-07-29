# frozen_string_literal: true

require "set"
require "yaml"
require_relative "cuneiform_scan"

# The "nothing untaught" validator (concept §3, pedagogy commitment 2).
# For every course directory (site/<school>/<NNN>/), chapters are
# ordered by their `chapter:` front matter; each chapter's body may use
# only cuneiform signs taught in chapters <= its own (`teaches:`
# accumulates) plus its own display-only `shows:` exhibits. The course
# index page (index.md, no `chapter:` key) is exempt from the taught
# rule but its glyphs must still be font-covered (lint's other rule).

module Edubba
  module CourseCheck
    Violation = Struct.new(:file, :rule, :detail)

    module_function

    def course_dirs(site_dir)
      Dir.glob(File.join(site_dir, "*", "[0-9][0-9][0-9]"))
         .select { |p| File.directory?(p) }
    end

    def violations(site_dir)
      course_dirs(site_dir).flat_map { |dir| check_course(dir) }
    end

    def check_course(course_dir)
      chapters = Dir.glob(File.join(course_dir, "*.md"))
                    .map { |p| load_chapter(p) }
                    .compact
                    .select { |c| c[:chapter] }
                    .sort_by { |c| c[:chapter] }
      found = []
      taught = Set.new
      chapters.each do |ch|
        taught.merge(ch[:teaches])
        allowed = taught + ch[:shows]
        (ch[:used] - allowed).sort.each do |cp|
          found << Violation.new(ch[:path], "untaught-sign",
                                 "U+#{CuneiformScan.format_codepoint(cp)} used but not taught by ch. #{ch[:chapter]} nor listed in shows:")
        end
      end
      found
    end

    def load_chapter(path)
      text = File.read(path, encoding: "UTF-8")
      return nil unless text.start_with?("---\n")

      fm_end = text.index("\n---", 4)
      return nil unless fm_end

      fm = YAML.safe_load(text[4..fm_end]) || {}
      body = text[(fm_end + 4)..] || ""
      {
        path: path,
        chapter: fm["chapter"],
        teaches: glyph_codepoints(fm["teaches"]),
        shows: glyph_codepoints(fm["shows"]),
        used: body_codepoints(body)
      }
    end

    def glyph_codepoints(list)
      Array(list).each_with_object(Set.new) do |glyphs, set|
        glyphs.to_s.each_codepoint { |cp| set << cp if CuneiformScan::RANGE.cover?(cp) }
      end
    end

    def body_codepoints(body)
      body.each_codepoint.select { |cp| CuneiformScan::RANGE.cover?(cp) }.to_set
    end
  end
end
