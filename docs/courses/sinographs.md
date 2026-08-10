# Sinograph school — course rulebook

Single source of truth for the sinograph school's conventions,
notations, and standards choices — written BEFORE course content
(owner ruling 2026-07-31, project-wide) and updated in the same
commit as any new choice. The machine-checkable subset lands in
script/rulebook.rb as each law activates; a notation decision never
lands in content without landing here.

School rulings ratified 2026-08-09 (owner, post-Gate-14 planning):
name, thesis, voice, keyword law, pinyin display, glyph-scout
fallback. Recorded in docs/concept.md §7.

## 1 · Name, scope, thesis

- The school is **sinographs** (slug `/sinographs/`) — the field's
  umbrella term for the characters across ALL their uses. *Hanzi*,
  *kanji*, *hanja*, *chữ Hán* are the per-language names, used when
  speaking of that language's use of the characters; "character"
  and "sinograph" are the school's generic terms.
- **Classical-first thesis (ruled):** the school teaches the HISTORIC
  tradition — Literary Chinese (wenyan), the script's own history,
  old Japanese later — not modern Chinese or Japanese writing.
  Modern-language instruction is a saturated, well-served market
  (Heisig, WaniKani, Pleco, the Anki ecosystem); where an existing
  tool does a job well, the school points at it in Further study
  instead of duplicating it. The pitch in one line: *Heisig teaches
  you to remember the characters of modern Japanese; this school
  teaches you to read what the characters were writing for their
  first two thousand years.*

## 2 · The voice of readings (pinyin law)

- Readings carry **modern Mandarin pinyin** as their spoken layer —
  the field's own default for reading the classics aloud. It is to
  wenyan what bound transcription is to Akkadian: the access layer,
  framed honestly in each course's orientation (the classics were
  not pronounced this way; reconstructed Old Chinese exists, is
  mentioned there, and is never taught).
- **Display law — diacritics, never indices (ruled):** tone marks
  in all displayed pinyin (xué ér shí xí zhī), never tone numbers
  (xue2 er2). ASCII tone numbers may appear only in verbatim
  raw-source exhibits and explicit mentions of the ASCII
  convention — the exact shape of cuneiform's subscript-index law,
  adopted in advance this time. The lint for it lands with or
  before the first content commit.
- Later courses declare their own additional voices in their own
  Reference (kanbun: Japanese kundoku — the green voice-marking
  law of cuneiform §9 transfers verbatim; hanja: Sino-Korean).

## 3 · The keyword law

