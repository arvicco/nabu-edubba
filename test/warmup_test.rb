# frozen_string_literal: true

require "minitest/autorun"
require_relative "../script/warmup"

class WarmupTest < Minitest::Test
  R101 = [
    { "name" => "A", "glyph" => "𒀀", "keyword" => "water", "value" => "a", "meaning" => "water", "taught_in" => 0 },
    { "name" => "AN", "glyph" => "𒀭", "keyword" => "heaven", "value" => "an", "meaning" => "heaven", "taught_in" => 0 },
    { "name" => "UD", "glyph" => "𒌓", "keyword" => "day", "value" => "ud", "meaning" => "day", "taught_in" => 1 },
    { "name" => "KI", "glyph" => "𒆠", "keyword" => "place", "value" => "ki", "meaning" => "earth", "taught_in" => 2 }
  ].freeze
  R102 = [
    { "name" => "ME", "glyph" => "𒈨", "keyword" => "rites", "value" => "me", "meaning" => "rites", "chapter" => 0 },
    { "name" => "SZU", "glyph" => "𒋗", "keyword" => "hand", "value" => "szu", "meaning" => "hand", "chapter" => 1 },
    { "name" => "MI", "glyph" => "𒈪", "keyword" => "night", "value" => "mi", "meaning" => "night", "chapter" => nil }
  ].freeze

  SEATS = Edubba::Warmup.sequence(R101, R102, "cuneiform")

  def test_sequence_orders_101_then_102_and_skips_unpinned
    assert_equal [["cuneiform-101", 0], ["cuneiform-101", 1], ["cuneiform-101", 2],
                  ["cuneiform-102", 0], ["cuneiform-102", 1]],
                 SEATS.map { |s| [s[:course], s[:chapter]] }
    refute SEATS.flat_map { |s| s[:signs] }.any? { |s| s["name"] == "MI" }
  end

  R103 = [
    { "name" => "UM", "glyph" => "𒌝", "keyword" => "cord", "value" => "um", "meaning" => "(syllable)", "chapter" => 1 }
  ].freeze

  def test_sequence_grows_a_third_course_and_103_looks_back
    seats = Edubba::Warmup.sequence(R101, R102, "cuneiform", R103)
    assert_equal ["cuneiform-103", 1], [seats.last[:course], seats.last[:chapter]]
    picks = Edubba::Warmup.prompts("cuneiform-103", 1, seats)
    courses = picks.map { |p| p[:seat][:course] }.uniq
    assert_includes courses, "cuneiform-102"   # the spiral crosses into 102/101
  end

  def test_first_chapter_and_references_get_no_panel
    assert_nil Edubba::Warmup.prompts("cuneiform-101", 0, SEATS)
    assert_nil Edubba::Warmup.prompts("cuneiform-101", 12, SEATS)   # no seat
  end

  def test_cross_course_lookback_from_102
    picks = Edubba::Warmup.prompts("cuneiform-102", 0, SEATS)
    courses = picks.map { |p| p[:seat][:course] }.uniq
    assert_equal ["cuneiform-101"], courses
    assert picks.size.between?(2, 6)
  end

  def test_prompts_are_deterministic_and_unique
    a = Edubba::Warmup.prompts("cuneiform-102", 1, SEATS)
    b = Edubba::Warmup.prompts("cuneiform-102", 1, SEATS)
    assert_equal a, b
    assert_equal a.map { |p| p[:sign] }.uniq.size, a.size
  end

  def test_silent_signs_always_draw
    silent = { "name" => "Z6", "glyph" => "𓏱", "keyword" => "death's stand-in",
               "value" => "—", "meaning" => "substitute" }
    assert_equal :draw, Edubba::Warmup.direction_for(silent, 1)
    assert_equal "—", Edubba::Warmup.reads(silent, "hieroglyphs")
  end

  def test_cuneiform_reads_are_display_form
    assert_equal "šu", Edubba::Warmup.reads(R102[1], "cuneiform")
  end

  def test_panel_html_folds_answers_and_links_the_seat
    urls = { ["cuneiform-101", 0] => "/cuneiform/101/00-x/",
             ["cuneiform-101", 1] => "/cuneiform/101/01-x/",
             ["cuneiform-101", 2] => "/cuneiform/101/02-x/" }
    html = Edubba::Warmup.panel_html("cuneiform-102", 0, SEATS, "cuneiform", urls, "/b")
    assert_includes html, %(<details class="warmup">)
    assert_includes html, "Warm-up ·"
    assert_includes html, %(<li><details><summary>)
    assert_includes html, %(href="/b/cuneiform/101/)
    assert_nil Edubba::Warmup.panel_html("cuneiform-101", 0, SEATS, "cuneiform", urls)
  end
end
