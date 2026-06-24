# Plan

## Phase 1: Guard And Orient

1. Confirm repo root, branch, HEAD, and `git status --short --branch`.
2. Confirm the branch is `codex/rpva-goal037-its-shinyproxy-vm-handoff` and the
   base is the current accepted `origin/main` head.
3. Read the Goal 037 packet.
4. Read the Practical 1 ShinyProxy scaffold and relevant hosted-route records.
5. Record the start guard and source list in `Log.md`.

## Phase 2: Design The ITS Handoff

1. Translate the deployment target from `deep-server` to the ITS-managed
   RedHat 9/rootless-Docker VM.
2. Define Gitea registry naming and image tag conventions.
3. Define app ids for KPZ308 now and KPZ314 later.
4. Clarify auth, TLS/DNS, update, monitoring, rollback, and support ownership.
5. Keep credentials, student identifiers, and student release out of scope.

## Phase 3: Create Handoff Materials

1. Write `its-vm-handoff.md`.
2. Write `application.its-staging.example.yml`.
3. Write `gitea-registry-runbook.md`.
4. Write `mark-reply-draft.md`.
5. Add narrow pointers to existing deployment/teaching docs if useful.

## Phase 4: Validate

1. Run deployment scaffold static validation.
2. Parse existing and new YAML examples.
3. Run `renv::status`.
4. Run marker, secret/private-key, stricter secret assignment, and
   route/student-release wording scans.
5. Manually review for accidental secrets, student identifiers, or real
   registry values.

## Phase 5: Report

1. Write `its-handoff-report.md`.
2. Update `Log.md`.
3. Leave changes uncommitted.
4. Wake the orchestrator with the handoff summary, validation evidence, and
   recommended next gate.
