# Plan

1. Report branch/worktree state before editing.
2. Fetch/prune and confirm `origin/main` is `260e3b2` or newer.
3. Create `codex/rpva-goal022-local-remote-staging-validation` from
   `origin/main`.
4. Read Goal 020, Goal 021, teaching Shiny planning docs, deployment scaffold,
   and Nectar control-plane placement/routing docs.
5. Inspect GitHub Actions failures after SRF-A adds CI health to the goal.
6. Make a focused CI/bootstrap fix only if the root cause is clear.
7. Verify the CI-equivalent local sequence.
8. Create the Goal 022 packet and update targeted teaching docs.
9. Run one local Mac mini Shiny smoke bound to `127.0.0.1`.
10. Run read-only remote discovery on `deep-server-ts`.
11. Apply the Track B conditional rule:
    - proceed only if existing service state is inspected, reversible, backed
      up, syntax-validatable, non-student, and does not need firewall, DNS, TLS,
      Docker daemon, or major host changes;
    - otherwise stop Track B and record the blocker.
12. Run static validation, scaffold validation, YAML parse, marker scan, secret
    scan, and final status.
13. Report back to SRF-A without commit, push, student exposure, or unapproved
    service changes.
