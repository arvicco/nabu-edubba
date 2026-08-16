# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

# Contract test for the sinograph character queues (CLAUDE.md
# rule 5: curriculum data files are frozen contracts — additive
# changes only once published; this pins the shape) plus the data
# layer of the sinograph rulebook laws: keyword unique (§3), pinyin
# diacritics never numbers (§2), 5–6 fresh characters per chapter
# (the §5 chapter dial). Since the course-border ruling (concept
# §7, 2026-08-12) the school carries TWO registries: S101 holds
# chapters 00–09 only, S102 everything beyond; school-wide laws
# run over the union, border laws over each file.
class SinoQueueContractTest < Minitest::Test
  Q101 = YAML.safe_load_file(
    File.expand_path("../site/_data/sinographs101_queue.yml", __dir__)
  ).freeze
  Q102 = YAML.safe_load_file(
    File.expand_path("../site/_data/sinographs102_queue.yml", __dir__)
  ).freeze
  ALL = (Q101["signs"] + Q102["signs"]).freeze

  def test_the_course_border_holds
    assert Q101["signs"].all? { |s| s["chapter"] <= 9 && s["course"].nil? },
           "S101 may hold chapters 00-09 only (concept §7)"
    assert Q102["signs"].all? { |s| s["course"] == 102 && (1..15).cover?(s["chapter"]) },
           "S102 rows carry course: 102 and grammar-spine ordinals 1-15 (Gate 24)"
    assert_equal (0..9).to_a, Q101["signs"].map { |s| s["chapter"] }.uniq.sort,
                 "S101 is complete: every chapter 00-09 teaches"
    assert_equal (1..15).to_a, Q102["signs"].map { |s| s["chapter"] }.uniq.sort,
                 "S102 is fully batched: every chapter 1-15 teaches"
  end

  def test_every_character_carries_the_contract_fields
    ALL.each do |s|
      %w[char codepoint keyword pinyin meaning category certainty
         strokes ids rank count_kanripo docs].each do |k|
        refute_nil s[k], "#{s['char']} missing #{k}"
      end
    end
  end

  def test_glyph_matches_its_declared_codepoint
    ALL.each do |s|
      assert_equal s["codepoint"].hex, s["char"].codepoints.first,
                   "#{s['char']}: char/codepoint mismatch"
    end
  end

  def test_keywords_are_unique_school_wide
    dup = ALL.map { |s| s["keyword"] }.tally.select { |_, n| n > 1 }
    assert_empty dup, "keyword taken twice (rulebook §3): #{dup.keys.join(', ')}"
  end

  def test_pinyin_is_diacritic_never_numbered
    ALL.each do |s|
      refute_match(/\d/, s["pinyin"],
                   "#{s['char']}: pinyin #{s['pinyin'].inspect} carries a digit — " \
                   "tone diacritics only (rulebook §2)")
    end
  end

  def test_chapters_pin_five_to_six_characters
    ALL.select { |s| s["chapter"] }
       .group_by { |s| [s["course"] || 101, s["chapter"]] }.each do |ch, batch|
      assert_includes 5..6, batch.size,
                      "ch #{ch} pins #{batch.size} characters — the law says 5-6 " \
                      "(owner ruling 2026-08-10)"
    end
  end

  def test_compounds_never_precede_their_parts
    # ALL is already in teaching order: each file is chapter-sorted
    # by the compiler and S102 begins where S101 ends; a sort here
    # would shuffle within-chapter order (sort_by is not stable)
    seen = []
    ALL.each do |s|
      Array(s["parts"]).each do |part|
        assert_includes seen, part,
                        "#{s['char']} is built from #{part} before it is taught — " \
                        "components before compounds (owner ruling 2026-08-10)"
      end
      seen << s["char"]
    end
  end

  def test_batches_are_pinned_characters_with_monotonic_coverage
    [Q101, Q102].each do |q|
      pinned = q["signs"].select { |s| s["chapter"] }.map { |s| s["char"] }
      batched = q["batches"].flat_map { |b| b["signs"] }
      assert_equal pinned.sort, batched.sort
      coverages = q["batches"].map { |b| b["coverage_pct"] }
      assert_equal coverages, coverages.sort,
                   "cumulative coverage must be monotonic"
    end
  end
end
