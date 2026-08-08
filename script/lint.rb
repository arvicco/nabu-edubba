# frozen_string_literal: true

require_relative "script_scan"
require_relative "course_check"
require_relative "rulebook"

# Conventions scan over site/ sources (the lint half of `rake gate`).
# Rules (see CLAUDE.md):
#   no-js         wave 1 is text-pure — no <script> tags, no .js assets
#   front-matter  every Markdown page starts with front matter ("---")
#   relative-links internal links never hard-code the production origin
#   base-relative internal links go through Liquid's relative_url, never
#                 root-absolute href="/x" or ](/x) — the site must work
#                 at any base path (github.io/nabu-edubba AND edubba.ac)
#   font-coverage every tracked-script codepoint (cuneiform,
#                 hieroglyphs — script/script_scan.rb) used in site/ is
#                 covered by that script's committed font subset
#                 manifest (no tofu ships)
#   untaught-sign a course chapter uses only signs taught in chapters
#                 <= its own (front-matter teaches:) plus its own
#                 shows: exhibits (script/course_check.rb)
#   subscript-index transliteration display uses Unicode subscript
#                 index digits (lu₂, e₂), never full-size ASCII (lu2)
#                 — owner stylistic ruling 2026-07-30. Applies to
#                 <span class="translit"> content; spans additionally
#                 classed "atf" are exempt (verbatim raw-ATF exhibits)
#   tail-fit-width a sign-table--tail-fit table pins its last
#                 column to one unwrapped line (style.css), so
#                 cells there stay <= 60 chars of rendered text —
#                 commentary belongs in prose, never in cells (§5)
#   rulebook      course content obeys its school's rulebook
#                 (docs/courses/<school>.md — the single source of
#                 truth for conventions; script/rulebook.rb
#                 implements the machine-checkable subset)
#
# Usage: ruby script/lint.rb [SITE_DIR]   (exit 1 + report on violations)

