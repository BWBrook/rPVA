# Plan

## Phase 1: Start Guard

1. Confirm `pwd`, branch, HEAD, and `git status --short --branch`.
2. Fetch `origin/main` and create or use
   `codex/rpva-goal039-gitea-handoff-identity-refresh` from current
   `origin/main` only if the worktree is clean.
3. Inventory current references to `kpz308-rpva-practical1`,
   `kpz308-rpva-practical`, Gitea, and ITS handoff surfaces.

## Phase 2: Refresh Current Handoff Surfaces

1. Update current deploy scaffold docs and ITS staging YAML to use
   `kpz308-rpva-practical`.
2. Add the confirmed source clone URL:
   `https://git.its.utas.edu.au/UTAS/kpz308-rpva-practical.git`.
3. Keep `ecology-teaching-shiny` only as a possible coordination/access-group
   label, not the confirmed repository owner/path.
4. Use a neutral registry namespace placeholder until ITS confirms the
   container registry path.
5. Avoid editing live service state or testing Gitea access.

## Phase 3: Packet And Draft

1. Create the Goal 039 packet.
2. Write a concise handoff-refresh report.
3. Write a corrected Mark/ITS update draft for later human review.
4. Record validation evidence in `Log.md`.

## Phase 4: Non-Secret Bundle

1. Regenerate `/tmp/rpva-goal039-its-handoff/` from accepted repo files.
2. Include refreshed handoff docs, YAML, runbook, update draft, and report.
3. Generate `SHA256SUMS.txt`.
4. Do not include image layers, credentials, tokens, private keys, student
   identifiers, or live config payloads.

## Phase 5: Validation And Wake-Up

1. Run the requested static checks and scans.
2. Confirm stale `kpz308-rpva-practical1` remains only in historical Goal 037
   records, not in current sendable/operator handoff surfaces.
3. Leave changes uncommitted.
4. Wake the orchestrator thread with evidence and recommendation.
