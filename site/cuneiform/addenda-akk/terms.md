---
layout: school
title: "Akkadian terms — the language's own glossary"
short_title: "Terms"
course: cuneiform-addenda-akk
chapter: 2
terms_page: true
terms_school: akk
permalink: /cuneiform/addenda-akk/terms/
description: >-
  Every Akkadian-specific technical term Edubba's Akkadian courses
  use, defined in one plain sentence — the same definitions that
  pop up when you hover a term anywhere on the site.
---

# Akkadian terms — the language's own glossary

Every technical term specific to the Akkadian courses, in one
plain sentence each. These are the same definitions that appear in
a small bubble when you hover a dotted-underlined term anywhere on
the site; this page is the place to look one up deliberately.
Terms are listed alphabetically.

Terms shared across all of Edubba's scripts — determinative,
logogram, transliteration, and their kin — live in the
[general glossary]({{ '/terms/' | relative_url }});
Sumerian-side terms stay with the
[Sumerian shelf]({{ '/cuneiform/addenda/' | relative_url }}).

<dl class="terms-list">
{% assign sorted = site.data.terms.terms | where: "school", "akk" | sort: "name" %}
{% for t in sorted %}
  <dt id="term-{{ t.slug }}">{{ t.name }}</dt>
  <dd>{{ t.def }}</dd>
{% endfor %}
</dl>

Missing a term that puzzled you? That is worth an issue:
[GitHub Issues](https://github.com/arvicco/nabu-edubba/issues).
