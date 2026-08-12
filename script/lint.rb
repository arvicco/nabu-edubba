# frozen_string_literal: true

require_relative "script_scan"
require_relative "course_check"
require_relative "rulebook"
require_relative "value_check"
require_relative "font_metrics"
require_relative "table_balance"
require_relative "../bin/pinyin_audio" # tone_of — the canonical tone reader

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
#   reading-width a three-column reading figure's widest script
#                 line fits the measured 20.3rem budget (real font
#                 metrics, script/font_metrics.rb) or the figure
#                 declares reading--stacked — gloss text is never
#                 cut at the measure (§5, 2026-08-09)
#   value-coverage every syllabic token in an Akkadian reading is a
#                 value taught, by that chapter, for a sign present
#                 in the line (script/value_check.rb; §9 2026-08-09
#                 — glyph coverage alone let a-wi-lim ride the
#                 eye-sign as an untaught lim)
#   reading-cites in a cuneiform reading transliteration a dot never
#                 sits between letters/digits — citation format
#                 (KU₃.BABBAR) stays in prose and sign lists;
#                 readings hyphenate values and speak voices (§9,
#                 2026-08-09)
#   reading-logo  in an Akkadian reading, capitals in the translit
#                 live only inside <span class="logo"> voice-marks,
#                 script and translit carry equally many marks per
#                 line, and the marking never appears on
#                 Sumerian-course pages (cuneiform §9, 2026-08-09)
#   citation-urn  every reading figure cites its witness — a
#                 urn:nabu: code in the figcaption — or declares
#                 what it is instead, class AND displayed wording
#                 together: reading--composed says "assembled"/
#                 "composed" in the caption; reading--monument
#                 (a real object outside the corpora) says
#                 "carved"/"inscribed" (M19-2, retro rec 3 — two
#                 codex wilds were drafted without witnesses in
#                 one phase)
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
    # D17-a (owner-ruled 2026-08-11): the ONE sanctioned script — the
    # self-contained audio enhancement, included with this exact tag.
    # Any other <script>, anywhere, is still a violation.
    SANCTIONED_SCRIPT = %r{\A<script src="\{\{ '/assets/say\.js' \| relative_url \}\}" defer></script>\z}
    ROOT_ABSOLUTE_LINK = %r{(?:href="|\]\()/(?![/)])}

    TRANSLIT_SPAN = %r{<span class="translit(?<extra>[^"]*)">(?<body>(?:[^<]|<span[^>]*>[^<]*</span>)*)</span>}m
    ASCII_INDEX = /[A-Za-zŠšŊŋĜĝḪḫŘř]\d/
    LOGO_SPAN = %r{<span class="logo">[^<]*</span>}
    READING_LINE = %r{<div class="reading-line">(.*?)</div>}m

    Violation = Struct.new(:file, :rule, :detail)

    module_function

    # manifests: optional {script_name => manifest_path} overrides
    # (tests point them at fixture files).
    def violations(site_dir, manifests = {})
      sources(site_dir).flat_map { |path| check_file(site_dir, path) } +
        js_assets(site_dir) +
        font_coverage(site_dir, manifests) +
        nav_order_unique(site_dir) +
        course_toc_complete(site_dir) +
        CourseCheck.violations(site_dir) +
        Rulebook.violations(site_dir) +
        Rulebook.codex_violations(site_dir) +
        ValueCheck.violations(site_dir)
    end

    # course-toc (owner report 2026-08-11: /sinographs/101 promised
    # "chapters appear here as they are written" while its list
    # stopped ten chapters short — two stretches of hand-maintained
    # TOC rot): every chapter page of a course must be LINKED from
    # that course's index page. The taglines stay hand-curated; only
    # completeness is mechanical.
    def course_toc_complete(site_dir)
      require "yaml"
      fm_of = lambda do |path|
        text = File.read(path, encoding: "UTF-8")
        next [nil, text] unless text.start_with?("---\n") && (fm_end = text.index("\n---", 4))

        [(YAML.safe_load(text[4..fm_end]) rescue nil), text]
      end
      chapters = Hash.new { |h, k| h[k] = [] }
      Dir.glob(File.join(site_dir, "**", "[0-9][0-9]-*.md")).each do |path|
        fm, = fm_of.call(path)
        next unless fm.is_a?(Hash) && fm["course"] && fm["chapter"] && fm["permalink"]
        # parked chapters (published: false — the S102 rework
        # window, concept §7) are not on the site and owe no TOC row
        next if fm["published"] == false

        chapters[fm["course"]] << [path, fm["permalink"]]
      end
      Dir.glob(File.join(site_dir, "**", "index.md")).flat_map do |index|
        fm, text = fm_of.call(index)
        next [] unless fm.is_a?(Hash) && fm["course_no"] && fm["school"]

        course = "#{fm['school']}-#{fm['course_no']}"
        chapters[course].reject { |_, permalink| text.include?(permalink.to_s) }
                        .map do |page, permalink|
          Violation.new(index, "course-toc",
                        "#{File.basename(page)} (#{permalink}) is not linked from its course " \
                        "index — the TOC rotted ten chapters deep once (2026-08-11); every " \
                        "chapter lands in its course index in the same commit")
        end
      end
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
      Dir.glob(File.join(site_dir, "**", "*.js")).filter_map do |path|
        next if path.end_with?("/assets/say.js") # D17-a: the one sanctioned script

        Violation.new(path, "no-js", "JavaScript asset in site sources")
      end
    end

    def check_file(site_dir, path)
      text = File.read(path, encoding: "UTF-8")
      found = []
      found.concat(check_say_audio(site_dir, path, text))
      found.concat(check_production_vocab(path, text))
      text.scan(/<script\b[^>]*>(?:<\/script>)?/i) do |tag|
        next if SANCTIONED_SCRIPT.match?(tag) && !path.end_with?(".md")

        found << Violation.new(path, "no-js",
                               "<script> tag (text-pure law; the only sanctioned script is the " \
                               "say.js enhancement include in the layout — D17-a)")
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
      found.concat(check_logo_marking(path, text))
      found.concat(check_reading_width(path, text))
      found.concat(check_reading_dots(path, text))
      found.concat(check_pinyin_display(path, text))
      found.concat(check_box_share(path, text))
      found.concat(check_citation_urn(path, text))
      found.concat(check_table_balance(path, text))
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

    # Tone-numbered pinyin (ma1, xue2) shaped like a letters+digit
    # token; two letters minimum keeps version-y tokens (v2) out.
    TONE_NUMBER = /\b[a-zA-ZüÜ]{2,}[1-5]\b/

    # pinyin-display (sinographs rulebook §2, ruled 2026-08-09 —
    # the subscript-index law's shape, adopted BEFORE content):
    # displayed pinyin carries tone diacritics (xué), never tone
    # numbers (xue2). ASCII tone numbers live only in spans classed
    # "pinyin ascii" (verbatim-source exhibits and mentions of the
    # ASCII convention).
    def check_pinyin_display(path, text)
      return [] unless path.include?("/sinographs/")

      bare = text.gsub(%r{<span class="pinyin ascii">.*?</span>}m, "")
                 .gsub(/<[^>]+>/, "") # the law governs DISPLAYED text, not markup attributes
      bare.scan(TONE_NUMBER).map do |hit|
        Violation.new(path, "pinyin-display",
                      "tone number #{hit.inspect} in displayed text — tone marks only " \
                      "(xué), or class the span \"pinyin ascii\" for a verbatim exhibit")
      end
    end

    # box-share (sinographs §5, owner ruling 2026-08-10): untaught
    # boxes never outnumber taught characters in a reading line —
    # ▢-share ≤ 50%, tightening five points per five-chapter
    # stretch. A famous line trims to its readable clause; the
    # gloss carries the rest.
    def check_box_share(path, text)
      return [] unless path.include?("/sinographs/") && path.end_with?(".md")

      ch = text[/^chapter:\s*(\d+)/, 1] or return []
      cap = [25, 50 - 5 * (ch.to_i / 5)].max
      found = []
      text.scan(READING_FIGURE) do
        Regexp.last_match[:body].scan(%r{<span class="script">((?:[^<]|<span[^>]*>[^<]*</span>)*)</span>}) do |(s)|
          txt = s.gsub(/<[^>]+>/, "")
          boxes = txt.count("▢")
          next if boxes.zero?

          han = txt.each_char.count { |c| han?(c.ord) }
          share = 100.0 * boxes / (boxes + han)
          next if share <= cap

          found << Violation.new(path, "box-share",
                                 "reading line #{txt[0, 12].inspect}… is #{share.round}% boxes " \
                                 "(cap #{cap}% for ch. #{ch}) — untaught may never outnumber taught: " \
                                 "trim to the readable clause or pick a better-taught line (sinographs §5)")
        end
      end
      found
    end

    # table-balance (owner ruling 2026-08-11, a HARD rule): no
    # single column of a sign table may add more than 15% to the
    # table's height over what the table would measure without it.
    # Width first: the build already gives every table its balanced
    # per-table grid (script/table_balance.rb, emitted as colgroup
    # by the table_wrap plugin), so anything this check finds is
    # CONTENT — excessive text concentrated in one column; trim or
    # compress it. Enforced school-wide since 2026-08-11 (M22-1):
    # the staged activation ended when the older schools' notes
    # columns were compressed to their computed budgets.
    TB_EL = %r{<table class="sign-table(?<mods>[^"]*)">(?<body>.*?)</table>}m

    def check_table_balance(path, text)
      return [] unless path.end_with?(".md")

      sino = path.include?("/sinographs/")
      found = []
      text.scan(TB_EL) do
        mods, body = Regexp.last_match[:mods], Regexp.last_match[:body]
        next if mods.include?("tail-fit") || mods.include?("--even")

        rows = TableBalance.rows_of(body)
        next if rows.empty? || rows.map(&:size).max < 2

        TableBalance.excesses(rows, sino).each do |col, added|
          found << Violation.new(path, "table-balance",
                                 "sign-table column #{col + 1} adds #{(added * 100).round}% to the " \
                                 "table's height even at its balanced width (hard limit 15%) — " \
                                 "text is concentrated in one column: trim or compress the cells " \
                                 "(table-balance law, 2026-08-11)")
        end
      end
      found
    end

    # citation-urn (M19-2, retro rec 3): the anti-fabrication law,
    # mechanized. A reading figure either cites its witness (a
    # urn:nabu: code in the figcaption) or wears its true nature as
    # class AND caption wording together — the honesty is displayed,
    # not just declared. Two escapes, both discovered by the first
    # sweep: reading--composed (lesson-assembled lines) must say
    # "assembled" or "composed"; reading--monument (a real object
    # outside the corpora, e.g. the Rosetta Stone) must say "carved"
    # or "inscribed".
    ANY_READING_FIGURE = %r{<figure class="reading(?<mods> [^"]*|)">(?<body>.*?)</figure>}m
    CITATION_CAPTION = %r{<figcaption class="citation[^"]*">(?<cap>.*?)</figcaption>}m

    def check_citation_urn(path, text)
      return [] unless path.end_with?(".md")

      found = []
      text.scan(ANY_READING_FIGURE) do
        mods, body = Regexp.last_match[:mods], Regexp.last_match[:body]
        cap = body[CITATION_CAPTION, :cap].to_s
        rule = "citation-urn"
        if mods.include?("reading--composed")
          next if cap.match?(/assembled|composed/i)

          found << Violation.new(path, rule,
                                 "reading--composed figure whose caption never says so — write " \
                                 "\"assembled\" or \"composed\" where the reader sees it")
        elsif mods.include?("reading--monument")
          next if cap.match?(/carved|inscribed/i)

          found << Violation.new(path, rule,
                                 "reading--monument figure whose caption never says so — write " \
                                 "\"carved\" or \"inscribed\" where the reader sees it")
        else
          next if cap.include?("urn:nabu:")

          found << Violation.new(path, rule,
                                 "reading figure without a urn:nabu: witness in its figcaption — " \
                                 "cite the source, or class it reading--composed / reading--monument " \
                                 "and say so in the caption")
        end
      end
      found
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

    # reading-logo (§9, owner ruling 2026-08-09; report:
    # GIR₃.PAD.RA₂ mid-reading): a reading's transliteration prints
    # the VOICE of a logographically-written stretch — capitals
    # wrapped in <span class="logo"> — and the glyphs that carry it
    # wear the same span, so the green binds voice to signs.
    # Mechanically: capitals in an Akkadian reading transliteration
    # live only inside logo spans, and every reading line carries as
    # many logo marks in its script as in its transliteration. The
    # marking is an Akkadian-course convention — on Sumerian-course
    # pages it may not appear at all.
    def check_logo_marking(path, text)
      found = []
      unless path.match?(%r{cuneiform/(103|addenda-akk)/})
        if path.include?("cuneiform/") && text.include?('class="logo"')
          found << Violation.new(path, "reading-logo",
                                 %(logogram voice-marking (span class "logo") is an Akkadian-course convention (§9) — it does not belong on Sumerian-course pages))
        end
        return found
      end

      text.scan(READING_LINE) do |(line)|
        spans = {}
        line.scan(%r{<span class="(script|translit)([^"]*)">((?:[^<]|<span[^>]*>[^<]*</span>)*)</span>}) do |cls, extra, body|
          spans[cls] = [extra, body]
        end
        script_marks = (spans.dig("script", 1) || "").scan(LOGO_SPAN).size
        translit_extra, translit_body = spans["translit"] || ["", ""]
        translit_marks = translit_body.scan(LOGO_SPAN).size
        if script_marks != translit_marks
          found << Violation.new(path, "reading-logo",
                                 "logogram marks must pair: #{script_marks} in script vs #{translit_marks} in transliteration — the green binds voice to signs (§9)")
        end
        next if translit_extra.split.include?("atf")

        bare = translit_body.gsub(LOGO_SPAN, "").gsub(/<[^>]+>/, "")
        if (hit = bare[/\p{Lu}[\p{Lu}₀-₉.]*/])
          found << Violation.new(path, "reading-logo",
                                 "unmarked capitals #{hit.inspect} in an Akkadian reading transliteration — a logogram stretch shows its voice inside <span class=\"logo\"> (§9)")
        end
      end
      found
    end

    # reading-width (§5, owner report 2026-08-09: gloss text cut at
    # the figure's edge): a three-column reading figure holds only
    # while its widest script line fits the measured budget — 44rem
    # measure − 2.5rem figure padding − 2×1rem gaps − 8rem/11rem
    # text floors ≈ 20.3rem, i.e. 14.5em at the 1.4rem script size.
    # Width is MEASURED with the committed subset fonts
    # (script/font_metrics.rb), never guessed; a wider line means
    # the figure declares reading--stacked (voice under script,
    # nothing ever cut). Spaces and boxes render in the fallback
    # font — estimated 0.4em / 0.75em, on the generous side.
    READING_FIGURE = %r{<figure class="reading reading--script(?<mods>[^"]*)">(?<body>.*?)</figure>}m
    SCRIPT_EM_BUDGET = 14.5
    def check_reading_width(path, text)
      return [] unless path.end_with?(".md")
      # Sinograph readings ALWAYS stack by stylesheet law (rulebook
      # §6; the size-law scale left three columns no honest gloss
      # room even under a calibrated budget — owner report
      # 2026-08-10), so no width arithmetic applies there.
      return [] if path.include?("/sinographs/")

      found = []
      text.scan(READING_FIGURE) do
        mods, body = Regexp.last_match[:mods], Regexp.last_match[:body]
        next if mods.include?("reading--stacked")

        body.scan(%r{<span class="script">((?:[^<]|<span[^>]*>[^<]*</span>)*)</span>}) do |(s)|
          txt = s.gsub(/<[^>]+>/, "")
          em = script_width_em(txt)
          next if em <= SCRIPT_EM_BUDGET

          found << Violation.new(path, "reading-width",
                                 "script line #{txt[0, 12].inspect}… measures #{em.round(1)}em " \
                                 "(budget #{SCRIPT_EM_BUDGET}em ≈ 20.3rem) — three columns would cut the " \
                                 "gloss at the measure; declare the figure reading--stacked (§5)")
        end
      end
      found
    end

    def script_width_em(txt, school = nil)
      fonts = reading_fonts
      em = txt.each_char.sum do |c|
        cp = c.ord
        if cp.between?(0x12000, 0x1247F) then fonts[:cuneiform].advance_em(cp)
        elsif cp.between?(0x13000, 0x1342F) then fonts[:hieroglyphs].advance_em(cp)
        elsif han?(cp) then fonts[:sinographs].advance_em(cp)
        elsif cp.between?(0x3000, 0x303F) || cp.between?(0xFF00, 0xFFEF) then 1.0
        elsif c == " " then 0.4
        else 0.75
        end
      end
      # The size law (sinographs §6) renders that school's reading
      # script at 1.9rem against cuneiform's 1.4rem — the same pixel
      # budget holds fewer, bigger glyphs.
      school == :sinographs ? em * SINO_READING_SCALE : em
    end

    SINO_READING_SCALE = 1.9 / 1.4

    def han?(cp)
      ScriptScan.ranges_of(ScriptScan::SCRIPTS["sinographs"][:range]).any? { |r| r.cover?(cp) }
    end

    def reading_fonts
      @reading_fonts ||= {
        cuneiform: FontMetrics::Font.new(File.expand_path("../site/assets/fonts/NotoSansCuneiform-subset.ttf", __dir__)),
        hieroglyphs: FontMetrics::Font.new(File.expand_path("../site/assets/fonts/NotoSansEgyptianHieroglyphs-subset.ttf", __dir__)),
        sinographs: FontMetrics::Font.new(File.expand_path("../site/assets/fonts/NotoSerifTC-subset.otf", __dir__))
      }
    end

    # reading-cites (§9, owner report 2026-08-09: a reading line
    # showed KU₃.BABBAR ŠU BA.AN.TI — sign-name citation format,
    # not a reading): in a cuneiform reading transliteration a dot
    # may never sit between letters or digits. The dot is how sign
    # lists FILE compounds; a reading line never cites, it reads —
    # Sumerian values hyphenate (ŠU BA-AN-TI, I₃-LA₂-E), taught
    # sumerogram voices speak (KASPAM). Editorial [...] and the
    # hieroglyph school's Leiden morphology dots are out of scope.
    CITATION_DOT = /[\p{L}\p{Nd}₀-₉]\.[\p{L}\p{Nd}{]/
    def check_reading_dots(path, text)
      return [] unless path.include?("cuneiform/")

      found = []
      text.lines.each_with_index do |line, i|
        next unless line.include?("reading-line")

        line.scan(TRANSLIT_SPAN) do
          extra, body = Regexp.last_match[:extra], Regexp.last_match[:body]
          next if extra.split.include?("atf")

          bare = body.gsub(/<[^>]+>/, "")
          if (hit = bare[CITATION_DOT])
            found << Violation.new(path, "reading-cites",
                                   "sign-name citation dot #{hit.inspect} in a reading transliteration (line #{i + 1}) — " \
                                   "readings read, they never cite: hyphenate Sumerian values (ŠU BA-AN-TI), speak taught voices (KASPAM) (§9)")
          end
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

    # production-vocab (owner ruling 2026-08-11, on ch08's "one
    # chapter left in this stretch"): the authoring mechanics —
    # stretches, phase borders — are invisible in the final course
    # and only confuse the student. The word "stretch" (any
    # inflection, including physical senses — use a synonym) never
    # appears in site prose; "in a later phase" never defers to the
    # production calendar.
    PRODUCTION_VOCAB = /stretch|\b(?:later|next|future) phase\b/i

    def check_production_vocab(path, text)
      return [] unless path.end_with?(".md")

      text.scan(PRODUCTION_VOCAB).map do |hit|
        Violation.new(path, "production-vocab",
                      "#{hit.inspect} in student-facing prose — authoring borders " \
                      "(stretches, phases) do not exist in the final course; speak in " \
                      "chapters and content (owner ruling 2026-08-11)")
      end
    end

    # say-audio (sinographs rulebook §2; owner report 2026-08-11 —
    # pǐn shipped silent): in a sign-table row the reading IS the
    # button, so a pinyin span on a sign-cell line must sit inside
    # an a.say link; every say-link on any page must point at an
    # audio file that exists in the tree; and the tone the link
    # DISPLAYS must be the tone the file DECLARES in the audio
    # manifest (the zì/zǐ class, 2026-08-11: three primer links
    # showed 4th tone and played 3rd — the generator verifies files
    # against declared tones, but nothing checked links against
    # files until now).
    SAY_LINK = %r{<a class="say" href="\{\{ '(?<href>/assets/audio/[^']+)' \| relative_url \}\}"}
    PINYIN_SPAN = /<span class="translit pinyin">(?<body>[^<]*)</
    VOICED_SPAN = %r{<a class="say"[^>]*>\s*<span class="translit pinyin">}
    SAY_PINYIN_LINK = %r{<a class="say" href="\{\{ '/assets/audio/pinyin/(?<slug>[^.']+)\.mp3' \| relative_url \}\}"[^>]*>\s*<span class="translit pinyin">(?<shown>[^<]+)</span>}
    SAY_MANIFEST = File.expand_path("../assets-src/data/pinyin-audio-sources.yml", __dir__)

    # slug => declared pinyin, memoized per manifest path (tests
    # inject fixtures).
    def say_declared(manifest)
      @say_declared ||= {}
      @say_declared[manifest] ||= begin
        require "yaml"
        sources = (YAML.safe_load_file(manifest)["sources"] rescue nil) || {}
        sources.transform_values { |s| s["pinyin"].to_s }
      end
    end

    def check_say_audio(site_dir, path, text, manifest: SAY_MANIFEST)
      return [] unless path.end_with?(".md")

      found = []
      if path.include?("/sinographs/")
        text.each_line do |line|
          next unless line.include?("sign-cell")

          mute = line.scan(PINYIN_SPAN).flatten.size - line.scan(VOICED_SPAN).size
          next unless mute.positive?

          reading = line[PINYIN_SPAN, :body]
          found << Violation.new(path, "say-audio",
                                 "sign-table reading #{reading.inspect} is not a say-link — " \
                                 "the reading is the button (§2); acquire the syllable or flag it")
        end
      end
      text.scan(SAY_LINK) do
        href = Regexp.last_match[:href]
        next if File.exist?(File.join(site_dir, href))

        found << Violation.new(path, "say-audio",
                               "say-link target #{href} does not exist in the site tree")
      end
      text.scan(SAY_PINYIN_LINK) do
        slug, shown = Regexp.last_match[:slug], Regexp.last_match[:shown]
        declared = say_declared(manifest)[slug]
        next if declared.nil? || declared.empty?

        heard = Edubba::PinyinAudio.tone_of(declared)
        read = Edubba::PinyinAudio.tone_of(shown)
        next if heard == read

        found << Violation.new(path, "say-audio",
                               "say-link shows #{shown.inspect} (#{read}) but #{slug}.mp3 is " \
                               "declared #{declared.inspect} (#{heard}) — the ear must hear the " \
                               "tone the eye reads (zì/zǐ class, 2026-08-11)")
      end
      found
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
