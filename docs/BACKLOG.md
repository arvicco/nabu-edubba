# Backlog — Edubba

Flat, human-editable packets; the loop's entire coordination state.
Statuses: ready -> in-progress -> done | blocked: <reason>.
Packet IDs: M<phase>-<n>. Decision items: D<phase>-<letter>, ruling
recorded inline when it lands. The executing session updates its own
packet's status and appends one worklog paragraph per completed packet.

Packet format:

## M0-1 · <title>  [tier: <model-or-role>] [status: ready] [deps: --]
Goal: <one testable outcome>
Acceptance: <the machine-checkable oracle: which tests/checks prove it>

---

## Phase 0 — greenfield bootstrap (gate + conventions + stub)

## M0-1 · The gate command  [tier: top — first-of-family for the repo] [status: done] [deps: --]
Goal: `rake gate` = lint (script/lint.rb: no-JS rule, front matter,
      relative-links) + minitest suite + jekyll build + html-proofer
      (internal only). Fully offline.
Acceptance: gate red on a seeded violation (a `<script>` tag in a site
      page), green on HEAD; lint rules pinned by test/lint_test.rb.

## M0-2 · Site stub  [tier: top — establishes the visual/layout family] [status: done] [deps: M0-1]
Goal: buildable minimal site/ — _config.yml (Edubba branding,
      url edubba.ac), default layout, shared stylesheet skeleton,
      placeholder index, CNAME. No JS, semantic HTML.
Acceptance: `rake build && rake check` green; index renders title,
      one-paragraph promise, and honest "under construction" state.

## M0-3 · CI workflows  [tier: top — CI is the authority; first-of-kind] [status: done] [deps: M0-1]
Goal: .github/workflows/ci.yml runs `rake gate` on push/PR (Ruby 3.3,
      bundler-cache); pages.yml builds site/ with OUR bundle (Jekyll
      4.4 parity, not actions/jekyll-build-pages) and deploys on main.
Acceptance: CI green on the pushed phase-0 head (verifiable only after
      the owner creates the GitHub repo — Gate 0 runbook step).

## M0-4 · README v1  [tier: top — public authorship statement, owner-adjacent] [status: done — accepted via Gate 0 PR merge] [deps: M0-2]
Goal: honest user-facing document: what Edubba is, what exists today
      (nothing but a stub), the roadmap, the plainly-stated AI-drafted-
      under-owner-review authorship stance, GitHub Issues as feedback,
      CC BY-SA licensing.
Acceptance: owner accepts at Gate 0.

## Decision items — Phase 0
- D0-a · Wave-1 opening scope: how far into Cuneiform 102/103 before
  wave 2 opens (concept §8.2). Ruling needed before Phase 2 packet
  elaboration, not before Gate 0.

---

## Phase 1 — site skeleton (Gate 0 merged 2026-07-29; elaborated)

## M1-1 · Auto-deploy on merge  [tier: top — deploy semantics, owner ruling] [status: done] [deps: --]
Goal: merging any PR to main deploys the site, no manual dispatch:
      pages.yml paths filter removed; github-pages environment policy
      fixed to allow main only (was pinned to phase-0 — see worklog
      incident).
Acceptance: the PR merging this packet itself triggers a green deploy
      run; construction sign live at arvicco.github.io/nabu-edubba.

## M1-2 · Visual identity + vendored fonts  [tier: top — first-of-family design; identity is owner-adjacent] [status: done] [deps: --]
Goal: typography scale, per-school accent tokens, and vendored
      subsetted webfonts (Noto Sans Cuneiform first; OFL license file
      alongside) so the 𒂍𒁾𒁀𒀀 wordmark and any cuneiform render
      without tofu on stock systems.
Acceptance: rake gate green; screenshot of served page read by the
      session shows real glyphs (surface checklist §6b); font files
      + OFL committed; no external font requests (lint/proofer clean).

## M1-3 · Map-of-writing landing page  [tier: top — first-of-family content] [status: done] [deps: M1-2]
Goal: replace the construction sign: typology grid (logographic /
      syllabary / abjad / alphabet / abugida / featural) + the family
      tree of writing, linking to school stubs; still text-pure.
Acceptance: rake gate green; surface checklist pass; every school
      cell links to a stub that exists.

