# Goal 026: Campus Route And TLS Readiness Proof

## Objective

Produce a concise, evidence-backed readiness report for the current Practical 1
non-student ShinyProxy staging service, focused on campus-route reachability and
TLS/browser trust.

The completed state is either:

1. a clear diagnostic report showing what currently works, what remains unsafe
   or unproven, and the recommended next gate before any student-facing use; or
2. an exact blocker report with no service/config changes made.

This goal is diagnostic/readiness work only. It is not a TLS-fix goal and not a
student release.

## Why This Matters

Goal 025 proved authenticated non-student staging over the tailnet, but it did
not prove campus-browser readiness. Barry has now checked the campus route from
inside the University network and reached the ShinyProxy sign-in page at:

```text
https://131.217.90.193/login
```

Barry also observed that the browser still shows the page as not secure, with
HTTPS crossed out. That is the next critical risk: routing appears to reach
ShinyProxy from campus, but TLS trust and post-login campus app behavior are not
yet classroom-ready evidence.

## Operating Mode

Read-only diagnostics, browser/HTTP checks, and documentation.

Do not change live service state. Do not fix TLS in this goal.

## Review Surface

The rPVA orchestrator will review:

- Goal 026 `Log.md`;
- a campus/TLS readiness report under this goal directory;
- any narrow update to Shiny/deployment docs if needed;
- route, certificate, and browser evidence summaries with secrets redacted;
- final local and remote service state;
- final git status and changed-file list.

## Scope

In scope:

- local repository branch/status checks;
- read-only inspection of Goal 025 records and the current Shiny teaching
  deployment docs;
- read-only live checks of the current non-student staging service;
- tailnet route checks;
- campus/public-IP route checks from the Mac mini with short timeouts and no
  looping;
- incorporation of Barry's campus observation that the login page loads from
  inside the University network but shows as not secure;
- read-only certificate/TLS inspection for the tailnet and campus/public-IP
  routes;
- redacted read-only inspection of nginx and ShinyProxy routing/config shape
  when needed to diagnose TLS/routing;
- authenticated tailnet app check using the existing non-student staging
  identity, with the secret value never printed, copied into the repo, or
  included in logs/chat;
- browser evidence for the TLS warning/login page if feasible without exposing
  credentials;
- a recommendation for the next gate: keep supervisor-only staging, perform a
  TLS/DNS/certificate fix goal, request Barry-side authenticated campus app
  verification, or roll back/disable staging.

Out of scope:

- student-facing release;
- class accounts, class tokens, student identifiers, or student workspaces;
- DNS changes;
- firewall changes;
- TLS certificate replacement, trust-chain changes, or browser trust-store
  changes;
- nginx route edits;
- ShinyProxy config edits;
- Docker daemon/service changes;
- account or credential changes;
- printing, rotating, or replacing the existing staging password;
- public announcement or distribution of any URL or credential;
- load testing beyond tiny reachability/smoke checks;
- Practical 2 Shiny app mode;
- assessment redesign;
- scenario/YAML changes or research-grade Lord Howe woodhen analysis;
- new R package dependencies;
- committing, pushing, opening a PR, or merging.

## Read First

- `README.md`
- `docs/codex/thread-handoff-2026-06-04.md`
- `docs/goals/025-nonstudent-shinyproxy-staging-bootstrap/Goal.md`
- `docs/goals/025-nonstudent-shinyproxy-staging-bootstrap/Log.md`
- `docs/goals/025-nonstudent-shinyproxy-staging-bootstrap/staging-report.md`
- `docs/teaching/shiny/README.md`
- `docs/teaching/shiny/deep-server-hosting-feasibility.md`
- `docs/teaching/shiny/implementation-roadmap.md`
- `docs/teaching/shiny/platform-options-decision-matrix.md`
- `docs/teaching/shiny/road-test-operations-plan.md`
- `deploy/shinyproxy/practical1/README.md`
- `deploy/shinyproxy/practical1/application.example.yml`
- `deploy/shinyproxy/practical1/nginx-practical1.example.conf`
- `deploy/shinyproxy/practical1/staging-gate-checklist.md`
- `deploy/shinyproxy/practical1/validate-scaffold.sh`

There is no repo-local `AGENTS.md` in this checkout. Use the repo-local files
above plus Barry's global Mac mini instructions and this Goal 026 packet.

## Starting State Checks

Before diagnostics, report in `Log.md` and final response:

```sh
pwd
git branch --show-current
git rev-parse --short HEAD
git status --short --branch
```

Expected branch at handoff:

```text
codex/rpva-goal026-campus-tls-readiness
```

Expected starting base:

```text
7b0e3fb Record Practical 1 non-student staging bootstrap
```

Treat any unexpected dirty state as project state. Do not clean, restore, or
overwrite it unless it is clearly your own failed intermediate output.

