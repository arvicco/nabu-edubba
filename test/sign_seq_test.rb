# frozen_string_literal: true

require "minitest/autorun"
require "json"
require_relative "../bin/sign_seq"

class SignSeqTest < Minitest::Test
  def batch(tokens_per_line)
    JSON.dump({ "lines" => tokens_per_line.map { |ts| { "tokens" => ts } } })
  end

  def tok(status, name, cps = [])
    { "status" => status, "sign_name" => name, "codepoints" => cps }
  end

  def test_count_values_still_counts_spelled_values
    counts, passages = Edubba::SignSeq.count_values(StringIO.new("lugal-e e2\nx du11\n"))
    assert_equal 2, passages
    assert_equal({ "lugal" => 1, "e" => 1, "e2" => 1, "du11" => 1 }, counts)
  end

  def test_counts_only_honest_resolutions
    counts = Hash.new(0)
    statuses = Hash.new(0)
    json = batch([[tok("deterministic", "AK", ["U+1201D"]),
                   tok("ambiguous", nil),
                   tok("qualified", "É", ["U+1208D"]),
                   tok("no-codepoint", "E₂"),
                   tok("broken", nil),
                   tok("unknown", nil)],
                  [tok("deterministic", "AK", ["U+1201D"])]])
    Edubba::SignSeq.count_signs_json(json, counts, statuses)
    assert_equal({ "AK" => 2, "É" => 1, "E₂" => 1 }, counts)
    assert_equal({ "deterministic" => 2, "ambiguous" => 1, "qualified" => 1,
                   "no-codepoint" => 1, "broken" => 1, "unknown" => 1 }, statuses)
  end

  def test_remembers_glyph_from_codepoints
    counts = Hash.new(0)
    glyphs = {}
    Edubba::SignSeq.count_signs_json(
      batch([[tok("deterministic", "AK", ["U+1201D"])]]),
      counts, Hash.new(0), glyphs
    )
    assert_equal "𒀝", glyphs["AK"]
  end

  def test_compound_codepoints_pack_to_multi_glyph
    glyphs = {}
    Edubba::SignSeq.count_signs_json(
      batch([[tok("deterministic", "KA×A", ["U+12157"])]]),
      Hash.new(0), Hash.new(0), glyphs
    )
    assert_equal "\u{12157}", glyphs["KA×A"]
  end
end
