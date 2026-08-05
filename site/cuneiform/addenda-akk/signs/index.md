---
title: "Signs — one page for every sign in Akkadian"
short_title: "Signs"
description: >-
  The Akkadian Sign Codex: every sign the Akkadian course uses,
  with its keyword, its syllable-values, and its own page.
layout: chapter
school: cuneiform
course: cuneiform-addenda-akk
chapter: 1
permalink: /cuneiform/addenda-akk/signs/
course_url: /cuneiform/addenda-akk/
course_title: "Akkadian Addenda"
kicker_no_chapter: true
teaches: []
shows: []
---

# Signs — one page for every sign in Akkadian

Every sign Cuneiform 103 uses has one page here: its Akkadian
home. New signs get their full story — where the shape comes
from, per the scholarship, and a memory hook we invented and say
so. **Veterans** — signs taught back in the Sumerian courses that
gained an Akkadian value — get a page for their new life, with a
pointer back to their
[Sumerian page]({{ '/cuneiform/addenda/signs/' | relative_url }});
the keyword never changes on the way over. Frequencies here are
Akkadian frequencies, counted over the Old Babylonian corpus —
a separate base, never mixed with the Sumerian ranks.

<table class="sign-table sign-table--tail-fit">
  <thead>
    <tr><th>Sign</th><th>Name</th><th>Key</th><th>Taught in</th></tr>
  </thead>
  <tbody>
  {% assign akk = site.data.cuneiform103_queue.signs | sort: "chapter" %}
  {% for s in akk %}
    {% assign slug = s.name | downcase | replace: "š", "sz" | replace: "é", "e2" | replace: "×", "x" %}
    {% capture target %}/cuneiform/addenda-akk/signs/{{ slug }}/{% endcapture %}
    {% assign spage = site.pages | where: "url", target | first %}
    <tr>
      <td class="script sign-cell">{% if spage %}<a href="{{ target | relative_url }}">{{ s.glyph }}</a>{% else %}{{ s.glyph }}{% endif %}</td>
      <td>{% if spage %}<a href="{{ target | relative_url }}">{{ s.name }}</a>{% else %}{{ s.name }}{% endif %}{% if s.veteran %} <em>(vet)</em>{% endif %}</td>
      <td>{{ s.keyword }}</td>
      {% assign ch = site.pages | where: "course", "cuneiform-103" | where: "chapter", s.chapter | first %}
      <td>{% if ch %}<a href="{{ ch.url | relative_url }}">103 · ch. {{ s.chapter | prepend: "0" | slice: -2, 2 }}</a>{% else %}103 · ch. {{ s.chapter | prepend: "0" | slice: -2, 2 }}{% endif %}</td>
    </tr>
  {% endfor %}
  </tbody>
</table>

Each sign's page gives its Akkadian values in display form
(ṣi, ṭu₂, šum) and the story behind them.
