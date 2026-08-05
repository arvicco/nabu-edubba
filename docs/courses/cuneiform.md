# Cuneiform school — course rulebook

Governs: Cuneiform 101 · Foundations, Cuneiform 102 · Sumerian, and
every later course of the cuneiform school. This document spells
out the school's conventions, notations, and standards choices
explicitly (owner ruling 2026-07-31, after the ĝ/ŋ notation drift
incident). It is written BEFORE content and updated in the same
commit as any new choice; the gate checks content against its
machine-enforceable subset (`script/rulebook.rb`, run by
`rake lint`) before every Gate.

## 1 · Transliteration display

- Values in **ATF style**, lowercase italic: *lugal*, *nam-ti*.
- Homophone indexes are **Unicode subscripts, always**: *lu₂*,
  *e₂*, *gu₇* (owner stylistic ruling 2026-07-30). Full-size ASCII
  digits (*lu2*) appear only inside verbatim raw-ATF exhibits
  (`span class="translit atf"`) and explicit mentions of the ASCII
  convention. Enforced by the `subscript-index` lint rule.
- The velar nasal is printed **ŋ** (*saŋ*, *niŋ₂*), **never ĝ**.
  The ĝ spelling may be *mentioned* as other books' habit (the 102
  Orientation primer does), never used as this school's notation.
  Enforced by the rulebook lint rule.
- **Accent notation is not used as indexing**: *e₂* and *i₃*,
  never *é* and *ì*. Accented forms appear only in explicit
  mentions of the convention and in the school's own name,
  *é-dub-ba-a*. Enforced (é ì í ù ú) by the rulebook lint rule;
  *é-dub-ba-a* is exempt at the pattern level, other explicit
  mentions by per-file allowance.
- The velar fricative is printed plain **h** in values (*ha*,
  *mah*), matching the corpora's folding; *ḫ* appears only when
  discussing notation itself.
- **š** is always printed š in display; *sz* (CDLI) and *c*
  (ETCSL) only in verbatim corpus quotes, marked as such.
