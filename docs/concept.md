# Edubba — concept

*é-dub-ba-a, "the tablet house": the Sumerian scribal school where, four
thousand years ago, students copied sign lists, proverbs, and hymns until
they could read and write. Edubba is that school, rebuilt on the web —
a place to acquire real literacy in the world's writing systems, ancient
and living.*

**Status:** ratified 2026-07-29 (owner review of first draft). Remaining
open items are collected in §8.

---

## 1. What Edubba is

Edubba is a free, static, self-paced **school of writing systems**: a
GitHub Pages site published at **edubba.ac**, made of independent
**schools**, one per scripting tradition — cuneiform, Egyptian
hieroglyphs, Hanzi/Kanji, Devanagari and the Brahmic family, the
alphabet lineage, syllabaries, runes, and more.

A scripting tradition is not one thing: cuneiform served Sumerian,
Akkadian, Hittite, Elamite, Urartian and others across three millennia
of change; Egyptian writing spans hieroglyphs, hieratic, demotic, and
its Coptic afterlife. So each school is not a single course but a
**course catalog with a prerequisite tree**: a foundations course on the
writing system itself, then numbered courses for each language, period,
or branch of the tradition. Each individual course takes a motivated
reader from its prerequisites to genuine reading literacy in its slice
of the tradition — not trivia about the script, but the ability to look
at a real tablet, inscription, or page and read it. For ancient and
partially-understood traditions, courses end where scholarship ends —
with an honest chapter on what remains undeciphered, disputed, or open.

Edubba is the teaching companion to **Nabu** (the library next door):
Nabu holds ~968k documents of the ancient world with per-passage
citations and licenses; Edubba teaches you to read them. Every course's
capstone is reading *real texts* drawn from Nabu's shelves, cited by URN.

### What Edubba is not

- Not a linguistics survey or a Wikipedia mirror — it is didactic,
  sequenced, and drill-oriented, like a language textbook.
- Not a language course per se — the target is *script literacy*
  (reading and writing the system), though enough grammar and vocabulary
  is taught to make reading real. Where script and language are
  inseparable (Sumerian cuneiform, Classical Chinese), the course
  teaches both to the degree literacy demands.
- Not an app. No accounts, no backend, no build-time dependence on
  external services. Plain files that will still render in twenty years.

### Audience

The curious autodidact: a reader with no prior training but real
commitment — the person who would buy Huehnergard's Akkadian grammar or
Heisig's kanji book and actually work through it. Secondary audiences:
students wanting a free on-ramp before formal study, and teachers
looking for structured open materials.

---

## 2. The schools

Schools are grouped by **typology** on the site index, and the index also
presents the **family tree of writing** (one page: how systems descend
from four-ish independent inventions) so a visitor sees both maps.

Roster and build order — **waves 1–3 confirmed; 4+ to be planned by the
owner when we get closer:**

| Wave | School | Notes |
|------|--------|-------|
| 1 | **Cuneiform** | The flagship. Names the project, deepest Nabu support (CDLI, Oracc, eBL), richest open-questions material. |
| 2 | **Egyptian hieroglyphs** | Second great logophonetic tradition; Nabu has TLA, Coptic Scriptorium. |
| 3 | **Hanzi / Kanji** | The living logographic tradition; huge audience; Nabu has Kanripo, CBETA, Unihan, IDS decompositions, Old Japanese. |
| 4+ | Alphabet lineage · Devanagari & Brahmic · syllabaries · runes & ogham · Maya · Hangul · the undeciphered | Candidate pool; ordering deferred. |

Each wave ships as its own phase-group of the dev loop — the site is
useful after wave 1 and grows school by school, course by course.

---

## 3. Schools as course trees

Each school is a **catalog of numbered courses** with explicit
prerequisites, university-catalog style: **1xx** foundations and core
literacy tracks, **2xx** further languages/branches of the tradition,
**3xx** advanced and special topics. The school's landing page shows the
catalog and the prerequisite tree; a student picks a path, not a single
forced sequence.

Sketch for the flagship (numbers illustrative, to be firmed in
curriculum design):

- **Cuneiform 101 · Foundations** — wedge and stylus, tablet and clay,
  sign anatomy and formation, how the system encodes language
  (logograms, syllabograms, determinatives, polyvalency), the
  3,000-year arc from proto-cuneiform to the last dated tablet, and the
  decipherment story. Prerequisite for everything below.
- **Cuneiform 102 · Sumerian** — literacy track: the sign inventory in
  frequency order, Sumerian to the degree reading demands, graded
  readings from royal inscriptions to proverbs and Edubba texts.
