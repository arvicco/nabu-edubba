# frozen_string_literal: true

require "minitest/autorun"
require "set"
require_relative "../bin/sino_reading_picker"

# M19-4: the pure functions (clause split, coverage, ranking) on
# string fixtures; the nabu-streaming shell stays thin and untested,
# matching the other pickers' convention.
class SinoReadingPickerTest < Minitest::Test
  P = Edubba::SinoReadingPicker

  def test_clause_split_on_stops_and_brackets
    assert_equal %w[學而時習之 不亦說乎], P.clauses("學而時習之，不亦說乎？")
    assert_equal %w[乾 元亨 利貞], P.clauses("《乾》元亨，\n利貞。")
    assert_equal %w[道可道 非常道], P.clauses("道可道；非常道、")
  end

  def test_commentary_parentheticals_are_stripped_before_the_split
    assert_equal %w[知之為知之], P.clauses("知之(臣/)為知之。")
    assert_equal %w[不知為不知], P.clauses("不知（釋文/ 後）為不知。")
  end

  def test_qualify_bounds_length_purity_and_boxes
    inv = Set.new(%w[人 大 天 之 不 知])
    assert_equal [], P.qualify("人不知天", inv), "fully covered — zero wild characters"
    assert_equal %w[魚], P.qualify("人不知魚", inv), "one wild character listed"
    assert_nil P.qualify("魚龍鳳麟", inv), "three wild characters is past the 2-box grain"
    assert_nil P.qualify("人不知", inv), "under reading length (4)"
    assert_nil P.qualify("人" * 17, inv), "over reading length (16)"
    assert_nil P.qualify("人不&KR1;知", inv), "entity refs / Latin disqualify"
    assert_equal %w[魚], P.qualify("人魚魚魚", inv),
                 "wild characters count DISTINCT, not per occurrence"
  end

  def test_earliest_chapter_walks_the_cumulative_inventory
    cumulative = [
      [0, Set.new(%w[人 大])],
      [1, Set.new(%w[人 大 天])],
      [2, Set.new(%w[人 大 天 之])]
    ]
    assert_equal 1, P.earliest_chapter("人天大天", cumulative, 0)
    assert_equal 0, P.earliest_chapter("人天大天", cumulative, 1),
                 "with one box allowed, 天 may stay wild a chapter earlier"
    assert_equal 2, P.earliest_chapter("人之天大", cumulative, 0)
    assert_nil P.earliest_chapter("人魚大大", cumulative, 0),
               "never covered inside the queue — no chapter"
  end

  def test_rank_orders_by_fame_then_brevity
    rows = [
      { clause: "四海之內皆兄弟", docs: 3 },
      { clause: "學而時習之", docs: 9 },
      { clause: "有朋自遠方來", docs: 9 },
      { clause: "溫故而知新", docs: 9 }
    ]
    ranked = P.rank(rows).map { |r| r[:clause] }
    assert_equal "四海之內皆兄弟", ranked.last, "fame first — 3 docs sorts below 9"
    assert_equal %w[學而時習之 溫故而知新], ranked.first(2),
                 "inside a fame tier, shorter first, ties broken stably by text"
  end
end
