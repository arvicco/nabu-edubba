---
layout: school
title: "Egyptian terms — the hieroglyphs glossary"
short_title: "Terms"
course: hieroglyphs-addenda
chapter: 1
terms_page: true
terms_school: hieroglyphs
permalink: /hieroglyphs/addenda/terms/
description: >-
  Every hieroglyph-specific technical term Edubba's Egyptian courses
  use, defined in one plain sentence — the same definitions that pop
  up when you hover a term anywhere on the site.
---

# Egyptian terms — the hieroglyphs glossary

Every technical term specific to the Egyptian courses, in one plain
sentence each. These are the same definitions that appear in a
small bubble when you hover a dotted-underlined term anywhere on
the site; this page is the place to look one up deliberately.
Terms are listed alphabetically.

Terms shared across all of Edubba's scripts — determinative,
logogram, rebus, and their kin — live in the
[general glossary]({{ '/terms/' | relative_url }}).

<dl class="terms-list">
{% assign sorted = site.data.terms.terms | where: "school", "hieroglyphs" | sort: "name" %}
{% for t in sorted %}
  <dt id="term-{{ t.slug }}">{{ t.name }}</dt>
  <dd>{{ t.def }}</dd>
{% endfor %}
</dl>

Missing a term that puzzled you? That is worth an issue:
[GitHub Issues](https://github.com/arvicco/nabu-edubba/issues).
