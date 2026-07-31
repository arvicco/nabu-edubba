# frozen_string_literal: true

require "minitest/autorun"
require "set"
require_relative "../bin/hiero_reading_picker"

class HieroReadingPickerTest < Minitest::Test
  P = Edubba::HieroReadingPicker

  def tok(form, inventar)
    { "form" => form, "hiero_inventar" => inventar }
  end

  def test_codes_split_all_separators_and_variants
    assert_equal %w[N5 T21], P.codes("N5;T21")
    assert_equal %w[M17 G17 N35], P.codes("M17*G17:N35")
    assert_equal %w[V31A Z3A], P.codes("V31A;Z3A")
    assert_equal [], P.codes(nil)
  end

  def test_mixed_case_categories_upcase_instead_of_vanishing
    assert_equal %w[AA1 D21], P.codes("Aa1;D21")
    assert_equal %w[FF101 Z1], P.codes("Ff101;Z1")
  end

  def test_line_codes_requires_annotation_and_wholeness
    assert_equal %w[N5 X1], P.line_codes([tok("Rꜥw", "N5"), tok("t", "X1")], "Rꜥw t")
    assert_nil P.line_codes([tok("Rꜥw", "N5"), tok("t", nil)], "Rꜥw t"),
               "token without hiero_inventar disqualifies"
    assert_nil P.line_codes([tok("[Rꜥw]", "N5")], "[Rꜥw]")
    assert_nil P.line_codes([tok("Rꜥw", "N5")], "⸢Rꜥw⸣")
    assert_nil P.line_codes([], "x")
    assert_nil P.line_codes([tok("a", "A1")] * 13, "long line")
  end

  def test_readable_chapter_earliest_cover
    cumulative = [[7, Set.new(%w[N5 X1])], [9, Set.new(%w[N5 X1 A1])]]
    assert_equal 7, P.readable_chapter(%w[N5 X1], cumulative)
    assert_equal 9, P.readable_chapter(%w[X1 A1], cumulative)
    assert_nil P.readable_chapter(%w[Q7], cumulative)
  end
end
