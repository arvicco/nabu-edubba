# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require_relative "../script/lint"

class LintTest < Minitest::Test
  def with_site(files)
    Dir.mktmpdir do |dir|
      files.each do |rel, content|
        path = File.join(dir, rel)
        Dir.mkdir(File.dirname(path)) unless File.directory?(File.dirname(path))
        File.write(path, content)
      end
      yield dir
    end
  end

  CLEAN_PAGE = "---\ntitle: Test\n---\n\nWedge [basics]({{ '/cuneiform/' | relative_url }}).\n"

  def test_clean_site_has_no_violations
    with_site("index.md" => CLEAN_PAGE, "_layouts/default.html" => "<html>{{ content }}</html>") do |dir|
      assert_empty Edubba::Lint.violations(dir)
    end
  end

  def test_script_tag_is_flagged_no_js
    with_site("index.md" => CLEAN_PAGE + "<script>alert(1)</script>\n") do |dir|
      rules = Edubba::Lint.violations(dir).map(&:rule)
      assert_includes rules, "no-js"
    end
  end

  def test_js_asset_is_flagged_no_js
    with_site("index.md" => CLEAN_PAGE, "assets/app.js" => "console.log(1)") do |dir|
      rules = Edubba::Lint.violations(dir).map(&:rule)
      assert_includes rules, "no-js"
    end
  end

  def test_markdown_without_front_matter_is_flagged
    with_site("index.md" => "# No front matter\n") do |dir|
      rules = Edubba::Lint.violations(dir).map(&:rule)
      assert_includes rules, "front-matter"
    end
  end

  def test_ascii_index_in_translit_span_is_flagged
    page = CLEAN_PAGE + %(<span class="translit">lu2-dingir-mu</span>\n)
    with_site("index.md" => page) do |dir|
      rules = Edubba::Lint.violations(dir).map(&:rule)
      assert_includes rules, "subscript-index"
    end
  end

  def test_subscript_index_and_atf_exempt_span_are_clean
    page = CLEAN_PAGE +
           %(<span class="translit">lu₂-diŋir-mu ARAD₂ {ki}</span>\n) +
           %(<span class="translit atf">mu {d}szul-gi kal-ga# limmu2-ba-ke4</span>\n)
    with_site("index.md" => page) do |dir|
      refute_includes Edubba::Lint.violations(dir).map(&:rule), "subscript-index"
    end
  end

  def test_hard_coded_production_origin_is_flagged
    with_site("index.md" => CLEAN_PAGE + "[home](https://edubba.ac/cuneiform/)\n") do |dir|
      rules = Edubba::Lint.violations(dir).map(&:rule)
      assert_includes rules, "relative-links"
    end
  end

  def test_html_layout_without_front_matter_is_not_flagged
    with_site("_layouts/default.html" => "<html>{{ content }}</html>") do |dir|
      refute_includes Edubba::Lint.violations(dir).map(&:rule), "front-matter"
    end
  end

  # --- base-relative rule (site must work at any base path) ---

  def test_root_absolute_markdown_link_is_flagged
    with_site("index.md" => CLEAN_PAGE + "[school](/cuneiform/)\n") do |dir|
      assert_includes Edubba::Lint.violations(dir).map(&:rule), "base-relative"
    end
  end

  def test_root_absolute_href_is_flagged
    with_site("index.md" => CLEAN_PAGE + "<a href=\"/hanzi/\">hanzi</a>\n") do |dir|
      assert_includes Edubba::Lint.violations(dir).map(&:rule), "base-relative"
    end
  end

  def test_relative_url_links_and_external_links_are_clean
    page = CLEAN_PAGE +
           "<a href=\"{{ '/hanzi/' | relative_url }}\">h</a> " \
           "[gh](https://github.com/arvicco/nabu-edubba/issues)\n"
    with_site("index.md" => page) do |dir|
      refute_includes Edubba::Lint.violations(dir).map(&:rule), "base-relative"
    end
  end

  # --- font-coverage rule (cuneiform must never ship as tofu) ---

  CUNEIFORM_PAGE = CLEAN_PAGE + "\nThe sign 𒀀 (A, U+12000).\n"

  def test_cuneiform_without_manifest_is_flagged
    with_site("index.md" => CUNEIFORM_PAGE) do |dir|
      offenses = Edubba::Lint.violations(dir, { "cuneiform" => File.join(dir, "missing-manifest.txt") })
      assert_includes offenses.map(&:rule), "font-coverage"
      assert_match(/U\+12000/, offenses.find { |v| v.rule == "font-coverage" }.detail)
    end
  end

  def test_cuneiform_covered_by_manifest_is_clean
    with_site("index.md" => CUNEIFORM_PAGE, "coverage.txt" => "# comment\n12000\n") do |dir|
      assert_empty Edubba::Lint.violations(dir, { "cuneiform" => File.join(dir, "coverage.txt") })
    end
  end

  HIERO_PAGE = CLEAN_PAGE + "\nThe sign \u{13000} (GARDINER A1, U+13000).\n"

  def test_hieroglyph_without_manifest_is_flagged
    with_site("index.md" => HIERO_PAGE) do |dir|
      offenses = Edubba::Lint.violations(dir, { "hieroglyphs" => File.join(dir, "missing-manifest.txt") })
      hit = offenses.find { |v| v.rule == "font-coverage" }
      refute_nil hit
      assert_match(/U\+13000 \(hieroglyphs\)/, hit.detail)
    end
  end

  def test_hieroglyph_covered_by_manifest_is_clean
    with_site("index.md" => HIERO_PAGE, "coverage.txt" => "13000\n") do |dir|
      assert_empty Edubba::Lint.violations(dir, { "hieroglyphs" => File.join(dir, "coverage.txt") })
    end
  end

  def test_scanner_finds_codepoints_per_script_range
    with_site("index.md" => CUNEIFORM_PAGE + HIERO_PAGE) do |dir|
      cun = Edubba::ScriptScan::SCRIPTS["cuneiform"][:range]
      hie = Edubba::ScriptScan::SCRIPTS["hieroglyphs"][:range]
      assert_equal Set[0x12000], Edubba::ScriptScan.used_codepoints(dir, cun)
      assert_equal Set[0x13000], Edubba::ScriptScan.used_codepoints(dir, hie)
    end
  end

  def test_scanner_handles_multi_range_scripts
    with_site("index.md" => CUNEIFORM_PAGE + "\n學𦥯\n") do |dir|
      han = Edubba::ScriptScan::SCRIPTS["sinographs"][:range]
      assert_equal Set[0x5B78, 0x2696F],
                   Edubba::ScriptScan.used_codepoints(dir, han),
                   "URO and Ext-B codepoints both counted, cuneiform excluded"
    end
    assert Edubba::ScriptScan.tracked?(0x5B78)
    refute Edubba::ScriptScan.tracked?(0x0041)
  end

  def test_citation_urn_requires_a_witness_in_the_figcaption
    fig = lambda do |mods, caption|
      "---\nt: 1\n---\n<figure class=\"reading reading--script#{mods}\">" \
        "<div class=\"reading-lines\"></div>" \
        "<figcaption class=\"citation\">#{caption}</figcaption></figure>"
    end
    path = "site/cuneiform/101/04-x.md"
    assert_empty Edubba::Lint.check_citation_urn(
      path, fig.call("", "<em>Laozi</em> 42. <code>urn:nabu:kanripo:KR5c0057:042:1a</code>")
    )
    assert_equal ["citation-urn"],
                 Edubba::Lint.check_citation_urn(path, fig.call("", "A famous line.")).map(&:rule),
                 "a reading figure without a urn:nabu: witness fails"
    assert_empty Edubba::Lint.check_citation_urn(
      path, fig.call(" reading--composed", "Assembled from signs you already hold.")
    ), "composed figures escape via class + displayed wording"
    assert_equal ["citation-urn"],
                 Edubba::Lint.check_citation_urn(
                   path, fig.call(" reading--composed", "A teaching example.")
                 ).map(&:rule),
                 "the composed class alone is not enough — the caption must SAY so"
    assert_empty Edubba::Lint.check_citation_urn(
      path, fig.call(" reading--monument", "As carved on the Rosetta Stone, BM EA 24.")
    ), "real objects outside the corpora escape via reading--monument + wording"
    assert_equal ["citation-urn"],
                 Edubba::Lint.check_citation_urn(
                   path, fig.call(" reading--monument", "The Rosetta Stone, BM EA 24.")
                 ).map(&:rule),
                 "monument class without carved/inscribed wording fails"
    assert_empty Edubba::Lint.check_citation_urn(
      path, "---\nt: 1\n---\n<figure class=\"reading-grid\">no caption at all</figure>"
    ), "only reading figures are in scope"
  end

  def test_box_share_caps_untaught_boxes_progressively
    fig = ->(script) { "---\nchapter: 0\n---\n<figure class=\"reading reading--script\"><div><span class=\"script\">#{script}</span></div></figure>" }
    sino = "site/sinographs/101/00-x.md"
    v = Edubba::Lint.check_box_share(sino, fig.call("人▢▢，▢▢天。"))
    assert_equal ["box-share"], v.map(&:rule), "67% boxes breaks the ch0 50% cap"
    assert_empty Edubba::Lint.check_box_share(sino, fig.call("▢▢大，天大，▢大。")),
                 "43% boxes passes at ch0"
    ch5 = fig.call("▢水，▢山。").sub("chapter: 0", "chapter: 5")
    assert_equal ["box-share"], Edubba::Lint.check_box_share(sino, ch5).map(&:rule),
                 "50% breaks the tightened 45% cap of the second stretch"
    assert_empty Edubba::Lint.check_box_share("site/cuneiform/103/x.md", fig.call("▢▢▢▢天。")),
                 "sinograph law only"
  end

  def test_only_the_sanctioned_script_passes
    good = %(<script src="{{ '/assets/say.js' | relative_url }}" defer></script>)
    v = Edubba::Lint.check_file(nil, __FILE__) rescue nil
    ok_html = Edubba::Lint.check_file("x", write_tmp("layout.html", good))
    assert_empty ok_html.select { |x| x.rule == "no-js" },
                 "the D17-a say.js include is sanctioned in layouts"
    bad_md = Edubba::Lint.check_file("x", write_tmp("page.md", "---\nt: 1\n---\n" + good))
    assert_equal ["no-js"], bad_md.map(&:rule) & ["no-js"],
                 "even the sanctioned tag is refused inside content pages"
    evil = Edubba::Lint.check_file("x", write_tmp("evil.html", %(<script src="{{ '/assets/other.js' | relative_url }}" defer></script>)))
    assert_includes evil.map(&:rule), "no-js", "any other script still fails"
  end

  def write_tmp(name, content)
    path = File.join(Dir.mktmpdir, name)
    File.write(path, content)
    path
  end

  def test_production_vocab_stays_out_of_site_prose
    v = Edubba::Lint.check_production_vocab("site/sinographs/101/08-x.md",
                                            "One chapter left in this stretch: the last little words.")
    assert_equal ["production-vocab"], v.map(&:rule), "the ch08 line the owner flagged"

    v2 = Edubba::Lint.check_production_vocab("site/hieroglyphs/addenda/signs/e34.md",
                                             "A desert hare at full stretch, ears flat.")
    assert_equal ["production-vocab"], v2.map(&:rule),
                 "even physical senses are banned — use a synonym, keep the lint simple"

    v3 = Edubba::Lint.check_production_vocab("site/cuneiform/102/index.md",
                                             "the track continues in a later phase")
    assert_equal ["production-vocab"], v3.map(&:rule), "calendar deferrals are borders too"

    assert_empty Edubba::Lint.check_production_vocab("site/cuneiform/101/11-x.md",
                                                     "The earliest phase of the script, proto-cuneiform."),
                 "historical 'phase' with no calendar sense stays legal"
  end

  def test_say_audio_flags_mute_sign_table_readings
    sino = "site/sinographs/101/04-x.md"
    mute = %(<td class="script sign-cell">品</td><td>kinds</td><td><span class="translit pinyin">pǐn</span></td>)
    v = Edubba::Lint.check_say_audio("site", sino, mute)
    assert_equal ["say-audio"], v.map(&:rule), "the shipped-silent pǐn case"
    assert_match(/pǐn/, v.first.detail)

    voiced = %(<td class="script sign-cell">品</td><td><a class="say" href="{{ '/assets/audio/pinyin/pin.mp3' | relative_url }}" title="hear it"><span class="translit pinyin">pǐn</span></a></td>)
    assert_empty Edubba::Lint.check_say_audio("site", sino, voiced)

    reading_line = %(<div class="reading-line"><span class="translit pinyin">rén fǎ dì</span></div>)
    assert_empty Edubba::Lint.check_say_audio("site", sino, reading_line),
                 "reading transliteration is not a button"
  end

  def test_say_audio_flags_dead_targets
    live = %(<a class="say" href="{{ '/assets/audio/pinyin/ren.mp3' | relative_url }}">x</a>)
    assert_empty Edubba::Lint.check_say_audio("site", "site/sinographs/101/00-x.md", live)

    dead = live.sub("ren.mp3", "no-such.mp3")
    v = Edubba::Lint.check_say_audio("site", "site/anywhere/page.md", dead)
    assert_equal ["say-audio"], v.map(&:rule), "a say-link must resolve on any page"
    assert_match(%r{no-such\.mp3}, v.first.detail)
  end

  def test_pinyin_display_bans_tone_numbers_in_sinograph_pages
    sino = "site/sinographs/101/00-x.md"
    v = Edubba::Lint.check_pinyin_display(sino, "say xue2 aloud")
    assert_equal ["pinyin-display"], v.map(&:rule)
    assert_match(/xue2/, v.first.detail)

    ok = 'the ASCII convention writes <span class="pinyin ascii">xue2</span>'
    assert_empty Edubba::Lint.check_pinyin_display(sino, ok)
    assert_empty Edubba::Lint.check_pinyin_display(sino, "phase-15 v2 M15-4 ch02"),
                 "version-y tokens are not pinyin"
    assert_empty Edubba::Lint.check_pinyin_display("site/cuneiform/103/05-x.md", "raw ATF du3"),
                 "the rule is sinograph law only"
  end

  def test_nav_label_must_be_drawn_from_title
    bad = "---\ntitle: \"06 · If a man…\"\nshort_title: \"06 · šumma\"\nchapter: 6\n---\nbody"
    v = Edubba::Lint.check_nav_label("x.md", bad)
    assert_equal 1, v.size
    assert_equal "nav-label", v[0].rule

    good = bad.sub("06 · šumma", "06 · If a man…")
    assert_empty Edubba::Lint.check_nav_label("x.md", good)

    index = "---\ntitle: \"Sumerian Addenda\"\nshort_title: \"C SUX Addenda\"\n---\nbody"
    assert_empty Edubba::Lint.check_nav_label("x.md", index)
  end

  def test_chapter_titles_speak_plain_english
    bad = "---\ntitle: \"13 · anāku — I am he\"\nshort_title: \"13 · anāku\"\nchapter: 13\n---\nbody"
    v = Edubba::Lint.check_title_language("x.md", bad)
    assert_equal 2, v.size
    assert_equal ["title-language"], v.map(&:rule).uniq

    good = "---\ntitle: \"13 · I am he\"\nshort_title: \"13 · I am he\"\nchapter: 13\n---\nbody"
    assert_empty Edubba::Lint.check_title_language("x.md", good)

    index = "---\ntitle: \"anāku everywhere\"\n---\nbody"
    assert_empty Edubba::Lint.check_title_language("x.md", index),
                 "non-chapter pages (no chapter: key) are out of scope"
  end

  def test_nav_order_must_be_globally_unique
    Dir.mktmpdir do |dir|
      %w[a b].each do |s|
        FileUtils.mkdir_p(File.join(dir, s))
        File.write(File.join(dir, s, "index.md"),
                   "---\nnav_order: 10\ncourse_no: \"101\"\n---\n")
      end
      v = Edubba::Lint.nav_order_unique(dir)
      assert_equal 2, v.size
      assert_equal "nav-order-unique", v[0].rule

      File.write(File.join(dir, "b", "index.md"),
                 "---\nnav_order: 20\ncourse_no: \"101\"\n---\n")
      assert_empty Edubba::Lint.nav_order_unique(dir)
    end
  end

  def test_codex_reads_holds_readings_only
    path = "site/cuneiform/addenda-akk/signs/sza.md"
    bad = %(---\nreads: "[ša]; the particle ša"\n---\nbody)
    v = Edubba::Lint.check_codex_reads(path, bad)
    assert_equal 1, v.size
    assert_equal "codex-reads", v[0].rule

    ["[ša]", "[an], diŋir", "[ku], dab₅, tuš",
     "[zi] (fuller form zid)", "[wa/wi]", "[mātum]", "[šarrum]"].each do |ok|
      assert_empty Edubba::Lint.check_codex_reads(path, %(---\nreads: "#{ok}"\n---\n)),
                   "#{ok} should pass"
    end
    assert_empty Edubba::Lint.check_codex_reads("site/cuneiform/103/00-orientation.md", bad),
                 "rule scopes to codex shelves only"
  end

  def test_chapter_mentions_must_carry_links
    bad = "---\nchapter: 3\n---\nsee chapter 02 for the rule"
    v = Edubba::Lint.check_chapter_links("x.md", bad)
    assert_equal 1, v.size
    assert_equal "chapter-link", v[0].rule

    linked = %(---\nchapter: 3\n---\nsee <a href="/x/">chapter 02</a> and [chapter 04](/y/))
    assert_empty Edubba::Lint.check_chapter_links("x.md", linked)
    selfref = "---\nchapter: 3\n---\nthis chapter 03 speaks of itself"
    assert_empty Edubba::Lint.check_chapter_links("x.md", selfref)
    svg = "---\nchapter: 3\n---\n<svg><title>after chapter 06</title></svg>"
    assert_empty Edubba::Lint.check_chapter_links("x.md", svg)
  end

  def test_tail_fit_last_column_stays_short
    long = "x" * 61
    bad = <<~HTML
      <table class="sign-table sign-table--tail-fit">
        <tbody><tr><td>G</td><td>#{long}</td></tr></tbody>
      </table>
    HTML
    v = Edubba::Lint.check_tail_fit("x.md", bad)
    assert_equal 1, v.size
    assert_equal "tail-fit-width", v[0].rule

    liquid = <<~HTML
      <table class="sign-table sign-table--tail-fit">
        <tbody><tr><td>A</td><td>{% if ch %}<a href="{{ ch.url | relative_url }}">ch. 04</a>{% else %}ch. 04{% endif %}</td></tr></tbody>
      </table>
    HTML
    assert_empty Edubba::Lint.check_tail_fit("x.md", liquid),
                 "Liquid and tags are stripped before measuring"

    plain_table = "<table class=\"sign-table\"><tbody><tr><td>#{long}</td></tr></tbody></table>"
    assert_empty Edubba::Lint.check_tail_fit("x.md", plain_table),
                 "tables without tail-fit may wrap and are exempt"
  end

  def test_tail_fit_non_tail_cells_share_the_width_budget
    clause = "n- put in front, melting into the root"   # 38 chars
    five_col = <<~HTML
      <table class="sign-table sign-table--tail-fit">
        <thead><tr><th>a</th><th>b</th><th>c</th><th>d</th><th>e</th></tr></thead>
        <tbody><tr><td>N</td><td>#{clause}</td><td>x</td><td>y</td><td>short</td></tr></tbody>
      </table>
    HTML
    v = Edubba::Lint.check_tail_fit("x.md", five_col)
    assert_equal 1, v.size, "38 chars busts a 5-column budget (180/5 = 36)"
    assert_equal "tail-fit-width", v[0].rule

    three_col = <<~HTML
      <table class="sign-table sign-table--tail-fit">
        <thead><tr><th>a</th><th>b</th><th>c</th></tr></thead>
        <tbody><tr><td>N</td><td>#{clause}</td><td>short</td></tr></tbody>
      </table>
    HTML
    assert_empty Edubba::Lint.check_tail_fit("x.md", three_col),
                 "the same label fits a 3-column budget (180/3 = 60)"
  end

  def test_akk_translit_bans_indexes_and_lowercase_sumerograms
    path = "site/cuneiform/103/04-x.md"
    idx = %(<span class="translit">i₃-nu an</span>)
    v = Edubba::Lint.check_akk_translit(path, idx)
    assert_equal 1, v.size
    assert_equal "akk-translit", v[0].rule

    low = %(<span class="translit">lugal {d}a-nun-na-ki</span>)
    assert_equal 1, Edubba::Lint.check_akk_translit(path, low).size

    ok = %(<span class="translit">LUGAL {d}a-nun-na-ki i-nu</span>)
    assert_empty Edubba::Lint.check_akk_translit(path, ok)
    caps_name = %(<span class="translit">E₂-su i-tab-ba-al</span>)
    assert_empty Edubba::Lint.check_akk_translit(path, caps_name),
                 "a sumerogram NAME keeps its index (E₂)"
    assert_empty Edubba::Lint.check_akk_translit("site/cuneiform/102/01-x.md", idx),
                 "Sumerian courses keep their indexes"
  end

  # reading-logo (§9 voice-marking, ruled 2026-08-09): capitals in
  # an Akkadian reading transliteration live only inside logo
  # spans, script and translit marks pair per line, and the marking
  # is Akkadian-course-only.
  def test_reading_logo_requires_marked_capitals
    path = "site/cuneiform/103/16-x.md"
    line = ->(script, translit) do
      %(<div class="reading-line"><span class="script">#{script}</span>) +
        %(<span class="translit">#{translit}</span>) +
        %(<span class="gloss"><span class="norm">x</span> — "y"</span></div>)
    end
    logo = ->(s) { %(<span class="logo">#{s}</span>) }

    unmarked = line.call("𒋳𒈠 𒄊𒉻𒁺", "šum-ma GIR₃.PAD.RA₂")
    v = Edubba::Lint.check_logo_marking(path, unmarked)
    refute_empty v
    assert_equal "reading-logo", v[0].rule

    marked = line.call("𒋳𒈠 #{logo.call('𒄊𒉻𒁺')}",
                       "šum-ma #{logo.call('EṢEMTI')}")
    assert_empty Edubba::Lint.check_logo_marking(path, marked)

    frame = line.call(logo.call("𒉌𒇲𒂊"), logo.call("I₃.LA₂.E"))
    assert_empty Edubba::Lint.check_logo_marking(path, frame),
                 "a Sumerian frame stretch keeps its values, marked"
  end

  def test_reading_logo_pairs_script_and_translit_marks
    path = "site/cuneiform/103/16-x.md"
    lopsided = %(<div class="reading-line"><span class="script">𒄊𒉻𒁺𒋗</span>) +
               %(<span class="translit"><span class="logo">EṢEMTA</span>-šu</span></div>)
    v = Edubba::Lint.check_logo_marking(path, lopsided)
    assert_equal 1, v.size
    assert_match(/must pair/, v[0].detail)
  end

  def test_reading_logo_is_akkadian_course_only
    logo = %(<span class="logo">MĀTIM</span>)
    v = Edubba::Lint.check_logo_marking("site/cuneiform/102/01-x.md", logo)
    assert_equal 1, v.size
    assert_equal "reading-logo", v[0].rule
    assert_empty Edubba::Lint.check_logo_marking("site/hieroglyphs/101/01-x.md", logo),
                 "scope is the cuneiform school's rulebook"
  end

  # reading-width (§5, 2026-08-09): a three-column reading figure's
  # widest script line must fit the measured budget, or the figure
  # declares reading--stacked. Widths come from the committed
  # subset fonts, so the check measures what the reader sees.
  def test_reading_width_flags_over_budget_three_column_figures
    wide_line = "𒋳𒈠 " * 8   # ~15em of ŠUM alone — over any sane budget
    fig = ->(mods) do
      %(<figure class="reading reading--script#{mods}"><div class="reading-lines") +
        %(><div class="reading-line"><span class="script">#{wide_line}</span>) +
        %(<span class="translit">x</span><span class="gloss">y</span></div></div></figure>)
    end
    v = Edubba::Lint.check_reading_width("site/cuneiform/103/16-x.md", fig.call(""))
    assert_equal 1, v.size
    assert_equal "reading-width", v[0].rule
    assert_match(/reading--stacked/, v[0].detail)

    assert_empty Edubba::Lint.check_reading_width("site/cuneiform/103/16-x.md", fig.call(" reading--stacked")),
                 "a stacked figure stacks its voice under the script — no budget applies"

    narrow = fig.call("").sub(wide_line, "𒋳𒈠")
    assert_empty Edubba::Lint.check_reading_width("site/cuneiform/103/16-x.md", narrow)
  end

  def test_font_metrics_measure_real_advances
    han = Edubba::Lint.script_width_em("天大", :sinographs)
    assert_in_delta 2 * (1.9 / 1.4), han, 0.05,
                    "Han glyphs measure with sino metrics × the size-law scale"
    em = Edubba::Lint.script_width_em("𒋳𒈠")
    assert_operator em, :>, 1.5, "two real glyphs are wider than 1.5em"
    assert_operator em, :<, 6, "and narrower than 6em — sane advance range"
    assert_in_delta 0.4, Edubba::Lint.script_width_em(" "), 0.001,
                    "spaces render in the fallback font — estimated width"
  end

  # reading-cites (§9, 2026-08-09): a reading reads, it never
  # cites — the dot is sign-list filing punctuation.
  def test_reading_dots_flag_citation_compounds
    line = ->(t) { %(<div class="reading-line"><span class="script">𒆬</span><span class="translit">#{t}</span><span class="gloss">g</span></div>) }
    v = Edubba::Lint.check_reading_dots("site/cuneiform/103/17-x.md", line.call("KU₃.BABBAR ŠU BA.AN.TI"))
    assert_equal 1, v.size, "one violation per offending translit span"
    assert_equal "reading-cites", v[0].rule

    assert_empty Edubba::Lint.check_reading_dots("site/cuneiform/103/17-x.md",
                                                 line.call(%(<span class="logo">KASPAM</span> <span class="logo">ŠU BA-AN-TI</span>))),
                 "hyphenated values and spoken voices are readings"
    assert_empty Edubba::Lint.check_reading_dots("site/cuneiform/101/06-x.md", line.call("[...]")),
                 "editorial damage ellipsis is not a citation"
    assert_empty Edubba::Lint.check_reading_dots("site/hieroglyphs/102/01-x.md", line.call("msi̯.t")),
                 "Leiden morphology dots are another school's law"
  end

  def test_translit_span_sees_through_logo_spans
    nested = %(<span class="translit"><span class="logo">MAŠ2.BI</span> u₃</span>)
    hits = []
    nested.scan(Edubba::Lint::TRANSLIT_SPAN) do
      hits << Regexp.last_match[:body]
    end
    assert_equal 1, hits.size
    assert_match(/MAŠ2\.BI/, hits[0], "nested logo spans stay inside the translit body")
    assert hits[0][Edubba::Lint::ASCII_INDEX], "ASCII index inside a logo span is still caught"
  end
end
