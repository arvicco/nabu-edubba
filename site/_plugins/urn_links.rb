# frozen_string_literal: true

# Jekyll wiring for the URN linker (script/urn_linker.rb): cited
# Nabu URNs link to the axis desk that explains their source.

require_relative "../../script/urn_linker"

Jekyll::Hooks.register [:pages, :documents], :post_render do |page|
  next unless page.output_ext == ".html"

  page.output = Edubba::UrnLinker.transform(page.output)
end
