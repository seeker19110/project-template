# Contributing

Read `CLAUDE.md`, then the single entrypoint
`docs/framework/standard-delivery.md`. It routes to stack/profile-specific guidance.

## Canonical flow

**Frame → Research → Approve Spec → Plan → Build → Verify → Integrate → Observe → Reconcile.**

Feature source code must not start before `docs/specs/*` is **Approved for implementation** with
approver/date. A goal spanning multiple PRs uses `docs/goals/*` and one outcome per iteration/PR.

## Git and PR

- Branch: `docs/spec-...` for research/spec; `feat|fix|refactor/<issue>-<slug>` for implementation.
- Conventional Commits; small logical commits; no direct push to default branch.
- Open draft PR early and link Goal/Issue/Spec.
- Ready only with evidence and profile gates; merge only via authorized reviewed PR.
- After release, verify health/metric/guardrail and checkpoint the Goal.

## Definition of Ready/Done

Use the canonical DoR/DoD in `standard-delivery.md`. Project commands come from the project
`CLAUDE.md`/manifest; never copy Web-specific commands into another profile without verification.

## AI loop limits

One iteration is one outcome and one PR. Reconcile from current default branch, not chat memory.
Repair the same failure at most three times. Stop WAITING/BLOCKED for approval, product/architecture
trade-off, destructive/breaking changes, production/secrets/cost/new permission, out-of-scope CI,
or exceeded guardrail. Never weaken tests or security to pass a gate.

## Automation

Do not bypass hooks, CI, PR policy, secret/security scans or branch protection. Configure required
checks to match the chosen project profile and verify the protection with a deliberately failing PR.
