# Plan

## Phase 1: Orient And Guard

1. Read Goal 027 and the Goal 025-026 staging/TLS records.
2. Record `pwd`, branch, `HEAD`, and status in `Log.md`.
3. Confirm the branch is `codex/rpva-goal027-trusted-class-hostname-tls` and
   the base is `20f18c3`.
4. Stop if unexpected dirty state exists outside the Goal 027 packet.

## Phase 2: Current Live Posture

1. Check `deep-server-ts` with read-only commands.
2. Confirm ShinyProxy and nginx are active.
3. Confirm ShinyProxy remains behind localhost/gateway routing.
4. Record current nginx server names, proxy target, TLS certificate paths, and
   safe certificate metadata.
5. Confirm credential/config/private-key permissions without printing secret or
   private-key content.

## Phase 3: Hostname And Certificate Discovery

1. List current hostnames in nginx and relevant DNS names already known to the
   host.
2. Test DNS resolution for candidate names from the Mac mini and, where
   meaningful, from `deep-server`.
3. Inspect public certificate metadata for any existing certificate candidates.
4. Check whether any non-interactive certificate mechanism is already available
   and appropriate.
5. Decide whether a class-appropriate trusted hostname is available now.

## Phase 4: Gate Decision

1. If hostname/certificate ownership is unclear, write a blocker report and do
   not modify live state.
2. If only a tailnet-only trusted route is available, report it separately as
   supervisor-staging useful but not class-ready.
3. If a class-appropriate hostname and trusted certificate path are clearly
   available, prepare the smallest reversible nginx/TLS change.
4. Back up any edited nginx/certificate config before changing it.
5. Run `sudo -n nginx -t` before any reload.
6. Reload nginx only after syntax validation passes.

## Phase 5: Proof

If implemented:

1. Verify ordinary browser access reaches login without certificate warning.
2. Verify authenticated `/app/practical1`.
3. Verify comparison CSV and evidence-notes downloads.
4. Confirm the service remains non-student staging.
5. Document rollback.

If blocked:

1. Name the missing owner/action precisely.
2. State the safest current posture: keep non-student staging or roll back.
3. Recommend the next human/IT action before another implementation attempt.

## Phase 6: Report And Validate

1. Create `trusted-class-hostname-tls-report.md`.
2. Update `Log.md` with exact evidence.
3. Update `docs/teaching/shiny/README.md` narrowly if the service boundary or
   next gate changed.
4. Run validation gates:
   - `git diff --check`;
   - `bash -n deploy/shinyproxy/practical1/validate-scaffold.sh`;
   - `bash deploy/shinyproxy/practical1/validate-scaffold.sh`;
   - `Rscript -e 'renv::status(sources = FALSE)'`;
   - marker scan;
   - secret/private-key-pattern scan.
5. Report final state, changed files, validations, live posture, and next
   recommendation.

## Recommendation Bias

Prefer a precise blocker over a fragile workaround. A raw IP URL with a
certificate warning is not acceptable for students. A tailnet-only route may be
useful for supervisor inspection, but it is not enough for classroom release.
