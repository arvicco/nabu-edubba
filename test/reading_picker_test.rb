# frozen_string_literal: true

require "minitest/autorun"
require "set"
require_relative "../bin/reading_picker"

class ReadingPickerTest < Minitest::Test
  P = Edubba::ReadingPicker

  def test_atf_values_handles_plain_parenthetical_and_multi
    assert_equal ["lugal"], P.atf_values("lugal")
    assert_equal ["e2"], P.atf_values("é (e2)")
    assert_equal %w[an dingir], P.atf_values("an; diŋir (dijir/dingir)")
    assert_equal %w[ni i3], P.atf_values("ni; i₃ (i3)")
  end

  def test_fold_etcsl_only_touches_differing_conventions
    assert_equal "ce3", P.fold_etcsl("sze3")
    assert_equal "saj", P.fold_etcsl("sag")
    assert_equal "lugal", P.fold_etcsl("lugal")
  end

  def test_clean_tokens_rejects_damage_numbers_and_length
    assert_equal %w[lugal kur ra], P.clean_tokens("lugal kur ra")
    assert_nil P.clean_tokens("lugal x ra")
    assert_nil P.clean_tokens("lugal [kur] ra")
    assert_nil P.clean_tokens("lugal")
    assert_nil P.clean_tokens((%w[a] * 13).join(" "))
  end

  def test_readable_chapter_finds_earliest_cover
    cumulative = [[6, Set.new(%w[lugal kur])],
                  [7, Set.new(%w[lugal kur mah])]]
    assert_equal 6, P.readable_chapter(%w[lugal kur], cumulative)
    assert_equal 7, P.readable_chapter(%w[lugal mah], cumulative)
    assert_nil P.readable_chapter(%w[lugal zag], cumulative)
  end
end