- **Cuneiform 103 · Akkadian** — literacy track centered on Old
  Babylonian; syllabary-first reading, Akkadian grammar as needed,
  graded readings toward Hammurabi and letters.
- **2xx · The wider cuneiform world** — one course per adapted
  tradition: Hittite; Elamite; Hurrian & Urartian (Nabu holds eCUT,
  gold-lemmatized); Ugaritic alphabetic cuneiform; Old Persian.
- **3xx · Special topics** — paleography across the millennia
  (reading actual sign forms by period); the first-millennium library
  world (Neo-Assyrian hands, colophons, Ashurbanipal); origins and
  proto-cuneiform; open questions of the field.

The same shape applies to every school — e.g., Egyptian: 101
foundations, 102 Middle Egyptian literacy, 2xx hieratic / demotic /
Coptic / Ptolemaic; Hanzi/Kanji: 101 how hanzi work, 102 Classical
Chinese, 103 Japanese (kanji + kana), 2xx onward. A wave is *opened*,
not *finished*: wave 1 minimally means Cuneiform 101 plus the start of
a literacy track, with later courses added in subsequent phases.

### The literacy ladder — one template, every course

Within a course, chapters follow the llm-manual pattern — one numbered
page per chapter, strictly progressive, readable end-to-end:

- **00 · Orientation** — what this course covers, for whom, what you
  will be able to read at the end; where it sits in the school's tree.
- **01 · How it works** — the course's mental-model chapter (for a 101:
  the writing system; for a literacy track: this language's use of it).
- **02 · First signs** — a deliberately tiny starter set (10–30 signs)
  chosen for frequency and shape-contrast; first words written and
  read; writing practice from stroke/wedge order up.
- **03–0n · The growing inventory** — signs and constructions in
  **frequency order**, each chapter paired with graded readings that
  use only what has been taught. The long middle, the heart of a
  literacy track.
- **The full system** — the hard truths of this slice of the tradition:
  polyvalency, determinatives, ligatures, historical spelling, period
  variation — whatever they really are.
- **Reading real texts** — graded reader of genuine passages pulled
  from Nabu, easiest first, each with facsimile/photo where licensable,
  normalized text, transliteration, translation, and URN citation.
  Capstone: an unassisted reading of a real document.
- **Scribal craft** — hands and paleography, writing by hand, the
  tradition's own scribal culture (the original edubba, the Egyptian
  scribal schools, the Chinese examination hall).
- **Open questions** — what is undeciphered, disputed, or newly moving
  in scholarship, with pointers into the literature; for living
  traditions, reform debates and digital-era evolution.
- **Reference** — the course's full sign list / glossary, conventions,
  fonts, further study (the standard grammars and courses), sources and
  licenses.

Short courses may collapse rungs; no course skips Orientation, real
readings, or Reference.

Two standing pedagogical commitments:

1. **Frequency-driven sequencing, computed, not guessed.** Sign and
   vocabulary order is derived from actual counts over Nabu's corpora
   (e.g., sign frequency across CDLI/Oracc transliterations, character
   frequency over Kanripo/CBETA). The curriculum is an artifact built
   from the library, and rebuildable when the library grows.
2. **Nothing untaught in a reading.** Every graded reading is
   machine-checked against the running set of taught signs/vocabulary —
   a gate, not an aspiration.

---

## 4. Site architecture

- **Hosting:** GitHub Pages from the `nabu-edubba` repo, served at
  **edubba.ac** (CNAME). Branding is plain **Edubba** everywhere —
  site, titles, prose; "nabu-edubba" is only the repo's name (logical
  grouping on GitHub). Nabu appears as the library Edubba reads from,
  with cross-links, not as part of the name.
- **Generator: Jekyll, null theme** (ratified) — nabu's approach:
  chapters authored in Markdown, custom `_layouts/` + one shared
  stylesheet, kramdown/GFM, built by GitHub's Jekyll action. We keep
  llm-manual's *page layout and progression*, not its no-generator
  choice.
- **Layout:** landing page = the map of writing (typology grid + family
  tree) linking to schools; each school is a directory with its catalog
  page and course subdirectories (`/cuneiform/`, `/cuneiform/101/`,
  `/cuneiform/102/`, …), chapters as numbered pages within a course.
  One visual identity site-wide, with a per-school accent (color +
  a motif glyph).
