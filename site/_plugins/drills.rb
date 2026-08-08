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

# One shelf per Addenda, keyed by the page's course (§9 language
# separation: the Akkadian shelf, deferred at Gate 12, is its own
# entry on its own frequency-base registry — the languages never
# share a deck).
DRILL_SHELVES = {
  "cuneiform-addenda" => {
    school: "cuneiform", base: "cuneiform/addenda",
    regs: ["sign_teaching", "cuneiform102_queue", nil],
    title: "Sumerian Addenda", back: "𒁾"
  },
  "hieroglyphs-addenda" => {
    school: "hieroglyphs", base: "hieroglyphs/addenda",
    regs: ["hiero_teaching", "hieroglyphs102_queue", nil],
    title: "Hieroglyphs Addenda", back: "𓏛"
  },
  "cuneiform-addenda-akk" => {
    school: "cuneiform", base: "cuneiform/addenda-akk",
    regs: [nil, nil, "cuneiform103_queue"],
    title: "Akkadian Addenda", back: "𒁾"
  }
}.freeze

class DrillShelfTag < Liquid::Tag
  def initialize(tag_name, markup, tokens)
    super
    @part = markup.strip.to_sym
  end

  def render(context)
    site = context.registers[:site]
    page = context.registers[:page]
    shelf = DRILL_SHELVES[page["course"].to_s] or return ""
    cut = page["drill_cut"] || Edubba::Drills.featured_cut
    drills_url = "#{site.baseurl}/#{shelf[:base]}/drills/"
    return Edubba::Drills.deal_html(drills_url, Edubba::Drills.featured_cut,
                                    shelf[:back]) if @part == :deal

    r101, r102, r103 = shelf[:regs].map { |d| d && site.data.dig(d, "signs") }
    seats = Edubba::Warmup.sequence(r101, r102, shelf[:school], r103)
    parts = Edubba::Drills.shelf_html(seats, shelf[:school],
                                      "/#{shelf[:base]}/signs/",
                                      site.baseurl.to_s, cut - 1)
    parts[@part] || ""
  end
end

Liquid::Template.register_tag("drill_shelf", DrillShelfTag)

# The cut pages: /{school}/addenda/drills/cut-N/ — no `chapter`
# key, so they stay out of chapter nav and sidebars; no warm-up
# panel (course is *-addenda).
class DrillCutPage < Jekyll::PageWithoutAFile
  def initialize(site, course, shelf, cut)
    super(site, site.source, "#{shelf[:base]}/drills", "cut-#{cut}.md")
    next_cut = cut % Edubba::Drills::CUTS + 1
    self.data = {
      "layout" => "chapter",
      "title" => "The deck — cut #{cut}",
      "description" => "The #{shelf[:title]} drill deck in ordering #{cut} of #{Edubba::Drills::CUTS} — same cards, fresh interleave.",
      "school" => shelf[:school],
      "course" => course,
      "course_url" => "/#{shelf[:base]}/",
      "course_title" => shelf[:title],
      "kicker_no_chapter" => true,
      "drill_cut" => cut,
      "permalink" => "/#{shelf[:base]}/drills/cut-#{cut}/",
      "teaches" => [], "shows" => []
    }
    self.content = <<~MD
      # The deck — cut #{cut}

      The same cards as [the drills shelf]({{ '/#{shelf[:base]}/drills/' | relative_url }}),
      dealt in another order. Answer out loud or on paper, then
      unfold and check. Next session, take another cut.

      {% drill_shelf cards %}

      <p class="deal-next"><a href="{{ '/#{shelf[:base]}/drills/cut-#{next_cut}/' | relative_url }}">Shuffle again — cut #{next_cut} &rarr;</a></p>
    MD
  end
end

class DrillCutGenerator < Jekyll::Generator
  safe true

  def generate(site)
    DRILL_SHELVES.each do |course, shelf|
      (1..Edubba::Drills::CUTS).each do |cut|
        site.pages << DrillCutPage.new(site, course, shelf, cut)
      end
    end
  end
end
