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

  def test_codex_reads_holds_readings_only
    path = "site/cuneiform/addenda-akk/signs/sza.md"
    bad = %(---\nreads: "[ša]; the particle ša"\n---\nbody)
    v = Edubba::Lint.check_codex_reads(path, bad)
    assert_equal 1, v.size
    assert_equal "codex-reads", v[0].rule

    ["[ša]", "[an], diŋir", "[ku], dab₅, tuš",
     "[zi] (fuller form zid)", "[wa/wi]"].each do |ok|
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
end
