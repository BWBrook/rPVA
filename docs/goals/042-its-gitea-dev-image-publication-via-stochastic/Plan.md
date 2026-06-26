# Plan

## Steps

1. Fetch/prune origin and confirm current `origin/main`.
2. Create the Goal 042 branch from current `origin/main`.
3. Read the existing `stochastic` protocol, inbox, outbox, and bootstrap
   report.
4. Create the Goal 042 packet.
5. Update the `stochastic` protocol with the report-branch convention.
6. Replace the inbox task with the Goal 042 image publication task.
7. Replace the outbox report template with a Goal 042-specific report shape.
8. Add the Goal 042 evidence hygiene README.
9. Run validation, targeted searches, scans, and manual review.
10. Update `Log.md`.
11. Wake the rPVA orchestrator and wait.

## Design Choices

- Keep `stochastic` autonomous enough for one substantial pass: build, local
  smoke, safe login, registry push, digest capture, Mark-ready note, report.
- Require a dedicated GitHub report branch and forbid `main` push.
- Keep ITS Gitea source push forbidden; registry image push is the only ITS
  publication action delegated.
- Treat credential entry as the only expected human interaction and require
  hidden input plus `--password-stdin`.
- Commit only small non-secret report/evidence files on the report branch.
