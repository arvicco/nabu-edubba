# frozen_string_literal: true

require "minitest/autorun"
require_relative "../script/rulebook"

class RulebookTest < Minitest::Test
  CUNEIFORM = Edubba::Rulebook::RULEBOOKS.find { |r| r[:scope].start_with?("cuneiform") }
  HIERO = Edubba::Rulebook::RULEBOOKS.find { |r| r[:scope].start_with?("hieroglyphs") }

  def test_forbidden_g_tilde_flags_outside_the_primer
    details = Edubba::Rulebook.check_text("the word niĝ₂ appears", "cuneiform/102/09-x.md", CUNEIFORM)
    assert_equal 1, details.size
    assert_match(/never ĝ/, details[0])
  end

  def test_primer_may_mention_the_alternative_notations
    text = "books print it ĝ; older habit writes ì"
    assert_empty Edubba::Rulebook.check_text(text, "cuneiform/102/00-orientation.md", CUNEIFORM)
  end

  def test_accent_indexes_flag
    details = Edubba::Rulebook.check_text("its other value, ì, oil", "cuneiform/102/08-x.md", CUNEIFORM)
    assert_match(/accent index/, details[0])
  end

  def test_accent_e_flags_but_the_school_name_is_exempt
    details = Edubba::Rulebook.check_text("write *é-gal* now", "cuneiform/101/07-x.md", CUNEIFORM)
    assert_equal 1, details.size
    assert_match(/use e₂/, details[0])
    assert_empty Edubba::Rulebook.check_text("the é-dub-ba-a, the tablet house", "cuneiform/102/16-x.md", CUNEIFORM)
  end

  def test_etcsl_quote_requires_noncommercial_label
    bare = "<code>urn:nabu:etcsl:2.1.7:958</code>"
    assert_match(/non-commercial/, Edubba::Rulebook.check_text(bare, "cuneiform/102/11-x.md", CUNEIFORM)[0])
    labeled = bare + " · license: ETCSL ·\n    non-commercial"
    assert_empty Edubba::Rulebook.check_text(labeled, "cuneiform/102/11-x.md", CUNEIFORM)
  end

  def test_cdli_and_aes_require_attribution_label
    assert_match(/attribution/, Edubba::Rulebook.check_text("urn:nabu:cdli:p1", "cuneiform/101/04-x.md", CUNEIFORM)[0])
    assert_empty Edubba::Rulebook.check_text("urn:nabu:cdli:p1 · license: attribution", "cuneiform/101/04-x.md", CUNEIFORM)
    assert_match(/attribution/, Edubba::Rulebook.check_text("urn:nabu:aes:x", "hieroglyphs/101/05-x.md", HIERO)[0])
    assert_empty Edubba::Rulebook.check_text("urn:nabu:aes:x · license: attribution", "hieroglyphs/101/05-x.md", HIERO)
  end

  def test_every_rulebook_cites_an_existing_doc
    Edubba::Rulebook::RULEBOOKS.each do |rb|
      assert File.exist?(File.expand_path("../#{rb[:doc]}", __dir__)),
             "#{rb[:doc]} missing — the docs are the source of truth"
    end
  end
end
