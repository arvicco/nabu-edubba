---
title: "19 · Reference"
short_title: "19 · Reference"
description: >-
  The course's shelf: every sign taught in 103 with its codex
  link, the grammar met — noun, verb, melody, particles — the
  display conventions, and where the road goes from here.
layout: chapter
course: cuneiform-103
chapter: 19
permalink: /cuneiform/103/19-reference/
course_url: /cuneiform/103/
course_title: "Cuneiform 103"
teaches: []
shows: []
---

# Reference

Everything the course taught, on one shelf — the mold of
<a href="{{ '/cuneiform/101/12-reference/' | relative_url }}">101's</a>
and
<a href="{{ '/cuneiform/102/18-reference/' | relative_url }}">102's</a>
closing pages. Nothing here is new; everything here is yours.

## Every sign taught in 103

The course's own sign list, generated from its registry —
each glyph links to its codex page; veterans carry the voice
they gained at the border:

<table class="sign-table sign-table--tail-fit">
  <thead>
    <tr><th>Sign</th><th>Name</th><th>Key</th><th>Reads</th><th>Means</th><th>Freq. rank (OB)</th><th>Taught in</th></tr>
  </thead>
  <tbody>
  {% assign taught = site.data.cuneiform103_queue.signs | where_exp: "s", "s.chapter" %}
  {% for s in taught %}
    <tr>
      <td class="script sign-cell">{{ s.glyph }}</td>
      <td>{{ s | sign_name }}</td>
      <td>{{ s.keyword }}</td>
      <td><em>{{ s | sign_reads }}</em></td>
      <td>{{ s.meaning }}</td>
      <td>{{ s.freq_akkob | default: "—" }}</td>
      {% assign ch = site.pages | where: "course", "cuneiform-103" | where: "chapter", s.chapter | first %}
      <td>{% if ch %}<a href="{{ ch.url | relative_url }}">ch. {{ s.chapter | prepend: "0" | slice: -2, 2 }}</a>{% else %}ch. {{ s.chapter | prepend: "0" | slice: -2, 2 }}{% endif %}</td>
    </tr>
  {% endfor %}
  </tbody>
</table>

With these signs and their veterans, the course's reading kit
covers **79.4%** of everything written in the Old Babylonian
corpus this school measures against — four of every five
signs on a random tablet of Hammurapi's century are now yours
on sight.

## The grammar, shelved

Everything below was met in a real line first; every cell
links back to its teaching. The dashes are honest — forms this
course never met.

**The noun** wears its case at the end
(<a href="{{ '/cuneiform/103/02-the-noun-wears-its-case/' | relative_url }}">ch. 02</a>,
<a href="{{ '/cuneiform/103/08-more-than-one/' | relative_url }}">ch. 08</a>):

<table class="sign-table sign-table--tail-fit">
  <thead>
    <tr><th>Role</th><th>Singular</th><th>Masc. plural</th><th>Fem. plural</th></tr>
  </thead>
  <tbody>
    <tr><td>subject</td><td><span class="norm">-um</span> · šarrum</td><td><span class="norm">-ū</span> · šarrū</td><td><span class="norm">-ātum</span> · šīmātum</td></tr>
    <tr><td>acted on</td><td><span class="norm">-am</span> · awātam</td><td><span class="norm">-ī</span> · šarrī</td><td><span class="norm">-ātim</span> · šīmātim</td></tr>
    <tr><td>of, after a preposition</td><td><span class="norm">-im</span> · awīlim</td><td><span class="norm">-ī</span> · nišī</td><td><span class="norm">-ātim</span> · awâtim</td></tr>
  </tbody>
</table>

A noun missing its mimation is reaching for the noun after it
— the construct
(<a href="{{ '/cuneiform/103/03-lord-of-heaven-and-earth/' | relative_url }}">ch. 03</a>:
<span class="norm">bēl šamê</span>, <span class="norm">šar
mīšarim</span>). The dual survives in paired body parts
(<a href="{{ '/cuneiform/103/16-eye-tooth-bone/' | relative_url }}">ch. 16</a>:
<span class="norm">īnān</span>, "the two eyes"). Suffixes ride
the case: <span class="norm">-šu</span> "his"
(<a href="{{ '/cuneiform/103/01-sound-by-sound/' | relative_url }}">ch. 01</a>),
<span class="norm">-ya</span> "my"
(<a href="{{ '/cuneiform/103/12-say-to-him-a-letter/' | relative_url }}">ch. 12</a>)
— and <span class="norm">-šu</span> melts against a root's last
consonant: <span class="norm">iktašassu</span>,
<span class="norm">bīssu</span>
(<a href="{{ '/cuneiform/103/10-the-river-decides/' | relative_url }}">ch. 10</a>).

