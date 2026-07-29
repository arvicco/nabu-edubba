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

## 4. Loop mechanics

1. **Pick** the first `ready` packet whose deps are `done`.
2. **Dispatch** at the packet's tier.
3. **Implement TDD**: failing test / seeded-violation check first,
   then the minimal diff to green. Content packets: chapter spec
   (taught-set in, taught-set out, readings list) precedes prose.
4. **Verify**: `rake gate` green + self-review checklist; contract-
   touching work diffs output against the contract test (updated in
   the SAME commit, additively).
5. **Commit** on `phase-N`, conventional message referencing the
   packet; update backlog + worklog; push and WATCH CI — local
   toolchains drift from the CI target; CI is the authority.
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
   - [ ] keyboard floor: navigation reachable and operable; semantic
         HTML (this site must work in a text browser — it has no JS)
   - [ ] against the previous screenshot: intended changes present,
         nothing else moved
7. **Pre-gate: README.md current** — honest about what does not work
   yet. A phase is not gate-ready with a stale README.
8. **Phase gate = a PR the loop prepares, the owner merges** (owner
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
