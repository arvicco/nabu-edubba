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

  CLEAN_PAGE = "---\ntitle: Test\n---\n\nWedge [basics](/cuneiform/).\n"

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
end
