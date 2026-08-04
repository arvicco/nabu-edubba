---
title: "18 · Reference"
short_title: "18 · Reference"
description: >-
  Every sign taught in Cuneiform 102, the case system on one page,
  the conventions the course reads by — and the track complete.
layout: chapter
course: cuneiform-102
chapter: 18
permalink: /cuneiform/102/18-reference/
course_url: /cuneiform/102/
course_title: "Cuneiform 102"
teaches: []
shows: []
---

# Reference

The lexical lists were <a href="{{ '/cuneiform/101/09-the-tablet-house/' | relative_url }}">chapter 09 of 101</a>; the colophon was
<a href="{{ '/cuneiform/102/16-the-tablet-house-speaks/' | relative_url }}">chapter
16</a> of this course. This page is both at once: the course's own
sign list, generated live from its registry, with the scribe's
closing line implied. The track that began with three signs and a
promise is complete.

## Every sign taught in 102

<table class="sign-table sign-table--tail-fit">
  <thead>
    <tr><th>Sign</th><th>Name</th><th>Key</th><th>Reads</th><th>Means</th><th>Freq. rank (lit / doc)</th><th>Taught in</th></tr>
  </thead>
  <tbody>
  {% assign taught = site.data.cuneiform102_queue.signs | where_exp: "s", "s.chapter" %}
  {% for s in taught %}
    <tr>
      <td class="script sign-cell">{{ s.glyph }}</td>
      <td>{{ s.name }}</td>
      <td>{{ s.keyword }}</td>
      <td><em>{{ s.value }}</em></td>
      <td>{{ s.meaning }}</td>
      <td>{{ s.freq_etcsl | default: "—" }} / {{ s.freq_cdli | default: "—" }}</td>
      <td>ch. {{ s.chapter | prepend: "0" | slice: -2, 2 }}</td>
    </tr>
  {% endfor %}
  </tbody>
</table>

{% assign taught_count = site.data.cuneiform102_queue.signs | where_exp: "s", "s.chapter" | size %}
{{ taught_count }} signs taught in this course — counted live from
the registry — on top of
[101]({{ '/cuneiform/101/' | relative_url }})'s twenty-six:
seventy-seven in all. Set against the corpora, your inventory now
covers a little over half of all sign-value occurrences in both
Sumerian literature and the administrative record (a floor, as
<a href="{{ '/cuneiform/102/00-orientation/' | relative_url }}">chapter 00's</a> chart explains — polyvalent signs cover more than we
count). Values in the Reads column are each sign's primary
teaching value; veterans picked up further readings along the way
(*lil₂*, *i₃*, *ke₄*, *išib*, *tum₂*, *de₃*, *be₂*)
exactly where readings demanded them.

## The grammar, shelved

- **The sentence**: participants first, verb last (<a href="{{ '/cuneiform/102/01-the-sentence-in-the-clay/' | relative_url }}">ch. 01</a>).
- **The cases**, all seven with taught examples: the table in
  [chapter 13]({{ '/cuneiform/102/13-you-are/' | relative_url }}).
- **The genitive's** hidden /k/ and when it surfaces (chs. <a href="{{ '/cuneiform/102/02-the-case-that-hides/' | relative_url }}">02</a>, <a href="{{ '/cuneiform/102/07-i-am-king/' | relative_url }}">07</a>,
  11).
- **The verbal chain**: negation and wishes outermost (*nu-*,
  *ga-*, *ha-*, *na-*), finite openers next (*i₃-*, *in-*, *ba-*,
  *mu-* and its fused *ma-*), the dative *-na-* inside, stem, and
  trailing suffixes mostly glimpsed (chs. <a href="{{ '/cuneiform/102/04-the-verbal-chain/' | relative_url }}">04</a>, <a href="{{ '/cuneiform/102/08-the-chain-grows-rings/' | relative_url }}">08</a>, <a href="{{ '/cuneiform/102/09-the-proverb-tablet/' | relative_url }}">09</a>, <a href="{{ '/cuneiform/102/12-the-chain-completed/' | relative_url }}">12</a>, <a href="{{ '/cuneiform/102/14-a-row-of-proverbs/' | relative_url }}">14</a>).