## M1-4 · School stubs (waves 1–3)  [tier: implementation — template-following, spec below] [status: done — delegated to implementation-tier agent, diff reviewed] [deps: M1-3]
Goal: /cuneiform/, /hieroglyphs/, /hanzi/ catalog pages: one-paragraph
      school intro, planned course tree (from concept §3), honest
      "no courses yet" state.
Acceptance: rake gate green; linked from landing; no dead links.

## M1-5 · Sample chapter  [tier: top — establishes the chapter template family] [status: done] [deps: M1-2]
Goal: one fully-styled specimen chapter exercising the literacy-ladder
      layout end-to-end: chapter nav (prev/next/TOC), native-script +
      transliteration blocks, graded-reading panel with URN citation
      footer, further-reading section. Lives under /specimen/ until a
      real course adopts the template.
Acceptance: rake gate green; surface checklist pass incl. mobile
      geometry and text-browser sanity.

## M1-6 · edubba.ac goes live  [owner action] [status: done — owner ruling 2026-07-29: edubba.ac REDIRECTS to the GitHub Pages URL by design (registrar forward), rather than serving as custom domain] [deps: M1-1]
Goal: edubba.ac reaches the site.
Acceptance: https://edubba.ac 301-redirects to
      arvicco.github.io/nabu-edubba (verified 2026-07-29).

## Decision items — Phase 1
- (none)

---

## Phase 2 — Cuneiform 101 · Foundations (plan approved 2026-07-29)

## M2-1 · Course architecture  [tier: top — first course of the site] [status: done] [deps: --]
Goal: /cuneiform/101/ course index (TOC 00–10), chapter template
      wiring (course/prev/next), taught-signs front-matter format.
Acceptance: gate green; TOC lists all chapters; nav round-trips.

## M2-2 · Taught-signs validator  [tier: top — pedagogy oracle, gate semantics] [status: done] [deps: M2-1]
Goal: gate rule: a chapter may only use cuneiform signs taught in
      chapters ≤ its own (per `teaches:` front matter).
Acceptance: seeded violation red; HEAD green; tests pin the rule.

## M2-3 · Sign sequencing table  [tier: top — curriculum methodology, owner-adjacent] [status: done] [deps: --]
Goal: corpus frequency (nabu: CDLI/Oracc) × curated complexity/
      iconicity per sign; committed data + offline-reproducible rank.
Acceptance: data files committed with citations; ch. 04 starter set
      justified by BOTH criteria.

## M2-4 · Ch. 00 Orientation  [tier: top — course voice] [status: done] [deps: M2-1]
## M2-5 · Ch. 03 How signs mean  [tier: top — mental-model spine] [status: done] [deps: M2-1]
## M2-6 · Ch. 04 Your first signs  [tier: top — sign-teaching template] [status: done] [deps: M2-2, M2-3, M2-5]
## M2-7 · Ch. 01 Clay and reed  [tier: implementation] [status: done] [deps: M2-4]
## M2-8 · Ch. 02 From tokens to signs  [tier: top — first SVG evolution panels] [status: done] [deps: M2-4]
## M2-9 · Ch. 05 Counting  [tier: implementation] [status: done] [deps: M2-6]
## M2-10 · Ch. 06 Seals and bricks  [tier: implementation — readings pre-pulled, top reviews licenses] [status: done] [deps: M2-6]
## M2-11 · Ch. 07 The tablet house  [tier: implementation] [status: done] [deps: M2-4]
## M2-12 · Ch. 08 One script, many tongues  [tier: implementation] [status: done] [deps: M2-4]
## M2-13 · Ch. 09 Decipherment  [tier: implementation — top fact-review mandatory] [status: done] [deps: M2-4]
## M2-14 · Ch. 10 Reference  [tier: implementation — partly generated from registry] [status: done] [deps: M2-6]
## M2-15 · School/landing flip to "101 open"  [tier: top — public promise] [status: done] [deps: M2-4..M2-14]
## M2-16 · Gate 2 prep: phase review, README, gate PR  [tier: top] [status: done] [deps: M2-15]

Chapter-packet acceptance (all): rake gate green (incl. taught-signs
rule), surface review of rendered page, top-tier factual review with
named scholarly basis, citations resolve, licenses stated.

