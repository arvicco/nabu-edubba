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

## Carried forward — cuneiform school
- ~~Retrofit Cuneiform 101 chapters 00–03~~ DONE in Phase 4 review
  rounds (2026-07-31): all 13 chapters comply with the
  every-chapter-opens rule; IM moved to 101 ch. 01, strokes seated
  as signs in ch. 05, taught-once rule enforced.

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
- D3-a · RULED 2026-07-31: hybrid, leaning CDLI. Default to CDLI
  exemplar tablets (attribution); use ETCSL wherever pedagogy
  requires a clean composite line — short quotes, each labeled
  "license: ETCSL · non-commercial" in place. The LICENSE
  source-texts carve-out covers the mix; derivative users sort out
  their own reuse (owner: explicitly not our concern). Unblocks
  literary readings for the 102 continuation
  (.docs/p3-readings.md candidates).

Gate 4 CLOSED — PR #7 merged 2026-07-31, CI + deploy green, live
pages surface-reviewed (hieroglyphs 05, /terms/, retrofitted C101
05). Egyptian school open: Hieroglyphs 101 chs 00–06, 35 signs.
Site-wide principles shipped and codified: every-chapter-opens +
taught-once, term bubbles + /terms/ glossary, URN axis links,
subscript rendering, 3-level sidebar.

## Phase 5 — Cuneiform 102 second stretch (plan .docs/phase-5-plan.md; owner pre-approved "plan and execute" 2026-07-31)

## M5-1 · Instruments: `nabu signs --json` identity resolution + sign_seq true counts + additive queue regen  [tier: top] [status: done] [deps: --]
## M5-2 · Second-stretch pool curation (batches for chs 06–11)  [tier: top] [status: done] [deps: M5-1]
## M5-3 · Reading sweep per D3-a (CDLI + ETCSL) → .docs/p5-readings.md  [tier: top] [status: done] [deps: M5-2]
## M5-4 · Ch. 06 (names that are sentences — CDLI onomastics)  [tier: top — voice] [status: todo] [deps: M5-3]
## M5-5 · Ch. 07 (the copula: -me-en, "I am king")  [tier: impl — spec'd] [status: todo] [deps: M5-4]
## M5-6 · Ch. 08 (ergative + verbal chain round 2)  [tier: impl — spec'd] [status: todo] [deps: M5-5]
## M5-7 · Ch. 09 (proverbs — first whole literary lines)  [tier: top] [status: done] [deps: M5-6]
## M5-8 · Ch. 10 (royal hymn lines — ud-bi-ta, the literary register)  [tier: impl — spec'd] [status: todo] [deps: M5-7]
## M5-9 · Ch. 11 capstone (a literary passage whole)  [tier: top] [status: done] [deps: M5-8]
## M5-10 · Stitching, docs/README refresh, gate PR  [tier: top] [status: done] [deps: M5-9]

Acceptance per chapter packet: gate green (untaught-sign +
subscript-index + font coverage), surface review, pedagogy
commitments 1–9 (thematic opening signs, taught-once, concrete
example per marker, essence titles, terms.yml in same commit),
URN + license class per reading (ETCSL quotes labeled non-
commercial per D3-a), citations footnoted.
Gate 5 CLOSED — PR #8 merged 2026-07-31, CI + deploy green, live
pages surface-reviewed (ch09 pixels). 102 second stretch live:
chs 06–11, 60 signs taught, ~49% coverage floor. Owner rulings
absorbed during review: content is Fable-only (golden rule 9 —
no delegated chapters, ever); back-references to prior material
carry links; approximate name senses are given cautiously, never
omitted; grammar walkthroughs piece by piece, never checklist
glosses.

## Phase 6 — Hieroglyphs 101 second stretch (plan approved 2026-07-31, "Approved, execute")

## M6-1 · hiero_reading_picker.rb as committed instrument (per-chapter buckets, aes) + tests  [tier: top] [status: done] [deps: --]
## M6-2 · Second-stretch sign pool: biliterals, triliterals, classifiers (registry + aes ranks)  [tier: top] [status: done] [deps: M6-1]
## M6-3 · Reading sweep over aes → .docs/p6-readings.md  [tier: top] [status: done] [deps: M6-2]
## M6-4 · Ch. 07 — biliterals (two sounds in one sign)  [tier: top — Fable, rule 9] [status: done] [deps: M6-3]
## M6-5 · Ch. 08 — phonetic complements (spelling that checks itself)  [tier: top — Fable] [status: done] [deps: M6-4]
## M6-6 · Ch. 09 — classifiers (ch05's promise: people and titles)  [tier: top — Fable] [status: done] [deps: M6-5]
## M6-7 · Ch. 10 — triliterals (ankh, nefer, hetep: the culture words)  [tier: top — Fable] [status: done] [deps: M6-6]
## M6-8 · Ch. 11 — decipherment: Rosetta, Champollion, Ptolemy whole; real RTL exhibit (D4-c delivery)  [tier: top — Fable] [status: done] [deps: M6-7]
## M6-9 · Ch. 12 — Reference; stitching, README, gate PR  [tier: top] [status: done] [deps: M6-8]

