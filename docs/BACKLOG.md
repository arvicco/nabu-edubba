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
## M7-14 · Owner review round 4 (rebuilt notes)  [tier: top — Fable] [status: done] [deps: M7-13]
   Six findings dictated after the ctrl-s draft loss (preserved in
   .docs/owner-review-round4.md): gur term bubble; "stretch,
   measured" gloating cut from chs 05/11 (promises kept, brag
   removed); ch07 kalam-ma-ka's final -a identified as the locative
   (corpus context verified — it is the eduba doxology ch16 quotes),
   a-zu's a- unpacked, -am₃ gets an attested example (e₂-zu mah-am₃,
   Ninurta B D.8, signs OSL-resolved); ch08 ba-/in- show their
   glyphs and the ba-ti diagram reordered noun-first/verb-last.
## M7-13 · E Addenda: Egyptian glossary split out  [tier: top — Fable] [status: done] [deps: M7-12]
   Owner-directed: hieroglyphs school gets its own Addenda shelf at
   /hieroglyphs/addenda/ with the Egyptian glossary — 17 terms used
   only by the Egyptian courses (classified empirically by grep:
   serekh, cartouche, uniliteral…, hieratic, demotic) tagged
   school: hieroglyphs in terms.yml (additive field) and rendered
   at /hieroglyphs/addenda/terms/; /terms/ keeps the shared +
   cuneiform terms with a cross-link. Term linker now routes each
   bubble to its term's home glossary (multi-page support in
   script/term_linker.rb + plugin, tests added). C102 ch17
   "emphatic prefix" reworded to "affirmative prefix" (Foxvog's
   term — and dodges the phonetics bubble). Stale hieroglyphs
   catalog entry ("opening chapters arriving") fixed in passing.
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

Gate 7 CLOSED — PR #10 merged 2026-08-02, CI + deploy green, live
surface verified. Cuneiform 102 complete (19 chapters, 51 signs,
77 total, ~54% coverage floor). Owner review rounds 1–4 absorbed;
walkthrough law sharpened in the rulebook (piece-by-piece, no
crammed glosses); Addenda shelves born in both schools (Writing
primer from the wedge-order scout; glossary split C/E); é banned
in transliteration with rulebook enforcement; every chapter
mention linked course-wide. Incident recorded: 2h of owner review
notes lost to ctrl+s stash (unbound now; notes land in .docs/
immediately, long drafts via external editor).

## Phase 8 — Hieroglyphs 102 · Middle Egyptian, first stretch (approved 2026-08-03: "E102, let's have 6 chapters in the first stretch" — 00 + chs 01–06)

## M8-1 · E102 rulebook extension (docs/courses/hieroglyphs.md)  [tier: top — Fable] [status: done]
   Conventions BEFORE content, per the rulebook law: verb-form
   display and glossing (sḏm=f notation), suffix-pronoun display,
   sentence-type terminology, corpus line-selection rules for the
   literacy track, coverage-chart method. Machine-checkable subset
   into script/rulebook.rb same commit.
## M8-2 · Instruments: E102 queue + reading sweep  [tier: top] [status: done — blocker cleared 2026-08-04, discovery-driven pins, 2120-line sweep] [deps: M8-1]
   Computed sign queue for the literacy track (curriculum-compiler
   run over the committed aes frequency table, continuing from
   E101's 53 signs; additive site/_data/hieroglyphs102_queue.yml +
   contract test); reading sweep via hiero_reading_picker into
   .docs/p8-readings.md — whole fully-annotated aes lines only,
   URNs verified before any citation.
## M8-3 · Ch. 00 — orientation: the literacy track  [tier: top — Fable] [status: done] [deps: M8-2]
## M8-4..M8-9 · Chs. 01–06 — first stretch subject chapters  [tier: top — Fable] [status: done] [deps: M8-3]
   Grammar in reading-sized bites, sequence driven by the sweep
   (expected terrain: the verbal sentence and sḏm=f, direct and
   indirect genitive, adjectives, adverbial sentences with
   prepositions); every chapter opens with 1–3 thematic signs,
   piece-by-piece walkthroughs per the sharpened law.
## M8-10 · Stretch close + stitching, gate PR  [tier: top] [status: done] [deps: M8-9]

