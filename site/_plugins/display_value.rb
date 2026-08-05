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

      sign["display_value"] || Edubba::SignLinker.display_form(sign["value"])
    end
  end
end

Liquid::Template.register_filter(Edubba::DisplayValueFilter)
