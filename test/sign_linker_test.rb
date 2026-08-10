# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
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

  REN = "人"
  SINO_MAP = {
    REN => { url: "/sinographs/101/00-orientation/", anchor: "sign-4EBA",
             tip: "person · rén · a human being; other people",
             codex: "/sinographs/addenda/signs/ren/" }
  }.freeze

  def test_han_glyph_links_with_tip_and_cell_routes_to_codex
    out = Edubba::SignLinker.transform("<p>the #{REN} walks</p>", SINO_MAP, "/x/", "")
    assert_includes out,
                    %(<a class="sign-link" href="/sinographs/101/00-orientation/#sign-4EBA">#{REN}) +
                    %(<span class="sign-tip" aria-hidden="true">person · rén · a human being; other people</span></a>)

    cell = %(<td class="script sign-cell">#{REN}</td>)
    out = Edubba::SignLinker.transform(cell, SINO_MAP, "/sinographs/101/02-x/", "")
    assert_includes out, %(href="/sinographs/addenda/signs/ren/"),
                    "a sign-cell off the teaching page routes to the codex"
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

  # --- codex links in sign-table cells (rulebook §7) ---

  CODEX = "/cuneiform/addenda/signs/an/"
  CODEX_MAP = {
    AN => { url: REF, anchor: "sign-1202D", tip: "AN · an · heaven", codex: CODEX }
  }.freeze

  def tc(html, page_url: "/x/", baseurl: "")
    Edubba::SignLinker.transform(html, CODEX_MAP, page_url, baseurl)
  end

  def test_sign_cell_links_to_codex_with_tip
    out = tc(%(<td class="sign-cell">#{AN}</td>), baseurl: "/b")
    assert_includes out,
                    %(<a class="sign-link" href="/b#{CODEX}">#{AN}) +
                    %(<span class="sign-tip" aria-hidden="true">AN · an · heaven</span></a>)
  end

  def test_own_page_sign_cell_keeps_anchor_id_on_codex_link
    out = tc(%(<td class="sign-cell">#{AN}</td>), page_url: REF)
    assert_includes out, %(<a class="sign-link" id="sign-1202D" href="#{CODEX}">#{AN}</a>)
  end

  def test_codex_page_itself_gets_no_self_link_in_cells
    out = tc(%(<td class="sign-cell">#{AN}</td>), page_url: CODEX)
    assert_includes out, %(href="#{REF}#sign-1202D")
  end

  def test_body_text_still_links_to_teaching_location_not_codex
    out = tc("<p>#{AN}</p>")
    assert_includes out, %(href="#{REF}#sign-1202D")
    refute_includes out, %(href="#{CODEX}")
  end

  # --- §9 language separation: per-course codex routing ---

  AKK_CODEX = "/cuneiform/addenda-akk/signs/an/"
  TWO_CODEX_MAP = {
    AN => { url: REF, anchor: "sign-1202D", tip: "AN · an · heaven",
            codex: CODEX, codex_akk: AKK_CODEX },
    ME => { url: CH0, anchor: "sign-12228", codex: "/cuneiform/addenda/signs/me/" }
  }.freeze

  def test_akkadian_pages_route_sign_cells_to_the_akk_codex
    html = %(<td class="sign-cell">#{AN}</td>)
    out = Edubba::SignLinker.transform(html, TWO_CODEX_MAP, "/cuneiform/103/01-x/", "", :codex_akk)
    assert_includes out, %(href="#{AKK_CODEX}")
    refute_includes out, %(href="#{CODEX}")
  end

  def test_akk_routing_falls_back_to_teaching_link_never_the_sux_codex
    html = %(<td class="sign-cell">#{ME}</td>)
    out = Edubba::SignLinker.transform(html, TWO_CODEX_MAP, "/cuneiform/103/01-x/", "", :codex_akk)
    assert_includes out, %(href="#{CH0}#sign-12228")
    refute_includes out, %(addenda/signs/me)
  end

  def test_akkadian_pages_show_the_akkadian_tip_never_the_sumerian
    map = { AN => { url: REF, anchor: "sign-1202D",
                    tip: "AN · [an], diŋir · heaven; god",
                    tip_akk: "AN · [an] · the sky-god, unchanged" } }
    akk = Edubba::SignLinker.transform("<p>#{AN}</p>", map, "/cuneiform/103/04-x/", "", :codex_akk)
    assert_includes akk, "the sky-god, unchanged"
    refute_includes akk, "diŋir · heaven"
    sux = Edubba::SignLinker.transform("<p>#{AN}</p>", map, "/cuneiform/102/04-x/", "")
    assert_includes sux, "diŋir · heaven"
    refute_includes sux, "sky-god, unchanged"
  end

  def test_sux_pages_still_route_to_the_sux_codex
    html = %(<td class="sign-cell">#{AN}</td>)
    out = Edubba::SignLinker.transform(html, TWO_CODEX_MAP, "/cuneiform/102/01-x/", "")
    assert_includes out, %(href="#{CODEX}")
    refute_includes out, %(addenda-akk)
  end

  def test_display_form_folds_akkadian_emphatics_and_subscripts
    assert_equal "ṣi", Edubba::SignLinker.display_form("s,i")
    assert_equal "ṭu₂", Edubba::SignLinker.display_form("t,u2")
    assert_equal "ku₃", Edubba::SignLinker.display_form("ku3")
    assert_equal "šum₂", Edubba::SignLinker.display_form("szum2")
  end

  def test_phonetic_strips_indexes_and_joins_variants
    assert_equal "ku", Edubba::SignLinker.phonetic("ku3")
    assert_equal "ṣi/ṣe", Edubba::SignLinker.phonetic("s,i, s,e")
    assert_equal "niŋ", Edubba::SignLinker.phonetic("niŋ₂")
  end

  def test_reads_display_separates_lexemes_from_phonetic_variants
    assert_equal "[an], diŋir", Edubba::SignLinker.reads_display("an; diŋir (dijir/dingir)")
    assert_equal "[wa/wi]", Edubba::SignLinker.reads_display("wa, wi")
    assert_equal "[dumu], tur", Edubba::SignLinker.reads_display("dumu; tur")
    assert_equal "[ni], i₃", Edubba::SignLinker.reads_display("ni; i₃ (i3)")
  end

  def test_tip_text_prefers_explicit_display_value
    tip = Edubba::SignLinker.tip_text(
      { "name" => "GAR", "value" => "nig2", "display_value" => "niŋ₂", "meaning" => "thing" }
    )
    assert_equal "GAR · [niŋ] · thing", tip
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
    assert_equal "AN · [an], diŋir · heaven; god", map[AN][:tip]
    assert_equal "EŠ₂ · [še] · rope; the terminative -še₃", map[ME][:tip]
  end

  def test_tip_text_veteran_keeps_reads_and_hook_drops_boilerplate
    tip = Edubba::SignLinker.tip_text_veteran(
      { "name" => "BI", "value" => "pi2", "keyword" => "its",
        "meaning" => "veteran — BI gains [pi₂]: the last syllable of Ḫammurapi" }
    )
    assert_equal "BI · [pi] · the last syllable of Ḫammurapi", tip
  end

  def test_pool_103_veteran_tips_stay_hover_sized
    pool = YAML.safe_load_file("assets-src/data/pool-103.yml")["signs"]
    pool.select { |s| s["veteran"] }.each do |s|
      tip = Edubba::SignLinker.tip_text_veteran(s)
      refute_match(/veteran/, tip, "#{s['name']}: boilerplate leaked into a hover tip")
      assert_match(/·\s\[/, tip, "#{s['name']}: tip #{tip.inspect} lost the Akkadian reading")
      assert_operator tip.length, :<=, 60, "#{s['name']}: tip #{tip.inspect} outgrew a hover bubble"
    end
  end

  def test_transform_routes_veteran_to_akk_reintroduction_on_akk_pages
    map = { AN => { url: "/cuneiform/102/03-say-it-twice/", url_akk: "/cuneiform/103/05-the-verb-arrives/",
                    anchor: "sign-1202D", tip: "sux tip", tip_akk: "akk tip" } }
    sux = Edubba::SignLinker.transform("<p>#{AN}</p>", map, "/cuneiform/102/09-x/", "", :codex)
    akk = Edubba::SignLinker.transform("<p>#{AN}</p>", map, "/cuneiform/103/06-if-a-man/", "", :codex_akk)
    assert_includes sux, 'href="/cuneiform/102/03-say-it-twice/#sign-1202D"'
    assert_includes sux, ">sux tip<"
    assert_includes akk, 'href="/cuneiform/103/05-the-verb-arrives/#sign-1202D"'
    assert_includes akk, ">akk tip<"
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

  def test_tip_join_keeps_gardiner_codes_raw
    assert_equal "D46 · d · hand",
                 Edubba::SignLinker.tip_join(["D46", "d", "hand"])
  end

  def test_hieroglyph_glyph_is_linked
    owl = "\u{13153}"
    map = { owl => { url: "/hieroglyphs/101/04-your-first-signs/", anchor: "sign-13153",
                     tip: "G17 · m · owl" } }
    out = Edubba::SignLinker.transform("<p>#{owl}</p>", map, "/x/", "")
    assert_includes out, %(<a class="sign-link" href="/hieroglyphs/101/04-your-first-signs/#sign-13153">#{owl})
    assert_includes out, "G17 · m · owl"
  end
end
