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

## M0-4 · README v1  [tier: top — public authorship statement, owner-adjacent] [status: in-progress — written (with LICENSE, CC BY-SA); owner accepts at Gate 0] [deps: M0-2]
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

## Phase 1 — site skeleton (outline only; elaborated after Gate 0)

Landing page as the map of writing (typology grid + family tree);
shared visual identity (typography, per-school accents, vendored
subsetted fonts incl. Noto Sans Cuneiform); one fully-styled sample
chapter exercising the whole layout; school stub pages for waves 1–3;
Pages live at edubba.ac (owner: Pages settings + DNS). Text-pure.
