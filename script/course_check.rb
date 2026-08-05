# frozen_string_literal: true

require "set"
require "yaml"
require_relative "script_scan"

# The "nothing untaught" validator (concept §3, pedagogy commitment 2).
# For every course directory (site/<school>/<NNN>/), chapters are
# ordered by their `chapter:` front matter; each chapter's body may use
# only tracked-script signs (any Edubba script — cuneiform,
# hieroglyphs) taught in chapters <= its own (`teaches:` accumulates)
# plus its own display-only `shows:` exhibits. The course
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

    # A course index.md may declare `assumes:` — one prerequisite
    # course dir or a list of them (e.g. "cuneiform/101", or
    # ["cuneiform/101", "cuneiform/102"] for C103): every sign taught
    # anywhere in those courses counts as taught from chapter 0 here.
    def assumed_signs(course_dir)
      index = File.join(course_dir, "index.md")
      return Set.new unless File.exist?(index)

      fm_text = File.read(index, encoding: "UTF-8")
      return Set.new unless fm_text.start_with?("---\n") && (fm_end = fm_text.index("\n---", 4))

      fm = YAML.safe_load(fm_text[4..fm_end]) || {}
      Array(fm["assumes"]).each_with_object(Set.new) do |prereq, all|
        prereq_dir = File.expand_path(File.join(course_dir, "..", "..", prereq))
        Dir.glob(File.join(prereq_dir, "*.md")).each do |p|
          ch = load_chapter(p)
          all.merge(ch[:teaches]) if ch && ch[:chapter]
        end
      end
    end

    def check_course(course_dir)
      chapters = Dir.glob(File.join(course_dir, "*.md"))
                    .map { |p| load_chapter(p) }
                    .compact
                    .select { |c| c[:chapter] }
                    .sort_by { |c| c[:chapter] }
      found = []
      taught = assumed_signs(course_dir)
      chapters.each do |ch|
        taught.merge(ch[:teaches])
        allowed = taught + ch[:shows]
        (ch[:used] - allowed).sort.each do |cp|
          found << Violation.new(ch[:path], "untaught-sign",
                                 "U+#{ScriptScan.format_codepoint(cp)} used but not taught by ch. #{ch[:chapter]} nor listed in shows:")
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
        glyphs.to_s.each_codepoint { |cp| set << cp if ScriptScan.tracked?(cp) }
      end
    end

    def body_codepoints(body)
      body.each_codepoint.select { |cp| ScriptScan.tracked?(cp) }.to_set
    end
  end
end
