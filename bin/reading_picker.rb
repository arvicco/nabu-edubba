# frozen_string_literal: true

# Reading picker (M3-4): the taught-signs validator's logic inverted
# into a search. Streams nabu's jsonl export and keeps passages whose
# every value lies inside the cumulative 102 inventory (101 signs +
# the compiler's queue), so graded readings in FULL script can be
# found instead of composed. License classes are reported per source;
# nc sources are flagged, never silently included (plan rule).
#
# Usage: ruby bin/reading_picker.rb [chapter]   (default: 5 = full queue)

require "yaml"
require "json"

NABU = ENV.fetch("NABU_BIN", "/Users/vb/Dev/nabu/bin/nabu")
NABU_DIR = File.expand_path("..", File.dirname(NABU))
SOURCES = { "cdli" => "attribution", "etcsl" => "nc (DECISION ITEM before use)" }.freeze

chapter_cap = (ARGV[0] || 5).to_i

taught = YAML.safe_load_file("site/_data/sign_teaching.yml")["signs"]
             .map { |s| s["value"][/[a-zŋš']+[0-9]*/] }
queue = YAML.safe_load_file("site/_data/cuneiform102_queue.yml")["signs"]
            .select { |s| s["chapter"] && s["chapter"] <= chapter_cap }
            .map { |s| s["value"] }
inventory = (taught + queue + %w[sz disz asz sze szul]).to_set
# etcsl-convention variants
inventory += inventory.map { |v| v.tr("c", "sz") }.to_set
inventory += %w[ce ce3 caj saj]

VALUE_RE = /\A[a-z']+[0-9]*\z/

def values_ok?(norm, inventory)
  vals = norm.split
  return false if vals.size < 3 || vals.size > 9
  vals.all? { |v| VALUE_RE.match?(v) && inventory.include?(v) }
end

SOURCES.each_key do |source|
  puts "## #{source} (license: #{SOURCES[source]})"
  count = 0
  IO.popen([NABU, "export", "--format=jsonl", "--lang=sux", "--source=#{source}"],
           err: File::NULL, chdir: NABU_DIR) do |io|
    io.each_line do |line|
      rec = JSON.parse(line)
      next unless values_ok?(rec["text_normalized"].to_s.strip, inventory)
      glosses = (rec.dig("annotations", "tokens") || []).map { |t| t["label"] }.compact
      puts "#{rec['urn']}  |  #{rec['text']}  |  #{glosses.join(' / ')}"
      count += 1
      break if count >= 40
    end
  end
  puts
end
