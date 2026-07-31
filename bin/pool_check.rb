# frozen_string_literal: true

# Pool identity check (M5-1, carried forward post-P53). Cross-checks
# every entry of a curated sign pool — value → sign name → codepoint —
# against the Oracc Sign List through `nabu signs --json` (the frozen
# P53-2 contract). The sign desk supplies IDENTITY only; curation
# (meanings, wedge counts, certainty grades, chapter pins) stays in
# the pool and is never touched here.
#
# One value per input line keeps matching positional: line N of the
# contract answers pool entry N — no reversing of C-ATF folds needed.
#
# Usage: ruby bin/pool_check.rb [pool.yml]   (default assets-src/data/pool-102.yml)
# Exit 1 on any identity mismatch; authoring-time gate for pool edits.

require "yaml"
require "json"

module Edubba
  module PoolCheck
    module_function

    # "EŠ₂" <-> "EŠ2": OSL names carry subscript indexes, pool names ASCII.
    def norm_name(name) = name.to_s.upcase.tr("₀₁₂₃₄₅₆₇₈₉", "0123456789")

    def norm_cp(cp) = cp.to_s.sub(/\AU\+/, "").upcase

    # First token of contract line N answers pool entry N. The
    # codepoint is the identity anchor — sign-list NAMES legitimately
    # differ (Unicode/Labat "NIN" vs OSL compound "|SAL.TUG₂|"), so a
    # name difference over a confirmed codepoint is a NOTE, silenced
    # by recording the OSL's convention in an `osl_name:` field.
    # Returns [problems, notes] — problems are fatal.
    def check_entry(entry, token)
      return [["#{entry['value']}: no token resolved"], []] unless token
      case token["status"]
      when "deterministic", "qualified", "no-codepoint"
        check_resolved(entry, token)
      when "ambiguous"
        cands = token["candidates"] || []
        hit = cands.find { |c| check_resolved(entry, c)[0].empty? }
        if hit
          [[], check_resolved(entry, hit)[1]]
        else
          [["#{entry['value']}: ambiguous — pool codepoint #{entry['codepoint']} " \
            "not among OSL candidates #{cands.map { |c| c['sign_name'] }.join('/')}"], []]
        end
      else
        [["#{entry['value']}: OSL status #{token['status']}"], []]
      end
    end

    def check_resolved(entry, token)
      cps = (token["codepoints"] || []).map { |c| norm_cp(c) }
      unless cps.include?(norm_cp(entry["codepoint"]))
        return [["#{entry['value']}: pool codepoint #{entry['codepoint']} not in OSL #{cps.join('+')}"], []]
      end
      known = [entry["name"], entry["osl_name"]].compact.map { |n| norm_name(n) }
      if known.include?(norm_name(token["sign_name"]))
        [[], []]
      else
        [[], ["#{entry['value']}: codepoint confirmed; OSL names it #{token['sign_name']} " \
              "(pool: #{entry['name']} — record osl_name: to acknowledge)"]]
      end
    end

    def check_pool(pool_signs, contract_json)
      lines = JSON.parse(contract_json)["lines"]
      problems = []
      notes = []
      pool_signs.each_with_index do |entry, i|
        p, n = check_entry(entry, lines[i] && lines[i]["tokens"] && lines[i]["tokens"][0])
        problems.concat(p)
        notes.concat(n)
      end
      [problems, notes]
    end
  end
end

if $PROGRAM_NAME == __FILE__
  nabu = ENV.fetch("NABU_BIN", "/Users/vb/Dev/nabu/bin/nabu")
  abort "pool_check: #{nabu} not found" unless File.executable?(nabu)
  pool_file = ARGV[0] || "assets-src/data/pool-102.yml"
  signs = YAML.safe_load_file(pool_file)["signs"]

  text = signs.map { |s| s["value"] }.join("\n")
  json = IO.popen([nabu, "signs", "--json", "--lang=sux", text],
                  err: File::NULL, chdir: File.expand_path("..", File.dirname(nabu)), &:read)
  abort "pool_check: nabu signs returned nothing" if json.to_s.strip.empty?

  problems, notes = Edubba::PoolCheck.check_pool(signs, json)
  notes.each { |n| puts "pool_check: note — #{n}" }
  if problems.empty?
    puts "pool_check: #{signs.size} entries — every value→codepoint identity confirmed by the OSL"
  else
    problems.each { |p| warn "pool_check: MISMATCH — #{p}" }
    abort "pool_check: #{problems.size} identity problem(s) in #{pool_file}"
  end
end
