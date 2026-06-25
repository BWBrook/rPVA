# Plan

## Steps

1. Verify start state on the Goal 040 branch from current `origin/main`.
2. Inventory the current ITS ShinyProxy VM/Gitea handoff surfaces.
3. Replace the previous registry path stand-ins with Mark's confirmed image path
   shape where the path is now known.
4. Update the ITS staging YAML for the confirmed image path, `shinyproxy-net`,
   and service-user-home workspace root.
5. Add the WSL/GlobalProtect image push runbook for Barry's human-assisted
   publication lane.
6. Prepare the sendable Mark/ITS bundle and keep internal report material out
   of the sendable subset.
7. Assess local Mac mini Docker build feasibility without pushing or touching
   external registry state.
8. Run validation, searches, and scans.
9. Update `Log.md` and wake the rPVA orchestrator.

## Constraints

- Keep Mac mini as source-of-truth/orchestration.
- Treat WSL only as the future publication lane.
- Do not contact ITS, log in to Gitea, push images, create tokens, or alter any
  live service state.
- Do not change app behavior, science, pedagogy, dependencies, or student
  release state.
