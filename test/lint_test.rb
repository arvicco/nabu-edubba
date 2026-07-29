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
      offenses = Edubba::Lint.violations(dir, File.join(dir, "missing-manifest.txt"))
      assert_includes offenses.map(&:rule), "font-coverage"
      assert_match(/U\+12000/, offenses.find { |v| v.rule == "font-coverage" }.detail)
    end
  end

  def test_cuneiform_covered_by_manifest_is_clean
    with_site("index.md" => CUNEIFORM_PAGE, "coverage.txt" => "# comment\n12000\n") do |dir|
      assert_empty Edubba::Lint.violations(dir, File.join(dir, "coverage.txt"))
    end
  end

  def test_scanner_finds_codepoints_and_ignores_non_cuneiform
    with_site("index.md" => CUNEIFORM_PAGE) do |dir|
      assert_equal Set[0x12000], Edubba::CuneiformScan.used_codepoints(dir)
    end
  end
end