Gate 8 CLOSED — PR #11 merged 2026-08-04, CI + deploy green, live
surface verified in pixels. Hieroglyphs 102 first stretch live
(chs 00–06, 21 signs, aes coverage 71.4→79.0%); rulebook §8
landed before content; every reading token-verified with URNs.
Incident recorded mid-phase: a red gate shipped once when its
output was piped through grep|head (pipeline exit masked the
failure) — gates are now read plain, never filtered.

## Phase 9 — Sign Codex, Stage A (retention plan approved in principle 2026-08-04; keywords + one-page-per-sign Addenda shelves, cuneiform pages first)

Source: .docs/sign-retention-plan.md (owner-ruled rewrite: the
keyword + story layer is the foundation; retrieval instruments
follow in a later stage). Permalinks owner-ruled (2026-08-04,
final): traditional sign-name slugs — /cuneiform/addenda/signs/
<name>/ (ASCII forms: asz, gal, e2), /hieroglyphs/addenda/signs/
<gardiner>/ — names are stable and unique where keywords may be
re-chosen as better stories emerge.

## M9-1 · Codex laws into both rulebooks  [tier: top — Fable] [status: done]
   Laws BEFORE content: keyword uniqueness within each school;
   the two-heading honesty rule (attested "Where it comes from"
   vs invented "How to remember it" — invention never masquerades
   as history); a chapter that teaches a sign ships its codex
   page same-commit; keyword-slug permalinks. Machine-checkable
   subset into script/rulebook.rb + tests same commit.
## M9-2 · Keywords + confusables backfill (all 154 signs, both schools)  [tier: top — Fable] [status: done — incl. the 3 unpinned pool signs] [deps: M9-1]
   Additive keyword: field in all four registries (unique per
   school — the three "great/big"s differentiated on purpose;
   invented keywords for pure syllabograms); curated
   confusable_with: sets; contract tests updated same commit;
   gate check for uniqueness and presence.
## M9-3 · Codex machinery  [tier: top] [status: done] [deps: M9-2]
   sign layout (glyph, keyword title, readings, taught-in link,
   confusable rows rendered from data; prose sections are the
   only hand content); Signs shelf index for the C Addenda
   (glyph + keyword + readings + taught-in, curriculum order);
   sidebar wiring; fonts.
## M9-4 · C101 codex pages (26 signs)  [tier: top — Fable] [status: done — plus BA taught-twice fix + taught-once guard] [deps: M9-3]
## M9-5 · C102 codex pages I (chs 00–08, 26 signs)  [tier: top — Fable] [status: done] [deps: M9-3]
## M9-6 · C102 codex pages II (chs 09–17, 25 signs)  [tier: top — Fable] [status: done] [deps: M9-5]
## M9-7 · C-school sign-table link sweep + stitching, gate PR  [tier: top] [status: done — sweep is a sign_linker extension, anchors preserved] [deps: M9-6]
   Every C-course sign-table glyph links to its codex page (links
   land only once all pages exist — gate enforces resolvable
   links); page-exists gate check activated for the C school;
   Addenda catalog updated; surface review in pixels; PR.

Acceptance per packet: gate green (incl. new rulebook checks);
origin sections cited with certainty flagged; stories tied to
keyword AND shape, plainly marked as ours; minimal diffs to
published chapters (glyph links only). E-school pages + links and
the retrieval/decks stages are OUT of this phase (Stages B–C).

Gate 9 CLOSED — PR #12 merged 2026-08-04, CI + deploy green, live
surface verified in pixels (77 codex pages serving, table glyphs
linked, shelf index live from data). Owner review absorbed as law:
codex lines are fully readable, never a ▢ (rulebook §7) — 11 pages
requoted from full-inventory-verified lines (ki-en-gi, lu₂-diŋir-mu,
1(u) še gur lugal…); glyph links wear no underline. Incidents fixed
along the way: BA taught twice (now one seat + taught-once test),
P210013 miscited as Umma (Girsu).

## Phase 10 — Sign Codex, Stage B: the hieroglyph codex (plan pending owner approval)

## M10-0 · Site favicon (owner add-on, approved with the plan)  [tier: top] [status: done]
   The family favicon from Nabu (.docs/inbox delivery): É 𒂍, the
   house — dark chocolate on old paper; svg + ico + touch icon in
   the site root, wired in the default layout head.
## M10-1 · E Signs shelf index + Addenda wiring  [tier: top] [status: done]
   /hieroglyphs/addenda/signs/ index live from both E registries in
   curriculum order (machinery reused; Gardiner-code slugs); E
   Addenda catalog entry; sidebar chapter.
