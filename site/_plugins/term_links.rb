# frozen_string_literal: true

# Jekyll wiring for the term linker (script/term_linker.rb): after
# each page renders, glossary terms in prose gain a hover-bubble
# definition and a link to /terms/. Logic lives outside _plugins so
# the test suite can exercise it without Jekyll.

require_relative "../../script/term_linker"

Jekyll::Hooks.register [:pages, :documents], :post_render do |page|
  next unless page.output_ext == ".html"

  site = page.site
  terms_page = site.pages.find { |p| p.data["terms_page"] }
  next unless terms_page
  next if page == terms_page # the glossary defines; it does not bubble

  terms = Array(site.data.dig("terms", "terms"))
  page.output = Edubba::TermLinker.transform(
    page.output, terms, terms_page.url, site.baseurl.to_s
  )
end
