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

  def test_cuts_permute_but_preserve_the_deck
    ids = ->(cards) { cards.map { |c| [c[:sign]["name"], c[:direction]] } }
    base = ids[Edubba::Drills.cards(SEATS)]
    assert_equal base, ids[Edubba::Drills.cards(SEATS, 0)]
    orders = (0...Edubba::Drills::CUTS).map { |s| ids[Edubba::Drills.cards(SEATS, s)] }
    orders.each { |o| assert_equal base.sort, o.sort }
    assert_equal 7, orders.uniq.size
    assert_equal [["UD", :read], ["UD", :mean], ["A", :read]], orders[3].first(3)
  end

  def test_featured_cut_is_a_fixed_public_function
    assert_equal 1, Edubba::Drills.featured_cut(nil)
    assert_equal 1, Edubba::Drills.featured_cut(" ")
    assert_equal 10, Edubba::Drills.featured_cut("2026-08-05")
    assert_equal 11, Edubba::Drills.featured_cut("2026-08-06")
  end

  def test_deal_html_marks_today_and_links_every_cut
    html = Edubba::Drills.deal_html("/b/cuneiform/addenda/drills/", 10, "𒁾")
    assert_equal Edubba::Drills::CUTS, html.scan(/<a class="deal-tile/).size
    assert_includes html, %(href="/b/cuneiform/addenda/drills/cut-12/")
    assert_includes html, %(deal-tile--today" href="/b/cuneiform/addenda/drills/cut-10/")
  end
end
