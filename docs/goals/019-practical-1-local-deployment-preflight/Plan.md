# Plan

1. Report branch/worktree state before editing.
2. Fetch/prune and confirm `origin/main` is `8c2c586` or newer.
3. Create `codex/rpva-goal019-local-deployment-preflight` from `origin/main`.
4. Read Goal 018, scaffold files, Shiny planning docs, and app context.
5. Inspect Docker availability with `docker info`.
6. Refine scaffold templates to reduce obvious local/staging defects while
   keeping them inert.
7. Create the Goal 019 packet and update targeted planning docs.
8. Run static validation, marker scan, secret scan, shell syntax check,
   scaffold validator, YAML parse check, and final status.
9. Report back to CoS without commit, push, remote writes, or service changes.
