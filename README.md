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

## Status — honest, as of 2026-07-30

**Two schools are open.** In the cuneiform school,
[101 · Foundations](https://edubba.ac/cuneiform/101/) is complete —
thirteen chapters from orientation to decipherment, 26 signs,
genuine Ur III royal inscriptions read in the original — and
[102 · Sumerian](https://edubba.ac/cuneiform/102/) has two
stretches live: twelve chapters, 34 more signs in computed order
(60 taught in all — about half the sign-occurrences of the real
corpora), readings from 4,600-year-old Fara-period tablets to
Gilgameš lines, Sumerian proverbs, and a ruler's dedication read
verbatim from its foundation inscription.
The Egyptian school has opened with
[Hieroglyphs 101 · Foundations](https://edubba.ac/hieroglyphs/101/):
seven chapters from the media and origins of the script through all
26 one-consonant signs to real cartouches (Teti, Pepi) and a
complete offering formula, read from real monuments (texts from the
CDLI and BBAW/AES corpora via Nabu, cited by URN and license).
Also live: the map-of-writing landing page, a catalog stub for the
hanzi school, and a layout specimen. Every recurring sign links to
where it was taught, with hover bubbles giving name, readings, and
meaning — no JavaScript anywhere.

Under the hood: a computed curriculum (sign order = corpus frequency
× graphic simplicity, from committed frequency tables over 1.7M+
Nabu passages), a "nothing untaught" validator that fails the build
if a chapter uses a sign not yet taught, a per-script font-coverage
rule that makes tofu unshippable (computed subsets of Noto Sans
Cuneiform and Noto Sans Egyptian Hieroglyphs), and the full gate
(`rake gate`: lint + tests + build + offline link check) with
auto-deploy on merge.

Next: the schools grow in alternating phases — the Sumerian track's
second stretch, and the hieroglyphs course toward biliterals and
the decipherment story.

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