## M2-17 · Gate 2 review revisions (owner feedback)  [tier: top — course-wide restructure] [status: done] [deps: M2-16]
Goal: sidebar course layout + chapter kicker; every chapter from 04
      teaches 1–3 theme-related signs (new ch. 07 Of gods and men;
      course now 12 chapters, 00–11, 21 signs); ≥1 graphic per
      chapter; script always beside translit with ▢ placeholders;
      concrete dates + map in ch. 09; stroke figures in ch. 00;
      CDLI links → cdli.earth; reference-citation dedup; nabu
      ATF→signs feature request drafted (.docs/).
Acceptance: rake gate green (validator re-proves the new teaching
      order); sidebar + figures surface-reviewed; PR #5 updated.

## M2-18 · Gate 2 review round 2 (owner feedback)  [tier: top] [status: done] [deps: M2-17]
Goal: stroke-figure orientation fix; Name-vs-Reads explained early;
      graphic-origin context in all sign-table notes; NEW ch. 08
      The sign workshop (SAG/KA/KA×A/KA×GAR — course now 13 chapters,
      25 signs); ch. 07 reading script column; reading-grid
      alignment; ch. 12 sign count computed by Liquid.
Acceptance: gate green; figures and alignment surface-reviewed;
      PR #5 updated.

## Decision items — Phase 2
- D0-a · RULED with P2 approval (2026-07-29), option (a): P3 = 102
  Sumerian chapters 00–05, P4 opens the Egyptian school; 102/103
  continue in alternating phases thereafter.

---

## Phase 3 — Cuneiform 102 · Sumerian, chapters 00–05 (plan approved 2026-07-29; D0-a)

## M3-1 · 102 course architecture  [tier: top] [status: done] [deps: --]
Goal: /cuneiform/102/ index (track intro, committed TOC 00–05),
      school catalog row flips to in-progress.
Acceptance: gate green; nav round-trips; 101 ch. 12 links forward.

## M3-2 · Curriculum compiler v1  [tier: top — methodology] [status: done] [deps: --]
Goal: bin/ instrument proposing sign batches by rank × simplicity ×
      unlocked-words; committed teaching queue for chapters 00–05.
Acceptance: queue data committed with provenance; tests on the
      selection logic.

## M3-3 · Value→sign map for the 102 inventory  [tier: top] [status: done] [deps: M3-2]
Goal: codepoint-verified value→glyph map covering the queue (or
      nabu-OGSL consumer if the upstream feature lands first).
Acceptance: every queued sign renders; font subset covers it; map
      feeds the readings.

## M3-4 · Reading picker + candidate readings  [tier: top — license-critical] [status: done] [deps: M3-3]
Goal: nabu query helper finding short attested passages with sign
      set ⊆ taught inventory; candidate list with URNs + license
      classes in .docs/ (NC texts become decision items, never
      silent inclusions).
Acceptance: ≥2 license-clean readings per chapter 02–05.

## M3-5 · Ch. 00 Orientation + first batch  [tier: top — track voice] [status: done] [deps: M3-2]
## M3-6 · Ch. 01 The sentence in the clay  [tier: top — grammar, fact-review critical] [status: done] [deps: M3-5]
## M3-7 · Ch. 02  [tier: impl — spec + pre-pulled readings] [status: done] [deps: M3-4, M3-6]
## M3-8 · Ch. 03  [tier: impl] [status: done] [deps: M3-7]
## M3-9 · Ch. 04  [tier: impl] [status: done] [deps: M3-8]
## M3-10 · Ch. 05  [tier: impl] [status: done] [deps: M3-9]
## M3-11 · 101↔102 stitching  [tier: top] [status: done] [deps: M3-10]
## M3-12 · Gate 3 prep: docs/ + README refresh, phase review, gate PR  [tier: top] [status: done] [deps: M3-11]
Goal: owner addition 2026-07-29 — docs/ (concept "ratified decisions"
      currency, BACKLOG/WORKLOG hygiene) AND README refreshed to the
      honest post-P3 state, then phase review + gate PR.

Chapter-packet acceptance (all): gate green (incl. untaught-sign
rule), surface review, top fact-review of grammar bites, citations
+ license classes verified, standing pedagogy rules (signs+figure+
script-beside-translit per chapter).

