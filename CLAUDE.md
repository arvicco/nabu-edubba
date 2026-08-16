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
   HTML/CSS. **Text-pure law: no JavaScript anywhere in the site**
   (ratified; the gate enforces it) — with ONE owner-ruled exception
   (D17-a, 2026-08-11): assets/say.js, the self-contained audio
   click-to-play enhancement; progressive only, nothing may ever
   REQUIRE JS, and the gate allowlists exactly that script.
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
9. **All content is written by the top-tier model itself — never
   delegated.** Chapter prose, readings, glosses, pedagogy: planned
   AND executed by the Fable session model (owner ruling
   2026-07-31; no Sonnet-drafted chapters, ever). Delegation to
   lesser models is permitted only for non-content work (code,
   tooling, mechanical transforms). Opus is banned from this
   project entirely (owner ruling 2026-07-30).

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

- Each school's conventions, notations, and standards choices are
  spelled out EXPLICITLY in docs/courses/<school>.md — the single
  source of truth, written BEFORE course content and updated in
  the same commit as any new choice (owner ruling 2026-07-31,
  after the ĝ/ŋ notation drift). script/rulebook.rb implements the
  machine-checkable subset; the gate runs it before every Gate. A
  notation decision never lands in content without landing in the
  rulebook.
- Every borrowed text/passage carries its Nabu URN and license class;
  original prose is CC BY-SA. Never strip or alter attribution.
- Native script always accompanied by transliteration in the field's
  standard convention (ATF for cuneiform, MdC/Leiden for Egyptian,
  IAST for Sanskrit); conventions declared in each course's Reference.
- Transliteration index numbers are ALWAYS Unicode subscripts in
  displayed text (lu₂, e₂, u₄) — owner stylistic ruling, all Edubba
  materials. Full-size ASCII digits (lu2) appear only in verbatim
  raw-ATF exhibits (span class "translit atf") and explicit mentions
  of the ASCII convention; the subscript-index lint rule enforces
  the reading-span case.
- Graded readings may use only signs/vocabulary already taught (the
  "nothing untaught" validator joins the gate with the first course).
- Didactic claims cite their scholarly basis (standard grammars, sign
  lists) in-line; no confident nonsense about ancient scripts. Cite a
  given standard reference once or twice per course, not per chapter.
- EVERY chapter (chapter 00 included) OPENS with 1–3 new
  theme-related signs in the standard sign-table format (owner
  ruling 2026-07-31) — THEMATICALLY relevant signs, never filler —
  and USES each new sign in that same chapter, immediately; a sign
  never waits for a later chapter for its first demonstration.
  A sign is TAUGHT exactly once: it never reappears as a new-sign
  entry in a later chapter's table (owner ruling 2026-07-31 — no
  double-entries); later tables may include it only explicitly
  marked as a veteran (e.g. a known sign gaining a new reading). Every chapter carries
  at least one graphic illustration; readings couple transliteration
  with native script, untaught signs as ▢. Recurring signs link back
  to where they were first taught (earlier courses: to that course's
  Reference summary) — the sign-linker plugin does this site-wide.
- Simplicity and clarity over adornment: say the idea in the
  plainest words that carry it; never dress up a simple fact.
  Substance over meta: lesson prose serves the student's goal — no
  corpus names, compiler talk, chart cross-references, or obscure
  external references in lesson flow (orientation chapters,
  citations, and footnotes are where machinery may speak).
  Production borders are INVISIBLE to the student (owner ruling
  2026-08-11): "stretches", phase boundaries, and any authoring-
  calendar talk never appear in site prose — speak in chapters
  and content; the production-vocab lint bans the word "stretch"
  site-wide (physical senses use a synonym).
- Chapter titles express the chapter's ESSENCE in a few short words
  (the grammar piece, the main idea) — never mechanical labels like
  "Batch III". Batches are a mechanic, not a name.
