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
end
