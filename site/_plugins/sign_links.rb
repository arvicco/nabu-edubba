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
    # C103 (Akkadian): new signs link to their teaching chapter;
    # veterans keep their sux teaching entry (body links follow
    # where-first-taught, §9 routes only the codex below).
    akk_urls = site.pages.each_with_object({}) do |p, h|
      h[p.data["chapter"]] = p.url if p.data["course"] == "cuneiform-103" && p.data["chapter"]
    end
    Array(site.data.dig("cuneiform103_queue", "signs")).each do |s|
      ch = s["chapter"] or next
      next if map[s["glyph"]] # veteran — sux teaching entry stands

      url = akk_urls[ch] or next
      map[s["glyph"]] = { url: url, anchor: "sign-#{s['codepoint']}",
                          tip: Edubba::SignLinker.tip_text(s) }
    end
    # Codex pages (rulebook §7/§9): sign-table cells link the glyph
    # to its Addenda sign page — wired per school as each shelf
    # ships, keyed on the page actually existing in the build. The
    # akk codex is a separate shelf (§9 language separation); every
    # sign the Akkadian course uses gets :codex_akk, routed to on
    # Akkadian-course pages only.
    page_urls = site.pages.each_with_object({}) { |p, h| h[p.url] = true }
    { "cuneiform" => [site.data["sign_teaching"], site.data["cuneiform102_queue"]],
      "hieroglyphs" => [site.data["hiero_teaching"], site.data["hieroglyphs102_queue"]] }.each do |school, regs|
      regs.each do |reg|
        Array(reg&.dig("signs")).each do |s|
          entry = map[s["glyph"]] or next
          slug = Edubba::Rulebook.sign_slug(s["gardiner"] || s["name"])
          url = "/#{school}/addenda/signs/#{slug}/"
          entry[:codex] = url if page_urls[url]
        end
      end
    end
    Array(site.data.dig("cuneiform103_queue", "signs")).each do |s|
      entry = map[s["glyph"]] or next
      slug = Edubba::Rulebook.sign_slug(s["name"])
      url = "/cuneiform/addenda-akk/signs/#{slug}/"
      entry[:codex_akk] = url if page_urls[url]
    end
    map
  end

  akk_page = %w[cuneiform-103 cuneiform-addenda-akk].include?(page.data["course"])
  page.output = Edubba::SignLinker.transform(
    page.output, @sign_map, page.url, site.baseurl.to_s,
    akk_page ? :codex_akk : :codex
  )
end
