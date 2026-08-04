# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

# Contract test for site/_data/hieroglyphs102_queue.yml (CLAUDE.md
# rule 5: curriculum data files are frozen contracts — additive
# changes only once published; this pins the shape).
class HieroQueueContractTest < Minitest::Test
  QUEUE = YAML.safe_load_file(
    File.expand_path("../site/_data/hieroglyphs102_queue.yml", __dir__)
  ).freeze

  def test_every_sign_carries_the_contract_fields
    QUEUE["signs"].each do |s|
      %w[glyph codepoint gardiner value meaning sense freq_aes certainty].each do |k|
        refute_nil s[k], "#{s['gardiner']} missing #{k}"
      end
    end
  end

  def test_every_pinned_sign_carries_a_keyword
    QUEUE["signs"].select { |s| s["chapter"] }.each do |s|
      refute_nil s["keyword"], "#{s['gardiner']} pinned without a keyword (rulebook §9)"
    end
  end

  def test_glyph_matches_its_declared_codepoint
    QUEUE["signs"].each do |s|
      assert_equal s["codepoint"].hex, s["glyph"].codepoints.first,
                   "#{s['gardiner']}: glyph/codepoint mismatch"
    end
  end

  def test_batches_are_pinned_signs_with_monotonic_coverage
    pinned = QUEUE["signs"].select { |s| s["chapter"] }
    batched = QUEUE["batches"].flat_map { |b| b["signs"] }
    assert_equal pinned.map { |s| s["gardiner"] }.sort, batched.sort
    coverages = QUEUE["batches"].map { |b| b["coverage_aes_pct"] }
    assert_equal coverages, coverages.sort,
                 "coverage must be cumulative (nondecreasing)"
    QUEUE["batches"].each do |b|
      assert b["chapter"].is_a?(Integer) && b["chapter"] >= 0
    end
  end

  def test_no_gardiner_code_taught_twice_across_the_school
    e101 = YAML.safe_load_file(
      File.expand_path("../site/_data/hiero_teaching.yml", __dir__)
    )["signs"].map { |s| s["gardiner"].upcase }
    e102 = QUEUE["signs"].map { |s| s["gardiner"].upcase }
    assert_empty e101 & e102, "a sign is taught once, never re-entered"
    assert_equal e102.uniq, e102, "duplicate codes inside the queue"
  end
end
