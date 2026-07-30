# frozen_string_literal: true

# Subscript-index renderer (owner report 2026-07-30): the site's serif
# stack has no real glyphs for Unicode subscript digits (U+2080–2089),
# so *lu₂* rendered as font-fallback roulette — full-size oldstyle
# digits on macOS. Sources keep the clean Unicode subscripts (the
# subscript-index lint rule guards them); this transformer converts
# them to genuine <sub> markup in the rendered HTML, which every
# browser typesets as a true subscript regardless of font coverage.
# Wired to post_render by site/_plugins/subscript_render.rb.
#
# Rules:
# - Runs of subscript digits become one <sub>…</sub> with ASCII digits.
# - Never inside <title>, <svg>, <script>, <style>, <code>, <pre>,
#   or an existing <sub>; tags (and so attributes) pass through whole.

module Edubba
  module SubscriptRender
    TOKEN = /<[^>]*>|[^<]+/m
    SUBSCRIPTS = /[₀-₉]+/
    DIGITS = ("₀".."₉").zip("0".."9").to_h

    module_function

    def transform(html)
      return html unless html.match?(SUBSCRIPTS)

      skip_depth = 0
      html.gsub(TOKEN) do |tok|
        if tok.start_with?("<")
          case tok
          when /\A<(title|svg|script|style|code|pre|sub)[\s>]/i then skip_depth += 1
          when %r{\A</(title|svg|script|style|code|pre|sub)>}i  then skip_depth -= 1 if skip_depth.positive?
          end
          tok
        elsif skip_depth.positive?
          tok
        else
          tok.gsub(SUBSCRIPTS) { |run| "<sub>#{run.gsub(/./) { |c| DIGITS[c] }}</sub>" }
        end
      end
    end
  end
end