## Git And Publication Policy

- Work on `codex/rpva-goal026-campus-tls-readiness`.
- Do not commit.
- Do not push.
- Do not open a PR.
- Keep a precise changed-file list in `Log.md` and final response.

The orchestrator will review the uncommitted result before deciding whether a
separate closeout commit/publish goal is needed.

## Secret Policy

Do not write real secrets, private keys, student identifiers, or credential
values into the git repo, logs, terminal summaries, screenshots, or chat.

For the existing non-student staging credential:

- use it only if needed for a bounded authenticated tailnet app check;
- read it from the existing remote credential path without printing it;
- keep it in process/local temp state only as needed;
- remove any local temporary copy immediately;
- report only the path and permissions, never the value.

Do not ask Barry to paste credentials into chat.

## Required Work

1. Prove current starting state.
   - Verify the action repo branch/status and expected base.
   - Confirm the Goal 025 closeout commit is present.
   - Confirm no unexpected local dirty state exists before editing Goal 026
     files.

2. Re-check live staging posture without changing it.
   - Verify ShinyProxy and nginx are active.
   - Verify ShinyProxy still binds only behind the existing localhost/gateway
     path.
   - Verify the Practical 1 image/tag expected from Goal 025 is present.
   - Verify the staging credential file exists with restrictive permissions,
     without printing its content.
   - Redact any config inspection so no password, token, private key, or secret
     value appears in output.

3. Check routes.
   - Tailnet health and login route.
   - Campus/public-IP health and login route from the Mac mini with short
     timeouts; do not loop if it times out.
   - Record Barry's campus-side observation:
     `https://131.217.90.193/login` loads from inside the Uni network, but the
     browser marks HTTPS as not secure/crossed out.
   - Distinguish clearly between:
     - route-to-login proof;
     - authenticated app proof;
     - student/class readiness.

4. Diagnose TLS/browser trust.
   - Use `curl -vk`, `openssl s_client`, browser evidence, or equivalent
     read-only tools to identify the observed certificate/trust behavior.
   - Record the subject, issuer, SAN/IP mismatch or self-signed/untrusted
     condition if visible.
   - Do not copy private keys.
   - Do not change certificates or trust stores.

5. Authenticated app smoke.
   - Confirm authenticated app access still works over the tailnet.
   - If campus/public-IP authenticated access cannot be tested from the Mac
     mini, say so explicitly.
   - If a Barry-side authenticated campus browser check is needed, produce a
     minimal orchestrator-facing checklist that does not include a credential
     value and does not ask Barry to paste credentials into chat.

6. Produce readiness report.
   - Create `campus-tls-readiness-report.md` under this goal directory.
   - Include:
     - current service posture;
     - route evidence;
     - Barry-provided campus observation;
     - TLS/browser-trust diagnosis;
     - what remains unproven;
     - a recommendation for the next goal.
   - Update `Log.md`.
   - Update `docs/teaching/shiny/README.md` narrowly only if the current
     boundary text needs the new campus/TLS observation.

## Validation Gates

The goal is not complete until these pass, or a blocker is logged with exact
evidence:

```sh
git status --short --branch
git diff --check
bash -n deploy/shinyproxy/practical1/validate-scaffold.sh
bash deploy/shinyproxy/practical1/validate-scaffold.sh
Rscript -e 'renv::status(sources = FALSE)'
```

Focused R tests are optional for this docs/diagnostic goal. Run them if any
code, package API, Shiny app code, scaffold behavior, or examples are changed.
Do not change those surfaces in this goal.

Also complete:

- marker scan over changed/new tracked text;
- secret-pattern scan over changed/new tracked text;
- manual review that no credential value, private key, or sensitive config
  payload appears in changed files or screenshots;
- final read-only live posture check, if the remote service is reachable.

## Stop Rules

Stop and report to the orchestrator if:

- the starting branch/base/status is not as expected;
- ShinyProxy or nginx is unexpectedly down;
- live config inspection would require printing a credential or private key;
- campus/public-IP checks behave inconsistently enough that repeated probing
  would look like load testing;
- diagnosing TLS would require changing DNS, cert files, trust stores, nginx,
  ShinyProxy config, firewall, Docker service, accounts, or credentials;
- any validation gate fails;
- a real secret appears in repo files or terminal output.

## Expected Final Report

Report:

- final branch, HEAD, and status;
- changed files;
- service posture;
- tailnet route result;
- campus/public-IP route result;
- Barry-provided campus observation as a separate source of evidence;
- TLS/browser warning diagnosis;
- whether authenticated app access is proven over tailnet and/or campus;
- next recommended goal;
- validation commands and results;
- explicit confirmation that no service/config/account/credential/student
  release changes were made.
