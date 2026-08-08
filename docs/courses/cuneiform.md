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
- **Readings are PHONETIC, in brackets** (owner rulings
  2026-08-05/06): wherever the site states what a sign READS —
  Reads columns, codex Reads rows, warm-up and drill prompts,
  sign tips — it shows the sound: [ku], [pi], [wa/wi], never
  ku₃ or pi₂. The homophone index is transliteration
  bookkeeping, not phonetics: it appears in transliterated text
  (*e₂ ku₃* in a reading line) and in sign NAMES (KU₃), and
  nowhere else. A bracket holds ONE reading's phonetic variants
  joined by slashes ([wa/wi], [ir/er]); a sign's OTHER lexemes —
  ideographic word-readings like diŋir, utu, dumu, i₃ — are not
  phonetic values of the first and list separately after it, in
  transliteration form: "[an], diŋir" (owner correction
  2026-08-06). In registry values, ";" separates lexemes while
  ","/"/" separate phonetic variants — the display rule reads
  that structure mechanically. Certainty tags — (stated), (classic) — do not appear
  in chapter sign tables or sign hover tips, which stay compact;
  the CODEX pages and the Reference's Origin column may carry
  them — that is where grading lives (owner clarification
  2026-08-06). A Means cell carries the semantic core only; the
  sound is the Reads column's job.

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
  2026-07-31; reaffirmed 2026-08-06 after C103 shipped bare
  "chapter NN" and "102's SIGN" mentions): a mention of ANY
  earlier material — a chapter, a sign, a course — links at the
  mention; a veteran sign's mention links its teaching-seat
  anchor (#sign-<codepoint>). Grammar walkthroughs go piece by piece — no
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
- Chapter titles and sidebar labels speak the student's
  language (owner rulings: "šumma" 2026-08-06, "anāku"
  2026-08-08): plain English carrying the chapter's essence — a
  transliterated ancient word is never a title or label; it
  enters in the first paragraph instead, where it can be
  taught. Root cause of the recurrence: the nav-label rule
  mechanized only sidebar-page AGREEMENT, so "anāku" passed by
  literally appearing in the title. The title-language lint now
  bans transliteration characters (macrons, ṣ/ṭ/ḫ/š/ŋ,
  subscript indexes) from chapter titles and short_titles
  outright.

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

`shows:` never licenses a reading (owner report 2026-08-08,
after law 197 shipped as a "reading exhibit" whose bone-compound
GIR₃.PAD.RA₂ transliterated three untaught signs as if the
student could read them): a `shows:` sign may appear only in a
standalone display exhibit, never inside a reading figure — a
graded reading carries taught signs only, untaught ones as ▢,
no exceptions and no exhibit framing. If a passage's key word
is written with untaught signs, the passage waits for its batch
or speaks in bound transcription alone. The shows-in-reading
check enforces this for cuneiform courses.

A reading that carries NEW grammar gets an item-by-item
breakdown after the figure (owner ruling 2026-08-06, the C102
"take inventory" style): every word parsed — form, ending,
function, teaching-seat link — then the line reassembled
literally. A lumped one-line gloss never introduces grammar on
its own; quick glosses are for review material, and even those
link the chapter that taught the form.

A grammatical MECHANISM is demonstrated, never asserted (owner
ruling 2026-08-07, after the stems table taught "doubled" on a
form whose doubling is invisible): the demonstrating example
must SHOW the mechanism in its spelling — a doubling the reader
can see (u-ub-bi-ir), a prefix they can point at — and terms
like "causative" are explained in plain words (fall vs fell)
before the label is used. A form that hides the mechanism
(ukīn's doubling inside a weak root) never carries the
demonstration. Sharpened same day: a PARADIGM is taught on ONE
model verb run consistently through every slot, in phonetic
transcription (the grammars' p-r-s), with the changing material
marked — never a different verb per slot with shifting
meanings. Only after the model grid stands are the corpus's
real (often weak-rooted) verbs mapped onto it. Sharpened again
2026-08-07 (owner request): when the pattern must be seen to
GENERALIZE, a second model root runs through the same slots in
parallel — every root filling EVERY slot, so the reader watches
the identical build land on different consonants. Model roots
are strong roots with textbook-standard forms in every slot;
gaps and weak-root wrinkles belong to the mapping step after —
and in that step each real verb's ROOT is spelled out before
its slot is named (owner report 2026-08-07: "the accusing-verb's
middle consonant is b" — of which root?), so the reader always
sees skeleton, then build, then form.

Table cells hold forms and few-word glosses; sentence-length
commentary lives in prose AROUND the table, never inside cells
(owner report 2026-08-07: the stems table's Says column carried
whole sentences and blew the layout). Mechanically:
`sign-table--tail-fit` pins the table's last column to a single
unwrapped line, so cells there stay ≤ 60 characters of rendered
text — the tail-fit-width lint enforces it; a longer tail
column means the class is wrong or the commentary belongs in
prose. Sharpened 2026-08-08 (owner report: the stems grid
unbalanced again, this time on The build): a table's width
budget is SHARED — in an n-column tail-fit table, non-tail
cells are labels capped at 180/n characters (five columns →
36); anything needing a clause is prose. The lint enforces
both caps.

## 6 · What the gate checks mechanically

From this rulebook: ŋ-not-ĝ, no accent indexes, ETCSL and CDLI
license labels (`script/rulebook.rb`); from §7, the codex checks —
keyword presence and uniqueness, one codex page per taught sign,
name-slug agreement (activation staged per school as the pages
land); plus the standing rules — subscript-index, untaught-sign,
font coverage, no-JS, link hygiene, tail-fit-width (§5). Everything else above is law
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
  contrast rows on a shelf page of their own (owner ruling
  2026-08-05: the deck and the lookalikes are separate drill
  pages). A print stylesheet renders the deck as cut-out Leitner
  cards.
- **The deal** (owner ruling 2026-08-05): the drill deck ships
  as TWELVE pre-generated cuts — the same cards under twelve
  seeded orderings, each produced by the same hash-and-spread
  rule, so every cut is content the gate has verified. The
  drills page holds no deck of its own (owner ruling
  2026-08-05: the deck stays hidden under the tiles): it deals
  all twelve cuts face-down, the calendar-picked one marked as
  today's deal, and each tile opens the full deck in that
  ordering; the reader's pick is the only random source the
  site ever uses, and visited-link styling may fade used tiles
  — no other state exists. WHICH cut is featured follows the
  calendar: the
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

## 9 · Akkadian (C103 and later)

Ruled 2026-08-05 at the opening of Phase 12, before any Akkadian
content exists.

- **Dialect: Old Babylonian.** The entry dialect of the standard
  teaching grammars and the dialect of the course's anchor text
  (the Codex Hammurapi, `urn:nabu:cdli:p464358`, license
  attribution). Cited reference for didactic claims:
  Huehnergard, *A Grammar of Akkadian* (cited once or twice per
  course, per the site rule). Later dialects (Standard
  Babylonian, Neo-Assyrian) belong to later courses and enter
  this rulebook before they enter content.
- **Transliteration display** (extends §1). Akkadian syllabic
  values are italic, hyphenated, with Unicode subscript indices
  (i₃-nu, ša-i-im). ATF phoneme ASCII folds to the field's
  standard signs in ALL displayed transliteration: sz → š,
  s, → ṣ, t, → ṭ, h → ḫ, ' → ʾ; raw ASCII appears only in
  verbatim raw-ATF exhibits (span class "translit atf"), same
  carve-out as the subscript rule. Sumerograms inside Akkadian
  text display in the field's CAPS convention (LUGAL, KALAM);
  the ATF underscore notation (`_lugal_`) is raw-ATF-exhibit
  material only. Determinatives stay in braces ({d}, {diš}) —
  the school's convention since C101 ch. 03. **Akkadian reading
  transliterations carry NO homophone indexes** (owner rulings
  2026-08-06, generalizing from u₃ → u): i-nu, ḫa-am-mu-ra-pi,
  ṭu-ub-bi-im, {d}en-lil — the script column carries the sign
  identity, and the accent-indexes of the handbooks are banned
  by §1 anyway. Sumerogram values inside Akkadian reading lines
  are CAPS (LUGAL, KALAM), per this section's display law —
  lowercase would read as Sumerian leaking in. A sumerogram
  NAME keeps its index (E₂-su — the index belongs to the name,
  §1); only lowercase readings drop theirs. Sumerian-course
  transliterations keep their indexes (field standard, §1).
  Enforced by the akk-translit lint rule.
- **Normalization (bound transcription).** A layer distinct from
  transliteration: dictionary-form Akkadian with vowel length
  marked (šarrum, awīlum, ā/â). It renders in its own visual
  register (its own span class — never the hyphenated
  transliteration style), is introduced and explained in the
  C103 orientation before first use, and NEVER appears in a
  reading without the transliteration it normalizes.
- **Language separation** (owner ruling 2026-08-05). Sumerian
  and Akkadian never mix in the codex. The existing Addenda is
  purely Sumerian — titled C SUX Addenda (title only; its live
  permalinks are frozen). A separate C AKK Addenda follows the
  Akkadian courses, at `/cuneiform/addenda-akk/`, carrying a
  completely separate Sign Codex (`/cuneiform/addenda-akk/signs/
  <slug>/`, same name-slug scheme) on its own frequency base.
  An Akkadian codex page tells the sign's AKKADIAN story: its
  syllabic work, its fit to Semitic phonology, its OB corpus
  rank. The codex laws of §7 (two-heading honesty, page ships
  with its sign, no-box attested line) and the retrieval laws of
  §8 bind the akk codex identically — its attested line is an
  AKKADIAN line from the OB corpus containing no sign untaught
  in the school.
- **The keyword is the cross-language invariant.** One keyword
  per sign, identical on its sux and akk codex pages,
  unchangingly unique across the whole school. The rulebook
  enforces both directions: the same sign may never carry two
  keywords across codices, and two different signs may never
  share one anywhere in the school.
- **Veteran signs.** A sign taught in C101/C102 never re-enters
  as a new sign (the taught-once law stands). In C103 sign
  tables it appears only as a marked veteran gaining its
  Akkadian reading, and its glyph links to its AKKADIAN codex
  page: sign_linker routes by course — C101/C102 surfaces link
  the sux codex, C103 surfaces the akk codex. On Akkadian pages
  a veteran's glyph links its AKKADIAN reintroduction chapter,
  never the Sumerian teaching seat (owner ruling 2026-08-06);
  Sumerian pages keep the sux seat. Its Akkadian hover tip
  stays hover-sized (same ruling): name · reads · the value's
  hook, the redundant "veteran — X gains [y]" boilerplate
  stripped — the full story is codex-page prose, never a
  bubble. A sign the course uses as a **sumerogram** (KALAM,
  LUGAL) is itself a veteran in this sense: it re-enters in a
  marked veteran table row with the Akkadian word it writes as
  its reading ([mātum], [šarrum]), gets its own akk codex page,
  and its bubble tells the Akkadian truth — a bubble may never
  imply a Sumerian reading on an Akkadian page. AMBIENT veterans
  — signs whose value crosses the border unchanged (A, MU, GI…)
  — keep their Sumerian bubble everywhere (owner ruling
  2026-08-06): the reading misleads nobody and the original
  teaching stands; only a sign that gains a NEW Akkadian reading
  (syllabic or sumerographic) gets the akk treatment above.
- **Ordering.** Value-frequency computed over the OB sub-corpus
  (CDLI `lect=akk:ob`) by the ratified frequency methodology,
  extended as a separate base — sux and akk ranks never mix.
  Reinforcement selection (§8) applies from the first chapter:
  candidate lines are scored for the veterans they revise.

### Stretch 2 (ruled 2026-08-06 at the phase-13 opening, before content)

- **Compound-only signs** (owner ruling 2026-08-07, after ENGUR
  shipped with Reads [engur] while the chapter said "spoken
  Id"): when a sign is taught only as part of a compound
  writing, its Reads bracket carries what the reader SPEAKS for
  that writing ([id] for 𒇉 in 𒀀𒇉), never the sign's Sumerian
  identity-value — that identity (engur, the deep) lives in the
  Name, keyword and story. The bracket is always the voice.
  Extended 2026-08-08 (owner report: ENGUR / [id] / {d}I₇ / Id —
  four labels, no bridge): the reading-line TRANSLITERATION of a
  compound writing carries that same voice — glyph →
  transliteration → bracket → normalized word must chain without
  a leap. The river-pair 𒀀𒇉 is therefore transliterated ID₂
  (OSL lists id₂ and i₇ as the same deterministic value of
  |A.LAGAB×HAL|), the index habit the reader owns from E₂ — and
  the chapter states the name/spelling/voice equation in one
  place. Where the corpus files the value differently (CDLI's
  {d}i7), the divergence is a footnote in the teaching chapter,
  never a reading line.

- **Plurals.** Displayed in the same two layers as the singular
  (§9 transliteration + bound transcription, vowel length always
  marked: nišū, nišī, šīmātum). Taught as the singular was — one
  table, concrete holdable examples (masc. -ū nominative / -ī
  genitive-accusative; fem. -ātum / -ātim). The "singular only"
  hedges stretch 1 planted (ch02's table, ch07's nišī note) are
  resolved by the plural chapter and link forward to it.
- **Verbal stems.** The course names stems with the field's
  letters — G, D, Š, N (as in Huehnergard) — and at first mention
  each letter carries a plain-word handle: G "the ground stem,"
  D "the doubled-middle stem," Š "the causative," N "the
  passive." The Roman-numeral stem systems of some handbooks
  never appear in this school. Stem letters are upright Latin
  caps. Stretch 1's "thickened forms" honesty note resolves into
  this naming; t-infixed forms (uktīn) are named where met, not
  systematized until a later stretch.
- **Letters.** Epistolary readings enter from the CDLI OB slice,
  license attribution only (the deck law stands). The citation
  line identifies the text as a letter with sender and recipient
  when known, plus the URN as ever. The epistolary frame (ana X
  qibīma — umma Y-ma) is taught before the first letter line is
  read; letter readings obey every §9 display law (no homophone
  indexes, CAPS sumerograms, bound transcription alongside).
- **Independent pronouns.** anāku, atta, šū … display in bound
  transcription; each pronoun taught with a concrete line, never
  a bare paradigm; the paradigm table stays course-sized (the
  persons the readings actually use).

### Stretch 3 (ruled 2026-08-08 at the phase-14 opening, before content)

- **The perfect.** The third and last tense this course names:
  iptaras, a -ta- after the first root consonant, glossed "has
  done." Taught on the parallel model roots (§5 law — p-r-s
  beside m-ḫ-ṣ), then every met -t- form re-parsed and slotted:
  G perfect (ištebir, iktašassu's kašādum, ištalmam), D perfect
  (uktīn, uḫtappid, ūtebbib). The šumma-clause tense chain —
  preterite/perfect for the deeds, durative for the verdict —
  is stated once, when first whole. ch09's "named where met"
  hedge resolves into this chapter and links forward. Gt/Št
  lexical stems stay named-where-met: the frontier.
- **The dual.** Paid where the corpus uses it — paired body
  parts (īnān "the two eyes") — displayed like the plural
  (bound transcription, length marked), one table row beside
  the plural's, never a full paradigm. ch02's hedge links
  forward to it.
- **Compound sumerograms.** When several signs write ONE
  Akkadian word (GIR₃.PAD.RA₂ = eṣemtum, "bone"), the compound
  is taught as one word: each NEW member sign's Reads bracket
  carries the compound's single voice ([eṣemtum]) — the bracket
  is always the voice — while Name, keyword and story keep the
  member's own identity (GIR₃ the foot, PAD the ration).
  Notes name the full compound on every member row; veteran
  members (RA₂ is 102's DU crossing with a new value) route as
  veterans with their sux bubbles. Codex pages mirror the same
  identity/voice split, ENGUR-style.
- **Contracts.** Legal-document readings enter from the CDLI OB
  slice, attribution only — the deck law stands. The citation
  identifies the document type (loan, sale) and parties when
  known, plus the URN as ever. Witness lines translate "before
  PN" (IGI routes per the veteran law); date formulae are
  taught before the first one is read. Party names take §4
  conventional forms in prose, exact forms in transliteration.
- **Weights and fines.** Fines stay in the text's own units
  (shekel, mina — the glossary carries the standing gram
  values); a modern equivalence may appear once per chapter at
  first mention, never per line.
- **The Reference (course close).** ch18 closes the course in
  the 101-ch12 / 102-ch18 mold: the full taught-sign table,
  each glyph linking its codex page. Future courses link a 103
  sign to its CHAPTER teaching-seat anchor (#sign-<cp> on the
  chapter that taught it) — the site-wide convention; 101's
  reference-page anchors are that course's own historical
  seat. Veterans point at their original seats,
  instrument-reported coverage (no invented numbers), the
  frontier named honestly (omens, mathematics, Standard
  Babylonian). Every standing lint applies — title-language,
  tail-fit width budgets, the two-codex checks.
