# Plan

## Phase 1: Orient And Guard

1. Read the Goal 026 packet and the Goal 025 staging record.
2. Record `pwd`, branch, `HEAD`, and status in `Log.md`.
3. Confirm the branch is `codex/rpva-goal026-campus-tls-readiness` and the base
   is `7b0e3fb`.
4. If unexpected dirty state exists outside the Goal 026 packet, stop and
   report it.

## Phase 2: Read-Only Service Posture

1. Check `deep-server-ts` with read-only commands.
2. Confirm ShinyProxy and nginx are active.
3. Confirm ShinyProxy is still local-gateway scoped, not a broad public
   listener.
4. Confirm the Goal 025 image exists.
5. Confirm credential/config permissions without printing credential values.
6. Inspect redacted nginx/ShinyProxy route shape only if needed.

## Phase 3: Route Evidence

1. Check tailnet health and login route.
2. Check campus/public-IP health and login route from the Mac mini with short
   timeouts.
3. Record Barry's campus-side observation:
   - `https://131.217.90.193/login` loads from inside the University network;
   - the browser still reports the connection as not secure with crossed-out
     HTTPS.
4. Keep route-to-login evidence separate from authenticated app evidence.

## Phase 4: TLS Diagnosis

1. Use `curl -vk`, `openssl s_client`, browser evidence, or equivalent read-only
   tooling to summarize:
   - certificate subject;
   - issuer;
   - SAN/IP coverage if available;
   - expiry dates;
   - verification error;
   - whether the problem is trust-chain, name/IP mismatch, self-signed cert, or
     a combination.
2. Do not read or copy private key material.
3. Do not modify certificate, nginx, ShinyProxy, DNS, firewall, or trust-store
   state.

## Phase 5: Authenticated App Evidence

1. Confirm authenticated tailnet app access still works using the existing
   non-student staging identity without printing or committing the credential.
2. If campus/public-IP authenticated app access cannot be tested from the Mac
   mini, say that explicitly.
3. If Barry-side authenticated campus app testing is needed, write a minimal
   orchestrator-facing checklist that avoids credential values and explains what
   success/failure signals to report.

## Phase 6: Report And Validate

1. Create `campus-tls-readiness-report.md`.
2. Update `Log.md` with exact evidence.
3. Update `docs/teaching/shiny/README.md` narrowly only if the current boundary
   statement needs the campus/TLS observation.
4. Run validation gates:
   - `git diff --check`;
   - `bash -n deploy/shinyproxy/practical1/validate-scaffold.sh`;
   - `bash deploy/shinyproxy/practical1/validate-scaffold.sh`;
   - `Rscript -e 'renv::status(sources = FALSE)'`;
   - marker scan;
   - secret-pattern scan.
5. Report changed files, final status, validation, evidence paths, and next
   recommendation.

## Recommendation Bias

Prefer a conservative recommendation. If route-to-login works but TLS remains
untrusted, do not call the service classroom-ready. Recommend a separate
TLS/DNS/certificate readiness or fix goal before any broader student testing.
