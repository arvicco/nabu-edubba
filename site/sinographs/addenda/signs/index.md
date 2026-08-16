---
title: "Signs — one page for every character"
short_title: "Signs"
description: >-
  The Character Codex: every character the sinograph courses teach,
  with its keyword, its reading, and its own page.
layout: chapter
school: sinographs
course: sinographs-addenda
chapter: 1
permalink: /sinographs/addenda/signs/
course_url: /sinographs/addenda/
course_title: "Sinograph Addenda"
kicker_no_chapter: true
teaches: []
shows: []
---

# Signs — one page for every character

Every character the sinograph courses teach has one page here:
its home. Each page tells where the shape comes from — per the
scholarship, uncertainty labeled — gives a memory hook we invented
and say so, and shows the character at work in a real cited line.
Foundations' characters come first, then Literary Chinese's, each
in teaching order.

<table class="sign-table sign-table--tail-fit">
  <thead>
    <tr><th>Sign</th><th>Key</th><th>Says</th><th>Taught in</th></tr>
  </thead>
  <tbody>
  {% assign s101 = site.data.sinographs101_queue.signs | sort: "chapter" %}
  {% assign s102 = site.data.sinographs102_queue.signs | sort: "chapter" %}
  {% for s in s101 %}
    {% capture target %}/sinographs/addenda/signs/{{ s.name }}/{% endcapture %}
    {% assign cpage = site.pages | where: "url", target | first %}
    <tr>
      <td class="script sign-cell">{{ s.char }}</td>
      <td>{% if cpage %}<a href="{{ target | relative_url }}">{{ s.keyword }}</a>{% else %}{{ s.keyword }}{% endif %}</td>
      <td><span class="translit pinyin">{{ s.pinyin }}</span></td>
      {% assign ch = site.pages | where: "course", "sinographs-101" | where: "chapter", s.chapter | first %}
      <td>{% if ch %}<a href="{{ ch.url | relative_url }}">101 · ch. {{ s.chapter | prepend: "0" | slice: -2, 2 }}</a>{% else %}101 · ch. {{ s.chapter | prepend: "0" | slice: -2, 2 }}{% endif %}</td>
    </tr>
  {% endfor %}
  {% for s in s102 %}
    {% capture target %}/sinographs/addenda/signs/{{ s.name }}/{% endcapture %}
    {% assign cpage = site.pages | where: "url", target | first %}
    <tr>
      <td class="script sign-cell">{{ s.char }}</td>
      <td>{% if cpage %}<a href="{{ target | relative_url }}">{{ s.keyword }}</a>{% else %}{{ s.keyword }}{% endif %}</td>
      <td><span class="translit pinyin">{{ s.pinyin }}</span></td>
      {% assign ch = site.pages | where: "course", "sinographs-102" | where: "chapter", s.chapter | first %}
      <td>{% if ch %}<a href="{{ ch.url | relative_url }}">102 · ch. {{ s.chapter | prepend: "0" | slice: -2, 2 }}</a>{% else %}102 · ch. {{ s.chapter | prepend: "0" | slice: -2, 2 }}{% endif %}</td>
    </tr>
  {% endfor %}
  </tbody>
</table>