## M10-2 · E101 codex pages I (chs 0–4, 29 signs + 2 pulled forward)  [tier: top — Fable] [status: done]
   The uniliteral core: attested lines box-free per the §7 law,
   found via the hiero picker with the full 74-sign inventory,
   every display token-matched to the source's hiero_inventar.
## M10-3 · E101 codex pages II (chs 5–11, 24 signs)  [tier: top — Fable] [status: done — pushed red once: gate piped through tail, law re-broken and re-learned; fixed by the M10-4 commit]
## M10-4 · E102 codex pages (19 remaining signs)  [tier: top — Fable] [status: done — V10 cartouche carries a flagged no-line exception]
## M10-5 · Activation + stitching, gate PR  [tier: top] [status: done — E102 queue wired into sign_linker (its tables had never been linked at all); E page-check live]

Gate 10 CLOSED — PR #13 merged 2026-08-04, CI + deploy green,
live surface verified in pixels (E shelf in school blue, keyword
columns serving). Owner review absorbed in four rounds: school
accent now derived from URL (every E page had rendered in
cuneiform orange since E101 shipped — chapters never carried
school: front matter); keyword column added to every chapter sign
table by registry-verified sweep (158 rows, the §7 law finally
fully delivered); sign-table widths rebalanced (last column 42%,
tail-fit opt-out for references/shelves) with headers shortened
to Name/Key. One red push mid-phase (gate piped through tail —
the recorded incident relapsed) fixed forward same hour.
   Flip the E page-per-sign gate check; sign-table glyph links
   self-heal via sign_linker (verify in pixels, incl. E102's
   promised retrofit); Addenda catalogs; surface review; PR.

## Phase 11 — Sign Codex, Stage C: the retrieval layer (plan pending owner approval)

Source: .docs/sign-retention-plan.md Stage C — the survey's top
evidence tier (spaced retrieval), built on the keywords and codex
pages Stages A–B laid down. Everything text-pure: retrieval via
native <details>/<summary> disclosure, wall-clock scheduling via
exported decks, zero JS.

## M11-1 · Retrieval laws into the rulebooks  [tier: top — Fable] [status: done]
   Conventions BEFORE instruments: warm-up panel format (prompts
   by keyword, production direction first, answers folded);
   drill-shelf format (three directions, deterministic interleave,
   lookalikes adjacent); deck-export rules (sign→identity cards,
   keyword + story + one attested line, CDLI/aes attribution only
   — ETCSL stays out of redistributable decks); the read-it-cold
   clause (script-with-translit law gains a folded-translit drill
   exhibit form); and the REINFORCEMENT-SELECTION law (owner
   ruling 2026-08-04, approved with the plan): when choosing a
   NEW chapter's example lines, candidates that also exercise
   older signs due for reinforcement are preferred — the pickers
   score it; a line that only shows the new sign loses to one
   that revises while it teaches.
## M11-2 · The spiral warm-up  [tier: top] [status: done — 47 chapters]
   A generated panel at the top of every subject chapter, zero
   hand-authoring: 4–6 retrieval prompts against signs from
   chapters N−1, N−2, N−4, N−8 (cross-course into 101 per
   school), keyword-first ("*big* — draw it, then check"),
   answers behind <details>. Rendered by the chapter layout from
   the registries — no per-file edits; all four courses at once.
## M11-3 · Drill shelves in both Addenda  [tier: top] [status: done]
   Per school, a generated drill page: every taught sign as
   disclosure-cards in three directions, deterministically
   shuffled so neighbors are not chapter-mates, confusable pairs
   deliberately adjacent as contrast rows; a print stylesheet
   turns the same page into cut-out Leitner cards.
## M11-4 · Study decks shelf + deck exports  [tier: top] [status: done — 151 cards, contract-tested]
   bin/deck_export.rb emits per-course Anki-importable CSV
   (committed, downloadable); the Study decks Addenda shelf
   (owner-ruled home): download links, the Anki-import and
   FSRS-switch how-to, tool links — tooling talk lives here and
   nowhere else.
## M11-5 · Read-it-cold + frontier  [tier: top — Fable] [status: done — cold-read transform (35 chapters), reinforcement scoring in both pickers, frontier picker + two Almost yours pages]
   Each course's star readings repeated bare at chapter end
   behind a disclosure (read the script cold, then unfold); the
   picker gains a ≥90% mode feeding a per-school "almost yours"
   frontier page — famous passages three signs out of reach,
   ▢-tolerant by design and saying so.