- **The nominalizing -a**, folding a clause into a description —
  "who ate," "built by an honest man" (chs. <a href="{{ '/cuneiform/102/08-the-chain-grows-rings/' | relative_url }}">08</a>, <a href="{{ '/cuneiform/102/14-a-row-of-proverbs/' | relative_url }}">14</a>); its
  noun-riding twin, the locative *-a*, sits in the case table.
- **The copula** *-me-en* for "I am" and "you are," with *za-e*
  settling person (chs. <a href="{{ '/cuneiform/102/07-i-am-king/' | relative_url }}">07</a>, <a href="{{ '/cuneiform/102/13-you-are/' | relative_url }}">13</a>); third-person *-am₃* previewed
  only.
- **Doubling** for plurals, intensity, and refrains (chs. <a href="{{ '/cuneiform/102/03-say-it-twice/' | relative_url }}">03</a>, <a href="{{ '/cuneiform/102/09-the-proverb-tablet/' | relative_url }}">09</a>,
  10, 17).
- **nam-** and **niŋ₂-** building abstractions and things (chs.
  03, 09); *nam tar*, fate as a thing cut (<a href="{{ '/cuneiform/102/17-the-day-destinies-were-decreed/' | relative_url }}">ch. 17</a>).

What this course left explicitly unopened: the chain's dimensional
suffix machinery, the *-eda* purpose-wrapper's internal parts, the
emesal register, and everything Akkadian. Those are another
course's promises, not broken ones.

## Conventions used in this course

The full law lives in the school's rulebook alongside 101's
Reference conventions; the essentials:

- Transliteration in ATF style with Unicode subscript indexes
  (*e₂*, *gu₇*); the velar nasal printed *ŋ*; corpus ASCII
  (*sza3*, *ce3*) only in verbatim quotes, marked as such.
- Every reading's script is resolved through the Oracc Sign List
  via the Nabu library — glyphs are looked up, never guessed.
- **▢** marks a sign not yet taught; determinatives sit in braces
  ({d}, {ki}), silent; hyphens join the signs of one word.
- Every ancient line carries its URN and license class in place:
  CDLI quotes are license attribution with artifact links; ETCSL
  quotes are short and labeled non-commercial.

## Further study

- **Daniel Foxvog, *Introduction to Sumerian Grammar*** (open
  access) — the reference this course's grammar bites lean on,
  cited in chapters <a href="{{ '/cuneiform/102/00-orientation/' | relative_url }}">00</a> and <a href="{{ '/cuneiform/102/01-the-sentence-in-the-clay/' | relative_url }}">01</a>; when you want the full chain, start
  there.
- **The open corpora this course reads from:** the
  <a href="https://cdli.earth/">CDLI</a> and the
  <a href="https://etcsl.orinst.ox.ac.uk/">ETCSL</a>, reachable
  with per-passage licenses through the
  <a href="https://arvicco.github.io/nabu/">Nabu</a> library.
- **Next in this school:** Cuneiform 103 · Akkadian — the script's
  second life in a Semitic tongue — opens in a later phase. The
  [school catalog]({{ '/cuneiform/' | relative_url }}) holds the
  map.

## Sources and licenses

Original prose on this page and throughout the course is
CC BY-SA 4.0. Ancient texts are quoted in place with URNs
throughout: CDLI material under license class attribution, ETCSL
material as short quotes under its non-commercial terms (the
site's LICENSE carries the source-texts carve-out). The votive
inscriptions of chapters
<a href="{{ '/cuneiform/102/11-a-dedication-for-real/' | relative_url }}">11</a>–<a href="{{ '/cuneiform/102/12-the-chain-completed/' | relative_url }}">12</a>
and every name list and receipt behind chapters
<a href="{{ '/cuneiform/102/06-names-that-are-sentences/' | relative_url }}">06</a>–<a href="{{ '/cuneiform/102/17-the-day-destinies-were-decreed/' | relative_url }}">17</a>
remain one click away, whole, through their
URNs — which was the promise of the tablet house all along: the
texts outlive everyone who copies them.
