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

## M1-6 · edubba.ac goes live  [owner action] [status: ready] [deps: M1-1]
Goal: custom domain on Pages + DNS records; site serves at
      https://edubba.ac with HTTPS.
Acceptance: curl -sI https://edubba.ac returns 200 with the landing
      page; recorded here.

## Decision items — Phase 1
- (none)

---

## Phase 2 — Cuneiform 101 · Foundations (plan approved 2026-07-29)

## M2-1 · Course architecture  [tier: top — first course of the site] [status: ready] [deps: --]
Goal: /cuneiform/101/ course index (TOC 00–10), chapter template
      wiring (course/prev/next), taught-signs front-matter format.
Acceptance: gate green; TOC lists all chapters; nav round-trips.

## M2-2 · Taught-signs validator  [tier: top — pedagogy oracle, gate semantics] [status: ready] [deps: M2-1]
Goal: gate rule: a chapter may only use cuneiform signs taught in
      chapters ≤ its own (per `teaches:` front matter).
Acceptance: seeded violation red; HEAD green; tests pin the rule.

## M2-3 · Sign sequencing table  [tier: top — curriculum methodology, owner-adjacent] [status: ready] [deps: --]
Goal: corpus frequency (nabu: CDLI/Oracc) × curated complexity/
      iconicity per sign; committed data + offline-reproducible rank.
Acceptance: data files committed with citations; ch. 04 starter set
      justified by BOTH criteria.

## M2-4 · Ch. 00 Orientation  [tier: top — course voice] [status: ready] [deps: M2-1]
## M2-5 · Ch. 03 How signs mean  [tier: top — mental-model spine] [status: ready] [deps: M2-1]
## M2-6 · Ch. 04 Your first signs  [tier: top — sign-teaching template] [status: ready] [deps: M2-2, M2-3, M2-5]
## M2-7 · Ch. 01 Clay and reed  [tier: implementation] [status: ready] [deps: M2-4]
## M2-8 · Ch. 02 From tokens to signs  [tier: top — first SVG evolution panels] [status: ready] [deps: M2-4]
## M2-9 · Ch. 05 Counting  [tier: implementation] [status: ready] [deps: M2-6]
## M2-10 · Ch. 06 Seals and bricks  [tier: implementation — readings pre-pulled, top reviews licenses] [status: ready] [deps: M2-6]
## M2-11 · Ch. 07 The tablet house  [tier: implementation] [status: ready] [deps: M2-4]
## M2-12 · Ch. 08 One script, many tongues  [tier: implementation] [status: ready] [deps: M2-4]
## M2-13 · Ch. 09 Decipherment  [tier: implementation — top fact-review mandatory] [status: ready] [deps: M2-4]
## M2-14 · Ch. 10 Reference  [tier: implementation — partly generated from registry] [status: ready] [deps: M2-6]
## M2-15 · School/landing flip to "101 open"  [tier: top — public promise] [status: ready] [deps: M2-4..M2-14]
## M2-16 · Gate 2 prep: phase review, README, gate PR  [tier: top] [status: ready] [deps: M2-15]

Chapter-packet acceptance (all): rake gate green (incl. taught-signs
rule), surface review of rendered page, top-tier factual review with
named scholarly basis, citations resolve, licenses stated.

## Decision items — Phase 2
- D0-a · RULED with P2 approval (2026-07-29), option (a): P3 = 102
  Sumerian chapters 00–05, P4 opens the Egyptian school; 102/103
  continue in alternating phases thereafter.
