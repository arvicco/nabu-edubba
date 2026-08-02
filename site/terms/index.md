---
layout: school
title: "Terms — a working glossary"
short_title: "Terms"
course: cuneiform-addenda
chapter: 2
terms_page: true
description: >-
  Every technical term Edubba's courses use, defined in one plain
  sentence — the same definitions that pop up when you hover a term
  anywhere on the site.
---

# Terms — a working glossary

Every technical term the courses use, in one plain sentence each.
These are the same definitions that appear in a small bubble when
you hover a dotted-underlined term anywhere on the site; this page
is the place to look one up deliberately. Terms are listed
alphabetically.

<dl class="terms-list">
{% assign sorted = site.data.terms.terms | sort: "name" %}
{% for t in sorted %}
  <dt id="term-{{ t.slug }}">{{ t.name }}</dt>
  <dd>{{ t.def }}</dd>
{% endfor %}
</dl>

Missing a term that puzzled you? That is worth an issue:
[GitHub Issues](https://github.com/arvicco/nabu-edubba/issues).
