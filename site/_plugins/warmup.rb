# frozen_string_literal: true

# Jekyll wiring for the spiral warm-up (script/warmup.rb): the
# chapter layout calls {% warmup_panel %}, and subject chapters get
# their retrieval panel rendered straight from the registries —
# references and course openers naturally render nothing. Logic
# lives outside _plugins so the test suite exercises it without
# Jekyll.

require_relative "../../script/warmup"

class WarmupPanelTag < Liquid::Tag
  SCHOOLS = {
    "cuneiform" => %w[sign_teaching cuneiform102_queue],
    "hieroglyphs" => %w[hiero_teaching hieroglyphs102_queue]
  }.freeze

  def render(context)
    site = context.registers[:site]
    page = context.registers[:page]
    course = page["course"].to_s
    school = course[/\A(cuneiform|hieroglyphs)-10[12]\z/, 1]
    return "" unless school && page["chapter"].is_a?(Integer)

    @cache ||= {}
    seats = (@cache[school] ||= begin
      r101, r102 = SCHOOLS[school].map { |d| site.data.dig(d, "signs") }
      Edubba::Warmup.sequence(r101, r102, school)
    end)
    urls = (@cache[:urls] ||= site.pages.each_with_object({}) do |p, h|
      next unless p.data["course"] && p.data["chapter"]

      h[[p.data["course"], p.data["chapter"]]] = p.url
    end)

    Edubba::Warmup.panel_html(course, page["chapter"], seats, school,
                              urls, site.baseurl.to_s) || ""
  end
end

Liquid::Template.register_tag("warmup_panel", WarmupPanelTag)
