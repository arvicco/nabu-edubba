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

Every character Sinographs 101 teaches has one page here: its
home. Each page tells where the shape comes from — per the
scholarship, uncertainty labeled — gives a memory hook we invented
and say so, and shows the character at work in a real cited line.
Pages appear as the shelf is written; every taught character will
have one.

<table class="sign-table sign-table--tail-fit">
  <thead>
    <tr><th>Sign</th><th>Key</th><th>Says</th><th>Taught in</th></tr>
  </thead>
  <tbody>
  {% assign chars = site.data.sinographs101_queue.signs | sort: "chapter" %}
  {% for s in chars %}
    {% capture target %}/sinographs/addenda/signs/{{ s.name }}/{% endcapture %}
    {% assign cpage = site.pages | where: "url", target | first %}
    {% assign tslug = "/sinographs/101/" %}
    <tr>
      <td class="script sign-cell">{{ s.char }}</td>
      <td>{% if cpage %}<a href="{{ target | relative_url }}">{{ s.keyword }}</a>{% else %}{{ s.keyword }}{% endif %}</td>
      <td><span class="translit pinyin">{{ s.pinyin }}</span></td>
      <td>ch. {{ s.chapter }}</td>
    </tr>
  {% endfor %}
  </tbody>
</table>
