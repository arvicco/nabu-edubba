# frozen_string_literal: true

# Course-rulebook checks (owner ruling 2026-07-31, after the ĝ/ŋ
# notation drift): each school's conventions live as a single
# human-readable source of truth in docs/courses/<school>.md,
# written before content and updated in the same commit as any new
# choice. This file IMPLEMENTS those documents' machine-enforceable
# subset — every check below cites the rulebook section it
# enforces. The docs rule; the script obeys.

module Edubba
  module Rulebook
    Violation = Struct.new(:file, :rule, :detail)

    # docs/courses/cuneiform.md §1 (notation) + §3 (license labels);
    # docs/courses/hieroglyphs.md §4 (license labels).
    RULEBOOKS = [
      {
        doc: "docs/courses/cuneiform.md",
        scope: "cuneiform/**/*.md",
        forbidden: [
          { pattern: /[ĝĜ]/,
            message: "the velar nasal is printed ŋ, never ĝ (§1)",
            allow: ["cuneiform/102/00-orientation.md"] },   # explicit mention in the primer
          { pattern: /[ìíùú]/,
            message: "accent index notation — use Unicode subscripts (i₃), accents only in explicit mentions (§1)",
            allow: ["cuneiform/102/00-orientation.md"] },
          { pattern: /é(?!-dub-ba-a)/,   # the school's own name keeps its accent
            message: "accent index é — use e₂; é only in explicit mentions and in é-dub-ba-a (§1)",
            allow: ["cuneiform/102/00-orientation.md",     # primer's explicit mention
                    "cuneiform/101/04-your-first-signs.md"] } # accent habit noted where É is taught
        ],
        license_labels: [
          { urn: "urn:nabu:etcsl",
            label: /license: ETCSL · non-commercial/,
            message: "an ETCSL quote must carry its non-commercial label — D3-a (§3)" },
          { urn: "urn:nabu:cdli",
            label: /license(?: class)?: attribution/,
            message: "a CDLI citation must carry its attribution label (§3)" }
        ]
      },
      {
        doc: "docs/courses/hieroglyphs.md",
        scope: "hieroglyphs/**/*.md",
        forbidden: [],
        license_labels: [
          { urn: "urn:nabu:aes",
            label: /license(?: class)?: attribution/,
            message: "an aes citation must carry its attribution label (§4)" }
        ]
      }
    ].freeze

    # docs/courses/cuneiform.md §7 / hieroglyphs.md §9 — the Sign
    # Codex: one Addenda page per taught sign, keyword unique within
    # the school, slug = traditional name in lowercase ASCII.
    # :keywords flips with the Stage-A backfill; :pages flips when a
    # school's shelf is complete (staged activation is the law).
    CODEX = [
      { doc: "docs/courses/cuneiform.md §7",
        registries: %w[_data/sign_teaching.yml _data/cuneiform102_queue.yml],
        shelf: "cuneiform/addenda/signs",
        keywords: false,
        pages: false },
      { doc: "docs/courses/hieroglyphs.md §9",
        registries: %w[_data/hiero_teaching.yml _data/hieroglyphs102_queue.yml],
        shelf: "hieroglyphs/addenda/signs",
        keywords: false,
        pages: false }
    ].freeze

    module_function

    # §7: lowercase ASCII of the traditional name — š→sz, É→e2, ×→x,
    # index digits already full-size in names. Gardiner codes pass
    # through untouched but lowercased.
    def sign_slug(name)
      name.downcase.gsub("š", "sz").gsub("é", "e2").gsub("×", "x")
    end

    def codex_violations(site_dir, codexes = CODEX)
      require "yaml"
      codexes.flat_map do |cx|
        signs = cx[:registries].flat_map do |rel|
          path = File.join(site_dir, rel)
          # Fixture sites carry no registries; the contract tests pin
          # their presence in the real one.
          File.exist?(path) ? YAML.load_file(path)["signs"] : []
        end
        shelf = File.join(site_dir, cx[:shelf])
        pages = Dir.glob(File.join(shelf, "*.md"))
                   .map { |p| File.basename(p, ".md") } - ["index"]
        check_codex(signs, pages, cx)
          .map { |detail| Violation.new(cx[:shelf], "rulebook-codex", detail) }
      end
    end

    # Pure: registry entries + existing page slugs + codex hash ->
    # details. A sign is TAUGHT when it carries taught_in (teaching
    # registries) or a chapter pin (queues); identity is gardiner
    # where present, else name.
    def check_codex(signs, page_slugs, cx)
      out = []
      ident = ->(s) { s["gardiner"] || s["name"] }
      taught = signs.select { |s| s["taught_in"] || s["chapter"] }

      signs.map { |s| s["keyword"] }.compact
           .tally.select { |_, n| n > 1 }.each_key do |kw|
        out << "keyword #{kw.inspect} on more than one sign — unique within the school (#{cx[:doc]})"
      end
      if cx[:keywords]
        taught.reject { |s| s["keyword"] }.each do |s|
          out << "taught sign #{ident.call(s)} has no keyword: (#{cx[:doc]})"
        end
      end

      taught_slugs = taught.map { |s| sign_slug(ident.call(s)) }
      (page_slugs - taught_slugs).each do |slug|
        out << "codex page #{slug}.md matches no taught sign's name slug (#{cx[:doc]})"
      end
      if cx[:pages]
        taught.zip(taught_slugs).each do |s, slug|
          next if page_slugs.include?(slug)
          out << "taught sign #{ident.call(s)} has no codex page #{slug}.md on #{cx[:shelf]} (#{cx[:doc]})"
        end
      end
      out
    end

    def violations(site_dir, rulebooks = RULEBOOKS)
      rulebooks.flat_map do |rb|
        Dir.glob(File.join(site_dir, rb[:scope])).sort.flat_map do |path|
          rel = path.sub(%r{\A#{Regexp.escape(site_dir)}/}, "")
          check_text(File.read(path, encoding: "UTF-8"), rel, rb)
            .map { |detail| Violation.new(path, "rulebook", detail) }
        end
      end
    end

    # Pure: text + site-relative path + rulebook hash -> details.
    def check_text(text, rel, rb)
      out = []
      rb[:forbidden].each do |f|
        next if f.fetch(:allow, []).include?(rel)
        if (hit = text[f[:pattern]])
          out << "#{hit.inspect} — #{f[:message]} · #{rb[:doc]}"
        end
      end
      squashed = text.gsub(/\s+/, " ")   # captions wrap; labels must not care
      rb[:license_labels].each do |l|
        if squashed.include?(l[:urn]) && !squashed.match?(l[:label])
          out << "#{l[:message]} · #{rb[:doc]}"
        end
      end
      out
    end
  end
end
