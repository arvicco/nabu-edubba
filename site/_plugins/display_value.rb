# frozen_string_literal: true

# Liquid filter for registry sign rows (owner report 2026-08-05: the
# C102 Reference printed raw ATF — ku3, sza3, szu — because the
# template emitted {{ s.value }} unfolded). `sign_reads` renders a
# row's reading in display convention: the row's explicit
# display_value when present (niŋ₂ — the mechanical fold can't know
# g→ŋ), else the standard fold (sz→š, s,→ṣ, t,→ṭ, index digits to
# subscripts). Logic lives in script/sign_linker.rb for the tests.

require_relative "../../script/sign_linker"

module Edubba
  module DisplayValueFilter
    def sign_reads(sign)
      return "" unless sign.is_a?(Hash)

      p = Edubba::SignLinker.phonetic(sign["display_value"] || sign["value"])
      p.empty? ? "" : "[#{p}]"
    end

    # Sign NAMES display with subscript indexes (EŠ₂, not EŠ2);
    # ASCII stays in identifiers and slugs only.
    def sign_name(sign)
      name = sign.is_a?(Hash) ? sign["name"] : sign
      name.to_s.gsub(/(?<=\p{L})\d+/) { |run| run.each_char.map { |c| Edubba::SignLinker::SUB_DIGITS[c] }.join }
    end
  end
end

Liquid::Template.register_filter(Edubba::DisplayValueFilter)
