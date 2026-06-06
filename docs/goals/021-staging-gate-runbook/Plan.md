# Plan

1. Report branch/worktree state before editing.
2. Fetch/prune and confirm `origin/main` is `d50cb51` or newer.
3. Create `codex/rpva-goal021-staging-gate-runbook` from `origin/main`.
4. Read the handoff note, teaching Shiny planning docs, Goals 017-020, and the
   Practical 1 deployment scaffold.
5. Run optional read-only probes for gateway health, image metadata, and
   no-container state.
6. Create the Goal 021 packet.
7. Add an inert staging-gate checklist under `deploy/shinyproxy/practical1/`
   if it improves operator clarity.
8. Update targeted Shiny planning docs only to point at Goal 021 or reconcile
   stale status.
9. Run local static validation and secret-pattern review.
10. Report back to SRF-A without commit, push, live staging, service changes,
    Docker build, container launch, or public/student-facing exposure.
