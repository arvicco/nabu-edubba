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

- **D15-a (pending ruling):** base forms are the traditional
  (kaishu) forms as the classical corpus writes them — near-forced
  by the classical-first thesis; simplified forms appear as
  later-hand notes (the pattern used for Neo-Assyrian sign forms),
  never as the teaching base. Recommended, not yet ratified; no
  course content lands before this is ruled.

## 5 · Corpus, ordering, licenses

- Teaching order follows the ratified frequency-AND-simplicity
  methodology (concept §3): character frequency computed over the
  CLASSICAL corpus (a licensed Kanripo slice as the base), never
  modern usage lists — the ordering divergence from every modern
  list is the product. Simplicity uses stroke count (Unihan) and
  component structure (IDS decompositions); curated pins recorded
  per character with their basis.
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
- Old-form glyphs (oracle bone, bronze, seal) appear only via
  vendored, license-verified fonts or public-domain imagery —
  never hotlinked. **Ruled fallback (2026-08-09):** if no
  licensable font renders a needed old form, public-domain
  *Shuowen jiezi* seal-form imagery is the fallback. A dedicated
  glyph scout (D15-b) precedes any scheduling of the
  script-history course; the 101/102 courses do not depend on it.

## 7 · What the gate checks mechanically

Nothing sinograph-specific yet — this section grows as laws
activate, each with its check named here:

- With the first content commit: pinyin-display lint (tone numbers
  in displayed text = violation, verbatim-source exhibits
  excepted); keyword-uniqueness check; the nothing-untaught
  validator adapted to characters.
- When a multi-voice course opens (kanbun): the value-coverage
  machinery (cuneiform §9) adapts to on/kun readings.
