# frozen_string_literal: true

require "set"

# Shared scanner for every native script Edubba teaches: which tracked
# codepoints does the site actually use, and which does each committed
# font subset cover? Used by script/subset_fonts.rb (generation),
# script/lint.rb (gate: used ⊆ covered per script — no tofu ships) and
# script/course_check.rb (the nothing-untaught rule, script-agnostic).
#
# Adding a school's script = adding one SCRIPTS entry (+ vendored font).

module Edubba
  module ScriptScan
    SCRIPTS = {
      # Sumero-Akkadian + Numbers and Punctuation + Early Dynastic blocks.
      "cuneiform" => {
        range: (0x12000..0x1254F),
        manifest: "site/assets/fonts/cuneiform-coverage.txt",
        source_ttf: "assets-src/fonts/NotoSansCuneiform-Regular.ttf",
        subset_ttf: "site/assets/fonts/NotoSansCuneiform-subset.ttf"
      },
      # Egyptian Hieroglyphs base block (no format controls: D4-a rules
      # linear display; quadrat stacking is taught in figures, not text).
      "hieroglyphs" => {
        range: (0x13000..0x1342F),
        manifest: "site/assets/fonts/hieroglyphs-coverage.txt",
        source_ttf: "assets-src/fonts/NotoSansEgyptianHieroglyphs-Regular.ttf",
        subset_ttf: "site/assets/fonts/NotoSansEgyptianHieroglyphs-subset.ttf"
      }
    }.freeze

    RANGES = SCRIPTS.values.map { |s| s[:range] }.freeze

    module_function

    def tracked?(codepoint)
      RANGES.any? { |r| r.cover?(codepoint) }
    end

    # yml included: site/_data files feed Liquid-generated pages (e.g.
    # the 101 Reference sign list), so their glyphs need font coverage.
    def used_codepoints(site_dir, range)
      Dir.glob(File.join(site_dir, "**", "*.{md,html,yml}")).each_with_object(Set.new) do |path, set|
        File.read(path, encoding: "UTF-8").each_codepoint do |cp|
          set << cp if range.cover?(cp)
        end
      rescue ArgumentError, Encoding::InvalidByteSequenceError
        # invalid UTF-8 is reported separately by the lint encoding rule
      end
    end

    def manifest_codepoints(manifest_path)
      return Set.new unless File.exist?(manifest_path)

      File.readlines(manifest_path, chomp: true)
          .reject { |l| l.empty? || l.start_with?("#") }
          .map { |l| Integer(l, 16) }
          .to_set
    end

    def format_codepoint(codepoint)
      format("%04X", codepoint)
    end
  end
end
