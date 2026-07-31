# Egyptian school — course rulebook

Governs: Hieroglyphs 101 · Foundations and every later course of
the Egyptian school. Spells out the school's conventions,
notations, and standards choices explicitly (owner ruling
2026-07-31); written before content, updated in the same commit as
any new choice; the gate checks content against its
machine-enforceable subset (`script/rulebook.rb`, run by
`rake lint`) before every Gate.

## 1 · Transliteration display

- **Leiden/Egyptological convention** (D4-b, ruled 2026-07-30):
  *ꜣ ꜥ ḥ ḫ ẖ š ṯ ḏ*, printed in italics. The MdC ASCII forms
  (`anx`, `Htp`) appear only when quoting raw corpus data, in
  `translit atf` spans or captions that say so.
- **No vowels, ever, in transliteration.** Conventional
  pronunciations ("nefer", "hotep", "Pepi") are prose-only and
  flagged as conveniences; the Orientation primer states the
  e-insertion rule once for the whole course.
- Suffix pronouns join with **≡** in display (*zꜣ≡f*); the
  corpora's `=` appears only in verbatim quotes. Editors' marks
  from the source — *i̯*, commas, brackets — are preserved in
  transliteration lines and explained in the Orientation primer.

## 2 · Display and direction

- Signs print in a **single left-to-right line** (D4-a, D4-c).
  Quadrat stacking and right-to-left runs are shown only in
  figures, labeled as facsimiles (mirrored rendering is drawn,
  since fonts do not mirror); the compass rule — read into the
  faces — is taught in chapter 11 and declared in the Reference.
- Sign order in a script column follows the word; the sign
  *inventory* of any reading matches the cited source's own
  `hiero_inventar` annotation exactly — no signs added or dropped.

## 3 · Identity and registry

- Gardiner codes resolve to codepoints **by Unicode character
  name** through `bin/hiero_registry.rb` — verified, never
  guessed. Gardiner category names compare case-insensitively
  (Aa1 ≡ AA1; the 2026-07-31 mixed-case incident is why this is
  written down).
- Classifiers are silent: their Reads column is "—"; they are
  never given a sound value.
- Sign pictures with debated identifications carry their honest
  question marks (*sandal strap?*) and `certainty: unclear` in the
  pool — the course teaches the use, not a story.

## 4 · Readings and citations

- Corpus readings come from the aes corpus (license class
  **attribution**) — every citation carries
  `license: attribution` and its Nabu URN. Enforced by the
  rulebook lint rule.
- Museum-object exhibits (Rosetta Stone BM EA 24, the Bankes
  obelisk) are cited to their objects and labeled exhibits, not
  corpus readings.
- ▢ stands for an untaught sign; damaged lines are not used as
  readings; name translations are approximate and say so.

## 5 · Prose register

- Conventional English names in prose (Amun, Khufu, Hetepheres);
  exact transliterations in reading lines.
- Simple over adorned; substance over meta; back-references link;
  new jargon enters `site/_data/terms.yml` in the same commit.
- Standard references footnoted once or twice per course (Allen's
  *Middle Egyptian*; Gardiner's Sign List for codes).

## 6 · Pedagogy mechanics

The site-wide CLAUDE.md rules apply in full (thematic opening
signs, taught-once, concrete examples, essence titles, terms in
the same commit). This course additionally keeps its promises
ledger explicit: a forward promise made in a chapter (Pepi's box,
Ptolemy's ring) is delivered in the chapter that was named, and
the delivering chapter says so.

## 7 · What the gate checks mechanically

From this rulebook: the aes license label
(`script/rulebook.rb`); plus the standing rules — untaught-sign,
font coverage, no-JS, link hygiene. Everything else above is law
for the author and material for review; when a rule becomes
regexable, its check joins the script in the same commit.