- **Scripts on screen:** real Unicode text everywhere it exists
  (cuneiform, hieroglyphs, and almost everything on the roster are in
  Unicode), rendered with subsetted webfonts (Noto Sans Cuneiform, Noto
  Sans Egyptian Hieroglyphs, etc.) vendored into the repo — never
  hotlinked. SVG for sign-form evolution, wedge/stroke order, and
  paleographic detail that fonts can't carry. Transliteration always
  accompanies native script; conventions per school follow the field's
  standard (ATF for cuneiform, MdC/Leiden for Egyptian, IAST for
  Sanskrit…) and are stated in each school's Reference chapter.
- **Interactivity: wave 1 ships text-pure — no JS** (ratified).
  Chapters must be fully usable as static text. Small self-contained
  vanilla-JS widgets (flashcard drill, sign tracing,
  reveal-the-translation) are a possible later enhancement layer, to be
  decided when wave 1 is standing; nothing may ever *require* JS.
- **Licensing: CC BY-SA for original prose** (ratified); every borrowed
  text/image carries its source license, inherited from Nabu's
  per-passage `license_class`. Only openly-licensed material is used —
  Edubba inherits Nabu's license-honesty as a founding rule.
- **Authorship & feedback:** the README states plainly that materials
  are AI-drafted under owner review; this is not repeated across the
  site. GitHub Issues is the main feedback and errata channel.

---

## 5. Relationship to Nabu

Nabu is upstream; Edubba is a reader of it, never a fork of its data.

- **Texts:** graded readers and examples are extracted via the nabu CLI /
  read-only MCP server (`nabu_search`, read-by-URN, dictionary lookup)
  at *authoring time*; the extracted passages are committed into Edubba
  with URN + license. The published site has no runtime dependency on
  Nabu.
- **Instruments:** frequency tables, sign lists, glossary entries, and
  concordance-backed example hunting are computed from Nabu corpora by
  small scripts living in Edubba's `bin/` — the "curriculum compiler."
- **Non-goals:** Edubba does not ingest corpora, run a database, or
  duplicate Nabu's catalog. If a course needs a source Nabu lacks
  (e.g., a Maya glyph corpus), that's a Nabu ingestion request first.

---

## 6. Development process

Edubba adopts the **dev-loop** methodology wholesale (`dev-loop init`
scaffolding: root `CLAUDE.md` golden rules, `docs/DEV-LOOP.md`,
`docs/BACKLOG.md`, `docs/WORKLOG.md`, `.claude/settings.json`
permission profile). Specifics for this repo:

- **Gate command:** site builds clean + link checker + the
  "nothing-untaught" reading validator + HTML/Markdown lint. All local,
  no network in tests.
- **Phase 0:** repo bootstrap, gate command, this concept ratified.
- **Phase 1:** site skeleton — landing page with the map of writing,
  shared stylesheet and layouts, one fully-styled sample chapter,
  school stubs, CI + Pages deployment with the edubba.ac CNAME
  (deploys human-gated per dev-loop rules). Minimalist: no JS, no
  ornament beyond the shared identity.
- **Phase 2+:** courses, starting with Cuneiform 101; packets are
  chapter-sized (one chapter, or one instrument like the frequency
  compiler, per packet). A school opens when its 101 and the start of a
  literacy track are live; later courses arrive in later phases.
- **Review discipline:** every chapter packet's acceptance includes the
  rendered-surface checklist (fonts actually render, transliteration
  aligns, citations resolve) plus factual review — didactic prose about
  ancient scripts is exactly where confident nonsense creeps in, so
  chapters cite their scholarly basis (standard grammars, sign lists)
  in-line for the reviewer.

---

## 7. Ratified decisions (2026-07-29)

- Schools are **course trees** (1xx/2xx/3xx catalogs with
  prerequisites), not single monolithic courses; llm-manual layout
  applies *within* a course.
- Generator: **Jekyll, null theme**.
- **Wave 1 is text-pure** — no JS; minimalist scope overall.
- License: **CC BY-SA** for original prose.
- Repo stays **nabu-edubba**; site domain **edubba.ac**; branding is
  plain **Edubba** everywhere else.
- Waves **1–3 confirmed** (Cuneiform, Egyptian, Hanzi/Kanji); wave 4+
  ordering deferred to the owner closer to the time.
- Authorship stated **in README only**; **GitHub Issues** is the
  feedback loop.

## 8. Open items

1. Course numbering and exact catalog for Cuneiform (the 101/102/103 +
   2xx/3xx sketch in §3 needs firming during Phase 2 curriculum
   design — a decision-item-shaped packet).
2. Wave-1 "opening" scope for the cuneiform school: how far into
   102/103 before wave 2 starts.
3. Wave 4+ roster and ordering (owner, later).
4. JS enhancement layer: revisit after wave 1 ships.