**The verb** — three tenses on four stems, every filled cell a
word you read
(<a href="{{ '/cuneiform/103/05-the-verb-arrives/' | relative_url }}">ch. 05</a>,
<a href="{{ '/cuneiform/103/09-the-stems-named/' | relative_url }}">ch. 09</a>,
<a href="{{ '/cuneiform/103/15-it-has-happened/' | relative_url }}">ch. 15</a>):

<table class="sign-table sign-table--tail-fit">
  <thead>
    <tr><th>Stem</th><th>Preterite</th><th>Durative</th><th>Perfect</th></tr>
  </thead>
  <tbody>
    <tr><td><strong>G</strong> — ground</td><td><span class="norm">iprus</span> · iddi</td><td><span class="norm">iparras</span> · inaddin</td><td><span class="norm">iptaras</span> · imtaḫaṣ</td></tr>
    <tr><td><strong>D</strong> — doubled</td><td><span class="norm">uparris</span> · ubbir</td><td>—</td><td><span class="norm">uptarris</span> · uḫtappid</td></tr>
    <tr><td><strong>Š</strong> — causative</td><td><span class="norm">ušapris</span> · šūbilam</td><td>—</td><td>—</td></tr>
    <tr><td><strong>N</strong> — passive</td><td><span class="norm">ipparis</span> · immaḫiṣ</td><td><span class="norm">ipparras</span> · iddâk</td><td>—</td></tr>
  </tbody>
</table>

Around the stem: the hither-marker <span class="norm">-am</span>
(<a href="{{ '/cuneiform/103/09-the-stems-named/' | relative_url }}">ch. 09</a>:
<span class="norm">šūbilam</span>, "send HERE"); the chaining
<span class="norm">-ma</span>, "and then / and so"
(<a href="{{ '/cuneiform/103/05-the-verb-arrives/' | relative_url }}">ch. 05</a>);
the naked imperative
(<a href="{{ '/cuneiform/103/12-say-to-him-a-letter/' | relative_url }}">ch. 12</a>:
<span class="norm">qibīma</span>, "speak!"); the wishing
<span class="norm">li-</span> of blessings and verdicts
(<a href="{{ '/cuneiform/103/12-say-to-him-a-letter/' | relative_url }}">ch. 12</a>,
<a href="{{ '/cuneiform/103/18-the-kings-invitation/' | relative_url }}">ch. 18</a>:
<span class="norm">lillikma</span>, <span class="norm">līmur</span>);
and the quiet <span class="norm">-u</span> a verb takes inside a
ša-clause
(<a href="{{ '/cuneiform/103/17-silver-changes-hands/' | relative_url }}">ch. 17</a>:
<span class="norm">wašbu</span>).

**The melody of a law** — the tense chain every šumma-law walks
(<a href="{{ '/cuneiform/103/15-it-has-happened/' | relative_url }}">ch. 15</a>),
here from law 1:

<table class="sign-table sign-table--tail-fit">
  <thead>
    <tr><th>Beat</th><th>Tense</th><th>Law 1 sings it</th></tr>
  </thead>
  <tbody>
    <tr><td>the deed</td><td>preterite</td><td><span class="norm">ubbir</span> — "he accused"</td></tr>
    <tr><td>the proof that seals it</td><td>perfect</td><td><span class="norm">lā uktīnšu</span> — "he has NOT convicted him"</td></tr>
    <tr><td>the sentence</td><td>durative</td><td><span class="norm">iddâk</span> — "he shall be killed"</td></tr>
  </tbody>
</table>

**The little words**, each with its teaching seat:

<table class="sign-table sign-table--tail-fit">
  <thead>
    <tr><th>Word</th><th>Does</th><th>Met in</th></tr>
  </thead>
  <tbody>
    <tr><td><span class="norm">šumma</span></td><td>"if" — opens every law</td><td><a href="{{ '/cuneiform/103/06-if-a-man/' | relative_url }}">ch. 06</a></td></tr>
    <tr><td><span class="norm">ša</span></td><td>"which, of" — the hinge</td><td><a href="{{ '/cuneiform/103/00-orientation/' | relative_url }}">ch. 00</a></td></tr>
    <tr><td><span class="norm">u</span></td><td>"and"</td><td><a href="{{ '/cuneiform/103/00-orientation/' | relative_url }}">ch. 00</a></td></tr>
    <tr><td><span class="norm">ana</span></td><td>"to, for"</td><td><a href="{{ '/cuneiform/103/10-the-river-decides/' | relative_url }}">ch. 10</a></td></tr>
    <tr><td><span class="norm">ina</span></td><td>"in, with"</td><td><a href="{{ '/cuneiform/103/15-it-has-happened/' | relative_url }}">ch. 15</a></td></tr>
    <tr><td><span class="norm">eli</span></td><td>"upon, over"</td><td><a href="{{ '/cuneiform/103/10-the-river-decides/' | relative_url }}">ch. 10</a></td></tr>
    <tr><td><span class="norm">aššum</span></td><td>"because of"</td><td><a href="{{ '/cuneiform/103/12-say-to-him-a-letter/' | relative_url }}">ch. 12</a></td></tr>
    <tr><td><span class="norm">lā</span></td><td>"not," inside clauses</td><td><a href="{{ '/cuneiform/103/10-the-river-decides/' | relative_url }}">ch. 10</a></td></tr>
    <tr><td><span class="norm">ul</span></td><td>the flat no of statements</td><td><a href="{{ '/cuneiform/103/13-i-am-he/' | relative_url }}">ch. 13</a></td></tr>
    <tr><td><span class="norm">umma</span></td><td>"thus (says)" — opens speech</td><td><a href="{{ '/cuneiform/103/12-say-to-him-a-letter/' | relative_url }}">ch. 12</a></td></tr>
    <tr><td><span class="norm">anāku</span></td><td>"I" — standing alone</td><td><a href="{{ '/cuneiform/103/13-i-am-he/' | relative_url }}">ch. 13</a></td></tr>
  </tbody>
