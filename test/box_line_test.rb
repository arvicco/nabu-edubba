# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require_relative "../bin/box_line"

# M19-1: mechanical boxing. The unit half runs on tmpdir fixtures;
# the acceptance half re-derives three SHIPPED phase-18 readings from
# the real committed queue — byte-identical script spans, shares
# matching the lint's counting.
class BoxLineTest < Minitest::Test
  B = Edubba::BoxLine

  QUEUE_FIXTURE = <<~YAML
    signs:
    - {char: 人, chapter: 0}
    - {char: 大, chapter: 0}
    - {char: 天, chapter: 1}
    - {char: 之, chapter: 2}
  YAML

  FREQ_FIXTURE = <<~TSV
    # comment line
    rank\tchar\tcount\tdocs\tstrokes\tpinyin\tids
    1\t之\t18351733\t5090\t3\tzhī\t⿱丶
    2\t不\t8988592\t5096\t4\tbù\t⿸丆
    9999\t魚\t1\t1\t11\t\t魚
  TSV

  def with_fixtures
    Dir.mktmpdir do |dir|
      queue = File.join(dir, "queue.yml")
      freq = File.join(dir, "freq.tsv")
      File.write(queue, QUEUE_FIXTURE)
      File.write(freq, FREQ_FIXTURE)
      yield queue, freq
    end
  end

  def test_boxing_replaces_untaught_han_and_keeps_the_rest
    with_fixtures do |queue, _|
      taught = B.taught_set(queue, 1)
      assert_equal "人▢天大，▢。", B.box("人不天大，之。", taught),
                   "untaught Han → ▢ (之 is chapter 2, beyond --chapter 1); " \
                   "taught characters and punctuation pass through verbatim"
    end
  end

  def test_taught_set_is_cumulative_through_the_chapter
    with_fixtures do |queue, _|
      assert_equal %w[人 大].to_set, B.taught_set(queue, 0)
      assert_equal %w[人 大 天 之].to_set, B.taught_set(queue, 2)
    end
  end

  def test_share_counts_like_the_lint_punctuation_outside
    s = B.share("人▢，大▢。")
    assert_equal 2, s[:boxes]
    assert_equal 2, s[:han], "punctuation is not Han — excluded from the denominator"
    assert_in_delta 50.0, s[:share], 0.001
    assert_nil B.share("，。"), "no countable text — no share"
  end

  def test_cap_law_values
    assert_equal 50, B.cap_for(0)
    assert_equal 50, B.cap_for(4)
    assert_equal 45, B.cap_for(5)
    assert_equal 40, B.cap_for(10)
    assert_equal 40, B.cap_for(14)
    assert_equal 25, B.cap_for(30), "the cap floors at 25"
  end

  def test_the_cap_boundary_on_the_cap_passes_over_it_fails
    assert_equal "PASS", B.verdict(40.0, 40), "exactly on the cap is legal"
    assert_equal "OVER", B.verdict(40.1, 40)
  end

  def test_untaught_list_dedupes_and_reads_pinyin_from_the_freq_table
    with_fixtures do |queue, freq|
      taught = B.taught_set(queue, 0)
      assert_equal %w[不 不 魚].uniq, B.untaught("人不不魚。", taught)
      pinyin = B.pinyin_table(freq)
      assert_equal "bù", pinyin["不"]
      assert_nil pinyin["魚"], "beyond the Unihan rows the pinyin column is empty"
    end
  end

  def test_skeleton_is_the_shipped_reading_line_shape
    assert_equal '    <div class="reading-line"><span class="script">人▢。</span>' \
                 '<span class="translit pinyin">TODO</span>' \
                 '<span class="gloss">"TODO" — TODO</span></div>',
                 B.skeleton("人▢。")
  end

  # --- acceptance: re-derive three shipped phase-18 readings from the
  # --- real queue (frozen contract — chapters of shipped characters
  # --- never move).

  REAL_QUEUE = File.expand_path("../site/_data/sinographs101_queue.yml", __dir__)

  def real_taught(chapter) = B.taught_set(REAL_QUEUE, chapter)

  def test_rederives_laozi_42_as_shipped_in_ch12
    boxed = B.box("道生一，一生二，二生三，三生萬物。", real_taught(12))
    assert_equal "道生一，一生二，二生三，三生▢▢。", boxed
    assert_in_delta 100.0 * 2 / 13, B.share(boxed)[:share], 0.001,
                    "2 boxes over 11 taught characters — punctuation outside"
  end

  def test_rederives_analects_620_as_shipped_in_ch13
    boxed = B.box("好之者不如樂之者。", real_taught(13))
    assert_equal "好之者不如▢之者。", boxed
  end

  def test_rederives_the_daxue_leveling_line_as_shipped_in_ch14
    boxed = B.box("其所厚者薄，而其所薄者厚，", real_taught(14))
    assert_equal "其所▢者▢，而其所▢者▢，", boxed
    s = B.share(boxed)
    assert_in_delta 100.0 * 4 / 11, s[:share], 0.001
    assert_equal "PASS", B.verdict(s[:share], B.cap_for(14))
  end
end
