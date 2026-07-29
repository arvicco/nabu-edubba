# frozen_string_literal: true

require "set"

# Shared scanner: which cuneiform codepoints does the site actually use,
# and which does the committed font subset cover? Used by
# script/subset_fonts.rb (generation) and script/lint.rb (gate check:
# used ⊆ covered — a page must never show tofu).

module Edubba
  module CuneiformScan
    # Sumero-Akkadian + Numbers and Punctuation + Early Dynastic blocks.
    RANGE = (0x12000..0x1254F)

    MANIFEST = "site/assets/fonts/cuneiform-coverage.txt"

    module_function

    # yml included: site/_data files feed Liquid-generated pages (e.g.
    # the 101 Reference sign list), so their glyphs need font coverage.
    def used_codepoints(site_dir)
      Dir.glob(File.join(site_dir, "**", "*.{md,html,yml}")).each_with_object(Set.new) do |path, set|
        File.read(path, encoding: "UTF-8").each_codepoint do |cp|
          set << cp if RANGE.cover?(cp)
        end
      rescue ArgumentError, Encoding::InvalidByteSequenceError
        # invalid UTF-8 is reported separately by the lint encoding rule
      end
    end

    def manifest_codepoints(manifest_path = MANIFEST)
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
