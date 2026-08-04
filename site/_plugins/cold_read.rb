# frozen_string_literal: true

# Jekyll wiring for read-it-cold (script/cold_read.rb): subject
# chapters of the numbered courses get their last reading repeated
# bare before the bottom nav. Logic lives outside _plugins for the
# test suite.

require_relative "../../script/cold_read"

Jekyll::Hooks.register [:pages], :post_render do |page|
  next unless page.output_ext == ".html"
  next unless page.data["course"].to_s.match?(/\A(cuneiform|hieroglyphs)-10[12]\z/)
  next unless page.data["chapter"].is_a?(Integer)

  page.output = Edubba::ColdRead.transform(page.output)
end
