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

  def test_scroll_containers_reserve_right_rim_room
    # The right rim clips like the top (owner report 2026-08-11: a
    # hieroglyph reading's bubble cut at the figure's right edge —
    # school-wide law, every registered container). The reserve must
    # cover a bubble at max-width (16em at the 0.78rem bubble font
    # ≈ 12.5rem) plus its padding: 14rem, pulled back by an equal
    # negative margin-right.
    SCROLL_CONTAINERS.each_key do |sel|
      body = bodies_for(sel)
      pad = body[/padding-right:\s*([\d.]+rem)/, 1]
      refute_nil pad, "#{sel} must reserve right-rim room (padding-right)"
      assert_operator pad.to_f, :>=, 13.6,
                      "#{sel}: right reserve #{pad} is smaller than a max-width bubble"
      assert_match(/margin-right:\s*(?:-#{Regexp.escape(pad)}|calc\([^)]*-\s*#{Regexp.escape(pad)}\))/,
                   body,
                   "#{sel}: right reserve #{pad} must be pulled back by an equal " \
                   "negative margin-right so the clip box grows, not the layout")
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

  def test_last_column_bubbles_pin_to_the_right_rim
    # The mirror of the left-edge pin (owner report 2026-08-11): a
    # glyph in a table's LAST column extends its bubble across the
    # scroll container's right rim and is cut. Those bubbles pin to
    # the glyph's right edge and grow leftward into the row.
    body = bodies_for(".sign-table td:last-child .sign-tip")
    assert_match(/right:\s*0/, body,
                 "last-column bubbles must pin to the glyph's right edge")
    assert_match(/left:\s*auto/, body,
                 "last-column bubbles must release the left pin")
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
    ".school-sinographs .sign-cell" => [2.0, "cuneiform .sign-cell is 2rem"],
    ".school-sinographs .reading--script .script" =>
      [1.4, "cuneiform reading script is 1.4rem"],
    ".school-sinographs .sign-hero" => [6.5, "site .sign-hero is 6.5rem"],
    ".school-sinographs .sign-strip" => [2.6, "site .sign-strip is 2.6rem"]
  }.freeze

  SINO_INLINE = "body.school-sinographs :where(p, li, td, th, dd, dt, figcaption) > :where(.script)"

  # bodies_for splits selector lists on commas; a selector that
  # itself contains commas (:where(p, li, …)) needs whole-string
  # matching instead.
  def body_for_exact(selector)
    want = selector.gsub(/\s+/, " ")
    rules.select { |sel, _| sel.gsub(/\s+/, " ") == want }
         .map(&:last).join(";")
  end

  def test_sinograph_inline_script_scales_up
    body = body_for_exact(SINO_INLINE)
    scale = body[/font-size:\s*([\d.]+)em/, 1]
    refute_nil scale,
               "the size law needs a prose-scoped default rule scaling " \
               "inline Han runs (#{SINO_INLINE}, em units)"
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

  def test_sinograph_readings_always_stack
    body = bodies_for(".school-sinographs .reading--script .reading-lines")
    assert_match(/display:\s*block/, body,
                 "sinograph reading figures must stack unconditionally (rulebook §6 — " \
                 "size-law characters leave three columns no honest gloss room)")
  end
end
