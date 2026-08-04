# frozen_string_literal: true

# Jekyll wiring for the drill shelves (script/drills.rb): the two
# Addenda drill pages call {% drill_shelf cards %} and
# {% drill_shelf contrasts %}; everything renders from the
# registries. Logic lives outside _plugins for the test suite.

require_relative "../../script/drills"

class DrillShelfTag < Liquid::Tag
  SCHOOLS = {
    "cuneiform" => %w[sign_teaching cuneiform102_queue],
    "hieroglyphs" => %w[hiero_teaching hieroglyphs102_queue]
  }.freeze

  def initialize(tag_name, markup, tokens)
    super
    @part = markup.strip.to_sym
  end

  def render(context)
    site = context.registers[:site]
    school = context.registers[:page]["school"].to_s
    regs = SCHOOLS[school] or return ""
    r101, r102 = regs.map { |d| site.data.dig(d, "signs") }
    seats = Edubba::Warmup.sequence(r101, r102, school)
    parts = Edubba::Drills.shelf_html(seats, school,
                                      "/#{school}/addenda/signs/",
                                      site.baseurl.to_s)
    parts[@part] || ""
  end
end

Liquid::Template.register_tag("drill_shelf", DrillShelfTag)
