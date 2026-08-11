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

Before writing any chapter, run the author pre-flight checklist
(docs/DEV-LOOP.md §4 item 6c) — it compresses this section and the
site-wide laws into writing order.

The site-wide CLAUDE.md rules apply in full (thematic opening
signs, taught-once, concrete examples, essence titles, terms in
the same commit). Return arcs are planned, not found (M20-5; the
sinograph rulebook §5 states the law in full): a segment plan
carries its return-arc table from the next planned segment
onward. This course additionally keeps its promises
ledger explicit: a forward promise made in a chapter (Pepi's box,
Ptolemy's ring) is delivered in the chapter that was named, and
the delivering chapter says so.

## 7 · What the gate checks mechanically

From this rulebook: the aes license label
(`script/rulebook.rb`); from §9, the codex checks — keyword
presence and uniqueness, one codex page per taught sign, code-slug
agreement (activation staged as this school's pages land, Stage B
of the retention plan); plus the standing rules — untaught-sign,
font coverage, no-JS, link hygiene. Everything else above is law
for the author and material for review; when a rule becomes
regexable, its check joins the script in the same commit.

## 8 · E102 · Middle Egyptian — the literacy track's conventions

Ruled 2026-08-03 at the start of Phase 8, before any E102 content
(the rulebook law).

- **Course shape**: a literacy track in stretches, the proven C102
  pattern. Sign batches are computed from the committed aes
  frequency table (frequency × graphic simplicity), continuing
  from 101's inventory of 53; the queue lives in
  `site/_data/hieroglyphs102_queue.yml` — additive-only once
  introduced, contract-tested. Thematic pinning is allowed;
  taught-means-used: a sign keeps its batch seat only with an
  attested line readable at its chapter.
- **Verb forms**: the suffix conjugation is displayed with the
  school's join — *sḏm≡f*, "he hears" — never `sdm=f` outside
  verbatim corpus quotes (§1 already rules the join for nouns;
  this extends it to verbs). Paradigm names in prose use the
  display form ("the *sḏm≡f*"). Glosses carry the subject ("he
  hears," "may he give"); where Middle Egyptian aspect is
  ambiguous, the gloss follows the cited corpus translation and
  hedges rather than invents.
- **Sentence types** are taught under Allen's names — nominal,
  adjectival, adverbial, verbal — at most one new type per
  chapter, each entering `site/_data/terms.yml`
  (`school: hieroglyphs`) in the same commit it is taught.
- **Genitives** under the names "direct" and "indirect" (*nj*);
  *nisba* is mentioned as the grammars' term and bubble-defined
  when taught.
- **Readings**: whole, fully-annotated aes lines only (the
  `hiero_inventar` exact-match law, §2). The literacy track
  prefers connected clauses over isolated captions; formulaic
  genres — offering formulas, titularies, stela openings — are
  this track's receipts: used proudly, each formula taught once
  as a pattern and read thereafter.
- **Coverage chart** (ch00): cumulative share of sign-occurrences
  in the aes corpus per the committed frequency table; labeled a
  floor; machinery cited in a footnote, never in lesson flow.
- **Walkthrough law** (site-wide owner ruling 2026-08-02, restated
  for this school): any reading of three or more meaningful pieces
  gets a bullet-form piece-by-piece walkthrough — one bullet per
  piece, taught origin named, gloss carrying only the translation;
  deferrals explicit ("the grammars carry it"), never silent.
- Nothing in this section adds a safely regexable check beyond §7
  today; the ≡-in-verbs rule joins `script/rulebook.rb` if a
  robust pattern is found (bare `=` is unregexable in Markdown
  source full of HTML attributes).

## 9 · The Sign Codex (Addenda Signs shelf)

Ruled 2026-08-04 at the start of Phase 9, before any codex content
(source: the sign-retention plan, approved in principle). The
cuneiform rulebook §7 states the shared law in full — keyword law,
two-heading honesty rule, page-ships-with-sign, confusables,
glyph-links-to-page — and it binds this school identically. This
school's specifics:

- **Permalink**: `/hieroglyphs/addenda/signs/<slug>/` where the
  slug is the lowercase **Gardiner code** (*g1, n35a, aa2*) — the
  traditional stable name Egyptian signs have (§3 already rules
  codes as identity; descriptions describe, codes name).
- Keywords for classifiers name the FUNCTION a learner should
  recall (Z6 "death's stand-in"), since classifiers have no sound
  to anchor.
- This school's pages and sign-table links land in Stage B of the
  retention plan; its `keyword:` backfill lands with the school-
  wide pass in Stage A. Gate activation follows the pages.

## 10 · Retrieval instruments (Stage C)

Ruled 2026-08-04. The cuneiform rulebook §8 states the shared law
in full — reinforcement selection for new example lines, the
spiral warm-up, drill shelves and their dealt cuts, Study decks
(attribution-only
lines: aes qualifies, and this school has no ETCSL exposure),
read-it-cold, the frontier page — and it binds this school
identically. School specifics: warm-up lookback runs E102 → E101
through the combined sequence; classifier prompts ask for the
FUNCTION ("death's stand-in — draw the stroke"), since silent
signs have no reading to produce.

## 11 · Law ledger

The audit table (M20-4); same reading rules as the cuneiform
ledger (§10 there): site-wide laws live in CLAUDE.md +
script/lint.rb's header; "owner review" is a disposition.

| Law | Recorded | Enforcing check |
|---|---|---|
| Leiden translit; MdC only in verbatim exhibits | §1 | owner review (no robust pattern; §8 records why) |
| No vowels in transliteration | §1 | owner review |
| ≡ join for suffix pronouns; `=` verbatim-only | §1/§8 | owner review — GAP examined 2026-08-03 and again in this audit: bare `=` is unregexable in Markdown+HTML source; stands as review |
| Single-line LTR; facsimiles labeled | §2 | owner review |
| Reading inventory = source's hiero_inventar, exactly | §2/§8 | authoring instrument (picker emits matched lines); owner review |
| Gardiner codes resolve by Unicode name | §3 | bin/hiero_registry.rb verification; hiero_queue_contract_test |
| Classifiers are silent (Reads "—") | §3 | registry structure; drills prompt FUNCTION (drills_test) |
| Debated identifications carry `certainty: unclear` | §3 | pool field; presentation owner review |
| aes license labels | §4 | rulebook.rb |
| Every corpus reading cites its URN | §4 | `citation-urn` lint |
| Museum objects labeled exhibits, not readings | §4 | `citation-urn` lint, `reading--monument` class (M19-2) |
| Names approximate and say so | §4 | owner review |
| New jargon → terms.yml same commit | §5 | term_links plugin + terms contract test |
| Promises ledger: named chapter delivers, and says so | §6 | owner review |
| E102 queue additive-only | §8 | hiero_queue_contract_test |
| Batches from committed freq table; taught-means-used | §8 | queue contract; readable-line requirement owner review |
| Sentence types under Allen's names, one per chapter | §8 | terms contract (same-commit); pacing owner review |
| Walkthrough law (3+ pieces → bullets) | §8 | owner review |
| Codex: Gardiner-code slugs; classifier keywords = function | §9 | rulebook.rb codex checks |
| Retrieval laws (shared §8 of cuneiform) | §10 | warmup/drills/deck/cold-read tests |
