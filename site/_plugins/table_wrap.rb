# frozen_string_literal: true

# Jekyll wiring for the sign-table scroll wrapper
# (script/table_wrap.rb): after each page renders, every sign table
# gains its div.table-scroll scroll container. Logic lives outside
# _plugins so the test suite can exercise it without Jekyll.

require_relative "../../script/table_wrap"

Jekyll::Hooks.register [:pages, :documents], :post_render do |page|
  next unless page.output_ext == ".html"

  page.output = Edubba::TableWrap.wrap(page.output)
end
