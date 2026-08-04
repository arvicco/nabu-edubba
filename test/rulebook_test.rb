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

  # --- Sign Codex (cuneiform.md §7 / hieroglyphs.md §9) ---

  CODEX_ON = { doc: "docs/courses/cuneiform.md §7",
               shelf: "cuneiform/addenda/signs",
               keywords: true, pages: true }.freeze

  def test_sign_slug_exact_values
    { "AŠ" => "asz", "GAL" => "gal", "É" => "e2", "KA×A" => "kaxa",
      "ŠA3" => "sza3", "EŠ2" => "esz2", "LU2" => "lu2", "N35A" => "n35a" }.each do |name, slug|
      assert_equal slug, Edubba::Rulebook.sign_slug(name)
    end
  end

  def test_codex_flags_duplicate_keywords_even_before_activation
    signs = [{ "name" => "GAL", "taught_in" => 6, "keyword" => "big" },
             { "name" => "MAH", "chapter" => 3, "keyword" => "big" }]
    details = Edubba::Rulebook.check_codex(signs, [], CODEX_ON.merge(keywords: false, pages: false))
    assert_equal 1, details.size
    assert_match(/"big" on more than one sign/, details[0])
  end

  def test_codex_requires_keywords_on_taught_signs_only
    signs = [{ "name" => "GAL", "taught_in" => 6 },
             { "name" => "MI", "chapter" => nil }]   # unpinned pool sign — exempt
    details = Edubba::Rulebook.check_codex(signs, [], CODEX_ON.merge(pages: false))
    assert_equal 1, details.size
    assert_match(/GAL has no keyword/, details[0])
  end

  def test_codex_requires_a_page_per_taught_sign_and_flags_orphans
    signs = [{ "name" => "GAL", "taught_in" => 6, "keyword" => "big" },
             { "name" => "É", "chapter" => 7, "keyword" => "house" }]
    details = Edubba::Rulebook.check_codex(signs, ["gal", "ee2"], CODEX_ON)
    assert_equal 2, details.size
    assert_match(/ee2\.md matches no taught sign/, details[0])
    assert_match(/É has no codex page e2\.md/, details[1])
  end

  def test_codex_orphan_pages_flag_even_before_activation
    signs = [{ "name" => "GAL", "taught_in" => 6 }]
    details = Edubba::Rulebook.check_codex(signs, ["gall"], CODEX_ON.merge(keywords: false, pages: false))
    assert_equal 1, details.size
    assert_match(/gall\.md matches no taught sign/, details[0])
  end

  def test_codex_gardiner_identity_wins_and_live_config_is_quiet_today
    signs = [{ "gardiner" => "G1", "name" => "G1", "taught_in" => 4, "keyword" => "vulture" }]
    assert_empty Edubba::Rulebook.check_codex(signs, ["g1"], CODEX_ON)
    site = File.expand_path("../site", __dir__)
    assert_empty Edubba::Rulebook.codex_violations(site),
                 "live registries/shelves must satisfy the codex config as flagged"
  end
end
