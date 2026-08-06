# frozen_string_literal: true

# Contract test for the glossary data (owner report 2026-08-06: a
# duplicate "syllabogram" entry shipped unnoticed — nothing was
# checking term uniqueness). Terms are a site/_data contract: every
# name and slug appears exactly once, every entry carries a
# one-sentence def, and a school scope (when present) names a real
# glossary page key.

require "minitest/autorun"
require "yaml"

class TermsContractTest < Minitest::Test
  TERMS = YAML.load_file(File.expand_path("../site/_data/terms.yml", __dir__))["terms"]
  SCHOOLS = ["hieroglyphs", "akk", nil].freeze

  def test_names_are_unique_case_insensitively
    dupes = TERMS.map { |t| t["name"].downcase }.tally.select { |_, c| c > 1 }
    assert_empty dupes, "duplicate term names: #{dupes.keys.join(', ')}"
  end

  def test_slugs_are_unique
    dupes = TERMS.map { |t| t["slug"] }.tally.select { |_, c| c > 1 }
    assert_empty dupes, "duplicate term slugs: #{dupes.keys.join(', ')}"
  end

  def test_every_entry_has_name_slug_and_def
    TERMS.each do |t|
      %w[name slug def].each do |k|
        refute t[k].to_s.strip.empty?, "term #{t.inspect} missing #{k}"
      end
    end
  end

  def test_school_scopes_name_known_glossaries
    TERMS.each do |t|
      assert_includes SCHOOLS, t["school"],
                      "term #{t['name']} scopes unknown glossary #{t['school'].inspect}"
    end
  end
end
