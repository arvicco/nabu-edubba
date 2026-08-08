# frozen_string_literal: true

# Jekyll wiring for the term linker (script/term_linker.rb): after
# each page renders, glossary terms in prose gain a hover-bubble
# definition and a link to /terms/. Logic lives outside _plugins so
# the test suite can exercise it without Jekyll.

require_relative "../../script/term_linker"

Jekyll::Hooks.register [:pages, :documents], :post_render do |page|
  next unless page.output_ext == ".html"

  site = page.site
  terms_pages = site.pages.select { |p| p.data["terms_page"] }
  next if terms_pages.empty?
  next if terms_pages.include?(page) # a glossary defines; it does not bubble

  # Each glossary page may scope itself with `terms_school`; the page
  # without one is the general glossary and the fallback target.
  urls = terms_pages.each_with_object({}) { |p, h| h[p.data["terms_school"]] = p.url }
  terms = Array(site.data.dig("terms", "terms"))
  page.output = Edubba::TermLinker.transform(
    page.output, terms, urls, site.baseurl.to_s, page_url: page.url
  )
end
