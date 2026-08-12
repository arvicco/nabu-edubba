# frozen_string_literal: true

# Jekyll wiring for the sign-linking transformer (script/sign_linker.rb):
# after each page renders, every known cuneiform glyph becomes a link to
# where it was introduced. Logic lives outside _plugins so the test
# suite can exercise it without Jekyll.

require_relative "../../script/sign_linker"
require_relative "../../script/rulebook"

Jekyll::Hooks.register [:pages, :documents], :post_render do |page|
  next unless page.output_ext == ".html"

  site = page.site
  @sign_map ||= begin
    reference = site.pages.find { |p| p.data["course"] == "cuneiform-101" && p.data["chapter"] == 12 }
    chapter_urls = site.pages.each_with_object({}) do |p, h|
      h[p.data["chapter"]] = p.url if p.data["course"] == "cuneiform-102" && p.data["chapter"]
    end
    map = Edubba::SignLinker.build_map(
      site.data["sign_teaching"], site.data["cuneiform102_queue"],
      reference&.url || "/cuneiform/101/12-reference/", chapter_urls
    )
    # School #2: hieroglyphs link to their teaching chapter in 101
    # (hiero_teaching.yml uses taught_in; same anchors, bubbles free).
    hiero_urls = site.pages.each_with_object({}) do |p, h|
      h[p.data["chapter"]] = p.url if p.data["course"] == "hieroglyphs-101" && p.data["chapter"]
    end
    Array(site.data.dig("hiero_teaching", "signs")).each do |s|
      url = hiero_urls[s["taught_in"]] or next
      map[s["glyph"]] = { url: url, anchor: "sign-#{s['codepoint']}",
                          tip: Edubba::SignLinker.tip_join(
                            [s["gardiner"], s["value"], s["meaning"]]
                          ) }
    end
    # E102's queue joins the map the way C102's always did — its
    # chapters predate this wiring, so their tables self-heal here.
    hiero102_urls = site.pages.each_with_object({}) do |p, h|
      h[p.data["chapter"]] = p.url if p.data["course"] == "hieroglyphs-102" && p.data["chapter"]
    end
    Array(site.data.dig("hieroglyphs102_queue", "signs")).each do |s|
      ch = s["chapter"] or next
      url = hiero102_urls[ch] or next
      map[s["glyph"]] = { url: url, anchor: "sign-#{s['codepoint']}",
                          tip: Edubba::SignLinker.tip_join(
                            [s["gardiner"], s["value"], s["meaning"]]
                          ) }
    end
    # C103 (Akkadian): new signs link to their teaching chapter.
    # Veterans keep their sux entry for Sumerian pages but carry
    # url_akk + tip_akk (owner ruling 2026-08-06): on Akkadian
    # pages the glyph points at its AKKADIAN reintroduction and
    # shows the Akkadian bubble — no cross-language leaks (§9).
    akk_urls = site.pages.each_with_object({}) do |p, h|
      h[p.data["chapter"]] = p.url if p.data["course"] == "cuneiform-103" && p.data["chapter"]
    end
    Array(site.data.dig("cuneiform103_queue", "signs")).each do |s|
      ch = s["chapter"] or next
      url = akk_urls[ch] or next
      if (entry = map[s["glyph"]])
        entry[:url_akk] = url
        entry[:tip_akk] = Edubba::SignLinker.tip_text_veteran(s)
        next
      end

      map[s["glyph"]] = { url: url, anchor: "sign-#{s['codepoint']}",
                          tip: Edubba::SignLinker.tip_text(s) }
    end
    # School #3 (sinographs): characters link to their teaching
    # chapter in S101; the bubble is keyword · pinyin · meaning
    # (rulebook §3/§6 — the keyword is the handle, the pinyin the
    # voice).
    sino_urls = site.pages.each_with_object({}) do |p, h|
      h[p.data["chapter"]] = p.url if p.data["course"] == "sinographs-101" && p.data["chapter"]
    end
    Array(site.data.dig("sinographs101_queue", "signs")).each do |s|
      ch = s["chapter"] or next
      url = sino_urls[ch] or next
      map[s["char"]] = { url: url, anchor: "sign-#{s['codepoint']}",
                         tip: Edubba::SignLinker.tip_join(
                           [s["keyword"], s["pinyin"], s["meaning"]]
                         ) }
    end
    # S102 (Literary Chinese, the border split): its queue's chars
    # link to their S102 teaching chapters.
    sino102_urls = site.pages.each_with_object({}) do |p, h|
      h[p.data["chapter"]] = p.url if p.data["course"] == "sinographs-102" && p.data["chapter"]
    end
    Array(site.data.dig("sinographs102_queue", "signs")).each do |s|
      ch = s["chapter"] or next
      url = sino102_urls[ch] or next
      map[s["char"]] = { url: url, anchor: "sign-#{s['codepoint']}",
                         tip: Edubba::SignLinker.tip_join(
                           [s["keyword"], s["pinyin"], s["meaning"]]
                         ) }
    end
    # Codex pages (rulebook §7/§9): sign-table cells link the glyph
    # to its Addenda sign page. Wiring is driven by the rulebook's
    # CODEX ledger (SignLinker.wire_codex!) — a new registry joins
    # by landing in the ledger, which the rulebook gate already
    # forces, so the wiring can never lag a queue split again. The
    # akk shelf routes to :codex_akk (§9 language separation),
    # served on Akkadian-course pages only.
    page_urls = site.pages.each_with_object({}) { |p, h| h[p.url] = true }
    Edubba::SignLinker.wire_codex!(map, Edubba::Rulebook::CODEX, site.data, page_urls)
    map
  end

  akk_page = %w[cuneiform-103 cuneiform-addenda-akk].include?(page.data["course"])
  page.output = Edubba::SignLinker.transform(
    page.output, @sign_map, page.url, site.baseurl.to_s,
    akk_page ? :codex_akk : :codex
  )
end
