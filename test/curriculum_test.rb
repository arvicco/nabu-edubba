# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require_relative "../bin/curriculum"

class CurriculumTest < Minitest::Test
  def sign(name, etcsl, cdli, wedges)
    { "name" => name, "freq_etcsl" => etcsl, "freq_cdli" => cdli, "wedges" => wedges }
  end

  def test_score_prefers_best_rank_plus_weighted_wedges
    assert_equal 17 + 8 * 2, Edubba::Curriculum.score(sign("ME", 17, 57, "2"))
    assert_equal 7 + 8 * 8, Edubba::Curriculum.score(sign("RA", 7, 24, "~8"))
  end

  def test_simplicity_can_beat_raw_frequency
    me = sign("ME", 17, 57, "2")
    ra = sign("RA", 7, 24, "~8")
    assert_equal %w[ME RA], Edubba::Curriculum.order([ra, me]).map { |s| s["name"] }
  end

  def test_unranked_signs_sort_late
    rare = sign("X", nil, nil, "1")
    common = sign("Y", 5, 5, "9")
    assert_equal %w[Y X], Edubba::Curriculum.order([rare, common]).map { |s| s["name"] }
  end

  def test_batches_assign_chapters_in_order_and_leave_remainder_unassigned
    pool = (1..8).map { |i| sign("S#{i}", i, i, "1") }
    out = Edubba::Curriculum.assign_batches(Edubba::Curriculum.order(pool), { 0 => 3, 1 => 3 })
    assert_equal [0, 0, 0, 1, 1, 1, nil, nil], out.map { |s| s["chapter"] }
  end

  def test_coverage_counts_share_of_occurrences
    Dir.mktmpdir do |dir|
      tsv = File.join(dir, "f.tsv")
      File.write(tsv, "# header\nrank\tvalue\tcount\n1\ta\t60\n2\tb\t30\n3\tc\t10\n")
      assert_in_delta 90.0, Edubba::Curriculum.coverage(tsv, %w[a b]), 0.001
      assert_in_delta 0.0, Edubba::Curriculum.coverage(tsv, []), 0.001
    end
  end
end
