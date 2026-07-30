# Edubba

**A free, self-paced school of writing systems — courses in the
world's scripting traditions, ancient and living, from first signs to
reading real texts.**

Site: **[edubba.ac](https://edubba.ac)** (redirects to the GitHub
Pages site).

Edubba (Sumerian *é-dub-ba-a*, "the tablet house", the scribal school
of ancient Mesopotamia) is a static site of **schools**, one per
scripting tradition — cuneiform, Egyptian hieroglyphs, Hanzi/Kanji,
and more. Each school is a catalog of numbered courses with
prerequisites (Cuneiform 101 Foundations, 102 Sumerian, 103
Akkadian, …), and each course is a progressive sequence of chapters
ending in graded readings of *real* documents — tablets, inscriptions,
pages — drawn from the [Nabu](https://arvicco.github.io/nabu/) library
with per-passage citations and licenses. The full design is in
[docs/concept.md](docs/concept.md).

## Status — honest, as of 2026-07-29

**Two courses live in the cuneiform school.**
[101 · Foundations](https://edubba.ac/cuneiform/101/) is complete —
thirteen chapters from orientation to decipherment, 25 signs,
genuine Ur III royal inscriptions read in the original.
[102 · Sumerian](https://edubba.ac/cuneiform/102/) has opened its
first stretch — six chapters, 18 more signs in computed order,
grammar in reading-sized bites, and readings from 4,600-year-old
Fara-period tablets rendered in full cuneiform (all texts CDLI via
Nabu, cited by URN and license). Also live: the map-of-writing
landing page, catalog stubs for the hieroglyphs and hanzi schools,
and a layout specimen.

Under the hood: a computed curriculum (sign order = corpus frequency
× graphic simplicity, from committed frequency tables over 1.5M+
Nabu passages), a "nothing untaught" validator that fails the build
if a chapter uses a sign not yet taught, a font-coverage rule that
makes tofu unshippable (the site serves a computed subset of Noto
Sans Cuneiform), and the full gate (`rake gate`: lint + tests +
build + offline link check) with auto-deploy on merge.

Next (Phase 4): the Egyptian hieroglyphs school opens, while the
Sumerian track continues in alternating phases.

## Building locally

```
bundle install        # once
rake gate             # lint + tests + build + link check
rake serve            # preview at http://127.0.0.1:4000
```

Site sources live in `site/` (Jekyll 4.4, null theme, no JavaScript —
the first wave is deliberately text-pure and must work in any
browser).

## Authorship, corrections, license

Edubba's materials are **drafted by AI (Claude) and reviewed by the
project owner**; didactic content cites its scholarly basis (standard
grammars and sign lists) in-line. Errors are ours and fixable:
**[GitHub Issues](https://github.com/arvicco/nabu-edubba/issues)** is
the feedback and errata channel.

Original prose is licensed **[CC BY-SA 4.0](LICENSE)**. Source texts
and images carry their own licenses, always stated where they appear,
inherited from Nabu's per-passage license records.
