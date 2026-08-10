# frozen_string_literal: true

require "minitest/autorun"
require_relative "../script/value_check"

# value-coverage (§9, owner report 2026-08-09): a reading may only
# speak values taught, by that chapter, for signs present in the
# line — glyph coverage alone let a-wi-lim ride the eye-sign as an
# untaught lim for eight chapters.
class ValueCheckTest < Minitest::Test
  # 𒅆 teaches ši at ch3, lim deferred to ch10 (value_seats).
  TAUGHT = { "szi" => { "𒅆" => 3 }, "lim" => { "𒅆" => 10 },
             "a" => { "𒀀" => 0 }, "wi" => { "𒉿" => 0 } }.freeze

  def line(script, translit, chapter: 11)
    text = <<~MD
      ---
      chapter: #{chapter}
      ---
      <div class="reading-line"><span class="script">#{script}</span><span class="translit">#{translit}</span><span class="gloss">g</span></div>
    MD
    Edubba::ValueCheck.check_text("site/cuneiform/103/99-x.md", text, chapter, TAUGHT)
  end

  def test_taught_value_passes
    assert_empty line("𒀀𒉿𒅆", "a-wi-lim", chapter: 11)
  end

  def test_value_before_its_seat_fails
    v = line("𒀀𒉿𒅆", "a-wi-lim", chapter: 4)
    assert_equal 1, v.size
    assert_equal "value-coverage", v[0].rule
    assert_match(/teaches it only at ch10/, v[0].detail)
  end

  def test_value_taught_for_no_present_sign_fails
    v = line("𒀀𒉿", "a-wi-lim", chapter: 11)
    assert_match(/no sign in this line/, v[0].detail)
  end

  def test_box_pardons_the_untaught_sign_it_stands_for
    assert_empty line("𒀀𒉿▢", "a-wi-lam", chapter: 11),
                 "▢ is the honest device — its word is still spoken"
  end

  def test_logo_stretches_and_determinatives_are_out_of_scope
    marked = %(𒀭<span class="logo">𒀀𒇉</span>)
    assert_empty line(marked, %({d}<span class="logo">ID</span>), chapter: 11)
  end

  # A rebus writing (signs that do not spell their sound: 𒂗𒍪 read
  # Suen) wears the green voice-mark and is logogram territory —
  # out of this check's scope; its syllabic tail is still checked.
  def test_rebus_writings_are_marked_logograms
    text = %(<div class="reading-line"><span class="script">𒀭<span class="logo">𒂗𒍪</span>𒄿𒈪𒋾</span><span class="translit">{d}<span class="logo">SUEN</span>-i-mi-ti</span><span class="gloss">g</span></div>)
    taught = { "i" => { "𒄿" => 0 }, "mi" => { "𒈪" => 0 }, "ti" => { "𒋾" => 0 } }
    assert_empty Edubba::ValueCheck.check_text("x.md", text, 17, taught)
    v = Edubba::ValueCheck.check_text("x.md", text, 17, { "i" => { "𒄿" => 0 } })
    refute_empty v, "the name's syllabic tail is still value-checked"
  end

  def test_matching_is_index_blind
    # registry su₂ folded to su matches the display token su
    taught = { "su" => { "𒍪" => 10 } }
    text = %(<div class="reading-line"><span class="script">𒍪</span><span class="translit">su</span><span class="gloss">g</span></div>)
    assert_empty Edubba::ValueCheck.check_text("x.md", text, 10, taught)
  end

  def test_registry_parsing_keeps_emphatic_ascii_whole
    assert_equal ["as", "az", "as,"], Edubba::ValueCheck.ascii_values("as, az, as,")
    assert_equal ["s,i", "s,e"], Edubba::ValueCheck.ascii_values("s,i, s,e")
    assert_equal ["pi"], Edubba::ValueCheck.ascii_values("pi2")
  end

  # ambient-veteran guard (§9): a veteran row must gain a value not
  # already in the sign's Sumerian inventory.
  def test_ambient_veterans_may_not_reenter_the_queue
    require "tmpdir"
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "cuneiform102_queue.yml"),
                 { "signs" => [{ "glyph" => "𒆠", "value" => "ki" }] }.to_yaml)
      File.write(File.join(dir, "cuneiform103_queue.yml"),
                 { "signs" => [
                   { "glyph" => "𒆠", "name" => "KI", "value" => "ki", "veteran" => true, "chapter" => 17 },
                   { "glyph" => "𒆠", "name" => "KI2", "value" => "ki, qi2", "veteran" => true, "chapter" => 12 }
                 ] }.to_yaml)
      v = Edubba::ValueCheck.registry_violations(dir)
      assert_equal 1, v.size
      assert_match(/gains NOTHING/, v[0].detail)
      assert_match(/\AKI /, v[0].detail, "the qi2-gaining row passes; the unchanged row fails")
    end
  end

  def test_live_site_carries_no_untracked_debt
    site = File.expand_path("../site", __dir__)
    v = Edubba::ValueCheck.violations(site)
    assert_empty v.map { |x| "#{x.file}: #{x.detail}" },
                 "a reading speaks an untaught value — teach it or (owner-ruled) record it in KNOWN_DEBT"
  end
end
