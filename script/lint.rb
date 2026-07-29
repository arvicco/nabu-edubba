# frozen_string_literal: true

require_relative "cuneiform_scan"

# Conventions scan over site/ sources (the lint half of `rake gate`).
# Rules (see CLAUDE.md):
#   no-js         wave 1 is text-pure — no <script> tags, no .js assets
#   front-matter  every Markdown page starts with front matter ("---")
#   relative-links internal links never hard-code the production origin
#   base-relative internal links go through Liquid's relative_url, never
#                 root-absolute href="/x" or ](/x) — the site must work
#                 at any base path (github.io/nabu-edubba AND edubba.ac)
#   font-coverage every cuneiform codepoint used in site/ is covered by
#                 the committed font subset manifest (no tofu ships)
#
# Usage: ruby script/lint.rb [SITE_DIR]   (exit 1 + report on violations)

module Edubba
  module Lint
    PROD_ORIGIN = %r{https?://(www\.)?edubba\.ac}i
    SCRIPT_TAG = /<script\b/i
    ROOT_ABSOLUTE_LINK = %r{(?:href="|\]\()/(?![/)])}

    Violation = Struct.new(:file, :rule, :detail)

    module_function

    def violations(site_dir, manifest_path = CuneiformScan::MANIFEST)
      sources(site_dir).flat_map { |path| check_file(site_dir, path) } +
        js_assets(site_dir) +
        font_coverage(site_dir, manifest_path)
    end

    def font_coverage(site_dir, manifest_path)
      used = CuneiformScan.used_codepoints(site_dir)
      return [] if used.empty?

      covered = CuneiformScan.manifest_codepoints(manifest_path)
      (used - covered).sort.map do |cp|
        Violation.new(manifest_path, "font-coverage",
                      "U+#{CuneiformScan.format_codepoint(cp)} used in site/ but not in font subset — run `rake fonts`")
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
      found
    rescue ArgumentError, Encoding::InvalidByteSequenceError
      [Violation.new(path, "encoding", "not valid UTF-8")]
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