## M11-6 · Stitching + surface review, gate PR  [tier: top] [status: done]
## M11-7 · The deal — drill deck cuts  [tier: top] [status: done — 12 cuts/school, dated deploy features one, tiles + :visited fade; review round: confusables split to own shelf page]
   Owner-ratified 2026-08-05 in PR-#14 review: pseudo-randomness
   without JS. Twelve seeded orderings of the same deck (varied
   hash multiplier — a constant offset would only rotate the
   cyclic order), generated as cut pages; the drills page inlines
   the cut picked by EDUBBA_DEAL_DATE (MJD mod 12, deploy-only —
   gate/local builds are date-free and feature cut 1) and deals
   all twelve as face-down tiles, :visited fading used ones. A
   daily cron on the Pages workflow re-renders main, committing
   nothing. Law in cuneiform.md §8 "The deal".

Gate 11 CLOSED — PR #14 merged 2026-08-05, CI + deploy green,
live verified in pixels (today's tile cut 10 for the deploy date,
cut pages and confusables serving, reference Wedges gone and
Taught-in linking). Owner review absorbed in three rounds, each a
durable change: the deal (M11-7, both active and passive
entropy); Easily confused split to its own shelf; the deck hidden
under the tiles; Taught-in cells linked on every surface that had
them as text; wedge counts dropped from all displays (registry
field and compiler scoring intact).

## Phase 12 — C103 Akkadian, stretch 1 (Gate 12 CLOSED — PR #15
merged 2026-08-06, nineteen review rounds absorbed; the rounds
ruled: phonetic bracket law refinements, no homophone indexes +
CAPS sumerograms in akk readings (akk-translit lint), veteran
tips = name·reads·hook, veteran links route to the akk
reintroduction, sumerograms are veterans too (KALAM/LUGAL rows +
codex pages), ambient veterans keep sux bubbles, item-by-item
breakdowns for new-grammar readings (§5), Means-column CSS floor,
chapter-link + nav-label + codex-reads lint rules, terms contract
test)

Source: owner pick 2026-08-05 ("let's start on Akkadian").
Rulebook extension FIRST (carried constraint from the Phase 11
closure). Detailed plan: .docs/phase-12-plan.md. Anchor text
verified in Nabu: Codex Hammurapi composite (cdli p464358,
3,641 lines, license attribution). Proposed rulings pending
owner rulings 2026-08-05: dialect = Old Babylonian; course
/cuneiform/103/ ships stretch 1; transliteration law approved;
akk frequency base approved; LANGUAGE SEPARATION ruled — no
mixed codex: existing Addenda stays purely Sumerian (retitled
C SUX Addenda, permalinks untouched), a new C AKK Addenda
carries a completely separate Akkadian Sign Codex on its own
frequency base; the KEYWORD is the cross-language invariant
(one keyword per sign, identical across codices, unique across
the school); C103 veterans link to the akk codex.

## M12-1 · The Akkadian law  [tier: top — Fable] [status: done — §9 ruled, two-codex checks live, 3 terms]
   cuneiform.md Akkadian sections (dialect, transliteration +
   bound transcription, language separation + keyword invariance,
   ordering) + rulebook.rb two-codex checks + terms.yml. No
   content until this lands.
## M12-2 · Instruments  [tier: mid] [status: done — OB freq base (204,820 passages), warmup 3rd segment, per-course codex routing, SUX retitle; queue/pool/compiler land with M12-3 content, per the C102 precedent]
   akk value-frequency (lect=akk:ob, separate base), picker
   --lang=akk, cuneiform103 registry/queue + pool-103, compiler
   run; warm-up third segment; sign_linker per-course routing to
   the akk codex; C AKK Addenda scaffolding + C SUX retitle;
   exact-value tests. Fold the ASCII value-display nit fix.
## M12-3 · Orientation + first syllables  [tier: top — Fable] [status: done — pool-103 (20 new + 6 veterans, all pinned, nabu-verified), akk compiler, ch 00-01]
## M12-4 · The shape of the language  [tier: top — Fable] [status: done — ch 02-05: cases/mimation, construct, prologue lines 1-3, preterite/durative]
## M12-5 · šumma awīlum  [tier: top — Fable] [status: done — ch 06-07: law 1 (one honest box, then none), the creed; 26 akk codex pages]
## M12-6 · Stitching + surface review, gate PR  [tier: top] [status: done — C AKK Addenda + signs shelf, catalogs, akk codex checks flipped live, fonts, pixels]

