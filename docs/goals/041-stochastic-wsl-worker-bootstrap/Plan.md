# Plan

## Steps

1. Start from clean current `origin/main` and create the Goal 041 branch.
2. Create the Goal 041 packet.
3. Add the `docs/ops/stochastic/` protocol scaffold.
4. Add the narrow `.gitignore` exception needed to make `docs/ops/`
   reviewable.
5. Add the paste-ready WSL worker priming prompt.
6. Add the first inbox task as bootstrap/orientation only.
7. Add the outbox report and evidence hygiene templates.
8. Run validation, targeted searches, and scans.
9. Update `Log.md`.
10. Wake the rPVA orchestrator and wait.

## Design Choices

- Use markdown because it is easy for Barry to relay manually between Mac mini
  and WSL.
- Keep `current-task.md` and `current-report.md` simple so the first
  communication loop is obvious.
- Keep report/evidence paths repo-local, but require non-secret evidence only.
- Make every live operation opt-in by future explicit task authorization.
