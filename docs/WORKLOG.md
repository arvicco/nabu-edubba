# Worklog

One dense paragraph per completed packet, newest first:
date · packet · commit · notes (what changed, why, evidence, catches).
Incidents get their own entries: what happened, root cause, the
durable fix, the lesson now enforced.

2026-08-04 · Gate 9 closed · PR #12 merged by owner same day after
two review rounds, CI + deploy green, live surface verified (AŠ
page: hero wedge, keyword title, taught-in link, bubbles). Round 1
became law: codex lines fully readable, never a ▢ (rulebook §7,
number notation counts as taught) — a full-inventory picker pass
over the corpus requoted 11 pages, upgrades all (Sumer's own name
ki-en-gi for KI and GI; lu₂-diŋir-mu, the course's famous "my",
for MU; the royal-measure line 1(u) še gur lugal for U and GUR);
round 2 unhooked link underlines from sign-cell glyphs. Branch
phase-10 opened; M10-1..M10-5 skeleton laid for Stage B (74
hieroglyph pages).

2026-08-04 · M9-1..M9-7 · phase-9 · Sign Codex Stage A executed in
one day, laws first: rulebook §7 (cuneiform, the shared law) and §9
(hieroglyphs) before any content — name-slug permalinks (names
stable, keywords deliberately revisable and out of URLs, owner
reversal same day), keyword uniqueness per school, the two-heading
honesty rule, page-ships-with-sign, curated confusables — with the
machine subset in rulebook.rb under staged activation (orphan pages
and duplicate keywords flag from day one; keyword checks flipped at
the backfill, the C page-per-sign check when the shelf completed).
Backfill: one global content pass chose 154 keywords (GAL big / MAH
exalted, O29 great / G36 elder, X8 given loaf / D37 giving arm) and
shape-neighbor confusable sets; fields live in the pool sources and
flow through compilers (whitelists extended, regeneration verified
additive-only). Machinery: sign layout rendering all mechanical
parts from the registries, C Signs shelf index live from data,
graceful links while pages landed. Then all 77 cuneiform pages,
each with a certainty-honest origin (standard accounts cited once
on the shelf), an invented hook explicitly ours, and one attested
line reused from gate-verified course readings or freshly
nabu-verified and sign-resolved (P453265 sheep totals, P112410 loan
barley, P210013 ration line). The sweep surfaced and fixed two
shipped defects: BA taught in full twice (C101 ch09 + C102 ch08 —
now one seat at its queue pin, shown early as borrowed in ch09,
school-wide taught-once test added) and P210013 miscited as Umma
(it is Girsu). Table linking is a sign_linker extension, not a
40-file sweep: sign-cell glyphs link to their codex page while
keeping their anchor ids (taught-in links still land), keyed on the
page existing in the build so E102 self-heals at Stage B. Number
clusters 𒎙 𒐍 𒐌 joined the font subset.

2026-08-04 · Gate 8 closed · PR #11 merged by owner same day, CI +
Pages deploy green, live surface verified in pixels (E102 ch04
sign table, glyphs, grammar bite, term underlines all serving).
Between the PR and the merge, the sign-retention consideration ran
its full arc: first draft scored encoding as done and retrieval as
the gap; owner overruled — stories and keywords are the foundation
of human memory, not an accelerant — and the plan was rewritten
around the Sign Codex: one page per taught sign in each school's
Addenda (keyword as title, attested origin and invented mnemonic
under separate honesty-lawed headings, confusable rows, taught-in
loop), Heisig keyword law with gate-checked uniqueness, sign-table
glyphs linking to their pages, decks/tools on their own future
Addenda shelf (deck exports only, never a trainer — SRS assessment
confirmed). Owner ruled keyword-slug permalinks and approved the
plan in principle with Stage A as Phase 9; branch phase-9 opened
from main; M9-1..M9-7 skeleton laid (laws → backfill → machinery →
77 cuneiform pages → link sweep). E102 takes keywords in Stage A
and pages + links in Stage B, obviously.

2026-08-04 · M8-1..M8-10 · phase-8 · E102 Middle Egyptian first
stretch executed the day the nabu blocker cleared: rulebook §8
first (sḏm≡f display, one-sentence-type-per-chapter, formulaic
genres as the track's receipts), then instruments (43-sign pool
with Gardiner identities, hiero_curriculum compiler with offline
coverage from the committed tsv, picker --course=102, discovery
sweep of 2203 unlockable lines driving every pin — Q1 repinned
mid-course when its attestation's sentence type belonged to ch04,
one-type law self-enforced), then seven chapters, each reading
token-verified against hiero_inventar with per-line URNs: ch00
sky/land + the 71.4% dowry chart + jnk nb-pt at one new sign;
ch01 the nominal sentence via Ptahhotep's disputed 'mw pw' (the
translation fight told, the grammar certain); ch02 sḏm≡f from
Papyrus Westcar's own hinge (identified by its Khufu refrain) +
the falcon-on-the-pronoun; ch03 jr/dj/wnn with Amarna's eternity
parallelism and a foreman's 'do your work!'; ch04 the adverbial
sentence + three negations from the Doomed Prince, the temple
library, Piye's stela, and a kind doctor — closing on Wsjr =
eye+throne, the two-chapter cliffhanger paid; ch05 the recipe
register with four silent signs and the feminine-agreement bite;
ch06 anx-wDA-snb, the pharaoh etymology, Neferti bookending
Westcar (father and son), Wenamun's drink. Coverage 71.4→79.0%.
Sentence-type terms entered the Egyptian glossary as taught, per
the rulebook. Stitching: school catalog, E101 Reference pointer,
README. Incident absorbed mid-phase: one commit shipped red when
the gate was piped through grep|head (exit masked) — fixed
forward, gates now read plain.

