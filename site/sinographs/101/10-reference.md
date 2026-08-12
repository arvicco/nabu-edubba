---
title: "10 · Reference"
short_title: "10 · Reference"
description: >-
  Every character taught in Sinographs 101 with its keyword,
  voice, and formation class; the conventions used; and where to
  study next.
layout: chapter
school: sinographs
course: sinographs-101
chapter: 10
permalink: /sinographs/101/10-reference/
course_url: /sinographs/101/
course_title: "Sinographs 101"
teaches: []
shows: []
---

# Reference

Chinese lexicography began as lists too — the *Shuowen jiezi*
organized nine thousand characters by their parts eighteen
centuries ago, and dictionaries have kept its habits since. This
page is the course's own small list: every character taught,
generated straight from the course registry, so it can never
drift out of date with the chapters.

## Every character taught in 101

Formation classes are the ones the chapters demonstrated:
*pictograph* (a picture worn to strokes), *indicative* (a mark
pointing at the meaning), *compound ideograph* (meanings stacked),
*phono-semantic* (a meaning half beside a sound half), and *loan*
(a graph borrowed for its sound alone). Origins graded *classic*
carry the standard account; where the account is debated, the
chapter taught you the shape, not a story.

<table class="sign-table sign-table--tail-fit">
  <thead>
    <tr><th>Sign</th><th>Key</th><th>Says</th><th>Means</th><th>Made by</th><th>Taught in</th></tr>
  </thead>
  <tbody>
  {% assign taught = site.data.sinographs101_queue.signs %}
  {% for s in taught %}
    <tr id="sign-{{ s.codepoint }}">
      <td class="script sign-cell">{{ s.char }}</td>
      <td>{{ s.keyword }}</td>
      <td><span class="translit pinyin">{{ s.pinyin }}</span></td>
      <td>{{ s.meaning }}</td>
      <td>{{ s.category }}</td>
      {% assign ch = site.pages | where: "course", "sinographs-101" | where: "chapter", s.chapter | first %}
      <td>{% if ch %}<a href="{{ ch.url | relative_url }}">ch. {{ s.chapter | prepend: "0" | slice: -2, 2 }}</a>{% else %}ch. {{ s.chapter | prepend: "0" | slice: -2, 2 }}{% endif %}</td>
    </tr>
  {% endfor %}
  </tbody>
</table>

{% assign taught_count = site.data.sinographs101_queue.signs | size %}
{{ taught_count }} characters — counted live from the registry —
and, because the course picked them by frequency, they cover one
of every five characters on a classical page. More important than
the count: every FORMATION CLASS the script uses has passed
through your hands. A new character can now only ever be a new
combination of moves you know.

## Conventions used in this course

- **Voice:** modern Mandarin pinyin with tone diacritics (nǐ hǎo
  style), never tone numbers — those appear only when the ASCII
  convention itself is being shown. Every taught syllable is
  voiced; click any pinyin with a dotted underline to hear it.
- **Forms:** traditional characters, as the classical corpus
  writes them; simplified forms appear only as asides, never as
  the teaching base.
- **▢** in a reading stands for a character not yet taught — a
  placeholder for your growing inventory, never a gap in the
  original text.
- **Citations:** every ancient line on this site carries its Nabu
  URN (e.g. <code>urn:nabu:kanripo:KR1h0004:001:1a</code>), its
  source collection, and its license class. Follow the URN and
  you reach the witness.

## Further study

- **Qiu Xigui, *Chinese Writing*** (trans. Mattos &amp; Norman,
  2000) — the standard account of how the character system is
  built; this course cites it for every formation-class claim.
- **Paul W. Kroll, *A Student's Dictionary of Classical and
  Medieval Chinese*** — the dictionary to grow into as the
  reading begins.
- **The corpus this course reads from:** the
  <a href="https://www.kanripo.org/">Kanseki Repository</a>
  (Kanripo), reachable with per-passage licenses through the
  <a href="https://arvicco.github.io/nabu/">Nabu</a> library.
- **Next in this school:** [102 · Literary Chinese]({{ '/sinographs/102/' | relative_url }})
  — the grammar of the classical language, taught on the same
  real texts these chapters sampled.

## Sources and licenses

Original prose on this page and throughout the course is
CC BY-SA 4.0. The classical lines quoted in the chapters come
from the Kanseki Repository (license class: attribution) and are
cited in place with URNs. Character frequencies were counted over
Nabu's Kanripo mirror — 722 million character tokens — by this
site's own instrument, and the count is committed with the
course.
