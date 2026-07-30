# frozen_string_literal: true

# Jekyll wiring for the subscript-index renderer
# (script/subscript_render.rb): after each page renders, Unicode
# subscript digits become real <sub> markup so they typeset as true
# subscripts in any font. Logic lives outside _plugins so the test
# suite can exercise it without Jekyll.

require_relative "../../script/subscript_render"

Jekyll::Hooks.register [:pages, :documents], :post_render do |page|
  next unless page.output_ext == ".html"

  page.output = Edubba::SubscriptRender.transform(page.output)
end