## Phase 13 — C103 Akkadian, stretch 2 (Gate 13 CLOSED — PR #17
merged 2026-08-08, CI + deploy green, live pixels verified;
seven review rounds, each closing a rule class: §5
mechanism-demonstrated / one-model-verb / parallel roots /
root-before-slot, table width budget + tail-fit-width lint,
§9 bracket-is-the-voice + the ID₂/Id chain,
shows-never-licenses-a-reading + course check, title-language
lint; D13-a open on hieroglyphs frames)

Source: owner pick 2026-08-06 ("AKK stretch next"). Honors stretch
1's three promises: the D/Š/N stems named (ch05 footnote), the
plurals tabled (ch07 breakdown), anāku (ch07 close). Detailed
plan: .docs/phase-13-plan.md. Reading arc: plurals → stems → laws
2–3 → laws 196–200 (eye for an eye) → one OB letter → anāku →
stretch close; akk retrieval mirror (drills + deck) lands at the
end, lifting the Gate-12 deferral.

## M13-1 · The stretch-2 law  [tier: top — Fable] [status: done — §9 stretch-2 rules + verbal stem term]
   Rulebook §9: plural display, stem naming (G/D/Š/N), epistolary
   citations, independent pronouns; terms.yml additions. No
   content until this lands.
## M13-2 · Instruments  [tier: mid] [status: done — reading map + pins in .docs/phase-13-plan.md; letters picked (CUSAS 43,28 + YOS 13,172); pool rows land with chapters per the stretch-1 precedent]
   pool-103 stretch-2 pins (identities via nabu signs --lang=akk),
   letter pick (CDLI OB, attribution only), coverage report.
## M13-3 · ch 08–09 — plural; the stems named  [tier: top — Fable] [status: done — 2 chapters, 6 signs, 6 codex pages, stative term, hedges resolved]
## M13-4 · ch 10–11 — law 2 whole; eye for an eye  [tier: top — Fable] [status: done — ordeal both halves (one TE box, falls ch14), law 196 + 197 exhibit, E2/TUR sumerogram veterans, 8 codex pages]
## M13-5 · ch 12–13 — a letter; anāku  [tier: top — Fable] [status: done — epistolary frame + plea, epilogue self-naming, la/ul law, 4 codex pages]
## M13-6 · ch 14 + catalogs  [tier: top — Fable] [status: done — stretch close, TE box falls, course/school indexes updated]
## M13-7 · Akk retrieval mirror  [tier: mid] [status: done — DRILL_SHELVES per-course config, akk drills + 12 cuts + Anki deck (47 cards), decks page]
   DRILL_SCHOOLS gains akk; edubba-cuneiform-103 deck (license-
   hard-fail as ever).
## M13-8 · Stitching + surface review, gate PR  [tier: top] [status: done — pixels verified (ch08/10/13, akk drills), WORKLOG, PR]

## Decision items — Phase 13

- D13-a · OPEN (found 2026-08-08, mechanizing the shows-in-reading
  rule after the law-197 report): three hieroglyphs-101 chapters
  read `shows:`-licensed signs inside reading figures — ch05/ch11
  (cartouche rings 𓍹𓍺, and ch05's lion/lasso in the Ptolemy
  demo) and ch06 (the stroke 𓏤). The cuneiform law now bans
  shows-in-readings outright; Egyptian's silent frames may deserve
  an exemption or the same ban. Needs an owner ruling + a
  hieroglyphs-rulebook entry; the mechanical check is scoped to
  cuneiform until then.

## Phase 14 — C103 Akkadian, stretch 3: the course closed (plan approved 2026-08-08)

Source: owner pick 2026-08-08 ("C103 stretch 3, let's wrap up
Akk"), plan approved same day. Pays every standing debt (ch02
dual, ch09 perfect hedge, ch11 bone law in signs, ch14 contracts
promise) and closes the course at ch18 with its Reference.
Detailed plan: .docs/phase-14-plan.md.

## M14-1 · The stretch-3 law  [tier: top — Fable] [status: done — §9 stretch-3 (perfect, dual, compound sumerograms, contracts, weights, Reference), perfect/dual terms + term-scope guard]
   Rulebook §9 stretch-3: perfect, dual, compound sumerograms,
   contracts, weights, Reference conventions; terms perfect +
   dual with the new term-scope guard. No content until this
   lands.