- Sign NAMES in capitals (LUGAL, EŠ2, É — the accented É is the
  sign's conventional name and is fine in that role); names may
  carry ASCII indexes (ŠA3) since they are names, not readings.

## 2 · Corpus conventions

- CDLI (ATF: sz, full-size digits) and ETCSL (c = š, j = ŋ) keep
  their own spellings; they are **never merged** and never
  silently converted — folding happens in instruments
  (`bin/reading_picker.rb`), with the fold table in code.
- Corpus-convention text is quoted only verbatim, in captions or
  `translit atf` spans, and labeled as the corpus's own spelling.

## 3 · Readings and citations

- Every reading's script column is **OSL-resolved** — glyphs come
  from `nabu signs` resolution of the cited passage, never from
  memory or guesswork. Sign order follows the word.
- ▢ stands for a sign untaught at that chapter; damaged lines are
  not used as readings.
- **CDLI quotes**: license class attribution — the citation
  carries `license: attribution` and a cdli.earth artifact link.
- **ETCSL quotes** (per D3-a, ruled 2026-07-31): short, and each
  labeled `license: ETCSL · non-commercial` in place. Default to
  CDLI; use ETCSL where pedagogy needs a clean composite line.
  Both label rules are enforced by the rulebook lint rule.
- Personal-name translations are marked **approximate**; an
  approximate sense is *given cautiously, never omitted* (owner
  ruling 2026-07-31).

## 4 · Prose register

- Gods and places take conventional English forms in prose
  (Ninhursag, Enlil, Umma); transliteration lines keep the exact
  forms (*nin-hur-saŋ*).
- Simple over adorned; substance over meta: corpus names and
  tooling live in citations and footnotes, never in lesson flow.
- Back-references to prior material carry links (owner ruling
  2026-07-31). Grammar walkthroughs go piece by piece — no
  checklist glosses (owner ruling 2026-07-31); sharpened
  2026-08-02: any reading of three or more meaningful pieces gets
  a bullet-form walkthrough in the body — one bullet per piece,
  each naming what it is and where it was taught — with the figure
  gloss carrying only the translation. Single-sentence analysis is
  reserved for one- or two-piece items. Pieces beyond the course's
  depth are named and honestly deferred ("the grammars carry it"),
  never silently skipped.
- Standard references are footnoted, once or twice per course
  (102 uses Foxvog's *Introduction to Sumerian Grammar*).

## 5 · Pedagogy mechanics

The site-wide rules of CLAUDE.md apply in full: every chapter
opens with 1–3 thematically relevant new signs in the standard
table and uses them immediately; a sign is taught exactly once
(veterans marked explicitly); every grammatical marker gets a
concrete holdable example; batch label = chapter number + 1
("Batch nine" is chapter 08); new jargon enters
`site/_data/terms.yml` in the same commit; chapter titles express
essence. The nothing-untaught validator and the every-chapter
rules are enforced by `rake gate`.

## 6 · What the gate checks mechanically

From this rulebook: ŋ-not-ĝ, no accent indexes, ETCSL and CDLI
license labels (`script/rulebook.rb`); from §7, the codex checks —
keyword presence and uniqueness, one codex page per taught sign,
name-slug agreement (activation staged per school as the pages
land); plus the standing rules — subscript-index, untaught-sign,
font coverage, no-JS, link hygiene. Everything else above is law
for the author and material for review; when a rule becomes
regexable, its check joins the script in the same commit.

## 7 · The Sign Codex (Addenda Signs shelf)

Ruled 2026-08-04 at the start of Phase 9, before any codex content
(source: the sign-retention plan, approved in principle).

- **One page per taught sign**, the sign's permanent home for
  in-depth study, on the school's Addenda Signs shelf. Permalink:
  `/cuneiform/addenda/signs/<slug>/` where the slug is the
  **traditional sign name** in lowercase ASCII — š→sz, É→e2, ×→x,
  index digits full-size (*asz, gal, e2, kaxa, sza3*). Names are
  the permalink because they are stable identifiers; keywords are
  not, so they stay out of URLs.
- **The keyword law.** Every taught sign carries a `keyword:` in
  its registry: one short English handle, **unique within the
  school at any moment**, chosen for discriminability and
  imageability (GAL "big" vs MAH "exalted" — near-synonyms
  differentiated on purpose; pure syllabograms take invented
  story-keywords). The keyword titles the codex page and is used
  verbatim wherever the sign is drilled or named by sense —
  never paraphrased. Keywords are revisable in later phases
  (they are not permalinks); a revision updates every surface in
  the same commit.
- **The two-heading honesty rule.** Codex prose tells the sign in
  exactly two story sections, kept typographically and legally
  separate: **"Where it comes from"** — the attested or classical
  origin, cited, certainty flagged, the no-confident-nonsense law
  in full force — and **"How to remember it"** — an invented
  memory hook tying the keyword to the sign's actual shape,
  explicitly ours, never presented as history. Where the honest
  origin is already vivid, this section sharpens it into the
  keyword instead of inventing.
- **Page-ships-with-sign.** From Phase 9 onward, a chapter that
  teaches a sign ships that sign's codex page in the same commit
  (the terms.yml pattern).
- **Confusables.** `confusable_with:` in the registry lists
  curated shape-neighbors only — pairs a learner actually
  confuses — each rendered as a contrast row with one
  discriminating detail.
- **Citations.** Every codex page carries one attested corpus
  line with URN + license per §3; the display laws (§1) apply in
  full. In chapter sign tables, the glyph itself links to the
  sign's codex page.
- **Fully readable, no boxes** (owner ruling 2026-08-04): a codex
  page's attested line contains NO untaught sign — never a ▢.
  Chapters may box what a student hasn't met; the sign's own
  home page shows it only in company it can fully keep. Number
  notation n(aš), n(diš), n(u) counts as taught — repeated
  taught wedges.

## 8 · Retrieval instruments (Stage C)

Ruled 2026-08-04 at the start of Phase 11, before any instrument
renders. These laws bind both schools (the hieroglyph rulebook
§10 adopts them).

- **Reinforcement selection** (owner ruling 2026-08-04): when
  choosing a NEW chapter's example lines, candidates that ALSO
  exercise older signs due for reinforcement are preferred — a
  line that revises while it teaches beats one that only shows
  the new sign. The reading pickers score candidates by how many
  review-vintage signs they contain and surface that score in
  their sweeps; authoring follows it unless pedagogy overrules,
  and says so when it does.
- **The spiral warm-up.** Every SUBJECT chapter (not references,
  not a course's opening chapter with nothing behind it) opens
  with a generated retrieval panel: 4–6 prompts against signs
  taught in chapters N−1, N−2, N−4, N−8 of the school's combined
  curriculum sequence (a 102 chapter looks back into 101).
  Prompts lead with the KEYWORD and rotate direction — draw it,
  read it, what does it mean — production first; every answer
  sits folded in native `<details>` (no JS, per the wave-1 law).
  The panel is rendered by the layout from the registries: no
  hand-authoring, no per-chapter drift.
- **Drill shelves.** Each school's Addenda carries one generated
  drill page: every taught sign as disclosure-cards in three
  directions (sign→reading, reading→sign, sign→meaning),
  deterministically ordered so that chapter-mates are not
  adjacent (interleaving) — the order is a stable function of
  the sign data, never of a clock or a random source, so builds
  reproduce. Confusable pairs additionally stand side by side as
  contrast rows. A print stylesheet renders the same page as
  cut-out Leitner cards.
- **The deal** (owner ruling 2026-08-05): the drill deck ships
  as TWELVE pre-generated cuts — the same cards under twelve
  seeded orderings, each produced by the same hash-and-spread
  rule, so every cut is content the gate has verified. The
  drills page shows one cut inline (the featured deal) and
  offers all twelve as tiles ("cut the deck"); the reader's
  pick is the only random source the site ever uses, and
  visited-link styling may fade used tiles — no other state
  exists. WHICH cut is featured follows the calendar: the
  deploy workflow rebuilds `main` on a daily schedule, passing
  the build date, and date → cut is a fixed public function
  (modified Julian day mod 12, plus one). Gate and local builds
  carry no date and always feature cut 1 — reproducibility is
  unbroken; the calendar enters only at deploy time, and the
  scheduled rebuild commits nothing (it re-renders what the
  gate already blessed).
- **Study decks** (owner-ruled shelf, 2026-08-04): per-course
  Anki-importable exports, generated by a bin/ instrument and
  committed as static downloads. One card per sign: front the
  glyph, back keyword · name · readings · meaning · the sign's
  memory hook, plus one attested corpus line with URN — **license
  class attribution only** (CDLI, aes); ETCSL's non-commercial
  terms keep its lines out of redistributable decks, and the
  exporter hard-fails on any non-attribution URN rather than
  filtering silently. A card whose codex line is ETCSL ships
  without a line. All tooling talk (Anki, FSRS, import steps)
  lives on the Study decks shelf and nowhere else.
- **Read it cold** (drill-exhibit clause to §1's script-always-
  with-transliteration law): a chapter may repeat a reading it
  has already taught, at chapter end, with the SCRIPT bare and
  the transliteration + gloss folded in `<details>` — the
  transliteration is present, only folded, and the exhibit is
  always a repetition of a fully-walked reading, never a first
  presentation.
- **The frontier page.** Each school's Addenda may carry an
  "almost yours" page of famous passages just beyond the current
  inventory (≥90% covered, per the picker's frontier mode) —
  the ONE surface where ▢ appears by design in Addenda material,
  labeled as such, for motivation and honest stretch practice.
