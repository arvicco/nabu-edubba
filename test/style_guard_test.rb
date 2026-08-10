# frozen_string_literal: true

require "minitest/autorun"

# Tooltip-escape guard (owner report 2026-08-09: a hover bubble cut
# in half). A scroll container clips BOTH axes — overflow-x forces
# the perpendicular axis from visible to auto, per the CSS spec —
# so any box with an overflow rule swallows the absolutely
# positioned .sign-tip bubbles of the sign-links inside it. The
# stylesheet law this test enforces:
#   (a) every scroll container that can host sign-links reserves
#       bubble headroom — padding-top pulled back by an equal
#       negative margin-top, growing the clip box without moving
#       the layout;
#   (b) it pins its bubbles to the glyph's left edge (left: 0, no
#       centering transform) so they cannot cross the left rim;
#   (c) hidden bubbles take NO geometry (display: none) — a
#       visibility-hidden bubble still contributes its box to the
#       container's scrollable width (phantom sideways scroll).
# A new overflow rule fails the allowlist until its author handles
# bubble escape and registers it here, consciously.
class StyleGuardTest < Minitest::Test
  SHEET = File.read(File.expand_path("../site/assets/style.css", __dir__),
                    encoding: "UTF-8")

  # scroll container => the selector that pins its bubbles
  SCROLL_CONTAINERS = {
    ".sign-table" => ".sign-table .sign-tip",
    ".reading--script .reading-lines" => ".reading--script .sign-tip"
  }.freeze

  def rules
    css = SHEET.gsub(%r{/\*.*?\*/}m, "")                      # comments
    css = css.gsub(/@(?:media|starting-style)[^{]*\{/, "")   # at-rule headers
    css.scan(/([^{}]+)\{([^{}]*)\}/m).map { |sel, body| [sel.strip, body] }
  end

  def bodies_for(selector)
    rules.select { |sel, _| sel.split(",").map(&:strip).include?(selector) }
         .map(&:last).join(";")
  end

  def test_every_overflow_rule_is_a_registered_tip_safe_container
    offenders = rules.select do |_sel, body|
      body.match?(/overflow[^:;]*:\s*(auto|scroll|hidden|clip)\b/)
    end.map(&:first)
    offenders.each do |sel|
      assert_includes SCROLL_CONTAINERS.keys, sel,
                      "#{sel.inspect} becomes a clip box (overflow clips both axes) — " \
                      "hover bubbles inside it will be cut in half. Reserve bubble " \
                      "headroom (padding-top pulled back by an equal negative " \
                      "margin-top), pin its .sign-tip to left: 0, and register the " \
                      "pairing in StyleGuardTest::SCROLL_CONTAINERS"
    end
  end

  def test_scroll_containers_reserve_bubble_headroom
    SCROLL_CONTAINERS.each_key do |sel|
      body = bodies_for(sel)
      pad = body[/padding-top:\s*([\d.]+rem)/, 1]
      refute_nil pad, "#{sel} must reserve bubble headroom (padding-top)"
      assert_match(/margin-top:\s*(?:-#{Regexp.escape(pad)}|calc\([^)]*-\s*#{Regexp.escape(pad)}\))/,
                   body,
                   "#{sel}: headroom padding-top #{pad} must be pulled back by an " \
                   "equal negative margin-top so the clip box grows, not the layout")
    end
  end

  def test_scroll_containers_pin_bubbles_to_the_glyph
    SCROLL_CONTAINERS.each_value do |pin|
      body = bodies_for(pin)
      assert_match(/left:\s*0/, body,
                   "#{pin} must pin bubbles to the glyph's left edge (left: 0) — " \
                   "a centered bubble crosses the container's left rim and is cut")
      assert_match(/transform:\s*none/, body,
                   "#{pin} must drop the centering transform")
    end
  end

  def test_hidden_bubbles_take_no_geometry
    body = bodies_for(".sign-tip")
    assert_match(/display:\s*none/, body,
                 "hidden .sign-tip must be display: none — a visibility-hidden " \
                 "bubble still inflates a scroll container's scrollable width")
    refute_match(/visibility:\s*hidden/, body)
  end

  # Size law (sinographs rulebook §6, owner ruling 2026-08-10):
  # sinograph characters display bigger than cuneiform/Egyptian
  # script everywhere. The stylesheet's default inline rule must
  # scale Han runs up relative to their context; explicit sinograph
  # script contexts (readings, drills, exhibits) register here with
  # their cuneiform counterpart as they arrive, and must exceed it.
  SINO_CONTEXTS = {
    # sinograph selector => [its font-size floor in em/rem, note]
  }.freeze

  def test_sinograph_inline_script_scales_up
    body = bodies_for("body.school-sinographs :where(.script)")
    scale = body[/font-size:\s*([\d.]+)em/, 1]
    refute_nil scale,
               "the size law needs a low-specificity default rule scaling " \
               "inline Han runs (body.school-sinographs :where(.script), em units)"
    assert_operator scale.to_f, :>, 1.0,
                    "sinograph inline script must display BIGGER than its context " \
                    "(size law, rulebook §6) — got #{scale}em"
  end

  def test_registered_sinograph_contexts_exceed_their_floors
    SINO_CONTEXTS.each do |sel, (floor, note)|
      size = bodies_for(sel)[/font-size:\s*([\d.]+)(?:em|rem)/, 1]
      refute_nil size, "#{sel} registered in SINO_CONTEXTS but sets no font-size"
      assert_operator size.to_f, :>, floor,
                      "#{sel} must exceed #{floor} (#{note}) — size law, rulebook §6"
    end
  end
end
