# frozen_string_literal: true

# Jekyll wiring for the sign-linking transformer (script/sign_linker.rb):
# after each page renders, every known cuneiform glyph becomes a link to
# where it was introduced. Logic lives outside _plugins so the test
# suite can exercise it without Jekyll.

require_relative "../../script/sign_linker"

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
                          tip: Edubba::SignLinker.tip_text(s) }
    end
    map
  end

  page.output = Edubba::SignLinker.transform(
    page.output, @sign_map, page.url, site.baseurl.to_s
  )
end
