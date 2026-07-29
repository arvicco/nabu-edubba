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
- (none yet; D0-a still open, needed before Phase 2 elaboration)