2026-08-03 · Gate 7 closed · PR #10 merged 2026-08-02 by owner, CI
+ Pages deploy green, live surface verified in pixels (ch14 split
row, both Addenda shelves in sidebar, Egyptian glossary serving).
Cuneiform 102 stands complete at nineteen chapters; the phase also
grew the school-level Addenda concept (Writing primer from the
wedge-order scout, glossaries split C/E with a routing term
linker), banned accent-é with rulebook enforcement, linked every
chapter mention in both cuneiform courses, and absorbed four owner
review rounds — the fourth rebuilt from memory after the ctrl+s
incident. Branch phase-8 opened from main; Phase 8 plan (E102
Middle Egyptian first stretch, M8-1..9, rulebook-extension-first)
presented for owner approval with C103 Akkadian as the alternative.

2026-08-02 · M7-14 · phase-7 · Review round 4, rebuilt from memory
after an incident: the owner lost ~2h of dictated review notes to
ctrl+s (chat stash — single in-memory slot, overwritten; nothing
persisted to disk; recovery attempted via stash toggle, input
undo, session/state files, .claude.json backups — all empty;
ctrl+s now unbound in ~/.claude/keybindings.json, and long drafts
should go through ctrl+g external editing. Lesson: owner notes are
dictated in fragments now and land in .docs/ immediately). The six
rebuilt findings, applied: gur joins the glossary (300-liter
measure, mina/shekel's granary counterpart); the "stretch,
measured" self-congratulation cut from chs 05 and 11 — the
promises those sections made survive (ch08/ch12 openers depend on
them), the inventory brags do not; ch07's kalam-ma-ka finally
names its final vowel — the locative -a (nabu context check: lines
178–182 are the eduba doxology, "in the house … of the Land," the
very passage ch16 quotes at 179 — cross-linked), a-zu unpacked as
"the one who knows the waters," and -am₃ gets its concrete
attested example e₂-zu mah-am₃ "your house is majestic" (Ninurta's
journey to Eridug, 4.27.02:D.8 — first clause of the line is
damage-restored so only the intact clause is quoted; signs
OSL-resolved 𒂍𒍪𒈤𒀀𒀭), placed after -zu is taught and paired
with lugal-me-en as the copula's two faces; ch08's ba-/in-
paragraphs now show 𒁀/𒅔 like i₃- shows 𒉌, and the ba-ti ring
diagram reordered — šu's dashed noun box first, verb chain last,
practicing what ch01 preaches.

2026-08-02 · M7-13 · phase-7 · E Addenda + glossary split
(owner-directed): the hieroglyphs school gains its own Addenda
shelf, and the glossary splits along school lines — 17 terms used
only by Egyptian pages (classified empirically, grep over site
content, not by intuition: the phonetics row ꜣ/ʿ/ḥ, the sign-class
row uniliteral→triliteral + phonetic complement + phonogram +
ideogram, the culture row cartouche/serekh/honorific
transposition/hieratic/demotic/ostraca/suffix pronoun) tagged with
an additive school: field in terms.yml and rendered at
/hieroglyphs/addenda/terms/, sidebar-anchored under E Addenda;
/terms/ keeps the rest and cross-links. The term linker learned
multi-glossary routing: glossary pages declare terms_school, the
plugin builds a school→URL map, each bubble links to its term's
home page (String arg still accepted; tests cover both). Verified
in built HTML: all 14 cartouche bubbles route to the Egyptian
page, determinative stays general. Two catches in passing: C102
ch17's "emphatic prefix" would have worn the phonetics bubble —
reworded to "affirmative prefix," Foxvog's own term; and
"classifier" stays general because cuneiform 101/03 uses it,
despite its Egyptology-flavored definition. Hieroglyphs catalog's
stale "101 opening chapters arriving" fixed (same disease as the
cuneiform catalog's, caught in M7-12).

2026-08-02 · M7-12 · phase-7 · C Addenda born (owner-directed after
the wedge-order scout): a school-level out-of-course shelf at
/cuneiform/addenda/ — appears in the sidebar as C Addenda between
the numbered courses and the hieroglyphs school. First residents:
the Writing primer (the scribe's hand — three wedges and stylus
mechanics per Cammarosano, overlap paleography with schematic SVG,
Taylor's standardization finding and the PA-vs-GIŠ per-sign
convention with his own kanji parallel, KI's re-choreographing,
Wright/Huehnergard reconstruction rules with their disagreement
shown — every claim labeled proven-from-clay vs attested-tendency
vs honest-reconstruction; four sources footnoted; primary sources
re-fetched before writing per owner instruction) and the /terms/
glossary, previously unanchored, now listed under Addenda (URL
unchanged — permalinks frozen). C101 ch00 gains the two
honestly-teachable habits (drill the three strokes first as the
school exercises did; top-before-bottom, left-before-right) with
links to the primer. Mechanics: addenda dir is outside
course_check's numeric-course glob so the pedagogy contract stays
course-only; PA+GIŠ joined the font subset (79 codepoints);
Winkelhaken termed; chapter layout gained kicker_no_chapter so the
primer isn't mislabeled a chapter; school catalog's stale "102 in
progress" line fixed in passing.

2026-08-02 · M7-11 · phase-7 (ac58627, ce881e0, 45b44f2) · Owner
review round 3: full sequential re-read of C102 (mine) plus the
owner's own pass, seventeen findings all fixed. Structural: the
locative -a now enters at ch01's tag list and ud re-a's gloss
names it (ch13's table becomes consolidation, not revelation); the
nominalizing -a — promised by ch08, used ever after, never
delivered — got its named bite in ch14 with the locative-collision
warning and a Reference shelf entry. Explanation gaps closed:
nam-gi₄'s emphatic prefix flagged in ch17 (three jobs, one shape),
-ke₄ explained as genitive+ergative stack, -ani/-ni reconciled,
-ma-/-na- forward and back pointers. Dead references rooted out:
a₂-ki-ti "from chapter 10" (never existed), ch12's invented ch05
quote, ch01's phantom "search hit," ch03's kur-kur attributed to a
number-line reading (it was ch04's first words), the stale
sitting-down teaser; plus du/ti/la and "two signs" slips.
Owner-directed orientation rework: coverage chart cut to 12 rows
(every chapter through 04, then evens + finale) with figures after
the bars and a one-sentence student-facing caption (machinery →
footnote), course-end promise stated, MU-as-"my" explained with a
ŋu₁₀ footnote, hyphens get an immediate example, homophone/mina/
shekel/nominalizer term bubbles, emesal disclaimer footnoted.
Notation: accent-é banned in transliteration — both courses
normalized (102 chs 01/02/07, 101 chs 04/07/08/09/10,
sign_teaching.yml), é-dub-ba-a exempt at pattern level, rulebook
doc+rule+test in one commit. And a course-wide sweep per the new
ruling that chapter mentions always carry links: ~100 back-
references linked across 101+102 (script for the mechanical part,
hand-fixes for wrapped lines and ranges). Gate green at each
commit; chart and bubbles verified in pixels.

2026-07-31 · M7-1..M7-10 · phase-7 · Cuneiform 102 completed
same-day as approval: chapters 12–18 (chain completed with mu-/-na-
on the votive's own verb, za-e + locative + seven-case paradigm,
first connected proverb row with the na- prohibitive, Šulgi A
lines 1–3 with the king's name assembled, the tablet house reading
its own name and colophons, Gudea Cylinder A from line one with
zero boxes, registry-generated Reference) — course at nineteen
chapters, 51 signs (77 with 101), coverage 53.4/54.5 floor.
Taught-means-used enforced twice: KU unpinned from ch13 (no
attested line) then returned honestly at ch14 as dab₅ in the
glutton proverb; LAL joined ch17 when the untaught-sign rule
caught la₂ inside Enlil's spelling on the refrain line. Veterans
gained readings only where readings demanded (išib, tum₂, de₃,
be₂). ch11's purpose-wrapper promise reworded now that no later
102 stretch exists; MI/LI/IB stay unpinned in the pool for a
future course. All content Fable-written; rulebook checks green
throughout; ch17 surface-reviewed in pixels.

2026-07-31 · Owner ruling: course rulebooks (single source of
truth) · After the ĝ/ŋ drift the owner ruled: before starting a
course, a working document spells out its conventions, notations,
and standards choices explicitly, and mechanics check produced
content against that rulebook before each Gate. Retrofitted:
docs/courses/cuneiform.md + hieroglyphs.md (human-readable law —
transliteration display, corpus quoting, license labels, prose
register, pedagogy mechanics, and what the gate enforces);
script/rulebook.rb implements the machine-checkable subset (ŋ not
ĝ, no accent indexes, ETCSL/CDLI/aes license labels), wired into
lint; every check cites its rulebook section. First run caught a
published Gate-2-era accent (101 ch11's ì → i₃) and validated all
license labels once whitespace-wrapping was handled. Codified in
CLAUDE.md content rules: a notation decision never lands in
content without landing in the rulebook; a new school writes its
rulebook before any chapter.

2026-07-31 · M6-1..M6-9 · phase-6 · Hieroglyphs 101 completed
same-day as approval: chapters 07–12 (biliterals, phonetic
complements + tomb family album, classifier system, culture words,
Rosetta decipherment, Reference), 18 new signs (53 total), every
chapter Fable-written per golden rule 9. Instruments:
hiero_reading_picker.rb committed (per-chapter buckets over aes
hiero_inventar; qualifies only whole, fully-annotated lines);
bin/hiero_freq.rb replaces the P4 ad-hoc counter. INCIDENT, the
mixed-case Gardiner bug family: the P4 sweep, the registry rank
lookup, AND the new picker's first regex all dropped Aa/Ff
category codes ("Aa1" vs pool "AA1") — Aa1 (ḫ, true rank 14,
10,720 hits) sat at rank 1802 count 1 in the committed table;
caught via ch12's rendered rank column (pixels again). All three
fixed with upcasing; freq table regenerated over 266k tokens;
prose errata (fifteen-of-26 in top twenty; reed fifth not fourth).
Editorial: ch05's Pepi turns out to be the Satire-of-the-Trades
schoolboy (A51 dignitary classifier) — ch09 tells it as the
payoff, ch05 caption de-ambiguated. Promises delivered: Pepi's
box (ch09), Ptolemy in full + Cleopatra cross-check (ch11), RTL
compass facsimile per D4-c, index placeholder arc superseded per
approved plan (counting + hieratic/demotic line → later courses).
Gate green throughout; ch11/ch12 surface-reviewed.

2026-07-31 · Owner ruling: content is Fable-only (constitution) ·
On PR #8 review the owner ruled: no Sonnet-drafted chapters, ever,
period — all content writing is planned AND executed by the Fable
session model; delegation stays permitted only for non-content work
(code, tooling). Codified as CLAUDE.md golden rule 9; the P2–P5
"impl-tier chapter" pattern is retired. The P5 agent drafts
(07/08/10) stand as fully top-reviewed and revised in place. Also
per review: back-references to prior chapters carry links — ch08's
"chapter 04's delivery line" now links home.

2026-07-31 · M5-1..M5-10 · phase-5 · Second stretch of Cuneiform 102
shipped same-day: chapters 06–11 (names-as-sentences, copula +
genitive unmasked, verbal-chain rings, proverbs + wish-forms,
literary register, votive capstone), 17 new signs (60 taught),
coverage ~49%/49.5% (floor). Instruments first: bin/pool_check.rb
verifies pool identities against the OSL via nabu signs --json
(first catch: OSL names NIN |SAL.TUG₂| — codepoint anchors
identity, osl_name: acknowledges naming variance); sign_seq.rb
signs mode counts TRUE sign occurrences (ETCSL 384k tokens 92%
deterministic; CDLI 8M tokens as background run); reading_picker
upgraded to per-chapter buckets with registry-driven ETCSL folding.
GIŠ swapped out for A₂ when no attested line used it within
inventory — taught-means-used admits no exceptions; lugal-a2-zi-da
proved the replacement. Chapter 05's promise kept literally:
nam-ti-la-ni-sze3 found verbatim in Lu-Utu of Umma's foundation
inscription (P216741), read line by line in ch11. D3-a exercised:
ETCSL quotes short + labeled non-commercial (Gilgamesh, Gudea,
proverbs, incipit catalogues). Agent-drafted 07/08/10 top-reviewed;
caught: 0.2.01 URNs are CATALOGUE entries misread as hymn lines
(rewritten honestly), en zid hails the god not the ruler, third
Foxvog citation over the 2-per-course cap, corpus name leaked into
lesson prose, ch11 crediting ch08 with untaught mu-/-na- rings
(agent's own flag). Errata fixed: ch05 "forty-four"→forty-three,
README "18 more signs"→34 (off-by-one family). Gate green
end-to-end; built pages surface-reviewed (pixels).

2026-07-31 · Gate 4 CLOSED · PR #7 merged by owner (beb9528), CI +
Pages deploy green, live surface review passed (hieroglyphs 05
cartouches + sign table, /terms/ glossary, retrofitted C101 05 —
pixels verified per DEV-LOOP §4.5). Egyptian school open:
Hieroglyphs 101 chs 00–06, 35 signs, aes readings URN-verified.
Catch: the D3-a ruling commit (3d02e10) landed on phase-4 after
the owner had merged, so it missed main — cherry-picked onto
phase-5 (lesson: after "merging now", freeze the phase branch;
late notes start the next branch). Phase 5 opened: Cuneiform 102
second stretch (chs 06–11), literary readings unblocked by D3-a;
plan at .docs/phase-5-plan.md, owner pre-approved "plan and
execute".

2026-07-31 · Owner correction: signs must be THEMATIC, taught once ·
The C101 front-load had grabbed the three number-strokes for ch01
(Clay and Reed) — convenient, not thematic, and it double-listed
them in later tables. Redone per owner: ch01 now teaches its own
materials 𒅎 IM (clay — brought forward from the 102 pool) and 𒆤
KID (reed mat — moved from ch10, whose table now presents it as a
veteran gaining the lil₂ reading for {d}en-lil₂: polyvalency shown,
not re-taught); the strokes 𒀸𒁹𒌋 moved to ch05 Counting where
they thematically belong (ch05 had violated every-chapter-teaches
anyway), plus GUR — which the registry claimed ch05 taught but NO
chapter ever did (latent registry/content inconsistency, now fixed
with a real gur account line 3(aš) še gur). ch04 wall chart marks
the strokes "ch. 05" via shows:. 102 side (owner suggestion): AK
moved ch05→ch02 — the sign that writes the very -ak genitive ch02
teaches; ch02 gained the pairing lesson (case=/ak/, sign=𒀝) and a
chapter-05 hook; ch05 slimmed to nin+la (drill bug fixed: said
"nin, ne, ak" for a nin/la/ak batch). Pool: IM removed, ALL batches
pinned to their published chapters (published course = contract),
BATCHES ch5=2; queue regenerated — batches stable, coverage chart
updated (base now includes 101's IM). 101 grows to 26 signs; all
"25/forty-three" claims updated. New principle codified: a sign is
taught exactly once, later tables mark veterans explicitly. Gate
green; validator proves both courses end-to-end.

2026-07-31 · Principles generalized + C101/C102 compliance sweep ·
Three owner rulings codified (CLAUDE.md + concept §3.1-3): every
chapter opens with signs in table form; technical terms carry
bubble definitions linking to /terms/; Nabu URNs link to their axis
desks. C101 retrofit: ch00 now teaches the promise trio 𒀭𒆳𒀀,
ch01 the three one-stroke signs 𒀸𒁹𒌋 (they ARE the chapter's
theme), ch02 barley 𒊺 (grain accounts becoming writing), ch03 the
polyvalency star 𒌓; ch04 reframed as consolidation + its two
genuinely new signs 𒆠𒂍 ("Wave three: the two new ones" — the old
heading "two you have already met" had inverted meaning after the
move). Registry taught_in retagged; five stale cross-references
fixed (incl. ch02's "watch below how it got that shape" promising a
ŠE evolution the chapter demonstrates with SAG — caught in
self-review). 102 ch00 batch table lifted above the coverage chart
(opens-with means opens-with). C102 01-05 and C101 05-11 already
compliant (tables in first screen). Terms glossary grew 11 entries
from a cuneiform jargon audit (terminative, genitive, titulary,
colophon, paleography…); term bubbles verified live on cuneiform
pages (automatic — the transformer is site-wide), URN links verified
(4 in 101 ch06). Gate green; validator re-proves both courses.

2026-07-30 · M4-1..M4-11 (Phase 4 sweep) · Egyptian hieroglyphs
school opened same-day as plan approval. Instruments first:
ScriptScan generalizes the font-coverage + nothing-untaught gates to
per-script ranges (adding a school = one SCRIPTS entry + vendored
face); Noto Sans Egyptian Hieroglyphs vendored (OFL, google/fonts);
bin/hiero_registry.rb resolves curated Gardiner codes against
Unicode NAMES via python3 unicodedata (verified, never guessed —
the cuneiform lesson institutionalized) and merges computed
frequency from a full aes sweep (815k tokens, 267k with Gardiner
codes; 14 of the 26 uniliterals in the corpus top-20 — computed
frequency CONFIRMS the field's uniliteral-first didactic order,
lovely validation of commitment §3.1-1). Psych catch: to_yaml
escapes astral-plane glyphs (\U0001313F) which blinds the coverage
scanner — registry post-processes to literal glyphs. Sign-linker
catch: glyph regex was cuneiform-range-bound (hieroglyphs passed
through unlinked) and tip_text's ATF normalization mangled Gardiner
codes (D46→D₄₆) — GLYPH range union + tip_join raw path, tests
pinned. Content: ch00-03 + ch06 top-tier (media/origins/mechanism/
formula), ch04-05 Sonnet agents to written specs (both returned
clean; review caught a corpus-name leak into lesson prose, a
"long vowel" claim contradicting the no-vowels teaching, and
duplicate shows: entries). Readings discovered by inventory-⊆
search over cached aes export: Teti cartouche X1-X1-M17 standalone,
Pepi Q3-Q3-M17-M17-Z4+det, honorific transposition attested in
estate name Sḥtp-Ptḥ-Ttj, offering formula whole from the
Mut-neferet stela (n kꜣ n) — all four URNs grep-verified exact
against the export (1 match each); Ptolemy NOT attested
hieroglyphically in aes/tla-hf (demotic only) → Rosetta exhibit
treatment, flagged for ch11. Surface-reviewed built ch05/06 by
headless screenshots (sign tables, cartouche SVG, formula strip —
Q3's hollow-rectangle glyph looks like tofu but IS the stool sign;
coverage rule proves no tofu can ship). README + school catalogs
refreshed (stale "no courses exist" + "eleven chapters" fixed).
Gate green throughout; readings data in .docs/p4-readings.md.

2026-07-30 · Gate 3 CLOSED · PR #6 merged by owner 14:26Z; CI +
Pages deploy green; live surface review of /cuneiform/102/04/ passed
(sidebar, sign table, subscripts, sign links all correct on the
deployed URL). CLAUDE.md phase line → Phase 4; BACKLOG M3 packets
closed, carried-forward items recorded. Same day: Nabu `signs`
shipped (P53) — smoke-tested against course readings: "i3 e2-gal DU"
resolves all four tokens deterministically with correct codepoints,
--json contract present, uri₅→|ŠEŠ.AB| compound correct (the case
that motivated the request). Both response asks honored. Phase 4
plan (Egyptian hieroglyphs school, per D0-a) drafted to
.docs/phase-4-plan.md grounded in a Nabu holdings survey (aes 202k
passages attribution-licensed, tla-hf, aed; tokens carry Leiden +
MdC + partial Gardiner codes); three design decisions flagged for
ruling (D4-a linear display, D4-b Leiden display convention, D4-c
reading direction). Awaiting owner approval.

2026-07-30 · M3-16 done · Hover bubbles on every linked sign (owner
request): the sign-linker now embeds a hidden <span class="sign-tip">
inside each generated sign link — "NAME · readings · meaning" — shown
by pure CSS on :hover/:focus-visible (no JS; tap on touch follows the
link, the designed fallback). Tip text composed in build_map from the
same two data files that drive linking; display_form normalizes ATF
for display (parentheticals/certainty grades stripped, sz→š, index
digits→Unicode subscripts — which the subscript renderer then turns
into real <sub>, since plugins run alphabetically sign_links before
subscript_render), orphaned separators trimmed (the NI meaning began
with a stripped parenthetical, leaving "; oil…" — caught in built
HTML). Own-page anchor cells get no bubble (the table row already
shows the data). 6 new unit tests; visual check via forced-visible
bubble over real built markup + site stylesheet in headless Chrome.
Gate green (45 tests). Owner catch, same day: bubbles inside
big-glyph exhibits inherited the host's display styling (2.6em,
letter-spacing 0.2em → sprawling spaced-out text). .sign-tip now
carries a full typographic reset (family, size, spacing, transform,
indent) so every bubble is compact regardless of context;
re-verified with a forced-visible bubble inside the ch05
nam-ti-la-ni-še₃ exhibit itself.

2026-07-30 · M3-15 incident+fix · Owner screenshot: the "subscripts"
shipped in M3-15 rendered as full-size oldstyle digits — the serif
stack has no glyphs for U+2080-2089, so browsers fell back to
whatever font had them. Lesson: a Unicode codepoint in the source
is NOT a typographic guarantee; verify the rendered SURFACE (we had
checked the bytes, not the pixels). Durable fix: new post_render
transformer (script/subscript_render.rb + _plugins wiring, mirroring
the sign-linker architecture) converts subscript-digit runs to real
<sub> markup at build time — skips title/svg/script/style/code/pre/
existing sub, attributes untouched; 7 unit tests; css sub rule
(0.72em, line-height 0) keeps line rhythm. Sources stay clean
Unicode (subscript-index lint rule unchanged). Verified in built
HTML (i<sub>3</sub> e<sub>2</sub>-gal, ATF exhibit untouched) AND by
headless-Chrome screenshot of the rendered chapter. Gate green (39
tests).

2026-07-30 · M3-15 done · Owner stylistic ruling: transliteration
index numbers are ALWAYS Unicode subscripts (lu₂, e₂) in displayed
text, never full-size ASCII digits — across all Edubba materials.
Converted every offender: 101 ch. 06 seal readings 1-2 + figcaption
(uri₅, limmu₂, li₉-si₄, ensi₂, ARAD₂), specimen page, 102 ch. 00
(lu₂-dingir-mu), ch. 02 (ga-gu₇-gu₇, ur-e₂-gal), ch. 04 (i₃ e₂-gal
DU, e₂-du-du, exercise 4); 101 ch. 03 convention paragraph now shows
subscript examples. Deliberate ASCII survivors: verbatim raw-ATF
exhibits (ch. 06 reading 3, now classed "translit atf" and its prose
extended to teach the full-size-digit ATF convention) and explicit
ASCII-convention mentions (ch. 03 e2 parenthetical, ch. 07 lu2, ch.
12 Reference — bullet expanded to declare the subscript style).
Enforcement: new subscript-index lint rule (letter+digit inside
`<span class="translit">`, "atf" class exempts) + 2 tests; rule found
an offender the manual grep missed (gu7) — oracle before hand-sweep,
as usual. CLAUDE.md content rule added. Gate green (32 tests).

2026-07-30 · M3-14 done · Review round 3: (1) essence titles — "Batch
N" chapter names banned; 102 chs. 02-05 renamed with permalinks (The
case that hides / Say it twice / The verbal chain, lightly / A
dedication, whole); (2) NE↔LA swapped between chs. 04/05 so signs are
taught where first USED — via a new curated `chapter:` pin in the
pool that the compiler honors over raw score (pedagogy overrides
frequency; queue regenerated, ch. 00 chart updated); NE now earns its
seat in 04: lugal-e-ne closes ch. 03's -ene promise and a-ne-ne (OIP
014, 049, ED IIIb Adab, P010528) shows it doubled in the wild; LA is
taught in 05 two paragraphs before the formula uses it; (3) 𒀭𒀝
{d}AK = Nabû added to ch. 05 — the scribes' god, the library's
namesake, now writable in two taught signs; (4) sidebar extracted to
an include and added to course INDEX pages via a new course layout —
navigation is now universal. Gate green throughout.


2026-07-30 · M3-13 done · Gate 3 review revisions: (1) sidebar now
lists every course of the school in numeric order (school:/course_no:
front matter), current course expanded, siblings one-click links;
(2) footnotes ordered below the bottom nav line (flex order — kramdown
emits them in-content); (3) reference citations footnoted out of the
lesson flow (ch. 01 carries the track's single [^ref]); (4) every
grammar marker got a held example — the é-bi confusion resolved by
teaching the actual animate/inanimate rule (é-a-ni his vs é-bi its);
(5) ch. 04 rebuilt on the taught sign (𒈬𒁺 mu-du composed figure;
the du3 homophone banished — "poor choice, ummia" acknowledged);
(6) ch. 02's sign-count/translit mismatch made the explicit lesson;
(7) SIGN LINKS: script/sign_linker.rb + site/_plugins/sign_links.rb —
build-time transformer wraps every known glyph in a link to where it
was introduced (101 signs → reference-page anchors, 102 signs → their
batch table; own-page sign-cells become the anchors), skipping
existing links/titles/svg; 7 tests (30 total); htmlproofer validates
every generated link+anchor as part of the gate; zero visual change
until hover. First _plugins use — allowed because we build with our
own Jekyll in CI, not the github-pages gem.


2026-07-29 · PHASE 3 (M3-1..M3-10 substantially done) · phase-3 ·
Cuneiform 102 opened: course architecture with validator
prerequisite support (assumes: front matter — 102 inherits 101's
inventory; test pins both directions); curriculum compiler v1
(score = best rank + 8×wedges, calibrated so ME's 2 wedges beat RA's
better raw rank; per-chapter batches committed as generated queue
with cumulative coverage 38.1% ETCSL / 40.9% CDLI by ch. 05; 5
tests); ATF value-extraction bug found and fixed (subscript chars
truncated e2/lu2 — queue and coverage regenerated); reading picker
(validator logic inverted over nabu jsonl exports; ETCSL confirmed
license-class nc → D3-a decision item, CDLI attribution used
exclusively). Chapters 00-01 top-tier (coverage chart from the
compiler's own numbers; first zero-box reading lu2-dingir-mu from
ED IIIa Fara lists; Sumerian-in-one-chapter with sentence-anatomy
figure; Foxvog as the track's standing reference); chapters 02-05
delegated with batch data + pre-rendered native readings + grammar
outlines: genitive-that-hides, doubling/nam- (with -ene honestly
deferred since NE was future), verbal chain lightly + TI rebus
payoff + real account line i3/e2-gal/DU, dedication formula
nam-ti-la-ni-sze3 assembled entirely from taught signs. All
delegated chapters reviewed (02 post-hoc after the add -A near-miss;
03/05 spot-checked clean). All readings ED IIIa (~2600-2500 BCE),
attribution-licensed, URN-cited.

2026-07-29 · INCIDENT: deployed site unstyled · What happened: after
Gate 1 merged, arvicco.github.io/nabu-edubba rendered as raw HTML
(owner screenshot) while local builds were fine. Root cause: baseurl
"" — pages referenced /assets/style.css and /cuneiform/ at the DOMAIN
ROOT, but Pages serves the project under /nabu-edubba/; every internal
reference 404'd. Why verification missed it: the deploy check curl'd
individual files (which exist under /nabu-edubba/ and return 200) but
never rendered the live page, so the wrong hrefs inside the HTML went
unseen. Durable fix (hotfix branch): (1) pages.yml injects
configure-pages' base_path into jekyll build --baseurl, so the build
is correct at /nabu-edubba AND at edubba.ac (base ""); (2) all
internal content links converted to {{ '/x/' | relative_url }}; (3)
new lint rule base-relative forbids root-absolute href="/x" / ](/x)
forever (tests 12/12); (4) verified locally by building with
--baseurl /nabu-edubba, serving, and screenshotting — fully styled,
all hrefs carry the base. Lesson enforced in DEV-LOOP §4.5: after any
deploy, surface-review the deployed URL itself; a 200 on a file is
not evidence the page references it.

2026-07-29 · M1-3, M1-4, M1-5 done · phase-1 · Landing page (M1-3,
top): map of writing — school cards with per-school accents + glyphs
(𒀭 / ☥ / 字), family tree as accessible nested lists, start-here.
School stubs (M1-4): first packet DELEGATED to an implementation-tier
agent (sonnet) with a written spec (concept.md §2–3 as sole content
source, hard constraints incl. no uncovered native glyphs); returned
three constraint-clean catalog pages, diff reviewed and accepted —
the tiering model works. Specimen chapter (M1-5, top): chapter layout
family (_layouts/chapter.html: course/prev/next nav from front
matter), sign table (𒀭 𒈗 𒆠), reading panel
translit/gloss grid, citation footer. Reading content is REAL: the
Amar-Suen seal from CDLI P101077 (AnOr 01, 086, Ur III Umma), pulled
via nabu CLI (`nabu search`/`show`), license class attribution, cited
by URN + CDLI link. Coverage rule proven live: adding 𒀭𒈗𒆠 turned
lint red until `rake fonts` (subset now 7 codepoints / 3.9K). Surface
review (headless Chrome, all three page types): glyphs real, accents
correct, reading grid aligns, mobile OK. README refreshed pre-gate.

2026-07-29 · NEAR-MISS: gate exit code masked by pipe · The M3-5/6
commit landed while `rake gate 2>&1 | tail -1` reported only tail's
exit status (zsh, no pipefail) — the gate was actually RED (a
relative ../101/ link resolving wrong from a permalink directory)
and a concurrently-writing chapter agent's file (ch. 02) was swept
into the commit by `git add -A` unreviewed. Caught on the next
honest run; link fixed; ch. 02 reviewed post-hoc (excellent,
accepted). Lessons enforced: gate invocations use the bare exit code
(`rake gate >/dev/null && echo GREEN`), and no `git add -A` while
chapter agents are running — add explicit paths. Both now noted in
DEV-LOOP §4.4 practice.

2026-07-29 · M2-18 done · Second review round (owner): (1) ch. 00
stroke figure corrected — horizontal wedge head now at LEFT matching
the font's AŠ (owner caught the reversal), corner wedge redrawn to
match 𒌋; (2) Name-vs-Reads convention explained at first use (ch. 03
notation section + reminder at ch. 04's first table); (3) sign-table
Notes now carry graphic-origin context wherever the sign lists
support it, "origin opaque — learn the shape" where they don't;
(4) NEW ch. 08 The sign workshop (course now 13 chapters, 25 signs):
SAG (the ch. 02 evolution example finally taught), KA (gunû hatching
move), KA×A nag "drink" and KA×GAR gu7 "eat" (containment move) —
codepoints verified by Unicode name search after first guesses
proved WRONG (12295 not 122A1 etc — the name check earns its keep);
09-12 renumbered; (5) ch. 07 filiation reading gained its script+▢
column; (6) reading--script grid columns fixed to proportional
fractions (alignment complaint); (7) ch. 12 sign count now computed
by Liquid from the registry ("counted live, so this number can never
lie") after owner caught the stale "twelve signs" text — generated
beats prose for facts that move. Gate green; subset 26 codepoints.

2026-07-29 · M2-17 done · Gate 2 review revisions per owner feedback
(prose style approved and memorized; rules codified in concept §3.3–5
+ CLAUDE.md): (1) sidebar course layout — pure Liquid/CSS from
course:/chapter: front matter, current chapter highlighted, kicker
"Cuneiform 101 · Chapter NN", <details> fallback on mobile, zero JS;
(2) every chapter from 04 teaches signs: course restructured to 12
chapters (07-10 renumbered 08-11; NEW ch. 07 Of gods and men: LU2/
GAL/TUR with LUGAL decomposed and a real filiation roster line, CDLI
P109952), ch. 05 +GUR, ch. 08 +DUB/BA (opens by reading the site
wordmark), ch. 09 +EN/LIL2 (reads Enlil), ch. 10 +NA/NI (names as
the decipherers' crowbar) — 21 signs total, all codepoints verified
via unicodedata names, wedge counts from renders, ranks from the
committed tables; (3) ≥1 graphic per chapter (stroke figure + glyph
exhibits in 00, stylus section-view in 01, AN-three-roles in 03,
wall chart in 04, number exhibit in 05, cylinder-seal rolling in 06,
LUGAL composition in 07, wordmark in 08, schematic Near East map +
concrete middle-chronology dates in 09, trilingual-principle figure
in 10); (4) script-beside-translit principle with ▢ placeholders in
ch. 06 + specimen readings, ▢ documented in ch. 11, nabu ATF→signs
feature request drafted in .docs/; (5) CDLI links → cdli.earth;
Finkel & Taylor citations cut to ch. 01 + ch. 11 further-study.
Gate green (validator re-proved the new teaching order); subset now
22 codepoints / 8.4K.

2026-07-29 · PHASE 2 COMPLETE (M2-1..M2-16) · phase-2 · Cuneiform 101
Foundations: 11 chapters + course index live. Instruments first:
course architecture with dynamic prev/next nav computed from
course:/chapter: front matter (no dead links possible); taught-signs
validator (untaught-sign gate rule; teaches:/shows: contract; 5
tests); sign sequencing table realizing the frequency×simplicity
ruling — bin/sign_seq.rb computed value frequencies from nabu exports
(ETCSL 36,501 + CDLI 1,548,658 sux passages; per-corpus, never
merged), curated per-sign wedge counts (counted from rendered Noto
glyphs — all 14 candidate codepoints VERIFIED by rendering before
use) and iconicity with certainty grades. Chapters: top tier wrote
00/02/03/04/06 + reviewed everything; implementation tier (sonnet
agents, written specs with factual anchors) wrote 01/05/07/08/09 —
all five accepted, three with review fixes (07: etymology softened,
wrong-target links unlinked; 09: two phrasing fixes after mandatory
fact review; 08 clean; 01/05 clean). Ch. 06 reads three genuine Ur
III texts (CDLI P101077, P128972, P210013; license attribution;
URN-cited) incl. damage conventions and a year-name. Ch. 10 Reference
is Liquid-GENERATED from site/_data/sign_teaching.yml so it cannot
drift. Font subset grew 4→15 codepoints, coverage rule fired red at
every new-glyph moment as designed. School/landing flipped to "101
open"; README updated. Gate green throughout; every rendered surface
screenshot-reviewed.

2026-07-29 · M1-2 done · phase-1 · Font pipeline: full Noto Sans
Cuneiform v2.001 (801K, OFL) vendored as SOURCE in assets-src/fonts/;
site ships a computed subset (site/assets/fonts/, currently 4
codepoints = 2.6K) regenerated by `rake fonts` (script/subset_fonts.rb,
hb-subset). Gate now enforces no-tofu: new lint rule font-coverage
(shared scanner script/cuneiform_scan.rb) fails if site/ uses a
cuneiform codepoint absent from the committed coverage manifest.
Tests 9/9. CSS: @font-face with unicode-range U+12000-1254F +
font-display swap; per-school accent tokens (cuneiform terracotta,
hieroglyphs lapis, hanzi cinnabar; dark variants). Surface review
(headless Chrome vs served build): wordmark 𒂍𒁾𒁀𒀀 renders real
glyphs, dark scheme good; apparent mobile clipping at --window-size
390 diagnosed as headless Chrome's ~500px minimum layout width
cropping the capture (identical wrap points at 500px, all visible) —
not a real overflow; header got flex-wrap anyway. Note: `ruby -run -e
httpd` needs webrick (absent); use `python3 -m http.server` for
throwaway serving on this box.

2026-07-29 · M1-1 done · PR #2 merged by owner (10:16Z) · Acceptance
met exactly as specified: the merge push itself triggered the Deploy
workflow (run 30443040336, green, 39s) with no manual step; outside
verification: HTTP 200 at arvicco.github.io/nabu-edubba with page
content and stylesheet serving. Owner rulings at merge: P1 plan
approved; ALL phase improvements batch into the gate PR going forward
(mid-phase PRs only for owner-sanctioned hotfixes) — DEV-LOOP §4.8
updated. Phase 1 continues on phase-1 toward a single Gate 1 PR.

2026-07-29 · GATE 0 CLOSED · PR #1 merged by owner (09:01Z) · Phase 0
complete: M0-1..4 done, CI green on main merge commit. Owner rulings
landed at the gate: (1) gates close via a PR the loop prepares
(DEV-LOOP §4.8); (2) deploys must be automatic on merge — no manual
dispatch step (implemented as M1-1). Phase 1 elaborated.

2026-07-29 · INCIDENT: first Pages deploy failed · run 30437922348 ·
What happened: owner's workflow_dispatch deploy failed at the deploy
job: "Branch main is not allowed to deploy to github-pages due to
environment protection rules." Root cause: the auto-created
github-pages environment got a custom deployment-branch policy pinned
to phase-0 — the default branch at the moment Pages/the environment
came into being. Durable fix: policy now allows main ONLY (phase-0
policy deleted — phase branches must never deploy); pages.yml paths
filter removed so every merge to main deploys (a missed deploy is
worse than a redundant rebuild). Lesson enforced: when enabling Pages
on a repo whose default branch ever differed from main, verify
environments/github-pages/deployment-branch-policies before the first
deploy; M1-1 acceptance requires the merge itself to deploy green.

2026-07-29 · M0-3 done · phase-0 pushed · Repo arvicco/nabu-edubba
created by owner (public, empty); first push initially failed over SSH
(publickey) — this box has no GitHub SSH key; nabu's remote is HTTPS
with gh credential helper (gh auth: arvicco, protocol https). Durable
fix: origin set to https://github.com/arvicco/nabu-edubba.git; future
repos on this box use HTTPS remotes from the start. CI run 30436728929
GREEN on the pushed head (gate job 38s: checkout, Ruby 3.3 +
bundler-cache, full rake gate). Remaining Gate 0: owner enables Pages
(Actions source), accepts README (M0-4), merges main.

2026-07-29 · M0-1, M0-2 done · phase-0 · Owner ran the one-time
`bundle install` (vendor/bundle, jekyll 4.4.1, html-proofer 5.2.2);
full `rake gate` GREEN end-to-end (lint clean, 6/6 tests, build 0.012s,
htmlproofer 2 internal links OK). Outcome check on the built surface:
_build/site/index.html rendered through the layout (wordmark/h1/footer
present), CNAME=edubba.ac in the published tree, assets copied.
Gemfile.lock committed for local/CI parity. M0-3 remains in-progress
(CI green verifiable only once the GitHub repo exists); M0-4 awaits
owner acceptance at Gate 0.

2026-07-29 · M0-1..M0-4 (bootstrap sweep) · phase-0 · Repo initialized
(main unborn; work on phase-0). Scaffolding committed from dev-loop
templates with concept ratified same day. Gate tooling: Gemfile
(jekyll 4.4 / html-proofer 5 / minitest / rake, repo-local
vendor/bundle), Rakefile (lint/test/build/check/serve/gate),
script/lint.rb (no-JS, front-matter, relative-links, UTF-8 rules) +
test/lint_test.rb (6 tests). Evidence: `rake lint` clean on HEAD and
red on a seeded `<script>` tag (exit 1); `rake test` 6/6 green on
system Ruby 4.0.6. Site stub (config, null-theme layout, stylesheet
skeleton with light/dark, construction-sign index, CNAME edubba.ac);
CI (`rake gate` on push, Ruby 3.3 pin) + Pages deploy building with
our own bundle for local/CI parity (deliberate divergence from nabu's
actions/jekyll-build-pages — Jekyll version parity beats convention).
README v1 + LICENSE (CC BY-SA 4.0, source-texts carve-out). Catches:
`bundle install` correctly denied by our own fresh permission profile
(owner action — pending); zsh `status` is read-only, which aborted a
cleanup one-liner and left the seeded violation in the tree until
removed by hand — don't use `status` as a shell variable.
