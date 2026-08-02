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

    module_function

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
