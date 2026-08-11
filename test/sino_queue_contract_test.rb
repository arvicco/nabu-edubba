# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

# Contract test for site/_data/sinographs101_queue.yml (CLAUDE.md
# rule 5: curriculum data files are frozen contracts — additive
# changes only once published; this pins the shape) plus the data
# layer of the sinograph rulebook laws: keyword unique (§3), pinyin
# diacritics never numbers (§2), 5–6 fresh characters per chapter
# (the §5 chapter dial).
class SinoQueueContractTest < Minitest::Test
  QUEUE = YAML.safe_load_file(
    File.expand_path("../site/_data/sinographs101_queue.yml", __dir__)
  ).freeze

  def test_every_character_carries_the_contract_fields
    QUEUE["signs"].each do |s|
      %w[char codepoint keyword pinyin meaning category certainty
         strokes ids rank count_kanripo docs].each do |k|
        refute_nil s[k], "#{s['char']} missing #{k}"
      end
    end
  end

  def test_glyph_matches_its_declared_codepoint
    QUEUE["signs"].each do |s|
      assert_equal s["codepoint"].hex, s["char"].codepoints.first,
                   "#{s['char']}: char/codepoint mismatch"
    end
  end

  def test_keywords_are_unique_school_wide
    dup = QUEUE["signs"].map { |s| s["keyword"] }.tally.select { |_, n| n > 1 }
    assert_empty dup, "keyword taken twice (rulebook §3): #{dup.keys.join(', ')}"
  end

  def test_pinyin_is_diacritic_never_numbered
    QUEUE["signs"].each do |s|
      refute_match(/\d/, s["pinyin"],
                   "#{s['char']}: pinyin #{s['pinyin'].inspect} carries a digit — " \
                   "tone diacritics only (rulebook §2)")
    end
  end

  def test_chapters_pin_five_to_six_characters
    QUEUE["signs"].select { |s| s["chapter"] }
         .group_by { |s| s["chapter"] }.each do |ch, batch|
      assert_includes 5..6, batch.size,
                      "ch #{ch} pins #{batch.size} characters — the law says 5-6 " \
                      "(owner ruling 2026-08-10)"
    end
  end

  def test_compounds_never_precede_their_parts
    seen = []
    QUEUE["signs"].each do |s|
      Array(s["parts"]).each do |part|
        assert_includes seen, part,
                        "#{s['char']} is built from #{part} before it is taught — " \
                        "components before compounds (owner ruling 2026-08-10)"
      end
      seen << s["char"]
    end
  end

  def test_batches_are_pinned_characters_with_monotonic_coverage
    pinned = QUEUE["signs"].select { |s| s["chapter"] }.map { |s| s["char"] }
    batched = QUEUE["batches"].flat_map { |b| b["signs"] }
    assert_equal pinned.sort, batched.sort
    coverages = QUEUE["batches"].map { |b| b["coverage_pct"] }
    assert_equal coverages, coverages.sort,
                 "cumulative coverage must be monotonic"
  end
end
