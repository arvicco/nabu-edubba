---
title: "Signs — one page for every sign"
short_title: "Signs"
description: >-
  Every sign the hieroglyph courses teach, one page each: its
  keyword, the picture Gardiner identified, a way to remember it,
  its lookalikes, and one real line it lives in.
layout: chapter
course: hieroglyphs-addenda
chapter: 2
permalink: /hieroglyphs/addenda/signs/
course_url: /hieroglyphs/addenda/
course_title: "Hieroglyphs Addenda"
kicker_no_chapter: true
teaches: []
shows: []
---

# Signs — one page for every sign

Every sign the courses teach has one page here: its permanent home
for in-depth study. Each page carries the sign's **keyword** — one
handle-word, unique across the school, the word the drills will
always use for it — then two stories, kept honestly apart: *where
it comes from*, the picture the scholarship actually supports,[^gard]
and *how to remember it*, a memory hook we invented and say so.
Below those: the sign's lookalikes, and one real corpus line it
lives in.

One thing before the table: a memory image you build yourself
sticks better than any image handed to you.[^gen] Use our hooks as
scaffolding — the moment your own picture forms, throw ours away.

<table class="sign-table">
  <thead>
    <tr><th>Sign</th><th>Code</th><th>Keyword</th><th>Means</th><th>Taught in</th></tr>
  </thead>
  <tbody>
  {% assign e101 = site.data.hiero_teaching.signs | sort: "taught_in" %}
  {% assign e102 = site.data.hieroglyphs102_queue.signs | where_exp: "s", "s.chapter" | sort: "chapter" %}
  {% for s in e101 %}
    {% assign slug = s.gardiner | downcase %}
    {% capture target %}/hieroglyphs/addenda/signs/{{ slug }}/{% endcapture %}
    {% assign spage = site.pages | where: "url", target | first %}
    <tr>
      <td class="script sign-cell">{% if spage %}<a href="{{ target | relative_url }}">{{ s.glyph }}</a>{% else %}{{ s.glyph }}{% endif %}</td>
      <td>{% if spage %}<a href="{{ target | relative_url }}">{{ s.gardiner }}</a>{% else %}{{ s.gardiner }}{% endif %}</td>
      <td>{{ s.keyword }}</td>
      <td>{{ s.meaning }}</td>
      <td>101 · ch. {{ s.taught_in | prepend: "0" | slice: -2, 2 }}</td>
    </tr>
  {% endfor %}
  {% for s in e102 %}
    {% assign slug = s.gardiner | downcase %}
    {% capture target %}/hieroglyphs/addenda/signs/{{ slug }}/{% endcapture %}
    {% assign spage = site.pages | where: "url", target | first %}
    <tr>
      <td class="script sign-cell">{% if spage %}<a href="{{ target | relative_url }}">{{ s.glyph }}</a>{% else %}{{ s.glyph }}{% endif %}</td>
      <td>{% if spage %}<a href="{{ target | relative_url }}">{{ s.gardiner }}</a>{% else %}{{ s.gardiner }}{% endif %}</td>
      <td>{{ s.keyword }}</td>
      <td>{{ s.meaning }}</td>
      <td>102 · ch. {{ s.chapter | prepend: "0" | slice: -2, 2 }}</td>
    </tr>
  {% endfor %}
  </tbody>
</table>

[^gard]: Sign identifications per Gardiner's Sign List (*Egyptian
    Grammar*, 3rd ed., 1957); where it hedges, our pages hedge.

[^gen]: The generation effect: self-produced material is retained
    better than supplied material — Slamecka & Graf, "The
    generation effect: delineation of a phenomenon," *Journal of
    Experimental Psychology: Human Learning and Memory* 4 (1978).
