# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require "fileutils"
require_relative "../script/course_check"

class CourseCheckTest < Minitest::Test
  # 𒀭 U+1202D, 𒆠 U+121A0, 𒈗 U+12217
  AN = "\u{1202D}"
  KI = "\u{121A0}"
  LUGAL = "\u{12217}"

  def with_course(chapters)
    Dir.mktmpdir do |dir|
      course = File.join(dir, "cuneiform", "101")
      FileUtils.mkdir_p(course)
      chapters.each { |name, content| File.write(File.join(course, name), content) }
      yield dir
    end
  end

  def chapter(n, teaches: [], shows: [], body: "")
    fm = { "layout" => "chapter", "chapter" => n,
           "teaches" => teaches, "shows" => shows }
    "---\n#{YAML.dump(fm).sub(/\A---\n/, '')}---\n\n#{body}\n"
  end

  def test_signs_taught_in_earlier_chapter_are_allowed
    with_course(
      "00-a.md" => chapter(0, teaches: [AN]),
      "01-b.md" => chapter(1, teaches: [KI], body: "Recall #{AN}, meet #{KI}.")
    ) do |dir|
      assert_empty Edubba::CourseCheck.violations(dir)
    end
  end

  def test_untaught_sign_is_flagged_with_codepoint
    with_course("00-a.md" => chapter(0, teaches: [AN], body: "#{AN} and #{LUGAL}")) do |dir|
      offenses = Edubba::CourseCheck.violations(dir)
      assert_equal ["untaught-sign"], offenses.map(&:rule).uniq
      assert_match(/U\+12217/, offenses.first.detail)
    end
  end

  def test_later_chapter_cannot_use_signs_from_the_future
    with_course(
      "00-a.md" => chapter(0, teaches: [AN], body: LUGAL.to_s),
      "01-b.md" => chapter(1, teaches: [LUGAL])
    ) do |dir|
      offenses = Edubba::CourseCheck.violations(dir)
      assert_equal 1, offenses.size
      assert_match(/00-a\.md/, offenses.first.file)
    end
  end

  def test_shows_allows_display_only_exhibits_in_that_chapter_only
    with_course(
      "00-a.md" => chapter(0, teaches: [AN], shows: [LUGAL], body: "Exhibit: #{LUGAL}"),
      "01-b.md" => chapter(1, body: "Sneaky #{LUGAL}")
    ) do |dir|
      offenses = Edubba::CourseCheck.violations(dir)
      assert_equal 1, offenses.size
      assert_match(/01-b\.md/, offenses.first.file)
    end
  end

  def test_course_index_without_chapter_key_is_exempt
    with_course("index.md" => "---\ntitle: TOC\n---\n\nPreview #{LUGAL}\n") do |dir|
      assert_empty Edubba::CourseCheck.violations(dir)
    end
  end
end

class CourseAssumesTest < Minitest::Test
  AN = "\u{1202D}"
  LUGAL = "\u{12217}"

  def test_assumes_inherits_prerequisite_inventory
    Dir.mktmpdir do |dir|
      c101 = File.join(dir, "cuneiform", "101")
      c102 = File.join(dir, "cuneiform", "102")
      FileUtils.mkdir_p(c101); FileUtils.mkdir_p(c102)
      File.write(File.join(c101, "00-a.md"),
                 "---\nchapter: 0\nteaches: [\"#{AN}\"]\n---\nbody\n")
      File.write(File.join(c102, "index.md"),
                 "---\ntitle: T\nassumes: cuneiform/101\n---\ntoc\n")
      File.write(File.join(c102, "00-b.md"),
                 "---\nchapter: 0\nteaches: [\"#{LUGAL}\"]\n---\nUses #{AN} and #{LUGAL}\n")
      assert_empty Edubba::CourseCheck.violations(dir)
      # without assumes it would flag AN:
      File.write(File.join(c102, "index.md"), "---\ntitle: T\n---\ntoc\n")
      refute_empty Edubba::CourseCheck.violations(dir)
    end
  end
end
