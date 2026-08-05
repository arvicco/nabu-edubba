---
title: "Signs — one page for every sign"
short_title: "Signs"
description: >-
  Every sign the cuneiform courses teach, one page each: its keyword,
  where the shape comes from, a way to remember it, its lookalikes,
  and one real line it lives in.
layout: chapter
course: cuneiform-addenda
chapter: 3
permalink: /cuneiform/addenda/signs/
course_url: /cuneiform/addenda/
course_title: "Cuneiform Addenda"
kicker_no_chapter: true
teaches: []
shows: []
---

# Signs — one page for every sign

Every sign the courses teach has one page here: its permanent home
for in-depth study. Each page carries the sign's **keyword** — one
handle-word, unique across the school, the word the drills will
always use for it — then two stories, kept honestly apart: *where
it comes from*, the origin the scholarship actually supports, and
*how to remember it*, a memory hook we invented and say so. Below
those: the sign's lookalikes, and one real corpus line it lives in.

One thing before the table: a memory image you build yourself
sticks better than any image handed to you.[^gen] Use our hooks as
scaffolding — the moment your own picture forms, throw ours away.
The origin stories follow the standard accounts,[^origins] and each
says plainly how sure the scholarship is.

<table class="sign-table sign-table--tail-fit">
  <thead>
    <tr><th>Sign</th><th>Name</th><th>Key</th><th>Means</th><th>Taught in</th></tr>
  </thead>
  <tbody>
  {% assign c101 = site.data.sign_teaching.signs | sort: "taught_in" %}
  {% assign c102 = site.data.cuneiform102_queue.signs | where_exp: "s", "s.chapter" | sort: "chapter" %}
  {% for s in c101 %}
    {% assign slug = s.name | downcase | replace: "š", "sz" | replace: "é", "e2" | replace: "×", "x" %}
    {% capture target %}/cuneiform/addenda/signs/{{ slug }}/{% endcapture %}
    {% assign spage = site.pages | where: "url", target | first %}
    <tr>
      <td class="script sign-cell">{% if spage %}<a href="{{ target | relative_url }}">{{ s.glyph }}</a>{% else %}{{ s.glyph }}{% endif %}</td>
      <td>{% if spage %}<a href="{{ target | relative_url }}">{{ s.name }}</a>{% else %}{{ s.name }}{% endif %}</td>
      <td>{{ s.keyword }}</td>
      <td>{{ s.meaning }}</td>
      {% assign ch = site.pages | where: "course", "cuneiform-101" | where: "chapter", s.taught_in | first %}
      <td>{% if ch %}<a href="{{ ch.url | relative_url }}">101 · ch. {{ s.taught_in | prepend: "0" | slice: -2, 2 }}</a>{% else %}101 · ch. {{ s.taught_in | prepend: "0" | slice: -2, 2 }}{% endif %}</td>
    </tr>
  {% endfor %}
  {% for s in c102 %}
    {% assign slug = s.name | downcase | replace: "š", "sz" | replace: "é", "e2" | replace: "×", "x" %}
    {% capture target %}/cuneiform/addenda/signs/{{ slug }}/{% endcapture %}
    {% assign spage = site.pages | where: "url", target | first %}
    <tr>
      <td class="script sign-cell">{% if spage %}<a href="{{ target | relative_url }}">{{ s.glyph }}</a>{% else %}{{ s.glyph }}{% endif %}</td>
      <td>{% if spage %}<a href="{{ target | relative_url }}">{{ s.name }}</a>{% else %}{{ s.name }}{% endif %}</td>
      <td>{{ s.keyword }}</td>
      <td>{{ s.meaning }}</td>
      {% assign ch = site.pages | where: "course", "cuneiform-102" | where: "chapter", s.chapter | first %}
      <td>{% if ch %}<a href="{{ ch.url | relative_url }}">102 · ch. {{ s.chapter | prepend: "0" | slice: -2, 2 }}</a>{% else %}102 · ch. {{ s.chapter | prepend: "0" | slice: -2, 2 }}{% endif %}</td>
    </tr>
  {% endfor %}
  </tbody>
</table>

[^gen]: The generation effect: self-produced material is retained
    better than supplied material — Slamecka & Graf, "The
    generation effect: delineation of a phenomenon," *Journal of
    Experimental Psychology: Human Learning and Memory* 4 (1978).

[^origins]: Sign origins per the standard references: Labat,
    *Manuel d'épigraphie akkadienne*; Borger, *Mesopotamisches
    Zeichenlexikon*; the accessible synthesis in Finkel & Taylor,
    *Cuneiform* (British Museum Press, 2015). Where these hedge,
    our pages hedge.
