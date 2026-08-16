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

require_relative "rulebook"

module Edubba
  module SignLinker
    # All tracked script ranges (cuneiform, Egyptian hieroglyphs, and
    # the Han blocks of the sinograph school).
    GLYPH = /[\u{12000}-\u{1254F}\u{13000}-\u{1342F}\u{3400}-\u{4DBF}\u{4E00}-\u{9FFF}\u{F900}-\u{FAFF}\u{20000}-\u{2EBEF}\u{2F800}-\u{2FA1F}\u{30000}-\u{323AF}]/
    TOKEN = /<[^>]*>|[^<]+/m

    module_function

    # map: { "𒀭" => { url: "/cuneiform/101/12-reference/", anchor: "sign-1202D" }, ... }
    # codex_key routes sign-cell links by language (§9 separation):
    # :codex (sux, the default) or :codex_akk on Akkadian-course
    # pages. A sign with no page in the routed codex falls back to
    # its plain teaching link — never to the other language's codex.
    def transform(html, map, page_url, baseurl = "", codex_key = :codex)
      return html unless html.match?(GLYPH)

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
          link_glyphs(tok, map, page_url, baseurl, in_sign_cell, emitted_ids, codex_key)
        end
      end
    end

    def link_glyphs(text, map, page_url, baseurl, in_sign_cell, emitted_ids, codex_key = :codex)
      text.gsub(GLYPH) do |g|
        entry = map[g]
        next g unless entry

        anchor = entry[:anchor]
        # §9 separation extends to the hover bubble AND the target:
        # on Akkadian pages a veteran shows its AKKADIAN tip and
        # links its AKKADIAN reintroduction (url_akk), never the
        # Sumerian seat — and vice versa.
        tip_text = (codex_key == :codex_akk && entry[:tip_akk]) || entry[:tip]
        url = (codex_key == :codex_akk && entry[:url_akk]) || entry[:url]
        # Sign-table cells link to the sign's codex page (rulebook §7,
        # owner design 2026-08-04) once that page exists; on the sign's
        # own teaching page the cell keeps its anchor id so incoming
        # taught-in links still land. Without a codex page (a school
        # whose shelf hasn't shipped) the original behavior stands.
        if in_sign_cell && (codex = entry[codex_key]) && codex != page_url
          tip = ""
          id_attr = ""
          if url == page_url && !emitted_ids[anchor]
            emitted_ids[anchor] = true
            id_attr = %( id="#{anchor}")
          elsif tip_text
            tip = %(<span class="sign-tip" aria-hidden="true">#{tip_text}</span>)
          end
          next %(<a class="sign-link"#{id_attr} href="#{baseurl}#{codex}">#{g}#{tip}</a>)
        end

        if in_sign_cell && url == page_url && !emitted_ids[anchor]
          emitted_ids[anchor] = true
          %(<span id="#{anchor}">#{g}</span>)
        else
          href = url == page_url ? "##{anchor}" : "#{baseurl}#{url}##{anchor}"
          tip = tip_text ? %(<span class="sign-tip" aria-hidden="true">#{tip_text}</span>) : ""
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

    # Codex wiring (rulebook §7/§9): give map entries their :codex
    # (or :codex_akk, §9 language separation) URL so sign-table
    # cells link the glyph to its Addenda page. Driven by the
    # rulebook's CODEX ledger — every registry in the ledger gets
    # wired, so a new queue can never be silently left out (the
    # 2026-08-12 S102 gap: 82 taught characters' table glyphs
    # linked nowhere because a hand-written stanza still read only
    # the 101 queue). Only URLs that exist in the build are wired.
    def wire_codex!(map, codexes, data, page_urls)
      codexes.each do |cx|
        key = cx[:shelf].include?("addenda-akk") ? :codex_akk : :codex
        cx[:registries].each do |rel|
          reg = data[File.basename(rel, ".yml")]
          Array(reg&.dig("signs")).each do |s|
            entry = map[s["glyph"]] or next
            slug = Edubba::Rulebook.sign_slug(s["gardiner"] || s["name"])
            url = "/#{cx[:shelf]}/#{slug}/"
            entry[key] = url if page_urls[url]
          end
        end
      end
      map
    end

    # "AN · [an/diŋir] · heaven; god" — name (subscript-indexed),
    # PHONETIC reading in brackets (§1), short meaning. A registry
    # row may carry an explicit display_value where the mechanical
    # fold can't know better (nig2 -> niŋ₂ -> [niŋ]).
    def tip_text(sign)
      reads = reads_display(sign["display_value"] || sign["value"])
      tip_join([display_form(sign["name"]), reads, display_form(sign["meaning"])])
    end

    # A veteran's Akkadian tip (§9, owner rulings 2026-08-06): the
    # bubble carries name · reads · the value's hook — the pool
    # meaning minus its "veteran — X gains [y]:" boilerplate, which
    # only repeats the name and reading already in the bubble. The
    # full story stays on the codex page.
    def tip_text_veteran(sign)
      reads = reads_display(sign["display_value"] || sign["value"])
      hook = sign["meaning"].to_s.sub(/\Aveteran\s*—\s*\S+ gains \[[^\]]*\]:\s*/, "")
      tip_join([display_form(sign["name"]), reads, display_form(hook)])
    end

    # For registries whose fields are already display-form (hieroglyphs:
    # Gardiner codes like D46 must NOT get subscript digits).
    def tip_join(parts)
      tip = parts.map { |p| p.to_s.strip }.reject(&:empty?).join(" · ")
      tip.empty? ? nil : tip.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
    end

    SUB_DIGITS = ("0".."9").zip("₀".."₉").to_h

    # The PHONETIC reading (§1, owner ruling 2026-08-06): what the
    # sign actually says — folded, homophone indexes stripped,
    # variants joined with "/". [ku] not ku₃; [pi] not pi₂.
    # Brackets are applied by the caller (they are presentation).
    def phonetic(value)
      display_form(value)
        .gsub(/[₀-₉]+/, "")
        .split(/\s*[;,\/]\s*/)
        .reject(&:empty?)
        .uniq
        .join("/")
    end

    # The full Reads display (§1, owner correction 2026-08-06): in
    # registry values ";" separates LEXEMES, ","/"/" separate
    # phonetic variants. The first lexeme's sound goes in brackets;
    # the others are ideographic word-readings, listed after in
    # transliteration form: "an; diŋir" -> "[an], diŋir".
    def reads_display(value)
      lexemes = value.to_s.split(";").map { |part| display_form(part) }.reject(&:empty?)
      return "" if lexemes.empty?

      head = "[#{phonetic(lexemes.first)}]"
      ([head] + lexemes.drop(1)).join(", ")
    end

    def display_form(text)
      text.to_s
          .gsub(/\s*\([^)]*\)/, "")
          .gsub("sz", "š").gsub(/s,(?=[aeiouāēīū])/, "ṣ").gsub(/t,(?=[aeiouāēīū])/, "ṭ")
          .gsub(/(?<=\p{L})\d+/) { |run| run.each_char.map { |c| SUB_DIGITS[c] }.join }
          .gsub(/\A[;,·\s]+|[;,·\s]+\z/, "")
    end
  end
end
