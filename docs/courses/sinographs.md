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
- **The Pinyin primer and its audio (owner request 2026-08-10):**
  the Addenda shelf carries a pinyin page (tones with contours,
  initials/finals with IPA where English blurs). Sound samples are
  browser-native `<audio>` elements — no JS — with files VENDORED
  as mp3, transcoded from license-verified recordings (CC BY /
  CC BY-SA only, never NC), pitch-contour-verified for the tone
  set at vendoring time; per-file credits live in
  site/assets/audio/pinyin/CREDITS.txt, linked from the page.
  Audio filenames carry no tone digits (the display law's shape
  holds in URLs).
- **The syllable pipeline (owner ruling 2026-08-11):** in chapter
  sign tables the READING IS THE BUTTON — the pinyin is an
  `a.say` link that plays its syllable inline (D17-a's sanctioned
  script; with JS off the link opens the file). No visible player
  chrome; the dotted underline is the affordance. Longer clips
  (the primer's four-tones bar) may keep a full native player. Acquisition is an instrument, bin/pinyin_audio.rb,
  driven by the hand-curated manifest
  assets-src/data/pinyin-audio-sources.yml: Commons recordings
  only, license-gated at the API (CC BY / CC BY-SA, never NC),
  word recordings silence-segmented to the named syllable, and
  EVERY file pitch-verified against the tone its pinyin declares
  before it may ship — a recording that does not sing its tone
  does not ship. Every clip is loudness-normalized at encode
  (−20 dB mean, −1 dB peak ceiling; owner report 2026-08-11 —
  sources span voices at very different levels). Same-sound
  characters share one file: the manifest's `voices:` map joins
  each queue keyword-slug to its audio slug (person → ren,
  humane → ren). Characters with no clean recording are recorded in
  `absent:` and reported on every run, never faked (TTS output is
  barred by the same license test — Apple's voices are
  personal-use only, and open engines misteach tone). Credits
  regenerate into CREDITS-syllables.txt. The say-audio lint
  (owner request 2026-08-11, after pǐn shipped silent) enforces
  the law's surface: a sign-table reading that is not a say-link
  fails the gate, and every say-link must point at a file that
  exists in the tree.

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
- **Example-composition law (owner rulings 2026-08-10):** a
  reading line shows at most half boxes — untaught characters
  never outnumber taught ones in a displayed line (▢-share ≤ 50%),
  and the ceiling tightens five points with each five-chapter
  stretch (cap = max(25%, 50 − 5·⌊chapter/5⌋)). Beyond the
  arithmetic, every example ties its featured character to OTHER
  taught characters — the more the better, balanced against the
  fame and interest of the phrase: a famous line trimmed to its
  readable clause beats an obscure line quoted whole, and the
  gloss carries what the trim leaves out. The box-share lint
  enforces the ceiling.
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

### S101 stretch 2 (ruled 2026-08-10 at the phase-16 opening, before content)

Chapters 05–09 teach **the borrowed words**: the classical grammar
particles — the highest-frequency characters in the language —
written with borrowed pictures (the jiajie move, completing the
four-move arc), plus the component chains they need. Twenty-six
fresh characters, five batches, box-share cap 45% throughout:

- **ch05 · The busiest words:** 之 不 也 又 有 十 (又 the hand
  seeds 有; 十有五 = the annals' "fifteen"). The stretch opens
  with the course's first ZERO-BOX reading: Analects 1.2's
  未之有也, whole.
- **ch06 · Knowing and walking:** 矢 知 而 行 言 (the arrow seeds
  知, per components-first; 而 the borrowed beard). Analects 1.1's
  人不知而不慍 at one box.
- **ch07 · Doing and being:** 為 無 我 心 生 (the two great
  jiajie stories — the hand leading the elephant, the dancer who
  became "without"). Laozi 63's triple paradox nearly whole;
  1.2's 本立而道生 returns under cap.
- **ch08 · Stopping at true:** 止 正 是 夕 名 (the chain
  止→正→是, and 夕→名; Analects 13.3's rectification of names).
  Finale: 2.17 知之為知之… 是知也 at ZERO boxes.
- **ch09 · The master's opening:** 者 其 亦 于 乎 — enough to
  read both halves of Analects 1.1's famous opening under cap,
  and 6.23 returns at 25%.

Laws in force unchanged: 5–6 fresh per chapter, components before
compounds (parts: on every compound row), box-share ≤ 45% for
ch05–09, keywords unique, slug law (first entrant keeps the bare
slug), every new character's codex page lands IN THE SAME COMMIT
as its chapter (the complete-shelf check is live).

### S101 stretch 3 (ruled 2026-08-11 at the phase-18 opening, before content)

Chapters 10–14 put **the sentence at work**: the instrumental 以
(rank 3, the biggest character still untaught), the reflexive,
the modal pair, place-and-time words, the second number batch,
the seeing pictographs — and 道 itself. Twenty-six fresh
characters, five batches, box-share cap tightens to **40%**
(the declining-cap law's second step):

- **ch10 · The sentence's tools:** 以 自 丁 可 用 (丁 the nail
  seeds 可; 可以 the modal pair; 以 taught honestly as the
  grammaticalized loan). Anchors: 2.11 溫故而知新，可以為師矣;
  1.1's second clause 有朋自遠方來 — the return arc reaches the
  opening again.
- **ch11 · Counting continues:** 四 五 六 白 百 (the second
  number batch in one breath, the ch00 law; 白 seeds 百).
  Anchors: 2.4's decade ladder; 2.2's 詩三百.
- **ch12 · The eye and the Way:** 目 見 相 首 道 (eye seeds
  seeing and mutual regard; the head walks under 辶 — told in
  prose, parts: [首]). Anchor: Laozi 42's 道生一，一生二，二生三，
  三生萬物 at two boxes in twelve.
- **ch13 · Liking and likening:** 女 好 如 云 非 矣 (女 seeds
  both 好 and 如; 云 the loaned cloud; 非 the spread wings;
  矣 the perfective final). Anchors: 6.20's double 不如; 3.3's
  人而不仁，如禮何; 2.24's 非其鬼而祭之.
- **ch14 · Here and now:** 此 所 於 至 今 (此 through 止 with
  the standing figure in prose; 所 pairs with ch09's 者; 於 the
  fuller graph of ch09's 于 — the SAME word, a veteran row
  moment; 至 the arrow landing — 矢 pays off again). Anchor:
  Daxue's 自天子以至於庶人 at one box.

Laws in force unchanged, plus this stretch's own: every reading
verified against its Kanripo witness BEFORE writing (URNs in the
phase plan), and every fresh syllable voiced through the pipeline
in the same commit as its chapter — the say-audio lint holds the
gate to it.

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
- **Slug law (owner ruling 2026-08-11):** a page's slug is the
  character's KEYWORD, lowercased and hyphenated (人 person →
  `person`, 仁 humane → `humane`, 未 not-yet → `not-yet`).
  Keywords are unique by the §3 law, so slugs are collision-free
  by construction — where pinyin slugs drowned in homophones and
  tone ambiguity (rén/rěn, 人/仁), keywords never do. Tone
  numbers, diacritics, and pinyin of any kind never appear in
  slugs. The compiler derives the slug from the keyword and still
  enforces uniqueness; an explicit `slug:` in the pool overrides
  only when a keyword's ASCII form misbehaves.
- Page shape (the akk-codex mold): where it comes from (form
  origin, certainty-labeled), how to remember it (the keyword
  hook — this is where the memory-hook technique is applied), in
  the wild (one real cited attestation).
