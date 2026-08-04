# frozen_string_literal: true

require "minitest/autorun"
require "yaml"

# A sign is TAUGHT exactly once across its whole school (owner ruling
# 2026-07-31 — no double-entries; later appearances are veterans or
# shows:). This guards the front-matter layer: no glyph may appear in
# two chapters' teaches: lists anywhere in a school. Found necessary
# on 2026-08-04, when BA turned out to be taught in full both in
# C101 ch09 and C102 ch08.
class TaughtOnceTest < Minitest::Test
  SITE = File.expand_path("../site", __dir__)

  %w[cuneiform hieroglyphs].each do |school|
    define_method("test_#{school}_teaches_each_sign_once") do
      seats = Hash.new { |h, k| h[k] = [] }
      Dir.glob(File.join(SITE, school, "**", "*.md")).sort.each do |path|
        text = File.read(path, encoding: "UTF-8")
        next unless text.start_with?("---\n")

        front = YAML.safe_load(text.split(/^---\s*$/)[1])
        Array(front["teaches"]).each { |g| seats[g] << path.sub("#{SITE}/", "") }
      end
      dupes = seats.select { |_, v| v.size > 1 }
      assert_empty dupes.map { |g, v| "#{g} taught in #{v.join(' AND ')}" },
                   "signs with more than one teaching seat"
    end
  end
end
