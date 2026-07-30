# frozen_string_literal: true

require "minitest/autorun"
require_relative "../script/sign_linker"

class SignLinkerTest < Minitest::Test
  AN = "\u{1202D}"
  ME = "\u{12228}"
  REF = "/cuneiform/101/12-reference/"
  CH0 = "/cuneiform/102/00-orientation/"
  MAP = {
    AN => { url: REF, anchor: "sign-1202D", tip: "AN · an; diŋir · heaven; god" },
    ME => { url: CH0, anchor: "sign-12228" }
  }.freeze

  def t(html, page_url: "/x/", baseurl: "")
    Edubba::SignLinker.transform(html, MAP, page_url, baseurl)
  end

  def test_plain_glyph_becomes_link_with_baseurl_and_tip
    out = t("<p>see #{AN} here</p>", baseurl: "/nabu-edubba")
    assert_includes out,
                    %(<a class="sign-link" href="/nabu-edubba#{REF}#sign-1202D">#{AN}) +
                    %(<span class="sign-tip" aria-hidden="true">AN · an; diŋir · heaven; god</span></a>)
  end

  def test_glyph_without_tip_gets_bare_link
    out = t("<p>#{ME}</p>")
    assert_includes out, %(<a class="sign-link" href="#{CH0}#sign-12228">#{ME}</a>)
  end

  def test_glyph_inside_existing_link_untouched
    html = %(<a href="/">#{AN}</a>)
    assert_equal html, t(html)
  end

  def test_glyph_in_title_svg_untouched
    html = "<title>#{AN}</title><svg><text>#{AN}</text></svg>"
    assert_equal html, t(html)
  end

  def test_unknown_glyph_untouched
    kur = "\u{121B3}"
    assert_equal "<p>#{kur}</p>", t("<p>#{kur}</p>")
  end

  def test_sign_cell_on_own_page_becomes_anchor_once
    html = %(<td class="script sign-cell">#{ME}</td><p>#{ME} again</p>)
    out = t(html, page_url: CH0)
    assert_includes out, %(<span id="sign-12228">#{ME}</span>)
    assert_includes out, %(<a class="sign-link" href="#sign-12228">#{ME}</a>)
  end

  def test_sign_cell_on_other_page_still_links
    html = %(<td class="script sign-cell">#{AN}</td>)
    out = t(html, page_url: CH0)
    assert_includes out, %(href="#{REF}#sign-1202D")
  end

  def test_build_map_prefers_queue_chapters_for_queue_signs
    teaching = { "signs" => [{ "glyph" => AN, "codepoint" => "1202D" }] }
    queue = { "signs" => [{ "glyph" => ME, "codepoint" => "12228", "chapter" => 0 }] }
    map = Edubba::SignLinker.build_map(teaching, queue, REF, { 0 => CH0 })
    assert_equal REF, map[AN][:url]
    assert_equal CH0, map[ME][:url]
  end

  def test_build_map_composes_tips_from_sign_data
    teaching = { "signs" => [{ "glyph" => AN, "codepoint" => "1202D", "name" => "AN",
                               "value" => "an; diŋir (dijir/dingir)",
                               "meaning" => "heaven; god (determinative {d})" }] }
    queue = { "signs" => [{ "glyph" => ME, "codepoint" => "12228", "chapter" => 0,
                            "name" => "EŠ2", "value" => "sze3",
                            "meaning" => "rope (stated); the terminative -sze3" }] }
    map = Edubba::SignLinker.build_map(teaching, queue, REF, { 0 => CH0 })
    assert_equal "AN · an; diŋir · heaven; god", map[AN][:tip]
    assert_equal "EŠ₂ · še₃ · rope; the terminative -še₃", map[ME][:tip]
  end

  def test_tip_text_escapes_html_and_skips_empty
    assert_equal "AN · a &lt;b&gt; &amp; c",
                 Edubba::SignLinker.tip_text("name" => "AN", "meaning" => "a <b> & c")
    assert_nil Edubba::SignLinker.tip_text({})
  end

  def test_display_form_converts_multi_digit_indexes
    assert_equal "du₁₁", Edubba::SignLinker.display_form("du11")
  end

  def test_display_form_strips_orphaned_separators
    assert_equal "oil, butter as i₃",
                 Edubba::SignLinker.display_form("(syllable ni); oil, butter as i₃")
  end
end
