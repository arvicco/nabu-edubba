# frozen_string_literal: true

# Jekyll wiring for the drill shelves (script/drills.rb): the two
# Addenda drill pages call {% drill_shelf cards %},
# {% drill_shelf contrasts %} and {% drill_shelf deal %};
# everything renders from the registries. A generator emits the
# twelve cut pages per school (rulebook §8, the deal) — same
# cards, seeded orderings; the drills page inlines the featured
# cut (EDUBBA_DEAL_DATE at deploy, cut 1 in gate/local builds).
# Logic lives outside _plugins for the test suite.

require_relative "../../script/drills"

# Deliberately WITHOUT cuneiform103_queue: the drill deck is a
# Sumerian-Addenda instrument (§9 language separation) — Akkadian
# gets its own retrieval shelves when its inventory warrants them.
DRILL_SCHOOLS = {
  "cuneiform" => %w[sign_teaching cuneiform102_queue],
  "hieroglyphs" => %w[hiero_teaching hieroglyphs102_queue]
}.freeze
DRILL_BACKS = { "cuneiform" => "𒁾", "hieroglyphs" => "𓏛" }.freeze

class DrillShelfTag < Liquid::Tag
  def initialize(tag_name, markup, tokens)
    super
    @part = markup.strip.to_sym
  end

  def render(context)
    site = context.registers[:site]
    page = context.registers[:page]
    school = page["school"].to_s
    regs = DRILL_SCHOOLS[school] or return ""
    cut = page["drill_cut"] || Edubba::Drills.featured_cut
    drills_url = "#{site.baseurl}/#{school}/addenda/drills/"
    return Edubba::Drills.deal_html(drills_url, Edubba::Drills.featured_cut,
                                    DRILL_BACKS[school]) if @part == :deal

    r101, r102 = regs.map { |d| site.data.dig(d, "signs") }
    seats = Edubba::Warmup.sequence(r101, r102, school)
    parts = Edubba::Drills.shelf_html(seats, school,
                                      "/#{school}/addenda/signs/",
                                      site.baseurl.to_s, cut - 1)
    parts[@part] || ""
  end
end

Liquid::Template.register_tag("drill_shelf", DrillShelfTag)

# The cut pages: /{school}/addenda/drills/cut-N/ — no `chapter`
# key, so they stay out of chapter nav and sidebars; no warm-up
# panel (course is *-addenda).
class DrillCutPage < Jekyll::PageWithoutAFile
  def initialize(site, school, cut)
    super(site, site.source, "#{school}/addenda/drills", "cut-#{cut}.md")
    titled = school.capitalize
    next_cut = cut % Edubba::Drills::CUTS + 1
    self.data = {
      "layout" => "chapter",
      "title" => "The deck — cut #{cut}",
      "description" => "The #{school} drill deck in ordering #{cut} of #{Edubba::Drills::CUTS} — same cards, fresh interleave.",
      "school" => school,
      "course" => "#{school}-addenda",
      "course_url" => "/#{school}/addenda/",
      "course_title" => school == "cuneiform" ? "Sumerian Addenda" : "#{titled} Addenda",
      "kicker_no_chapter" => true,
      "drill_cut" => cut,
      "permalink" => "/#{school}/addenda/drills/cut-#{cut}/",
      "teaches" => [], "shows" => []
    }
    self.content = <<~MD
      # The deck — cut #{cut}

      The same cards as [the drills shelf]({{ '/#{school}/addenda/drills/' | relative_url }}),
      dealt in another order. Answer out loud or on paper, then
      unfold and check. Next session, take another cut.

      {% drill_shelf cards %}

      <p class="deal-next"><a href="{{ '/#{school}/addenda/drills/cut-#{next_cut}/' | relative_url }}">Shuffle again — cut #{next_cut} &rarr;</a></p>
    MD
  end
end

class DrillCutGenerator < Jekyll::Generator
  safe true

  def generate(site)
    DRILL_SCHOOLS.each_key do |school|
      (1..Edubba::Drills::CUTS).each do |cut|
        site.pages << DrillCutPage.new(site, school, cut)
      end
    end
  end
end
