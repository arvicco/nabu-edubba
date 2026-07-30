# Worklog

One dense paragraph per completed packet, newest first:
date · packet · commit · notes (what changed, why, evidence, catches).
Incidents get their own entries: what happened, root cause, the
durable fix, the lesson now enforced.

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