- Every taught character carries exactly ONE English keyword,
  **unique school-wide** — the same keyword-uniqueness law the
  cuneiform school arrived at independently; here it meets its
  origin (Heisig's core insight).
- **Grounding (ruled):** the keyword matches Heisig's where his
  keyword IS the plain classical sense; where the classical sense
  diverges from the modern-Japanese sense Heisig keys to, the
  keyword follows the HISTORIC meaning, with the divergence noted
  in the character's codex entry. Keywords are assigned from the
  classical sense with a standard-dictionary basis (Kroll, *A
  Student's Dictionary of Classical and Medieval Chinese*, as the
  default citation) — the school never reproduces the RTK keyword
  list as a list; convergence is word-by-word and independently
  justified. This is both the ruled pedagogy and what keeps the
  CC BY-SA repo clean of a copyrighted list.

## 4 · Character forms

- **D15-a (ruled 2026-08-10):** base forms are the traditional
  (kaishu) forms as the classical corpus writes them; simplified
  forms appear as later-hand notes (the pattern used for
  Neo-Assyrian sign forms), never as the teaching base.

## 5 · Corpus, ordering, licenses

- Teaching order follows the ratified frequency-AND-simplicity
  methodology (concept §3): character frequency computed over the
  CLASSICAL corpus (a licensed Kanripo slice as the base), never
  modern usage lists — the ordering divergence from every modern
  list is the product. Simplicity uses stroke count (Unihan) and
  component structure (IDS decompositions); curated pins recorded
  per character with their basis.
- **Chapter dial (owner ruling 2026-08-10):** every chapter teaches
  **5–6 fresh characters** — the site-wide 1–3 chapter-opening law
  is the floor; characters are lighter units than cuneiform signs
  and the pace dials up accordingly. The compiler enforces the
  range.
- **Components before compounds (owner ruling 2026-08-10, after
  the 時=日+寺 exhibit outran the taught set):** the opening
  chapters teach a base of SIMPLE, non-compound characters
  (S101 banks eighteen across ch00–02); a compound character never
  appears — in a teaching table, a reading, or an exhibit — before
  every component it is analyzed into has been taught. Compound
  pool rows carry `parts:`; the compiler and the queue contract
  test enforce the ordering.
- The frequency instrument lives in `bin/`, deterministic over
  committed inputs; its output tables under `site/_data/` are
  frozen contracts once introduced (additive changes only,
  contract test in the same commit).
- Every quoted passage carries its Nabu URN and license class;
  per-source license verification (Kanripo repo terms, CBETA
  CC BY-NC under the ETCSL precedent, Wikisource PD) precedes any
  reading drawn from that source; a new source needs its
  urn_linker AXES entry in the same commit.

## 6 · Display conventions

- Native characters beside pinyin beside gloss, always; untaught
  characters appear as ▢; recurring characters link home to where
  they were first taught — the site-wide laws apply unchanged.
- **Text face:** Noto Serif TC (OFL, vendored, subset via the
  site-wide pipeline — sinographs-coverage.txt is the gate-checked
  manifest). Serif matches the classical print register and the
  site's serif body; traditional glyphs per §4. Han runs in pages
  always sit in a `script` span — bare Han text outside one never
  gets the vendored face.
- **Size law (owner ruling 2026-08-10):** sinograph characters
  display BIGGER than cuneiform/Egyptian script text everywhere —
  a character's strokes are genuinely difficult to make out at the
  sizes the other scripts use. Mechanically: the stylesheet's
  sinograph script size must exceed the cuneiform script size in
  every context that shows both (inline runs, reading figures,
  sign tables); the style guard pins the comparison.
- Old-form glyphs (oracle bone, bronze, seal) appear only via
  vendored, license-verified fonts or public-domain imagery —
  never hotlinked. **Ruled fallback (2026-08-09):** if no
  licensable font renders a needed old form, public-domain
  *Shuowen jiezi* seal-form imagery is the fallback. A dedicated
  glyph scout (D15-b) precedes any scheduling of the
  script-history course; the 101/102 courses do not depend on it.

## 7 · What the gate checks mechanically

Live since the first content commit (2026-08-10):

- **pinyin-display** (lint): tone-numbered tokens in sinograph
  pages are violations; span class "pinyin ascii" is the
  verbatim-exhibit carve-out.
- **nothing-untaught + readings-strict** (course_check): Han
  codepoints tracked site-wide; a chapter body uses only taught
  (≤ its ordinal) plus its own `shows:`; inside a reading figure
  `shows:` licenses nothing — untaught is ▢, from birth.
- **reading-width** (lint): script lines measured with the vendored
  Serif TC metrics × the size-law scale against the calibrated
  13em sinograph budget; over-budget figures declare
  `reading--stacked`.
- **size law** (style guard): the low-specificity inline default
  must scale Han up; every explicit sinograph script context
  registers in SINO_CONTEXTS with its cuneiform counterpart floor
  and must exceed it.
- **queue contract** (test): required fields, char/codepoint match,
  keyword uniqueness, digit-free pinyin, 1–3 fresh per chapter,
  monotonic coverage; the compiler additionally cross-checks pinyin
  against Unihan kMandarin and enforces codex-slug uniqueness.
- **codex registry** (rulebook.rb): keyword invariance and
  page-slug matching on the Addenda shelf (§8); the complete-shelf
  check flips with the backfill.
- Still ahead: when a multi-voice course opens (kanbun), the
  value-coverage machinery (cuneiform §9) adapts to on/kun
  readings.

## 8 · The Character Codex (Addenda shelf)

- One Addenda page per taught character, on the shelf
  `sinographs/addenda/signs` — the site-wide Sign Codex law in this
  school's terms. Staged activation as ever: keyword checks are on
  from birth; the every-taught-character-has-a-page check flips
  when the shelf is complete.
- **Slug law:** a page's slug is the toneless ASCII of the
  character's pinyin (人 rén → `ren`). Where readings collide, the
  FIRST-taught character keeps the bare slug and later entrants
  carry explicit pinyin-keyword slugs (人 `ren` / 仁 `ren-humane`;
  月 `yue` / 曰 `yue-say`) — tone numbers never appear in slugs
  (the display law's shape holds in URLs too). The compiler
  enforces uniqueness and demands explicit slugs on collision.
- Page shape (the akk-codex mold): where it comes from (form
  origin, certainty-labeled), how to remember it (the keyword
  hook — this is where the memory-hook technique is applied), in
  the wild (one real cited attestation).