- Technical terms (glottal stop, determinative, genitive …) carry
  hover-bubble definitions site-wide and link to the /terms/
  glossary — when a chapter introduces new jargon, add it to
  site/_data/terms.yml in the same commit (owner ruling 2026-07-31).
- Every cited Nabu URN links to its axis desk (script/urn_linker.rb;
  a new Nabu source needs an AXES entry in the same commit).
- Reference citations are FOOTNOTES (kramdown [^ref]) or Reference-
  chapter entries, never inline meta in the lesson flow. Every
  grammatical marker taught gets a concrete usage example a learner
  can hold (who owns what, where the caravan goes) — never a bare
  gloss.
- Chapters are Markdown in `site/<school>/<course>/`, numbered
  (`00-orientation.md`, …), `layout: chapter`, permalink
  `/<school>/<NNN>/<NN-slug>/`. Front matter carries the pedagogy
  contract: `chapter:` (ordinal), `teaches:` (signs this chapter
  introduces, as glyph strings), `shows:` (display-only exhibits —
  never inside a reading figure). The gate enforces: a chapter's
  body may use only signs taught in chapters <= its own, plus its
  own `shows:` outside readings — nothing untaught in a reading,
  ever, exhibit framing included.

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
                concept.md, DEV-LOOP.md, BACKLOG.md, WORKLOG.md,
                courses/ (per-school rulebooks — conventions law)
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

Phase 25 — in progress: THE STANDARD VOICE, set complete
(M25-1..5). Owner ruling 2026-08-15: all course audio synthesized
in one pinned ElevenLabs voice (never-TTS bar overturned — no one
pronounces Old Chinese natively). 162/162 in Danyu Zhao
(BWN0mOtkGHghA3CYFzFK, pinned): 154 syllables + 8 pilot lines,
full-site ear review closed (76 ear-approved; carrier-swap and
instructed-script strategies for stubborn syllables),
citation-length clips under the LENGTH LAW (span 0.4–2.2 s,
gate-enforced), every clip transcript-gated (whisper.cpp +
Unihan — never ship speech the pipeline hasn't understood),
EAR-APPROVAL as final referee (machine gates advise, the owner's
ear rules — review page + `pinyin_voice.rb approve <take-ids>`).
Pipeline
bin/pinyin_voice.rb (agent: batch/integrate/approve; OWNER
alone: synth with ELEVENLABS_* env): variant fan-out + rolls,
previous_text rotation (cache-buster), eleven_v3 [slowly] tags,
envelope token cuts, atempo stretch, late-rise detector.
CONTRAST-ROW LAW (2026-08-16): a demo row varies exactly one
thing — primer rows rebuilt as uniform-tone sets. Open: full
line rollout (all readings) as the next packet.

Phase 24 — complete, gate PR pending: S102 REBUILT GRAMMAR-FIRST
(M24-1, Gate 24 of the owner-ruled two-gate cadence). The 82
characters re-batched into fifteen grammar chapters on the ruled
Pulleyblank spine; per-course queue ordinals and caps; every
reading box_line-re-verified; parked files deleted, redirects
chapter-grain, codex re-pointed, hover bubbles for all 137. The
sinograph school now reads: S101 Foundations (10 ch + Reference,
55 chars, complete) and S102 Literary Chinese (15 grammar
chapters, 82 chars, complete). This PR also carries Gate 23 (the
course-border law, concept §7) and all of phase 22. PR #27
superseded, never merged.

Gate 21 merged 2026-08-11 (S101 stretch 4, the world of the text:
ch15–19, 29 chars; 110 characters = 33.3% — one in three; finale
Analects 1.1 WHOLE. Plus five review rounds: table-balance law
with computed grids + 15% rule, sidebar scroll fix + school
folding, course-TOC lint, and the MEANING LAW + novice test —
every reading taught in plain modern speech; PR #26). Update this
line at each gate.

Gate 20 merged 2026-08-11 (the process codex: interactive-surface
review law, pre-flight checklist, structured-edits rule, law
ledgers + gap audit ×3 rulebooks, return-arc planning law;
PR #25). Update this line at each gate.
