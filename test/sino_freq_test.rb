# frozen_string_literal: true

require "minitest/autorun"
require_relative "../bin/sino_freq"

class SinoFreqTest < Minitest::Test
  def test_han_chars_keeps_characters_drops_the_rest
    assert_equal %w[乾 元 亨 利 貞],
                 Edubba::SinoFreq.han_chars("《乾》元亨，\n利貞。")
    assert_equal %w[學], Edubba::SinoFreq.han_chars("は學x ䷀")
    assert_empty Edubba::SinoFreq.han_chars(nil)
  end

  def test_doc_of_truncates_urn_to_the_text
    assert_equal "urn:nabu:kanripo:KR1a0001",
                 Edubba::SinoFreq.doc_of("urn:nabu:kanripo:KR1a0001:001:1a")
  end

  def test_unihan_field_picks_one_tag_and_decodes_codepoints
    lines = [
      "#\tkTotalStrokes\n",
      "U+5B78\tkTotalStrokes\t16\n",
      "U+5B78\tkMandarin\txué\n",
      "U+4E00\tkTotalStrokes\t1\n"
    ]
    assert_equal({ "學" => "16", "一" => "1" },
                 Edubba::SinoFreq.unihan_field(lines, "kTotalStrokes"))
    assert_equal({ "學" => "xué" },
                 Edubba::SinoFreq.unihan_field(lines, "kMandarin"))
  end

  def test_ids_map_strips_markers_bom_and_crlf
    lines = [
      "\u{FEFF}# Ideographic Description Sequences\r\n",
      "U+5B78\t學\t^⿱𦥯子$(GHTJKPV)\r\n",
      "U+4E00\t一\t^一$(GHTJKPV)\r\n",
      "U+4E0B\t下\t^𠄟$(G) ^丅$(T)\r\n"
    ]
    map = Edubba::SinoFreq.ids_map(lines)
    assert_equal "⿱𦥯子", map["學"]
    assert_equal "一", map["一"]
    assert_equal "𠄟", map["下"], "first alternative wins"
  end
end