## M3-13 · Gate 3 review revisions (owner feedback)  [tier: top] [status: done] [deps: M3-12]
Goal: school-wide sidebar (all courses listed in order, only current
      expanded); footnotes below the nav line; refs footnoted not
      inline; concrete example per grammar marker (animate/inanimate
      possession); ch. 04 rebuilt on taught 𒁺 (du3 banished); ch. 02
      invisible-ak made the explicit lesson; EVERY returning glyph
      now links to its introduction (build-time transformer plugin +
      anchors, htmlproofer-validated).
Acceptance: gate green; 30 tests; surface-reviewed; PR #6 updated.

## M3-14 · Review round 3: universal sidebar, essence titles, NE↔LA, Nabu sign  [tier: top] [status: done] [deps: M3-13]
## M3-15 · Subscript indexes site-wide (owner stylistic ruling) + <sub> renderer  [tier: top] [status: done] [deps: M3-14]
## M3-16 · Sign hover bubbles (name · readings · meaning, pure CSS)  [tier: top] [status: done] [deps: M3-15]

Gate 3 CLOSED — PR #6 merged 2026-07-30, deploy green, live 102
pages surface-reviewed. Pedagogy commitments 6–9 codified
(concept.md §3.1) from the review rounds.

## Carried forward (post-P53, Nabu `signs` live 2026-07-30)
- Replace the hand value→glyph map (assets-src/data/pool-102.yml
  curation stays; identity resolution moves to `nabu signs --json`).
- bin/sign_seq.rb: true sign-occurrence counts via `nabu signs` over
  corpus lines instead of value-frequency proxy; regenerate queue at
  the next 102 stretch, additive-only per the data contract.

## Phase 4 — Egyptian hieroglyphs school opens (plan approved 2026-07-30; D0-a)

## M4-1 · School + course architecture (/hieroglyphs/, 101 index)  [tier: top] [status: done] [deps: --]
## M4-2 · Gardiner→Unicode mapper + hiero registry + font pipeline  [tier: top] [status: done] [deps: --]
## M4-3 · Validator generalization to script ranges; linker/bubbles for school #2  [tier: top] [status: done] [deps: M4-2]
## M4-4 · Frequency instrument (aes) + uniliteral teaching queue  [tier: top] [status: done] [deps: M4-2]
## M4-5 · Reading picker over aes + candidate readings (.docs/p4-readings.md)  [tier: top] [status: done] [deps: M4-4]
## M4-6 · Ch. 00 Orientation + 01 Stone, reed, papyrus + 02 Pictures that talk  [tier: top — voice] [status: done] [deps: M4-1]
## M4-7 · Ch. 03 How signs mean  [tier: top — mechanism] [status: done] [deps: M4-6]
## M4-8 · Ch. 04 Your first signs (uniliterals)  [tier: impl — spec'd] [status: done] [deps: M4-4, M4-7]
## M4-9 · Ch. 05 Names in rings (cartouches)  [tier: impl — spec'd] [status: done] [deps: M4-5, M4-8]
## M4-10 · Ch. 06 The offering formula  [tier: top — formula] [status: done] [deps: M4-9]
## M4-11 · Cross-school stitching, docs/README refresh, gate PR  [tier: top] [status: done] [deps: M4-10]

Acceptance per chapter packet: gate green (untaught-sign +
font-coverage over U+13000–1342F), surface review, fact-review of
script-history claims against cited grammars (Allen, Gardiner),
URN + license per reading, pedagogy commitments 1–9.

## Decision items — Phase 4 (ruled 2026-07-30, with plan approval)
- D4-a · RULED: linear sign display; quadrat stacking taught via SVG
  figures; simplification declared in the course Reference.
- D4-b · RULED: Leiden/Egyptological display transliteration
  (ꜣ ꜥ ḥ ḫ š ṯ ḏ, italic); MdC ASCII only when explicitly quoting
  corpus data (the ATF/subscript pattern).
- D4-c · RULED: opening-stretch readings print left-to-right; sign
  orientation/direction taught early, real RTL exhibit in a later
  stretch.

## Decision items — Phase 3
- D3-a · May Edubba quote short NC-licensed passages (ETCSL, license
  class nc) as graded readings? The site is non-commercial and every
  reading is cited + licensed in place, but original prose is
  CC BY-SA — owner ruling needed on the mix. Until ruled: CDLI
  (attribution) only. Candidate NC readings recorded in
  .docs/p3-readings.md (e.g. "an gal-ta ki gal-še3").