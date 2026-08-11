# DEV-LOOP.md — driving Edubba's implementation with Claude models

*How this project gets built with maximum unattended automation,
minimum top-tier spend, and explicit human gates. Instantiated from
the dev-loop skill (ancestry: nabu -> mimir).*

## 1. Preconditions the loop needs

- **Machine-checkable done:** `rake gate` green is the pre-commit
  gate. No network in tests; fully deterministic verification.
- **Frozen contracts as oracles:** contract tests (permalink
  structure, `site/_data/` file shapes) and golden files grade the
  work, not judgment. Content-specific oracle: the "nothing untaught"
  validator over graded readings.
- **Minimal-diff / TDD rules** make packets naturally PR-sized.
- **Phases with review gates** are the standing human approval points
  — the loop never invents its own.

Greenfield repo: Phase 0 shrinks to gate + conventions + seams.

## 2. Model tiering policy

**Tiers are roles, not fixed model names.** Re-evaluate the mapping as
models ship; newer cost-effective models are first-class coding agents
for any packet with a written spec and a machine-checkable oracle
(owner ruling 2026-07-09). Top tier is NOT the default; a
`[tier: top]` tag on a packet carries a one-line justification.

| Tier | Used for |
|---|---|
| **Top** (orchestrator) | Phase/curriculum design; packet elaboration; FIRST-of-family patterns (first chapter of a rung, first validator, visual identity); anything touching the owner-ruled domain (concept §7 decisions, licenses/attribution, permalinks, ordering methodology — proposal-only, final say the owner's); review of every delegated diff; gate reviews; adjudication; **factual review of didactic content** |
| **Implementation** | Chapters following an established template with a written spec; test batteries; glue; fixture/data entries; doc syncs; backlog/worklog housekeeping — pick the CHEAPEST tier plausibly capable |

Hard rule regardless of tier: **no model changes the owner-ruled
domain, frozen contract fields, or license/attribution statements.**
Those become `blocked: decision-item`.

**Agent safety:** code agents run with an explicit
no-destructive-git-commands constraint; use worktree isolation when
agents run in parallel or the tree holds uncommitted owner edits.

## 3. Work packets and the backlog

docs/BACKLOG.md (see its header for the format) is the loop's entire
coordination state — no external tracker; survives any session dying.
Packets here are chapter-sized: one chapter, one instrument, or one
validator per packet.

**Internal docs rule (owner, 2026-07-29):** per-phase plans, owner
communication, surveys, and all consideration output live in
gitignored `.docs/` (e.g. `.docs/phase-1-plan.md`). The public repo
carries only the coordination state (BACKLOG/WORKLOG) and documents
meant for readers; nothing internal lands in `docs/`.

## 4. Loop mechanics

1. **Pick** the first `ready` packet whose deps are `done`.
2. **Dispatch** at the packet's tier.
3. **Implement TDD**: failing test / seeded-violation check first,
   then the minimal diff to green. Content packets: chapter spec
   (taught-set in, taught-set out, readings list) precedes prose.
4. **Verify**: `rake gate` green + self-review checklist; contract-
   touching work diffs output against the contract test (updated in
   the SAME commit, additively). Judge the gate by its BARE exit code
   — never through a pipe (`| tail` masks a red gate under zsh
   without pipefail; near-miss 2026-07-29). While delegated agents
   are writing files, commit explicit paths, never `git add -A`.
5. **Commit** on `phase-N`, conventional message referencing the
   packet; update backlog + worklog; push and WATCH CI — local
   toolchains drift from the CI target; CI is the authority. **After
   any deploy, surface-review the DEPLOYED URL itself** (headless
   screenshot + read), never just curl individual files — a 200 on a
   file proves it exists, not that pages reference it correctly
   (baseurl incident, 2026-07-29).
6. **Escalate on failure**: two failed attempts at tier -> bump one
   tier, retry once; two failures at top -> `blocked: <diagnosis>`,
   move on. Owner-ruled-domain packets skip attempts -> `blocked:
   decision-item`.
6b. **Visual work reviews itself first.** Anything rendered gets a
   headless screenshot of the SERVED surface (rake serve or the built
   _build/site) that the executing session READS and critiques before
   owner handoff.

   **Surface review checklist** (run against the served page;
   liveness markers alone are never sufficient):
   - [ ] every expected element present AND filled
   - [ ] elements in the correct order and place
   - [ ] native script actually renders (no tofu) with the vendored
         fonts; transliteration aligns with the script it glosses
   - [ ] no NaN / null / undefined / raw-Liquid rendered anywhere
   - [ ] cross-element consistency: the same fact shown twice agrees
   - [ ] failure states are the DESIGNED ones, never blank space or a
         silently missing element
   - [ ] every link on the page resolves (html-proofer backs this,
         but read the page too)
   - [ ] real rendered geometry + the mobile breakpoint
   - [ ] hover states probed: a static screenshot cannot hover, so
         force one bubble visible (a probe page injecting
         `display: block` on a .sign-tip) at each clip box's worst
         corner — first line of a scrolling figure, first row of a
         table (incident 2026-08-09: bubbles clipped by
         overflow-x containers shipped past a hoverless pixel
         review)
   - [ ] keyboard floor: navigation reachable and operable; semantic
         HTML (this site must work in a text browser — it has no JS)
   - [ ] against the previous screenshot: intended changes present,
         nothing else moved

   **Interactive surfaces get named checks** (M20-1; the bubble-clip
   class took THREE owner reports — left rim, last column, reading
   right rim — because no checklist said "hover near every rim").
   A review round or gate runbook that touched CSS, hover behavior,
   or audio is NOT closed by static screenshots: it must enumerate
   its interactive checks — each one a direct URL plus a concrete
   target and what good looks like. Copy and fill this block (the
   three interactive surfaces the site has today; extend it when a
   new one ships):

       INTERACTIVE CHECKS
       - hover: <URL> — hover <glyph> in <the risky spot: last
         table column, first row of a scrolling figure, longest
         reading line> — EXPECT the full bubble, no cut edge
       - listen: <URL> — click <syllable> — EXPECT the displayed
         tone/reading is what the ear hears
       - compare: <URL> — click <syllable A> then <syllable B>
         (different sources) — EXPECT no loudness jump

6c. **Before writing a chapter** (M20-2) — the owner taste rulings
   in the order they bite during writing. Each line compresses a law
   recorded elsewhere (cited); this list never replaces it.
   - [ ] witness VERIFIED first — the reading's URN is in the phase
         plan before a word is drafted (rulebook §-Readings; the §9
         instruments are the mechanical lanes)
   - [ ] famous line over obscure, trimmed to its readable clause —
         the gloss carries the rest (box-share law)
   - [ ] taught company around every new sign: it debuts amid known
         signs, never wild-among-wilds (nothing-untaught, CLAUDE.md)
   - [ ] box mechanically — bin/box_line.rb, never by head; share
         under the chapter cap (sinographs §5 cap law)
   - [ ] no production vocab in prose — chapters and content, never
         stretches and phases (owner ruling 2026-08-11)
   - [ ] every new sign USED in its own chapter, immediately; taught
         exactly once, ever (owner rulings 2026-07-31)
   - [ ] the syllable voiced and the codex page written in the SAME
         commit as the chapter (sinographs §2/§8; complete-shelf)
   - [ ] the return arc named in the stretch plan is DELIVERED at
         its promised chapter (return-arc law, rulebook §-Pedagogy)
7. **Pre-gate: README.md current** — honest about what does not work
   yet. A phase is not gate-ready with a stale README.
8. **One PR per phase** (owner ruling 2026-07-29): all of a phase's
   improvements batch into its gate PR — no mid-phase PRs to main
   except owner-sanctioned hotfixes (M1-1's deploy fix was one).
   **Phase gate = a PR the loop prepares, the owner merges** (owner
   ruling 2026-07-29): top-tier review of the entire phase diff
   against docs/concept.md; resolve blocked packets; update the
   "Current phase" line in CLAUDE.md; then open `phase-N -> main`
   whose PR body carries (a) the phase RUNDOWN — what shipped, per-
   packet evidence — and (b) the RUNBOOK for the gate's human actions
   (numbered steps, one command each, EXPECT lines; background
   quarantined at the end). **The owner reviews, executes the human
   actions, and merges the PR.** Next phase's packets are elaborated
   only after the gate closes.
9. **Ring for the owner** when the loop stops on something only the
   owner can do — as the LAST tool call of that turn:
   `nohup "$HOME/.claude/hooks/attention-alarm.sh" sticky >/dev/null 2>&1 &`
   Never for informational turns.

## 5. Execution modes

- **Phase 0 (bootstrap): interactive, top-tier.** Gate, conventions,
  site stub, CI, README v1. Owner present.
- **Stage A (new course families): top-tier-orchestrated,
  semi-attended.** Orchestrator designs the course spec and first
  chapters; implementation tiers write template-following chapters and
  tooling via subagents.
- **Stage B (assembly line): mid-tier-led, mostly unattended.** A
  mid-tier session runs the loop over chapter packets with an
  established template, dispatching down-tier; top-tier subagents for
  gate reviews, factual review, and adjudication. Fresh context per
  packet; the backlog carries state.

## 6. Guardrails

Principle: **inside the sandbox, full freedom — the boundary itself
is hard** (.claude/settings.json).

Freely allowed: file operations inside the repo + scratchpad; the gate
and its subcommands; git on phase branches; doc/web lookups; reading
Nabu next door (read-only).

Hard boundary (deny-listed or owner-only): merging/pushing to `main`
(deploys the site); GitHub repo, Pages, and DNS settings; `bundle
install` / any package install; force pushes; tags; anything outside
the repo; new dependencies; changes to the owner-ruled domain.

Loop discipline: two-strike rule bounds spend; the loop never marks
its own phase done; no opportunistic refactors; owner-facing
verification asks are always SPECIFIC (exact commands, files, and what
good/bad looks like).

Structured edits over text replaces (M20-3): machine-read YAML/data
files are edited only via (a) a loader → mutate → dump round-trip, or
(b) a script whose every replacement is ANCHOR-ASSERTED — assert the
anchor exists exactly once BEFORE replacing, fail loud otherwise.
Blind text substitution on files that carry comments is banned: both
manifest splice incidents (phase 17/18) were header-comment
collisions, where a comment happened to contain the literal key
string the replace was aimed at.

One writer per output dir (M19-5; 2026-08-11 incident — a live
`jekyll serve` regenerated into the gate's build dir mid-gate and 110
phantom failures shipped into the report): every long-running process
owns a PRIVATE output directory (`rake serve` → `_build/serve`), and
the gate asserts sole ownership of `_build/site` before it starts —
`rake gate` aborts, naming the PID, while any jekyll process that is
NOT pinned to the private `_build/serve` is alive (a `rake serve` on
its own dir is the sanctioned pattern and never blocks the gate).

## 7. Human-action inventory

| When | Action |
|---|---|
| Phase 0 | Create the GitHub repo; accept README v1; merge the Gate 0 PR |
| Phase 1 | Enable Pages (Actions source); set edubba.ac custom domain + DNS; approve visual identity |
| Gates | Visual sign-offs; golden approvals; merges to main (= deploys); installs; tags |
| Always | Rulings on decision items; owner-ruled-domain changes (concept §7, licenses, permalinks, ordering methodology) |

## 8. Ops pattern

Not yet applicable — no scheduled producers. If/when Edubba gains any
(e.g., a nightly link-rot check or a Nabu-sync freshness probe), adopt
the standard pattern: wrapper script + scheduler entry, TTY-gated
install task, status file, monitor, content-progress invariant.

## 9. Nabu instruments (authoring-time)

All authoring-time only — outputs verified and committed; the site
never talks to Nabu at runtime (CLAUDE.md rule 6). `NABU_BIN`
convention; the CLI lives next door (read-only for us). Delivered
against our FR survey (Nabu P72, 2026-08-11):

- **Witness hunting, interactive**: `nabu search --charset "<taught
  chars>" --max-foreign N [--source S] [TEXT]` — passages readable
  with at most N strangers, strangers printed, cleanest line first.
  The mid-writing lane; fold-aware (学 covers 學).
- **Witness hunting, batch**: `bin/*_picker.rb` — full-corpus sweeps
  with per-chapter bucketing and fame ranking (doc spread) that feed
  a stretch plan's candidate sheet into `.docs/`.
- **Codex verification**: `nabu char <GLYPH> --json` (all three
  schools; frozen contracts) — radical, IDS/components, readings,
  concordances, per-source attestation. Check a sign page's factual
  claims against it BEFORE writing; it is the mechanical backstop of
  the no-confident-nonsense law.
- **Collocation discovery**: `nabu formulas kanripo --gram-size 2` —
  char-grain recurrence (子曰-class) for choosing a chapter's frame
  phrases.
- **Next-witness choice**: `nabu vocab <URN> --chars --coverage
  "<taught chars>"` — per-document coverage %, top strangers by
  frequency: which text the course can read next, and what teaching
  those strangers would buy.
