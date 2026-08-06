# frozen_string_literal: true

require_relative "script_scan"
require_relative "course_check"
require_relative "rulebook"

# Conventions scan over site/ sources (the lint half of `rake gate`).
# Rules (see CLAUDE.md):
#   no-js         wave 1 is text-pure — no <script> tags, no .js assets
#   front-matter  every Markdown page starts with front matter ("---")
#   relative-links internal links never hard-code the production origin
#   base-relative internal links go through Liquid's relative_url, never
#                 root-absolute href="/x" or ](/x) — the site must work
#                 at any base path (github.io/nabu-edubba AND edubba.ac)
#   font-coverage every tracked-script codepoint (cuneiform,
#                 hieroglyphs — script/script_scan.rb) used in site/ is
#                 covered by that script's committed font subset
#                 manifest (no tofu ships)
#   untaught-sign a course chapter uses only signs taught in chapters
#                 <= its own (front-matter teaches:) plus its own
#                 shows: exhibits (script/course_check.rb)
#   subscript-index transliteration display uses Unicode subscript
#                 index digits (lu₂, e₂), never full-size ASCII (lu2)
#                 — owner stylistic ruling 2026-07-30. Applies to
#                 <span class="translit"> content; spans additionally
#                 classed "atf" are exempt (verbatim raw-ATF exhibits)
#   rulebook      course content obeys its school's rulebook
#                 (docs/courses/<school>.md — the single source of
#                 truth for conventions; script/rulebook.rb
#                 implements the machine-checkable subset)
#
# Usage: ruby script/lint.rb [SITE_DIR]   (exit 1 + report on violations)

module Edubba
  module Lint
    PROD_ORIGIN = %r{https?://(www\.)?edubba\.ac}i
    SCRIPT_TAG = /<script\b/i
    ROOT_ABSOLUTE_LINK = %r{(?:href="|\]\()/(?![/)])}

    TRANSLIT_SPAN = %r{<span class="translit(?<extra>[^"]*)">(?<body>.*?)</span>}m
    ASCII_INDEX = /[A-Za-zŠšŊŋĜĝḪḫŘř]\d/

    Violation = Struct.new(:file, :rule, :detail)

    module_function

    # manifests: optional {script_name => manifest_path} overrides
    # (tests point them at fixture files).
    def violations(site_dir, manifests = {})
      sources(site_dir).flat_map { |path| check_file(site_dir, path) } +
        js_assets(site_dir) +
        font_coverage(site_dir, manifests) +
        CourseCheck.violations(site_dir) +
        Rulebook.violations(site_dir) +
        Rulebook.codex_violations(site_dir)
    end

    def font_coverage(site_dir, manifests = {})
      ScriptScan::SCRIPTS.flat_map do |name, script|
        used = ScriptScan.used_codepoints(site_dir, script[:range])
        next [] if used.empty?

        manifest_path = manifests[name] || script[:manifest]
        covered = ScriptScan.manifest_codepoints(manifest_path)
        (used - covered).sort.map do |cp|
          Violation.new(manifest_path, "font-coverage",
                        "U+#{ScriptScan.format_codepoint(cp)} (#{name}) used in site/ but not in font subset — run `rake fonts`")
        end
      end
    end

    def sources(site_dir)
      Dir.glob(File.join(site_dir, "**", "*.{md,html}"))
    end

    def js_assets(site_dir)
      Dir.glob(File.join(site_dir, "**", "*.js")).map do |path|
        Violation.new(path, "no-js", "JavaScript asset in site sources")
      end
    end

    def check_file(_site_dir, path)
      text = File.read(path, encoding: "UTF-8")
      found = []
      if SCRIPT_TAG.match?(text)
        found << Violation.new(path, "no-js", "<script> tag (wave 1 is text-pure)")
      end
      if PROD_ORIGIN.match?(text)
        found << Violation.new(path, "relative-links", "hard-coded production origin")
      end
      if ROOT_ABSOLUTE_LINK.match?(text)
        found << Violation.new(path, "base-relative",
                               %q(root-absolute internal link — use {{ '/x/' | relative_url }}))
      end
      if path.end_with?(".md") && !text.start_with?("---\n")
        found << Violation.new(path, "front-matter", "Markdown page without front matter")
      end
      found.concat(check_nav_label(path, text))
      text.scan(TRANSLIT_SPAN) do
        extra, body = Regexp.last_match[:extra], Regexp.last_match[:body]
        next if extra.split.include?("atf")

        if (hit = body[ASCII_INDEX])
          found << Violation.new(path, "subscript-index",
                                 "full-size index digit #{hit.inspect} in translit span — use Unicode subscripts (lu₂), or class the span \"translit atf\" for verbatim ATF")
        end
      end
      found
    rescue ArgumentError, Encoding::InvalidByteSequenceError
      [Violation.new(path, "encoding", "not valid UTF-8")]
    end

    # nav-label (owner report 2026-08-06: the sidebar said "šumma"
    # while the page said "If a man…"): a CHAPTER's short_title must
    # be drawn from its title — the label text (after the "NN · "
    # prefix) a case-insensitive substring of the title text — so
    # navbar and page can never disagree. Course indexes (no
    # chapter:) keep their deliberate short codes (C SUX Addenda).
    def check_nav_label(path, text)
      return [] unless path.end_with?(".md") && text.start_with?("---\n")
      return [] unless (fm_end = text.index("\n---", 4))

      require "yaml"
      fm = YAML.safe_load(text[4..fm_end]) rescue nil
      return [] unless fm.is_a?(Hash) && fm["chapter"] && fm["title"] && fm["short_title"]

      strip = ->(s) { s.to_s.sub(/\A\d+\s*·\s*/, "").downcase }
      title, label = strip.call(fm["title"]), strip.call(fm["short_title"])
      return [] if title.include?(label)

      [Violation.new(path, "nav-label",
                     "short_title #{fm['short_title'].inspect} is not drawn from title #{fm['title'].inspect} — the sidebar must echo the page")]
    end
  end
end

if $PROGRAM_NAME == __FILE__
  site_dir = ARGV.fetch(0, "site")
  abort "lint: site directory #{site_dir.inspect} not found" unless File.directory?(site_dir)
  offenses = Edubba::Lint.violations(site_dir)
  offenses.each { |v| warn "#{v.file}: [#{v.rule}] #{v.detail}" }
  if offenses.empty?
    puts "lint: clean (#{Edubba::Lint.sources(site_dir).size} sources)"
  else
    abort "lint: #{offenses.size} violation(s)"
  end
end