module Edubba
  module Lint
    PROD_ORIGIN = %r{https?://(www\.)?edubba\.ac}i
    SCRIPT_TAG = /<script\b/i
    ROOT_ABSOLUTE_LINK = %r{(?:href="|\]\()/(?![/)])}

    TRANSLIT_SPAN = %r{<span class="translit(?<extra>[^"]*)">(?<body>.*?)</span>}m
    ASCII_INDEX = /[A-Za-zŠšŊŋĜĝḪḫŘř]\d/

    Violation = Struct.new(:file, :rule, :detail)

    module_function

    # manifests: optional {script_name => manifest_path} overrides
    # (tests point them at fixture files).
    def violations(site_dir, manifests = {})
      sources(site_dir).flat_map { |path| check_file(site_dir, path) } +
        js_assets(site_dir) +
        font_coverage(site_dir, manifests) +
        nav_order_unique(site_dir) +
        CourseCheck.violations(site_dir) +
        Rulebook.violations(site_dir) +
        Rulebook.codex_violations(site_dir)
    end

    # nav-order-unique (live-site incident 2026-08-06): the sidebar
    # sorts courses by nav_order and derives school order from first
    # appearance. Liquid's sort is stable, so a TIE falls back to
    # Jekyll's filesystem enumeration — cuneiform-first on macOS,
    # hash-order on CI's Linux, where hieroglyphs jumped the queue on
    # the deployed site. Ordering must never depend on the OS:
    # nav_order is globally unique across the site.
    def nav_order_unique(site_dir)
      require "yaml"
      orders = Dir.glob(File.join(site_dir, "**", "index.md")).filter_map do |path|
        text = File.read(path, encoding: "UTF-8")
        next unless text.start_with?("---\n") && (fm_end = text.index("\n---", 4))

        fm = YAML.safe_load(text[4..fm_end]) rescue nil
        [path, fm["nav_order"]] if fm.is_a?(Hash) && fm["nav_order"]
      end
      orders.group_by { |_, n| n }.select { |_, g| g.size > 1 }.flat_map do |n, group|
        group.map do |path, _|
          Violation.new(path, "nav-order-unique",
                        "nav_order #{n} is shared by #{group.size} pages — ties resolve by " \
                        "filesystem order, which differs between macOS and CI; make it unique")
        end
      end
    end

    def font_coverage(site_dir, manifests = {})
      ScriptScan::SCRIPTS.flat_map do |name, script|
        used = ScriptScan.used_codepoints(site_dir, script[:range])
        next [] if used.empty?

        manifest_path = manifests[name] || script[:manifest]
        covered = ScriptScan.manifest_codepoints(manifest_path)
        (used - covered).sort.map do |cp|
          Violation.new(manifest_path, "font-coverage",
                        "U+#{ScriptScan.format_codepoint(cp)} (#{name}) used in site/ but not in font subset — run `rake fonts`")
        end
      end
    end

    def sources(site_dir)
      Dir.glob(File.join(site_dir, "**", "*.{md,html}"))
    end

    def js_assets(site_dir)
      Dir.glob(File.join(site_dir, "**", "*.js")).map do |path|
        Violation.new(path, "no-js", "JavaScript asset in site sources")
      end
    end

    def check_file(_site_dir, path)
      text = File.read(path, encoding: "UTF-8")
      found = []
      if SCRIPT_TAG.match?(text)
        found << Violation.new(path, "no-js", "<script> tag (wave 1 is text-pure)")
      end
      if PROD_ORIGIN.match?(text)
        found << Violation.new(path, "relative-links", "hard-coded production origin")
      end
      if ROOT_ABSOLUTE_LINK.match?(text)
        found << Violation.new(path, "base-relative",
                               %q(root-absolute internal link — use {{ '/x/' | relative_url }}))
      end
      if path.end_with?(".md") && !text.start_with?("---\n")
        found << Violation.new(path, "front-matter", "Markdown page without front matter")
      end
      found.concat(check_nav_label(path, text))
      found.concat(check_title_language(path, text))
      found.concat(check_tail_fit(path, text))
      found.concat(check_codex_reads(path, text))
      found.concat(check_chapter_links(path, text))
      found.concat(check_akk_translit(path, text))
      text.scan(TRANSLIT_SPAN) do
        extra, body = Regexp.last_match[:extra], Regexp.last_match[:body]
        next if extra.split.include?("atf")

        if (hit = body[ASCII_INDEX])
          found << Violation.new(path, "subscript-index",
                                 "full-size index digit #{hit.inspect} in translit span — use Unicode subscripts (lu₂), or class the span \"translit atf\" for verbatim ATF")
        end
      end
      found
    rescue ArgumentError, Encoding::InvalidByteSequenceError
      [Violation.new(path, "encoding", "not valid UTF-8")]
    end

    # nav-label (owner report 2026-08-06: the sidebar said "šumma"
    # while the page said "If a man…"): a CHAPTER's short_title must
    # be drawn from its title — the label text (after the "NN · "
    # prefix) a case-insensitive substring of the title text — so
    # navbar and page can never disagree. Course indexes (no
    # chapter:) keep their deliberate short codes (C SUX Addenda).
    def check_nav_label(path, text)
      return [] unless path.end_with?(".md") && text.start_with?("---\n")
      return [] unless (fm_end = text.index("\n---", 4))

      require "yaml"
      fm = YAML.safe_load(text[4..fm_end]) rescue nil
      return [] unless fm.is_a?(Hash) && fm["chapter"] && fm["title"] && fm["short_title"]

      strip = ->(s) { s.to_s.sub(/\A\d+\s*·\s*/, "").downcase }
      title, label = strip.call(fm["title"]), strip.call(fm["short_title"])
      return [] if title.include?(label)

      [Violation.new(path, "nav-label",
                     "short_title #{fm['short_title'].inspect} is not drawn from title #{fm['title'].inspect} — the sidebar must echo the page")]
    end

    # tail-fit-width (§5, owner reports 2026-08-07/08: the stems
    # table blew its layout twice — first on sentence-length Says
    # cells, then on clause-length build labels): sign-table--tail-fit
    # sets white-space: nowrap on the last column, so its cells must
    # stay short — <= 60 characters after stripping tags and Liquid.
    # And the table's width budget is shared: in an n-column table,
    # non-tail cells are labels capped at 180/n characters. Longer
    # commentary lives in prose around the table.
    TAIL_FIT_MAX = 60
    TAIL_FIT_BUDGET = 180
    TAIL_FIT_TABLE = %r{<table[^>]*class="[^"]*sign-table--tail-fit[^"]*"[^>]*>.*?</table>}m
    def check_tail_fit(path, text)
      found = []
      text.scan(TAIL_FIT_TABLE) do |tbl|
        ncols = tbl.scan(%r{<th(?:\s[^>]*)?>}).size
        tbl.scan(%r{<tr>(.*?)</tr>}m) do |(row)|
          cells = row.scan(%r{<td[^>]*>(.*?)</td>}m).flatten
          next if cells.empty?

          label_max = TAIL_FIT_BUDGET / [ncols, cells.size, 1].max
          cells.each_with_index do |cell, i|
            plain = cell.gsub(/\{%.*?%\}/m, "").gsub(/\{\{.*?\}\}/m, "")
                        .gsub(/<[^>]+>/, "").gsub(/\s+/, " ").strip
            max, what = if i == cells.size - 1
                          [TAIL_FIT_MAX, "tail-fit last column cannot wrap"]
                        else
                          [label_max, "non-tail cells are labels (#{TAIL_FIT_BUDGET}/#{[ncols, cells.size].max} columns)"]
                        end
            next if plain.length <= max

            found << Violation.new(path, "tail-fit-width",
                                   "#{what}, but #{plain[0, 40].inspect}… is #{plain.length} chars (max #{max}) — move commentary into prose (§5)")
          end
        end
      end
      found
    end

    # title-language (§4, owner rulings: "šumma" 2026-08-06, "anāku"
    # 2026-08-08): chapter titles and sidebar labels speak the
    # student's language — plain English essence, never a
    # transliterated ancient word. nav-label only guarded
    # sidebar-page agreement, so "13 · anāku" slipped through by
    # appearing in the title; this bans the character class itself.
    TRANSLIT_CHARS = /[āēīūâêîûṣṭḫŋĝřĀĒĪŪÂÊÎÛṢṬḪŊĜŘšŠḏḎṯṮẖḳḲꜣꜥʾ₀-₉]/
    def check_title_language(path, text)
      return [] unless path.end_with?(".md") && text.start_with?("---\n")
      return [] unless (fm_end = text.index("\n---", 4))

      require "yaml"
      fm = YAML.safe_load(text[4..fm_end]) rescue nil
      return [] unless fm.is_a?(Hash) && fm["chapter"]

      %w[title short_title].filter_map do |key|
        next unless (val = fm[key]) && (hit = val[TRANSLIT_CHARS])

        Violation.new(path, "title-language",
                      "#{key} #{val.inspect} carries transliteration (#{hit.inspect}) — titles and labels speak plain English; the ancient word enters in the first paragraph (§4)")
      end
    end

    # akk-translit (§9, owner rulings 2026-08-06): Akkadian reading
    # transliterations carry no homophone indexes (i-nu, not i₃-nu)
    # and no lowercase sumerograms (KALAM, not kalam) — the script
    # column carries sign identity. Applies to translit spans on
    # Akkadian-course pages only; raw-ATF spans exempt as ever.
    SUMEROGRAMS = /\b(lugal|kalam|dumu|iti|e2|ku3-babbar)\b/
    def check_akk_translit(path, text)
      return [] unless path.match?(%r{cuneiform/(103|addenda-akk)/})

      found = []
      text.scan(TRANSLIT_SPAN) do
        extra, body = Regexp.last_match[:extra], Regexp.last_match[:body]
        next if extra.split.include?("atf")

        if (hit = body[/\p{Lower}[₀-₉]+/])
          found << Violation.new(path, "akk-translit",
                                 "homophone index #{hit.inspect} in an Akkadian reading — transliterate plain (i-nu, not i₃-nu); the script column carries the sign (§9). CAPS sumerogram NAMES (E₂) keep theirs")
        end
        if (hit = body[SUMEROGRAMS])
          found << Violation.new(path, "akk-translit",
                                 "lowercase sumerogram #{hit.inspect} in an Akkadian reading — CAPS (LUGAL, KALAM) per §9")
        end
      end
      found
    end

    # codex-reads (owner report 2026-08-06: a Reads row carried "the
    # particle ša, …" — meaning prose): a cuneiform codex page's
    # reads: field holds READINGS only — one bracket of phonetic
    # variants, then optional word-readings in transliteration, then
    # at most a "(fuller form …)" note. Meaning belongs to Means and
    # the page body.
    CODEX_READS = %r{\A\[[a-zāēīūâêîûšṣṭḫŋʾ'/]+\](, [a-zšṣṭḫŋ₀-₉]+)*( \(fuller form [a-zšṣṭḫŋ₀-₉]+\))?\z}
    def check_codex_reads(path, text)
      return [] unless path.match?(%r{cuneiform/addenda[^/]*/signs/}) && !path.end_with?("index.md")
      return [] unless (m = text.match(/^reads: "((?:[^"\\]|\\.)*)"$/))

      reads = m[1].gsub('\\"', '"')
      return [] if reads.match?(CODEX_READS)

      [Violation.new(path, "codex-reads",
                     "reads: #{reads.inspect} is not pure readings — [phonetics], word-readings, (fuller form …) only; meaning prose belongs in Means and the body")]
    end

    # chapter-link (owner request 2026-08-06, mechanizing the §4
    # back-reference law): every "chapter NN" mention in a page BODY
    # must sit inside a link — HTML or markdown — except a page's
    # reference to its own chapter number. Front matter is exempt
    # (descriptions cannot carry links).
    def check_chapter_links(path, text)
      return [] unless path.end_with?(".md")

      body = text
      own = nil
      if text.start_with?("---\n") && (fm_end = text.index("\n---", 4))
        require "yaml"
        fm = YAML.safe_load(text[4..fm_end]) rescue nil
        own = fm["chapter"] if fm.is_a?(Hash)
        body = text[(fm_end + 4)..].to_s
      end
      linkless = body.gsub(%r{<svg\b.*?</svg>}m, "")
                     .gsub(%r{<a\b[^>]*>.*?</a>}m, "")
                     .gsub(/\[[^\]]*\]\([^)]*\)/, "")
      found = []
      linkless.scan(/chapters?\s+(\d{1,2})\b/i) do
        n = Regexp.last_match(1).to_i
        next if own && n == own

        found << Violation.new(path, "chapter-link",
                               "\"chapter #{Regexp.last_match(1)}\" mentioned without a link — back-references carry links (§4)")
      end
      found
    end
  end
end

if $PROGRAM_NAME == __FILE__
  site_dir = ARGV.fetch(0, "site")
  abort "lint: site directory #{site_dir.inspect} not found" unless File.directory?(site_dir)
  offenses = Edubba::Lint.violations(site_dir)
  offenses.each { |v| warn "#{v.file}: [#{v.rule}] #{v.detail}" }
  if offenses.empty?
    puts "lint: clean (#{Edubba::Lint.sources(site_dir).size} sources)"
  else
    abort "lint: #{offenses.size} violation(s)"
  end
end
