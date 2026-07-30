# CLAUDE.md — Edubba

Edubba (é-dub-ba-a, "the tablet house") is a free static school of
writing systems: a Jekyll site published from this repo to GitHub Pages
at **edubba.ac**, teaching real reading literacy in scripting
traditions (cuneiform first). Branding is plain **Edubba** everywhere;
`nabu-edubba` is only the repo name. Read docs/concept.md before any
non-trivial task; it defines the schools/courses structure, ratified
decisions, and pedagogy. docs/DEV-LOOP.md governs process.

## Golden rules (non-negotiable)

1. **Target runtime is GitHub Pages via our own CI build: Jekyll 4.4
   on Ruby 3.3 (CI pin), kramdown/GFM.** Local dev may run newer Ruby;
   the Gemfile.lock is shared by local and CI — CI is the authority.
   Site sources live in `site/`; the built site must be pure static
   HTML/CSS. **Wave 1 ships text-pure: no JavaScript anywhere in the
   site** (ratified; the gate enforces it).
2. **Dependency policy: the Gemfile budget (jekyll, html-proofer,
   rake, minitest) is closed.** Never add a gem, webfont, or asset
   pipeline without asking. No JS dependencies exist, period.
3. **Never run deploys or network-mutating commands.** Merging to
   `main` (which deploys Pages), GitHub repo/DNS/Pages settings, gem
   installs, and `git push origin main` are HUMAN actions. You may
   prepare configs and print the exact commands.
4. **Never change the owner-ruled domain silently:** the ratified
   decisions in docs/concept.md §7, license and attribution statements
   on borrowed texts, the published permalink structure (once live),
   and the frequency-ordering methodology. If a task seems to require
   touching them, stop and flag a decision item.
5. **Machine-readable outputs are frozen contracts:** published URLs
   (permalinks) once live, and curriculum data files under
   `site/_data/` (sign lists, frequency tables) once introduced —
   additive changes only, contract test updated in the same commit.
6. **No network in tests or in the published site.** The gate runs
   fully offline (`html-proofer --disable-external`). Texts from Nabu
   are extracted at authoring time by `bin/` scripts and committed
   with URN + license; the site never fetches anything at runtime.
   Fonts and assets are vendored, never hotlinked.
7. **Minimal diffs.** Prefer the smallest behavior-preserving change;
   do not reformat, rename, or "clean up" beyond the task's scope.
8. **No secrets exist in this project and none may enter it.** The
   repo is public; never commit tokens, keys, or personal data.

## Commands

```
rake gate           # pre-commit gate: lint + test + build + check
rake test           # offline unit tests (minitest, test/*_test.rb)
rake lint           # conventions scan (script/lint.rb): no-JS rule,
                    #   front matter, relative-links rule
rake build          # jekyll build site/ -> _build/site
rake check          # html-proofer over _build/site (internal only)
rake serve          # local preview at http://127.0.0.1:4000
```

## Content rules (this project's equivalent of code style)

- Every borrowed text/passage carries its Nabu URN and license class;
  original prose is CC BY-SA. Never strip or alter attribution.
- Native script always accompanied by transliteration in the field's
  standard convention (ATF for cuneiform, MdC/Leiden for Egyptian,
  IAST for Sanskrit); conventions declared in each course's Reference.
- Graded readings may use only signs/vocabulary already taught (the
  "nothing untaught" validator joins the gate with the first course).
- Didactic claims cite their scholarly basis (standard grammars, sign
  lists) in-line; no confident nonsense about ancient scripts. Cite a
  given standard reference once or twice per course, not per chapter.
- Every chapter from the first-signs chapter on teaches 1–3 new
  theme-related signs (ideally opening the chapter); every chapter
  carries at least one graphic illustration; readings couple
  transliteration with native script, untaught signs as ▢.
- Chapter titles express the chapter's ESSENCE in a few short words
  (the grammar piece, the main idea) — never mechanical labels like
  "Batch III". Batches are a mechanic, not a name.
- Reference citations are FOOTNOTES (kramdown [^ref]) or Reference-
  chapter entries, never inline meta in the lesson flow. Every
  grammatical marker taught gets a concrete usage example a learner
  can hold (who owns what, where the caravan goes) — never a bare
  gloss.
- Chapters are Markdown in `site/<school>/<course>/`, numbered
  (`00-orientation.md`, …), `layout: chapter`, permalink
  `/<school>/<NNN>/<NN-slug>/`. Front matter carries the pedagogy
  contract: `chapter:` (ordinal), `teaches:` (signs this chapter
  introduces, as glyph strings), `shows:` (display-only exhibits).
  The gate enforces: a chapter's body may use only signs taught in
  chapters <= its own, plus its own `shows:` — nothing untaught in a
  reading, ever.

## Testing conventions

Minitest, `test/*_test.rb`, run by `rake test`; pure-Ruby units (lint
rules, later the curriculum compiler and validators) get exact-value
tests with tmpdir/string fixtures. Rendered output is graded by the
gate's build + html-proofer pass and, for visual work, the surface
review checklist in docs/DEV-LOOP.md §6b. No network, no live Nabu
calls in tests — committed extracts only.

## Git conventions

- Work on phase branches (`phase-N`) pushed to origin; `main` is
  owner-merged at gates (docs/DEV-LOOP.md).
- Conventional commits (`feat:`/`fix:`/`test:`/`refactor:`/`docs:`/
  `chore:`); imperative subject <= 72 chars; body explains WHY;
  reference packet IDs (M0-1).
- One logical change per commit; tests in the same commit as the code.
- No history rewrites on published branches; no tags (tags are gate
  actions).

## Repo map

```
site/           the published site (Jekyll source): _config.yml,
                _layouts/, assets/, index.md, <school>/<course>/
docs/           process + concept (in-repo public, not on the site):
                concept.md, DEV-LOOP.md, BACKLOG.md, WORKLOG.md
.docs/          GITIGNORED internal docs — phase plans, owner
                communication, surveys, consideration output. General
                owner rule (2026-07-29): anything not intended for
                public consumption goes here, never in docs/
script/         gate tooling (lint.rb)
test/           minitest suite
bin/            authoring-time instruments (curriculum compiler; talks
                to Nabu's CLI/MCP, outputs committed) — arrives P2
.github/        CI (gate) + Pages deploy workflows
```

## Current phase

Phase 3 — Cuneiform 102 Sumerian, opening chapters (per D0-a).

Gate 2 merged 2026-07-29 (101 complete: 13 chapters, 25 signs). Update this line at each gate.
