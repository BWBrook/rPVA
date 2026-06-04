# Plan

1. Confirm branch/worktree state on
   `codex/rpva-goal017-deployment-readiness`.
2. Read the handoff, Shiny planning docs, recent goal packets, and app
   surfaces listed in `Goal.md`.
3. Read the Nectar control-plane docs for remote-routing and `/data/codex`
   placement policy.
4. Run one narrow set of read-only gateway and `deep-server-ts` metadata
   probes.
5. Create the Goal 017 packet:
   - `Goal.md`
   - `Plan.md`
   - `Runbook.md`
   - `Log.md`
6. Update targeted Shiny planning docs only where the next-goal/status text is
   stale.
7. Validate:
   - `git diff --check`
   - `git status --short --branch`
8. Report back to CoS without committing, pushing, deploying, installing, or
   changing services.