</table>

## Conventions used in this course

The full law lives in the school's rulebook beside 101's and
102's; the essentials:

- The dialect is **Old Babylonian**, the entry dialect of the
  standard grammars and of the Codex Hammurapi.
- Akkadian transliteration is italic, hyphenated, and carries
  **no homophone indexes** (<em>i-nu</em>, not i₃-nu) — the
  script column carries the sign's identity. Sumerian-course
  quotes keep their indexes, as their own convention requires.
- **Bound transcription** — the upright register with vowel
  length marked (<span class="norm">šarrum</span>,
  <span class="norm">awīlum</span>) — is a separate layer: the
  word as spoken, never sign by sign.
- **Green marks what is read whole.** Wherever signs are spoken
  as one word rather than sounded in sequence, the reading
  prints the voice in green capitals over green-marked signs:
  sumerograms (<span class="logo">EṢEMTI</span>), the notary's
  Sumerian formulary (<span class="logo">ŠU BA-AN-TI</span>),
  and rebus-written names (<span class="logo">SUEN</span>).
  Black is sounded out; green is read whole. A reading never
  cites: sign-name spellings (GIR₃.PAD.RA₂) belong to prose and
  sign lists.
- **▢** marks a sign not yet taught; determinatives sit silent
  in braces ({d}, {diš}); raw corpus ASCII appears only in
  exhibits marked as verbatim ATF.
- Every reading's script is resolved through the Oracc Sign
  List via the Nabu library — glyphs are looked up, never
  guessed — and every ancient line carries its URN and license
  class in place.

## Where the road goes

The stele holds 280 more laws, and Babylon kept writing for
fifteen hundred years after it: omens and mathematics, school
letters and lamentations, and the long literary line of
Standard Babylonian — Gilgameš stands in it — whose dialect
differs from yours the way Shakespeare's English differs from
a newspaper's. Those are other courses' promises. What does
not change: the signs, the roots, the melody of the verb — and
the fact that you now stand in the small company of people, in
any century, who can face the stone and need no hired eyes.

## Further study

- **John Huehnergard, *A Grammar of Akkadian*** — the standard
  teaching grammar this course's didactic claims lean on, cited
  where each piece was taught; when you want the full paradigm
  tables, start there.
- **The open corpus this course reads from:** the
  <a href="https://cdli.earth/">CDLI</a>'s Old Babylonian
  slice, reachable with per-passage licenses through the
  <a href="https://arvicco.github.io/nabu/">Nabu</a> library.
- **In this school:** the
  <a href="{{ '/cuneiform/addenda-akk/' | relative_url }}">Akkadian Addenda</a>
  keeps every sign's story and the
  <a href="{{ '/cuneiform/addenda-akk/drills/' | relative_url }}">drills</a>
  keep them sharp; the
  <a href="{{ '/cuneiform/addenda/' | relative_url }}">Sumerian shelf</a>
  does the same for your veterans.

## Sources and licenses

Original prose on this page and throughout the course is
CC BY-SA 4.0. Ancient texts are quoted in place with URNs
throughout, every one of them license: attribution — the
<em>Codex Hammurapi</em> composite text
(<code>urn:nabu:cdli:p464358</code>) that carries the course
from its first law to the king's invitation; the school letter
of <a href="{{ '/cuneiform/103/12-say-to-him-a-letter/' | relative_url }}">chapter 12</a>
(CUSAS 43, 28 — <code>urn:nabu:cdli:p252638</code>) and the
beer-letter conditional (YOS 13, 172 —
<code>urn:nabu:cdli:p296097</code>); and the Sippar loan of
<a href="{{ '/cuneiform/103/17-silver-changes-hands/' | relative_url }}">chapter 17</a>
(PBS 8/2, 195 — <code>urn:nabu:cdli:p257793</code>). Each is
one click away, whole, through its URN — the texts outlive
everyone who copies them.
