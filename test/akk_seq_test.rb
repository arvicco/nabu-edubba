# frozen_string_literal: true

require "minitest/autorun"
require_relative "../bin/akk_seq"

class AkkSeqTest < Minitest::Test
  def tallies(line)
    v = Hash.new(0)
    s = Hash.new(0)
    d = Hash.new(0)
    Edubba::AkkSeq.count_line(line, v, s, d)
    [v, s, d]
  end

  def test_syllabic_values_split_on_hyphens_and_keep_atf_commas
    v, = tallies("s,i-ru-um sza-i-im")
    assert_equal({ "s,i" => 1, "ru" => 1, "um" => 1, "sza" => 1, "i" => 1, "im" => 1 }, v)
  end

  def test_sumerogram_stretches_are_tallied_separately
    v, s, = tallies("i-na _e2-gal_ u3 _ku3.babbar_ sza")
    assert_equal({ "i" => 1, "na" => 1, "u3" => 1, "sza" => 1 }, v)
    assert_equal({ "e2-gal" => 1, "ku3.babbar" => 1 }, s)
  end

  def test_determinatives_are_tallied_and_stripped
    v, _, d = tallies("{d}a-nun-na-ki {ki}")
    assert_equal({ "a" => 1, "nun" => 1, "na" => 1, "ki" => 1 }, v)
    assert_equal({ "{d}" => 1, "{ki}" => 1 }, d)
  end

  def test_damage_numbers_and_restorations
    v, s, = tallies("9(disz) _ma-na_ [t,e2]-er#-ta-ka3 x 1/3(disz)")
    assert_equal({ "t,e2" => 1, "er" => 1, "ta" => 1, "ka3" => 1 }, v)
    assert_equal({ "ma-na" => 1 }, s)
  end

  def test_ob_documents_filters_code_lect_and_source
    io = StringIO.new(<<~TSV)
      urn:nabu:cdli:p111192\takk\takk:ob\trule:x\tok
      urn:nabu:cdli:p999999\takk\takk:na\trule:x\tok
      urn:nabu:oracc:x\takk\takk:ob\trule:x\tok
      urn:nabu:cdli:p111195\tsux\takk:ob\trule:x\tok
    TSV
    assert_equal ["urn:nabu:cdli:p111192"], Edubba::AkkSeq.ob_documents(io).keys
  end

  def test_doc_urn_truncates_to_document
    assert_equal "urn:nabu:cdli:p464358",
                 Edubba::AkkSeq.doc_urn("urn:nabu:cdli:p464358:a:12")
  end
end
