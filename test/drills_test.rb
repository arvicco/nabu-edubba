# frozen_string_literal: true

require "minitest/autorun"
require_relative "../script/drills"

class DrillsTest < Minitest::Test
  R101 = [
    { "name" => "A", "codepoint" => "12000", "glyph" => "𒀀", "keyword" => "water", "value" => "a", "meaning" => "water", "taught_in" => 0, "confusable_with" => ["AN"] },
    { "name" => "AN", "codepoint" => "1202D", "glyph" => "𒀭", "keyword" => "heaven", "value" => "an", "meaning" => "heaven", "taught_in" => 0, "confusable_with" => ["A"] },
    { "name" => "UD", "codepoint" => "12313", "glyph" => "𒌓", "keyword" => "day", "value" => "ud", "meaning" => "day", "taught_in" => 1 }
  ].freeze
  SILENT = [
    { "name" => "G7", "gardiner" => "G7", "codepoint" => "13146", "glyph" => "𓅆", "keyword" => "watcher", "value" => "—", "meaning" => "divine classifier", "chapter" => 2 }
  ].freeze

  SEATS = Edubba::Warmup.sequence(R101, [], "cuneiform")

  def test_cards_three_directions_and_deterministic
    cards = Edubba::Drills.cards(SEATS)
    assert_equal 9, cards.size
    assert_equal cards, Edubba::Drills.cards(SEATS)
    a_dirs = cards.select { |c| c[:sign]["name"] == "A" }.map { |c| c[:direction] }.sort
    assert_equal %i[mean read write], a_dirs
  end

  def test_silent_signs_skip_the_read_direction
    seats = Edubba::Warmup.sequence([], SILENT, "hieroglyphs")
    dirs = Edubba::Drills.cards(seats).map { |c| c[:direction] }.sort
    assert_equal %i[mean write], dirs
    html = Edubba::Drills.card_html(Edubba::Drills.cards(seats).find { |c| c[:direction] == :write }, "hieroglyphs")
    assert_includes html, "draw the sign"
  end

  def test_clusters_dedupe_pairs
    assert_equal 1, Edubba::Drills.clusters(SEATS).size
    assert_equal %w[A AN], Edubba::Drills.clusters(SEATS).first.map { |s| s["name"] }.sort
  end

  def test_shelf_html_links_contrasts_to_codex
    parts = Edubba::Drills.shelf_html(SEATS, "cuneiform", "/cuneiform/addenda/signs/", "/b")
    assert_includes parts[:contrasts], %(href="/b/cuneiform/addenda/signs/an/")
    assert_includes parts[:cards], %(class="drill-card")
  end
end
