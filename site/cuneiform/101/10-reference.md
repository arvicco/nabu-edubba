---
title: "10 · Reference"
short_title: "10 · Reference"
description: >-
  Every sign taught in Cuneiform 101 with both selection criteria on
  display, the transliteration conventions used, and where to study
  next.
layout: chapter
course: cuneiform-101
chapter: 10
permalink: /cuneiform/101/10-reference/
course_url: /cuneiform/101/
course_title: "Cuneiform 101"
teaches: []
shows: []
---

# Reference

The scribes of the é-dub-ba-a opened their training with sign lists
and never stopped consulting them; chapter 07 called the lexical
lists the first dictionaries. This page is this course's own small
entry in that four-thousand-year-old genre — and unlike a clay list,
it is generated directly from the course's sign registry, so it can
never drift out of date with the chapters.

## Every sign taught in 101

Both selection criteria are on display for every sign, per this
school's founding rule: corpus frequency (rank of the sign's cited
value in the ETCSL literary and CDLI documentary corpora, computed by
this site's own instrument over the Nabu library) and graphic
simplicity (wedge count from the reference font; iconicity graded
*classic* / *stated* / *unclear* per the standard sign lists — Labat,
Borger's MZL, and the account in Finkel &amp; Taylor's *Cuneiform*).
Where the origin is graded *unclear*, the course taught you the
shape, not a story.

<table class="sign-table">
  <thead>
    <tr><th>Sign</th><th>Name</th><th>Reads</th><th>Means</th><th>Wedges</th><th>Freq. rank (lit / doc)</th><th>Origin</th><th>Taught in</th></tr>
  </thead>
  <tbody>
  {% assign taught = site.data.sign_teaching.signs | where_exp: "s", "s.taught_in" %}
  {% for s in taught %}
    <tr>
      <td class="script sign-cell">{{ s.glyph }}</td>
      <td>{{ s.name }}</td>
      <td><em>{{ s.value }}</em></td>
      <td>{{ s.meaning }}</td>
      <td>{{ s.wedges }}</td>
      <td>{{ s.freq_etcsl | default: "—" }} / {{ s.freq_cdli | default: "—" }}</td>
      <td>{{ s.iconicity }} <em>({{ s.certainty }})</em></td>
      <td>ch. {{ s.taught_in | prepend: "0" | slice: -2, 2 }}</td>
    </tr>
  {% endfor %}
  </tbody>
</table>

Twelve signs is a genuine, if small, working inventory: enough to
read the structural skeleton of every Ur III royal titulary, to
compose any number below sixty, and to parse determinatives on
sight. The registry holds further candidates (GAL "big", DUB
"tablet") already measured by both criteria; they open the
[Sumerian track](../), where the frequency-ordered long march
begins.

## Conventions used in this course

All transliteration in Edubba follows the field-standard ATF style
of the CDLI and Oracc corpora:

- **Values** in lowercase, with index numbers distinguishing
  homophonous signs: *e2* is the second sign read *e* (the sign É).
- ***š*** is written *sz* in CDLI's ASCII spelling (*szul-gi* =
  *šulgi*); the ETCSL corpus uses *c* for the same sound in its own
  files. This site prints *š* where typography allows and notes the
  ASCII forms beside real corpus data.
- **Determinatives** in braces, unpronounced: *{d}* (𒀭) before
  divine names, *{ki}* (𒆠) after place names.
- **Hyphens** join the signs spelling one word.
- **[…]** encloses text broken away and restored by editors; **#**
  marks a damaged but legible sign; a **prime** (′) on a line number
  means the surface's top is lost and counting starts at the first
  surviving line.
- **Citations**: every ancient text on this site carries its Nabu
  URN (e.g. <code>urn:nabu:cdli:p101077:seal.1</code>), its source
  collection, and its license class. Follow the URN and you reach
  the tablet.

## Further study

- **Irving Finkel &amp; Jonathan Taylor, *Cuneiform*** (British
  Museum Press, 2015) — the best short introduction to the script as
  a whole; this course cites it throughout.
- **C. B. F. Walker, *Cuneiform*** (Reading the Past series, British
  Museum) — a compact classic on the script and its decipherment.
- **The open corpora this course reads from:** the
  <a href="https://cdli.mpiwg-berlin.mpg.de/">Cuneiform Digital
  Library Initiative</a> (CDLI), <a href="https://oracc.org/">Oracc</a>,
  and the <a href="https://etcsl.orinst.ox.ac.uk/">Electronic Text
  Corpus of Sumerian Literature</a> (ETCSL) — all reachable, with
  per-passage licenses, through the
  <a href="https://arvicco.github.io/nabu/">Nabu</a> library.
- **Next in this school:** the [course catalog](../) — 102 Sumerian
  is the natural continuation.

## Sources and licenses

Original prose on this page and throughout the course is
CC BY-SA 4.0. The ancient texts quoted in chapters 04 and 06 come
from CDLI (license class: attribution) and are cited in place with
URNs. Frequency data was computed from Nabu's ETCSL and CDLI
holdings by <code>bin/sign_seq.rb</code> in this site's own
repository — the counts, commands, and corpus sizes are committed
alongside the site and reproducible.
