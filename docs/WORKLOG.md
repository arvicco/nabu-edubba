# Worklog

One dense paragraph per completed packet, newest first:
date · packet · commit · notes (what changed, why, evidence, catches).
Incidents get their own entries: what happened, root cause, the
durable fix, the lesson now enforced.

2026-07-29 · M0-1, M0-2 done · phase-0 · Owner ran the one-time
`bundle install` (vendor/bundle, jekyll 4.4.1, html-proofer 5.2.2);
full `rake gate` GREEN end-to-end (lint clean, 6/6 tests, build 0.012s,
htmlproofer 2 internal links OK). Outcome check on the built surface:
_build/site/index.html rendered through the layout (wordmark/h1/footer
present), CNAME=edubba.ac in the published tree, assets copied.
Gemfile.lock committed for local/CI parity. M0-3 remains in-progress
(CI green verifiable only once the GitHub repo exists); M0-4 awaits
owner acceptance at Gate 0.

2026-07-29 · M0-1..M0-4 (bootstrap sweep) · phase-0 · Repo initialized
(main unborn; work on phase-0). Scaffolding committed from dev-loop
templates with concept ratified same day. Gate tooling: Gemfile
(jekyll 4.4 / html-proofer 5 / minitest / rake, repo-local
vendor/bundle), Rakefile (lint/test/build/check/serve/gate),
script/lint.rb (no-JS, front-matter, relative-links, UTF-8 rules) +
test/lint_test.rb (6 tests). Evidence: `rake lint` clean on HEAD and
red on a seeded `<script>` tag (exit 1); `rake test` 6/6 green on
system Ruby 4.0.6. Site stub (config, null-theme layout, stylesheet
skeleton with light/dark, construction-sign index, CNAME edubba.ac);
CI (`rake gate` on push, Ruby 3.3 pin) + Pages deploy building with
our own bundle for local/CI parity (deliberate divergence from nabu's
actions/jekyll-build-pages — Jekyll version parity beats convention).
README v1 + LICENSE (CC BY-SA 4.0, source-texts carve-out). Catches:
`bundle install` correctly denied by our own fresh permission profile
(owner action — pending); zsh `status` is read-only, which aborted a
cleanup one-liner and left the seeded violation in the tree until
removed by hand — don't use `status` as a shell variable.
