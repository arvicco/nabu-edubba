# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

# The committed deck exports are a redistributable contract
# (rulebook cuneiform.md §8): tab-separated three-field cards, one
# per taught sign, every quoted line attribution-licensed, ETCSL
# absent entirely.
class DeckContractTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  DECKS = {
    "edubba-cuneiform-101" => ["site/_data/sign_teaching.yml", "taught_in"],
    "edubba-cuneiform-102" => ["site/_data/cuneiform102_queue.yml", "chapter"],
    "edubba-hieroglyphs-101" => ["site/_data/hiero_teaching.yml", "taught_in"],
    "edubba-hieroglyphs-102" => ["site/_data/hieroglyphs102_queue.yml", "chapter"]
  }.freeze

  DECKS.each do |deck, (registry, seat)|
    define_method("test_#{deck.tr('-', '_')}") do
      path = File.join(ROOT, "site/assets/decks/#{deck}.txt")
      assert File.exist?(path), "#{deck}.txt missing — run bin/deck_export.rb"
      rows = File.readlines(path, chomp: true).reject { |l| l.start_with?("#") || l.empty? }
      taught = YAML.safe_load_file(File.join(ROOT, registry))["signs"].count { |s| s[seat] }
      assert_equal taught, rows.size, "one card per taught sign"
      rows.each do |row|
        cols = row.split("\t")
        assert_equal 3, cols.size, "front/back/tags: #{row[0, 40]}"
        refute_includes row, "urn:nabu:etcsl", "ETCSL is not redistributable"
        if row.include?("urn:nabu")
          assert_includes row, "license: attribution", "quoted lines carry their license: #{row[0, 40]}"
        end
      end
    end
  end
end