## M14-2 · Instruments  [tier: mid] [status: done — reading map + pins in .docs/phase-14-plan.md; 10 new signs OSL-pinned (1+3+3+3, all within the 1–3 law); contract picked (PBS 8/2, 195 = p257793, attribution); ch18 close = the epilogue invitation a:3240'–3256'; LU stays reserve, stated honestly] [deps: M14-1]
   pool-103 stretch-3 pins (nabu signs --lang=akk), contract
   pick (CDLI OB legal, attribution only), coverage report,
   reading map + pins appended to the plan.
## M14-3 · ch 15 — the perfect  [tier: top — Fable] [status: done — iptaras on both model roots, law 202 whole (▢▢▢ whip line), law-1 melody stated, bone-law verbs in signs; AZ + TA/MAḪ veterans, 3 codex pages, 50-card deck] [deps: M14-2]
## M14-4 · ch 16 — eye, tooth, bone + dual  [tier: top — Fable] [status: done — law 197 paid in signs, law 200 whole (meḫrišu), scale of persons in transcription, dual paid; GIR₃/PAD/AḪ + DU veteran, 4 codex pages, 54-card deck, 75.7%] [deps: M14-3]
## M14-5 · ch 17 — a contract  [tier: top — Fable] [status: done — PBS 8/2, 195 whole (obverse + year-name + 2 witnesses), two-languages-one-tablet teaching, EN.ZU rebus, year-name term; MAŠ₂/GIN₂/INANNA + KI veteran, 4 codex pages, 58-card deck] [deps: M14-4]
## M14-6 · ch 18 + catalogs — close + Reference  [tier: top — Fable] [status: done — the invitation read whole (17 lines, precative festival), tense×stem grid with honest dashes, queue-driven Reference table with anchors, 76.4% final coverage, frontier; AR/UR₂/ALAN, 3 codex pages, catalogs flipped to complete] [deps: M14-5]
## M14-7 · Retrieval mirror update  [tier: mid] [status: done — deal includes all stretch-3 signs (build-verified), deck 61 cards with loan lines, decks-page provenance line updated, Reference-anchor law reconciled with the site-wide chapter-seat convention] [deps: M14-6]
   akk drills + deck regenerated; decks page counts.
## M14-8 · Stitching + surface review, gate PR  [tier: top] [status: done — built-site structural review (nav, term bubbles, reference rows, drill deal), WORKLOG, PR #18] [deps: M14-7]

---

## Phase 15 — wave 3 opens: the sinograph school (rulings 2026-08-09)

Source: owner directive 2026-08-09 (post-Gate-14): plan the third
school under a better semantic name, focused on applying modern
techniques to the HISTORIC tradition, not re-teaching modern
Chinese/Japanese. Rulings same day: name sinographs, classical-first
thesis, pinyin voice (diacritics never indices), keyword law,
Shuowen glyph fallback. Consideration: .docs/sinograph-school-scout.md;
plan: .docs/phase-15-plan.md.

## M15-1 · Ratification record + rulebook  [tier: top — owner-ruled domain recording] [status: done — concept §2/§3/§7 + docs/courses/sinographs.md skeleton, rulebook before content] [deps: --]
Goal: wave-3 rulings recorded in concept.md; sinograph rulebook
      written before any content, ruled laws only, proposals marked.
Acceptance: rake gate green; rulebook exists; concept §7 carries the
      dated rulings.

## M15-2 · School rename hanzi → sinographs  [tier: top] [status: done — /sinographs/ page (ruled catalog), /hanzi/ layoutless redirect stub, card/accents/body-class renamed] [deps: M15-1]
Goal: the ratified name site-wide; the live /hanzi/ URL never breaks.
Acceptance: gate green (html-proofer resolves both pages); redirect
      carries a visible link, meta refresh, noindex.

## M15-3 · Classical-corpus frequency instrument  [tier: top — first-of-family instrument, ordering methodology] [status: done — 721.8M tokens / 28,368 chars over 4.57M Kanripo passages; top-3000 = 95.9% coverage; canonical wenyan head 之不以也而; 17 top rows are edition-variant glyphs (no kMandarin), variant folding deferred to queue time] [deps: M15-1]
Goal: bin/ instrument computing character frequency over the
      license-verified Kanripo corpus (CC BY-SA 4.0, scout
      2026-08-09) merged with simplicity inputs (Unihan strokes,
      Mandarin readings, BabelStone IDS) per concept §3.1; committed
      table at assets-src/data/char-freq-kanripo.tsv (the
      hiero-freq-aes precedent — the frozen site/_data contract
      arrives with the first queue, at content time).
