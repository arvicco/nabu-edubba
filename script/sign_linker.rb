# frozen_string_literal: true

# Sign-linking transformer (owner request 2026-07-30): every cuneiform
# glyph in rendered HTML becomes a link to the place it was introduced
# — 101 signs to their row on the 101 Reference page, 102 signs to the
# batch table of the chapter that taught them — so lookup is one click
# from anywhere. Pure text transformation over rendered HTML; the
# Jekyll plugin (site/_plugins/sign_links.rb) wires it to post_render,
# and html-proofer then validates every generated link and anchor.
#
# Rules:
# - Only glyphs in the map are touched; unknown glyphs pass through.
# - Never inside an existing <a>, <title>, <svg>, <script>, <style>.
# - Inside a `sign-cell` table cell ON the glyph's own target page,
#   the first occurrence becomes the ANCHOR (<span id=...>) instead of
#   a link — that is the destination the rest of the site points at.
# - Each link carries a hover bubble (owner request 2026-07-30): a
#   hidden <span class="sign-tip"> with name · readings · meaning,
#   shown by pure CSS on hover/focus — no JS. Anchors on a sign's own
#   page get no bubble (the table row already shows the same data).

module Edubba
  module SignLinker
    RANGE = (0x12000..0x1254F)
    TOKEN = /<[^>]*>|[^<]+/m

    module_function

    # map: { "𒀭" => { url: "/cuneiform/101/12-reference/", anchor: "sign-1202D" }, ... }
    def transform(html, map, page_url, baseurl = "")
      return html unless html.match?(/[\u{12000}-\u{1254F}]/)

      a_depth = 0
      skip_depth = 0 # title/svg/script/style nesting
      in_sign_cell = false
      emitted_ids = {}

      html.gsub(TOKEN) do |tok|
        if tok.start_with?("<")
          case tok
          when /\A<a[\s>]/i          then a_depth += 1
          when %r{\A</a>}i           then a_depth -= 1 if a_depth.positive?
          when /\A<(title|svg|script|style)[\s>]/i then skip_depth += 1
          when %r{\A</(title|svg|script|style)>}i  then skip_depth -= 1 if skip_depth.positive?
          when /\A<td[^>]*class="[^"]*sign-cell[^"]*"/i then in_sign_cell = true
          when %r{\A</td>}i          then in_sign_cell = false
          end
          tok
        elsif a_depth.positive? || skip_depth.positive?
          tok
        else
          link_glyphs(tok, map, page_url, baseurl, in_sign_cell, emitted_ids)
        end
      end
    end

    def link_glyphs(text, map, page_url, baseurl, in_sign_cell, emitted_ids)
      text.gsub(/[\u{12000}-\u{1254F}]/) do |g|
        entry = map[g]
        next g unless entry

        anchor = entry[:anchor]
        if in_sign_cell && entry[:url] == page_url && !emitted_ids[anchor]
          emitted_ids[anchor] = true
          %(<span id="#{anchor}">#{g}</span>)
        else
          href = entry[:url] == page_url ? "##{anchor}" : "#{baseurl}#{entry[:url]}##{anchor}"
          tip = entry[:tip] ? %(<span class="sign-tip" aria-hidden="true">#{entry[:tip]}</span>) : ""
          %(<a class="sign-link" href="#{href}">#{g}#{tip}</a>)
        end
      end
    end

    # Build glyph -> {url:, anchor:, tip:} from the two data files.
    # reference_url: where 101 signs anchor; chapter_urls: {2=>"/...", ...}
    def build_map(sign_teaching, queue, reference_url, chapter_urls)
      map = {}
      Array(sign_teaching&.dig("signs")).each do |s|
        map[s["glyph"]] = { url: reference_url, anchor: "sign-#{s['codepoint']}",
                            tip: tip_text(s) }
      end
      Array(queue&.dig("signs")).each do |s|
        ch = s["chapter"] or next
        url = chapter_urls[ch] or next
        map[s["glyph"]] = { url: url, anchor: "sign-#{s['codepoint']}",
                            tip: tip_text(s) }
      end
      map
    end

    # "AN · an; diŋir · heaven; god" — name, readings, short meaning.
    # Parenthetical asides (ASCII forms, certainty grades) are stripped;
    # ATF spellings normalized for display (sz -> š, index digits ->
    # Unicode subscripts, which the subscript renderer then typesets).
    def tip_text(sign)
      parts = [sign["name"], sign["value"], sign["meaning"]].map { |p| display_form(p) }
      tip = parts.map { |p| p.to_s.strip }.reject(&:empty?).join(" · ")
      tip.empty? ? nil : tip.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
    end

    SUB_DIGITS = ("0".."9").zip("₀".."₉").to_h

    def display_form(text)
      text.to_s
          .gsub(/\s*\([^)]*\)/, "")
          .gsub("sz", "š")
          .gsub(/(?<=\p{L})\d+/) { |run| run.each_char.map { |c| SUB_DIGITS[c] }.join }
          .gsub(/\A[;,·\s]+|[;,·\s]+\z/, "")
    end
  end
end