Acceptance per chapter packet: gate green (untaught-sign +
font-coverage over U+13000–1342F), pedagogy commitments 1–9,
Leiden display translit (D4-b), linear display w/ SVG stacking
(D4-a), URN + license per reading, terms.yml in same commit,
surface review. All content written by the session model
(golden rule 9).

Gate 6 CLOSED — PR #9 merged 2026-07-31, CI + deploy green.
Hieroglyphs 101 complete (13 chapters, 53 signs). Owner rulings
absorbed: phonetics primers front-door in both schools; course
rulebooks as single source of truth (docs/courses/) with gate
checks; notation standardized (ŋ, subscript indexes) after the
drift incident.

## Phase 7 — Cuneiform 102 third and final stretch, chs 12–18 (approved 2026-07-31, "Approved, go"; six subject chapters, Reference at 18)

## M7-1 · Pool/queue extension: batches for chs 12–17 (~18 signs), additive regen  [tier: top] [status: done] [deps: --]
## M7-2 · Reading sweep chs 12–18 (CDLI + ETCSL per D3-a) → .docs/p7-readings.md  [tier: top] [status: done] [deps: M7-1]
## M7-3 · Ch. 12 — the chain completed: mu-, -na-, the votive's verb fully parsed  [tier: top — Fable] [status: done] [deps: M7-2]
## M7-4 · Ch. 13 — the locative and the cases, assembled whole  [tier: top — Fable] [status: done] [deps: M7-3]
## M7-5 · Ch. 14 — a proverb run: first multi-line passage  [tier: top — Fable] [status: done] [deps: M7-4]
## M7-6 · Ch. 15 — Šulgi's opening: a royal hymn passage whole  [tier: top — Fable] [status: done] [deps: M7-5]
## M7-7 · Ch. 16 — the tablet house speaks (eduba literature)  [tier: top — Fable] [status: done] [deps: M7-6]
## M7-8 · Ch. 17 — a literary capstone passage (per sweep)  [tier: top — Fable] [status: done] [deps: M7-7]
## M7-9 · Ch. 18 — 102 Reference; course complete  [tier: top] [status: done] [deps: M7-8]
## M7-10 · Stitching, docs/README refresh, gate PR  [tier: top] [status: done] [deps: M7-9]
## M7-12 · C Addenda: writing primer + terms anchored  [tier: top — Fable] [status: done] [deps: M7-11]
   Owner-directed: new school-level Addenda section (out-of-course
   shelf) at /cuneiform/addenda/ holding the Writing primer — the
   scribe's hand, sourced from the wedge-order scout (Taylor 2015
   overlap paleography, Cammarosano CWT, Wright/Huehnergard
   reconstructions; primary sources re-fetched before writing) with
   proven-vs-reconstruction labels, PA/GIŠ, overlap SVG — and the
   /terms/ glossary, now anchored in the sidebar under C Addenda.
   C101 ch00 gains the honestly-teachable wedge facts + primer
   links; school catalog updated (stale 102 entry fixed); PA+GIŠ
   into the font subset; Winkelhaken term added.
## M7-11 · Owner review round 3: full-course sequential fixes  [tier: top — Fable] [status: done] [deps: M7-10]
   Sequential review of all 19 chapters (mine + owner's own pass):
   locative named at ch01 and read honestly at ch10; nominalizer -a
   bite in ch14 (ch08's promise kept); nam-gi₄/-ke₄/-ani/-ma- gaps
   closed; dangling refs and slips fixed; ch00 chart decluttered +
   course promise + mu "my"; term bubbles (homophone, mina, shekel,
   nominalizer); meta → footnotes; é banned in translit (rulebook);
   chapter back-references linked course-wide.

Acceptance per packet: gate green (incl. rulebook checks), pedagogy
commitments 1–9, rulebook (docs/courses/cuneiform.md) obeyed —
notation decisions land there first; URN + license label per
reading; terms.yml same-commit (locative due); surface review.