Acceptance: unit tests for the parsing/counting units in the same
      commit; table committed with provenance + license header;
      doc-spread column beside raw counts.

## M15-4 · S101 ch00–04 + codex start  [tier: top — Fable, content] [status: done — ch00–04 live (15 chars, 6.5% coverage, 8 real readings from 6 Kanripo witnesses); codex shelf open with rulebook §8, staged registry entry, signs index + ren/da/tian pages] [deps: M15-3]
Goal: orientation + first chapters of Sinographs 101 in the wave-1
      mold; Character Codex shelf started.
Acceptance: gate green incl. pinyin-display lint, keyword
      uniqueness, readings-strict, size-law guard; pixel review
      per §6b.

## M15-5 · Codex backfill — the shelf complete  [tier: top — Fable, content] [status: done — all 29 characters paged (26 written this round), pages: true flipped, every chapter table cell now codex-routed; spot-checked wang + wei-flavor] [deps: M15-4]
Goal: one codex page per remaining taught character (the 28-char
      queue minus ren/da/tian), each with origin
      (certainty-labeled), memory hook, real attested line; then
      flip pages: true on the sinographs CODEX entry
      (staged-activation law).
Acceptance: rulebook.rb codex check green with pages: true; gate
      green; pixel spot-check of two pages.
Goal: orientation + first chapters of Sinographs 101 in the wave-1
      mold (signs from ch00, keyword law live, pinyin display law
      live), codex shelf started.
Acceptance: gate green incl. pinyin-display lint + keyword-uniqueness
      check landing with the first content commit.

## M15-6 · Pinyin audio completion  [tier: implementation — mechanical fetch, URLs recorded] [status: done — throttle cooled after ~25 min; all ten fetched paced, transcoded, wired (trap-row grid + ü/e table), credits complete] [deps: --]
Goal: vendor the ten remaining Commons recordings for the primer's
      initials/finals rows (chī shí rì · zì cí sī · bā pà · nǚ lǜ ·
      é) — exact verified URLs in the 2026-08-10 audio scout report;
      Wikimedia rate-limited this box mid-fetch, so refetch paced
      (≥30s gaps) after cool-down, transcode per the §2 audio law,
      extend CREDITS.txt + the trap-rows table.
Acceptance: files play (ffprobe); gate green; credits complete.

## Decision items — Phase 15

- D15-a · Character forms (was D-W3c) — RULED 2026-08-10 as
  recommended: traditional (kaishu) base as the classical corpus
  writes them; simplified as later-hand notes, never the teaching
  base. Same ruling added the SIZE LAW: sinograph characters
  display bigger than cuneiform/Egyptian script everywhere
  (rulebook §6, style-guard-pinned).
- D15-b · Old-form glyph fonts — SCOUTED 2026-08-09
  (.docs/scouts/sino-oldform-glyphs.md): seal is coverable by a
  vendorable font (CNS11643 Quanziku Shuowen seal TTF,
  OGDL-Taiwan-1.0, explicitly CC BY 4.0-compatible, 6,721 glyphs
  on ordinary codepoints); oracle bone/bronze have NO vendorable
  font (Unicode has no block; best-coverage fonts non-
  redistributable) — committed CC0/PD images instead (Academia
  Sinica 小學堂 CC0 dedication; Commons ACC project PD SVGs), in
  line with the ruled Shuowen fallback. S103 is feasible; the
  rulebook §6 law lands when S103 is scheduled.

---

## Phase 16 — S101 stretch 2: the borrowed words (owner pick 2026-08-10)

Source: owner at Gate 15 close ("Next phase extends S101 for the
next stretch"). Stretch law ruled in rulebook §5 (stretch-2
section) before content; plan in .docs/phase-16-plan.md. All
Gate-15 laws in force; box-share cap 45%; codex pages land in the
same commit as their chapter (shelf check live).

