# Edubba

**A free, self-paced school of writing systems — courses in the
world's scripting traditions, ancient and living, from first signs to
reading real texts.**

Site: **[edubba.ac](https://edubba.ac)** (not yet live — see status
below).

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

**Nothing is teachable yet.** The repo currently contains:

- the ratified concept (`docs/concept.md`);
- the development process (`docs/DEV-LOOP.md`, backlog, worklog);
- a working quality gate (`rake gate`: conventions lint incl. the
  no-JavaScript rule, unit tests, Jekyll build, offline link check);
- a placeholder site stub (construction sign) and CI/deploy
  workflows.

Next up (Phase 1): the site skeleton — the "map of writing" landing
page, shared visual identity with vendored fonts, one fully-styled
sample chapter. Then (Phase 2+): the cuneiform school, course by
course.

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
