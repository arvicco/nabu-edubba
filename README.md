# Edubba

**A free, self-paced school of writing systems — courses in the
world's scripting traditions, ancient and living, from first signs to
reading real texts.**

Site: **[edubba.ac](https://edubba.ac)** (redirects to the GitHub
Pages site).

Edubba (Sumerian *é-dub-ba-a*, "the tablet house", the scribal school
of ancient Mesopotamia) is a static site of **schools**, one per
scripting tradition — cuneiform, Egyptian hieroglyphs, sinographs,
and more. Each school is a catalog of numbered courses with
prerequisites (Cuneiform 101 Foundations, 102 Sumerian, 103
Akkadian, …), and each course is a progressive sequence of chapters
ending in graded readings of *real* documents — tablets, inscriptions,
pages — drawn from the [Nabu](https://arvicco.github.io/nabu/) library
with per-passage citations and licenses. The full design is in
[docs/concept.md](docs/concept.md).

## Status — honest, as of 2026-08-12

**Three schools are open.** In the cuneiform school,
[101 · Foundations](https://edubba.ac/cuneiform/101/) and
[102 · Sumerian](https://edubba.ac/cuneiform/102/) are complete
(orientation to decipherment; 77 signs in computed order; real
readings from Fara-period tablets through proverbs, Šulgi's hymn,
and Gudea's cylinders), and
[103 · Akkadian](https://edubba.ac/cuneiform/103/) is complete —
eighteen chapters plus a full Reference: the syllabary on Codex
Hammurapi, laws 1–2 and the mutilation laws read whole, real Old
Babylonian letters, a genuine Sippar silver loan, and the king's
own closing invitation, at 79% coverage of the Old Babylonian
value-tokens.
In the Egyptian school,
[101 · Foundations](https://edubba.ac/hieroglyphs/101/) is complete
(53 signs, Rosetta told with Ptolemy and Cleopatra read sign by
sign) and [102 · Middle Egyptian](https://edubba.ac/hieroglyphs/102/)
has its first stretch — sentence types, the suffix conjugation,
the doctors' register, from Westcar to the medical papyri.
The sinograph school has opened **classical-first**:
[101 · Foundations](https://edubba.ac/sinographs/101/) is
**complete** — ten chapters and a reference on how the characters
work: strokes, pictographs, compounds, borrowed sounds, and the
55 most frequent characters of the classical corpus, taught on
real lines of the *Laozi*, the *Analects*, and the *Great
Learning*. [102 · Literary Chinese](https://edubba.ac/sinographs/102/)
is **complete** too — fifteen chapters teaching the grammar of the
classical written language element by element, from the verbless
sentence to the discourse words, on the same real texts; the famous
sayings the foundations met in pieces read whole by the end. A Character Codex page
backs every taught character, and a Pinyin primer voices every
syllable in one standard synthesized voice, every clip
tone-verified and loudness-normalized.
Also live: the map-of-writing landing page and per-school sign
codices. Every recurring sign links to where it was taught, with
hover bubbles giving name, readings, and meaning. The site works
with JavaScript disabled; a single self-contained script upgrades
audio links to click-to-play, and that is the only JS anywhere.

Under the hood: a computed curriculum (sign order = corpus
frequency × graphic simplicity, from committed frequency tables —
including a 722-million-character count over the Kanripo classical
corpus), a "nothing untaught" validator that fails the build if a
chapter uses a sign not yet taught, a per-script font-coverage rule
that makes tofu unshippable (computed subsets of Noto Sans
Cuneiform, Noto Sans Egyptian Hieroglyphs, and Noto Serif TC), and
the full gate (`rake gate`: lint + tests + build + offline link
check) with auto-deploy on merge.

Next: the schools grow in alternating phases — the Egyptian
literacy track toward Sinuhe, the wider cuneiform world, and the
sinograph course's march past the half-corpus line.

## Building locally

```
bundle install        # once
rake gate             # lint + tests + build + link check
rake serve            # preview at http://127.0.0.1:4000
```

Site sources live in `site/` (Jekyll 4.4, null theme, text-pure —
the site must work in any browser with JavaScript off; one
self-contained enhancement script exists, for audio, and nothing
requires it).

## Authorship, corrections, license

Edubba's materials are **drafted by AI (Claude) and reviewed by the
project owner**; didactic content cites its scholarly basis (standard
grammars and sign lists) in-line. Errors are ours and fixable:
**[GitHub Issues](https://github.com/arvicco/nabu-edubba/issues)** is
the feedback and errata channel.

Original prose is licensed **[CC BY-SA 4.0](LICENSE)**. Source texts
and images carry their own licenses, always stated where they appear,
inherited from Nabu's per-passage license records.