## M16-1 · Stretch-2 law + pool pins  [tier: top — Fable] [status: done — rulebook §5 stretch-2 section; batches ruled ch05–09, 26 chars] [deps: --]
## M16-2 · Reading map verified  [tier: top — Fable] [status: done — anchors verified (Analects 1.1/1.2/2.17/13.3 punctuated, 十有五年, 三十而立, Laozi 63); per-line verification continues at writing per the standing rule] [deps: M16-1]
## M16-3 · ch05 The busiest words + codex  [tier: top — Fable] [status: done — 之不也又有十, the loan move taught, first ZERO-BOX reading (未之有也), 6 codex pages, coverage 8.0→14.4%] [deps: M16-2]
## M16-4 · ch06 Knowing and walking + codex  [tier: top — Fable] [status: done — 矢知而行言, arrow-seeds-know per components-first, the borrowed beard, 人不知而不慍 at one box, 三人行 verb lit, 2.17 teaser; 5 codex pages; 16.2%] [deps: M16-3]
## M16-5 · ch07 Doing and being + codex  [tier: top — Fable] [status: done — 為無我心生, the elephant and the dancer, 無為 opened (Laozi 63 at one distinct box), 7.22 fourth visit with 我, 天下▢心; 5 codex pages; 18.0%] [deps: M16-4]
## M16-6 · ch08 Stopping at true + codex  [tier: top — Fable] [status: done — 止正是夕名, the footprint chain, rectification of names (13.3 in the punctuated Analects), Daxue know-where-to-stop, and the ZERO-BOX 2.17 whole (11 chars); 5 codex pages; 18.8%] [deps: M16-5]
## M16-7 · ch09 The master's opening + codex  [tier: top — Fable] [status: done — 者其亦于乎, 6.23 fifth visit at 25%, Analects 1.1 first two questions under cap, Laozi-25 fourth fragment, the Peach Tree; 5 codex pages; 20.9%] [deps: M16-6]
## M16-8 · Stitching + surface review + gate PR  [tier: top] [status: ready] [deps: M16-7]

## Decision items — Phase 16
- D16-a · Sinograph retrieval instruments (deck export + drills,
  the cuneiform/hiero mirror): proposal for phase 17 — the queue
  and codex carry everything a deck needs.

---

## Phase 17 — opening item: the player (owner report at Gate 16 close)

## M17-1 · Audio player integration redesign  [tier: top — visual identity, owner-interactive] [status: done — the pinyin IS the button (owner spec): a.say links play inline via the one sanctioned script, D17-a ruled and recorded in concept/CLAUDE/README/rulebook, gate allowlists exactly say.js; primer phonetics voiced; keyword slugs; loudness-normalized; say-audio lint; all 55 characters voiced; owner reviewed through five rounds] [deps: --]
Goal: replace the shrunk native <audio> pills in sign tables (and
      align the primer's players) with an integration the owner
      likes — designed together in an interactive session; if the
      chosen design needs the vanilla-JS enhancement layer the
      concept reserved for post-wave-1, that is decision item
      D17-a (owner-ruled domain: the no-JS ratification).
Acceptance: owner approves the rendered result on the served
      preview; gate green; style guard pins whatever geometry the
      design fixes.

## Decision items — Phase 17
- D17-a · Whether to open the concept's reserved vanilla-JS
  enhancement layer (progressive enhancement only, nothing may
  REQUIRE JS) for the audio player. Owner-ruled; raised by M17-1.

## Phase 18 — S101 stretch 3 (owner pick at Gate 17 close)

## M18-1 · Stretch law + reading map  [tier: top] [status: done — rulebook §5 stretch-3 ruled before content; all anchors Kanripo-verified, URNs in the plan] [deps: --]
Goal: rulebook §5 stretch-3 section (ch10–14, cap 40%, the
      chapter roster) ruled before content; every anchor reading
      verified against its Kanripo witness, URN recorded in the
      plan.
## M18-2 · Pool + compiler + first audio batch  [tier: top] [status: done — 26 rows staged per-chapter after the complete-shelf lesson; ch10-11 syllables acquired] [deps: M18-1]
Goal: 26 pool rows (parts, keywords, divergences noted), queue
      regenerated green; syllables for ch10–11 acquired through
      the pipeline.
## M18-3..7 · ch10–ch14  [tier: top — content Fable-only] [status: done — five chapters, 26 codex pages, every syllable voiced, gate green at each] [deps: M18-2]
Goal: one chapter per packet — chapter + codex pages + syllables
      wired; gate green at each.
## M18-8 · Stitching + Gate 18 PR  [tier: top] [status: done — README/worklog/phase line current; PR open] [deps: M18-7]
