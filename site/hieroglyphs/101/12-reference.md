---
title: "12 · Reference"
short_title: "12 · Reference"
description: >-
  Every sign taught in Hieroglyphs 101, the conventions the course
  reads by, and where to go next.
layout: chapter
course: hieroglyphs-101
chapter: 12
permalink: /hieroglyphs/101/12-reference/
course_url: /hieroglyphs/101/
course_title: "Hieroglyphs 101"
teaches: []
shows: []
---

# Reference

Egyptian scribes kept sign lists too — onomastica, they are
called, catalogues of words and signs a working scribe was
expected to command. This page is this course's own: every sign
taught across twelve chapters, generated from the course's sign
registry so it can never drift out of date with the lessons.

## Every sign taught in 101

<table class="sign-table sign-table--tail-fit">
  <thead>
    <tr><th>Sign</th><th>Name</th><th>Key</th><th>Reads</th><th>Means</th><th>Corpus rank</th><th>Origin</th><th>Taught in</th></tr>
  </thead>
  <tbody>
  {% assign taught = site.data.hiero_teaching.signs | where_exp: "s", "s.taught_in" %}
  {% for s in taught %}
    <tr>
      <td class="script sign-cell">{{ s.glyph }}</td>
      <td>{{ s.gardiner }}</td>
      <td>{{ s.keyword }}</td>
      <td>{% if s.value == "" %}—{% else %}<em>{{ s.value }}</em>{% endif %}</td>
      <td>{{ s.meaning }}</td>
      <td>{{ s.freq_aes | default: "—" }}</td>
      <td>{{ s.certainty }}</td>
      <td>ch. {{ s.taught_in | prepend: "0" | slice: -2, 2 }}</td>
    </tr>
  {% endfor %}
  </tbody>
</table>

{% assign taught_count = site.data.hiero_teaching.signs | where_exp: "s", "s.taught_in" | size %}
{{ taught_count }} signs — counted live from the registry. The
corpus rank is the sign's occurrence rank across the annotated
hieroglyphic inventories of a corpus of over 800,000 Egyptian
words; smaller is commoner. Where the origin column says
*unclear*, the course taught you the shape and its use, not a
story. The set reads: all the one-consonant signs, the workhorse
two- and three-consonant signs, the classifier system's core, the
royal-name apparatus, and both signs the decipherers needed for
foreign names — enough to read names, titles, family lines,
offering formulae, and the two most famous cartouches in the
world.

## Conventions used in this course

- **Transliteration** is the Egyptological (Leiden) convention:
  *ꜣ ꜥ ḥ ḫ ẖ š ṯ ḏ*, printed in italics. The corpora's ASCII
  (MdC) spellings — <span class="translit atf">anx</span> for
  *ꜥnḫ* — appear only when quoting raw corpus data.
- **Vowels are not written.** Renderings like "Amun" or "hotep"
  are conventional pronunciations, not readings; chapter 03
  carries the full warning.
- **Sign order and layout.** This course prints signs in a single
  left-to-right line. Real inscriptions stack signs into balanced
  blocks and run in either direction (or in columns); chapter 11's
  compass rule — read into the faces — finds the true order on
  any wall. Stacking is shown in figures where it matters, never
  silently.
- **▢** stands for a sign not yet taught — a placeholder in the
  course, never a gap in the original.
- **Classifiers** (determinatives) are unpronounced and close
  their word; suffix pronouns are joined with *≡*; editors'
  brackets in transliteration mark restored text.
- **Citations**: every ancient text on this site carries its Nabu
  URN, its source collection, and its license class. Follow the
  URN and you reach the monument.

## Further study

- **James P. Allen, *Middle Egyptian*** (Cambridge) — the standard
  teaching grammar; this course cites it throughout.
- **Alan Gardiner, *Egyptian Grammar*** — the classic reference,
  home of the sign list whose codes (G17, N35 …) this course uses.
- **The open corpus this course reads from:** the Berlin-
  Brandenburg Academy's Egyptian text corpora (the digital
  heirs of the <em>Wörterbuch</em> project), reachable with
  per-passage licenses through the
  <a href="https://arvicco.github.io/nabu/">Nabu</a> library.
- **Next in this school:**
  [102 · Middle Egyptian]({{ '/hieroglyphs/102/' | relative_url }})
  is open — connected prose, verbs in their tenses, the tales
  themselves. Your fifty-three signs are its assumed inventory.

## Sources and licenses

Original prose on this page and throughout the course is
CC BY-SA 4.0. The ancient texts quoted in chapters 05–11 come from
the Berlin-Brandenburg Academy corpora and the Leipzig literary
corpus via Nabu (license class: attribution), cited in place with
URNs; the Rosetta and Philae cartouches are museum exhibits cited
to their objects.
