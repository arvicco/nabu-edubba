# frozen_string_literal: true

require "minitest/autorun"
require "json"
require_relative "../bin/pool_check"

class PoolCheckTest < Minitest::Test
  def entry(name, cp, value, osl_name: nil)
    e = { "name" => name, "codepoint" => cp, "value" => value }
    e["osl_name"] = osl_name if osl_name
    e
  end

  def token(status, name, cps, candidates: [])
    { "status" => status, "sign_name" => name, "codepoints" => cps,
      "candidates" => candidates }
  end

  def contract(tokens)
    JSON.dump({ "lines" => tokens.map { |t| { "tokens" => [t] } } })
  end

  def check(entries, json)
    Edubba::PoolCheck.check_pool(entries, json)
  end

  def test_deterministic_match_passes_clean
    problems, notes = check([entry("AK", "1201D", "ak")],
                            contract([token("deterministic", "AK", ["U+1201D"])]))
    assert_empty problems
    assert_empty notes
  end

  def test_subscript_osl_name_matches_ascii_pool_name
    problems, notes = check([entry("EŠ2", "120A0", "sze3")],
                            contract([token("deterministic", "EŠ₂", ["U+120A0"])]))
    assert_empty problems
    assert_empty notes
  end

  def test_wrong_codepoint_is_fatal
    problems, = check([entry("AK", "12000", "ak")],
                      contract([token("deterministic", "AK", ["U+1201D"])]))
    assert_equal 1, problems.size
    assert_match(/codepoint 12000 not in OSL 1201D/, problems[0])
  end

  def test_name_difference_over_confirmed_codepoint_is_a_note
    problems, notes = check([entry("NIN", "1238F", "nin")],
                            contract([token("deterministic", "|SAL.TUG₂|", ["U+1238F"])]))
    assert_empty problems
    assert_equal 1, notes.size
    assert_match(/OSL names it \|SAL\.TUG₂\|/, notes[0])
  end

  def test_osl_name_field_silences_the_note
    problems, notes = check([entry("NIN", "1238F", "nin", osl_name: "|SAL.TUG₂|")],
                            contract([token("deterministic", "|SAL.TUG₂|", ["U+1238F"])]))
    assert_empty problems
    assert_empty notes
  end

  def test_ambiguous_passes_when_pool_codepoint_among_candidates
    amb = token("ambiguous", nil, [],
                candidates: [token("deterministic", "KID", ["U+121A4"]),
                             token("no-codepoint", "E₂", [])])
    problems, notes = check([entry("KID", "121A4", "lil2")], contract([amb]))
    assert_empty problems
    assert_empty notes
    problems, = check([entry("GA", "120B5", "lil2")], contract([amb]))
    assert_match(/not among OSL candidates KID\/E₂/, problems[0])
  end

  def test_unknown_and_missing_token_fail
    problems, = check([entry("AK", "1201D", "ak")],
                      contract([token("unknown", nil, [])]))
    assert_match(/status unknown/, problems[0])
    problems, = check([entry("AK", "1201D", "ak")], JSON.dump({ "lines" => [] }))
    assert_match(/no token resolved/, problems[0])
  end
end
