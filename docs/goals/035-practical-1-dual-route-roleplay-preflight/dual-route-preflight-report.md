# Goal 035 Dual-Route Roleplay Preflight Report

## Summary

Goal 035 prepared the next Barry-as-student checkpoint as a two-route roleplay:

- Stage A: controlled local Mac route, locally rehearsed and green.
- Stage B: hosted deep-server route, instructor-only and warning-accepted while
  IT/TLS remains pending.
- Student release: no-go until a trusted class route, student access model,
  capacity, recovery, and release approval are separately proven.

No Barry roleplay, student contact, Moodle edit, app/package change, science
change, dependency change, service/config change, account change, public
exposure, commit, push, merge, PR, or Goal 036 work was performed.

## Starting State

- Working directory: `/Users/bwbrook/git/rPVA`
- Branch: `codex/rpva-goal035-dual-route-roleplay-preflight`
- Base:
  `dfe4be4079d049b8bdbfc544c1043191a048446f`
  (`dfe4be4 Add Practical 1 roleplay readiness pack`)
- Initial dirty state: untracked Goal 035 packet directory only.

## Sources Reviewed

- `docs/goals/035-practical-1-dual-route-roleplay-preflight/Goal.md`
- `docs/goals/035-practical-1-dual-route-roleplay-preflight/Plan.md`
- `docs/goals/035-practical-1-dual-route-roleplay-preflight/Runbook.md`
- `docs/goals/035-practical-1-dual-route-roleplay-preflight/Log.md`
- `docs/teaching/woodhen/README.md`
- `docs/teaching/woodhen/instructor-guide.md`
- `docs/teaching/shiny/README.md`
- `docs/teaching/woodhen/practical-1-student-launch-page.md`
- `docs/teaching/woodhen/practical-1-mission-worksheet.md`
- `docs/teaching/woodhen/practical-1-barry-roleplay-script.md`
- `docs/teaching/woodhen/practical-1-roleplay-notes-template.md`
- `docs/teaching/woodhen/practical-1-roleplay-go-no-go.md`
- `docs/teaching/woodhen/practical-1-moodle-ready-bundle/README.md`
- `docs/teaching/woodhen/practical-1-moodle-ready-bundle/moodle-section-text.md`
- `docs/teaching/woodhen/practical-1-day-of-class-pack.md`
- `docs/teaching/woodhen/practical-1-go-no-go-checklist.md`
- `docs/goals/025-nonstudent-shinyproxy-staging-bootstrap/staging-report.md`
- `docs/goals/026-campus-route-tls-readiness/campus-tls-readiness-report.md`
- `docs/goals/027-trusted-class-hostname-tls-gate/trusted-class-hostname-tls-report.md`
- `docs/goals/028-campus-it-tls-request-pack/campus-it-tls-request-pack.md`
- `docs/goals/033-practical-1-moodle-ready-artefact-bundle/artefact-bundle-report.md`
- `docs/goals/034-practical-1-barry-student-roleplay-readiness/roleplay-readiness-report.md`
- `inst/shiny/practical1/app.R`

## Route-Aware Materials Created

- `docs/teaching/woodhen/practical-1-dual-route-roleplay-runbook.md`
- `docs/teaching/woodhen/practical-1-roleplay-feedback-return-template.md`
- `docs/teaching/woodhen/practical-1-dual-route-go-no-go.md`

Narrow discoverability pointers were added to:

- `docs/teaching/woodhen/README.md`
- `docs/teaching/woodhen/instructor-guide.md`
- `docs/teaching/woodhen/practical-1-barry-roleplay-script.md`
- `docs/teaching/woodhen/practical-1-roleplay-go-no-go.md`
- `docs/teaching/shiny/README.md`

The runbook makes Stage A local-first, keeps Stage B instructor-only, and keeps
student release blocked until the trusted-route gate is green.

## Local Mac Route Rehearsal

Local app command:

```sh
Rscript -e 'source("bootstrap.R"); run_practical1_shiny(host = "127.0.0.1", port = 3901, launch.browser = FALSE)'
```

Local rehearsal route:

```text
http://127.0.0.1:3901/
```

Path exercised:

1. Opened the route-aware runbook, launch page, worksheet, roleplay script, and
   current app/materials during source review.
2. Opened the local app route in a real browser via Playwright CLI.
3. Clicked `Start baseline`.
4. Confirmed baseline remained run 1 for comparison.
5. Ran `Ceiling carrying capacity`.
6. Ran `Environmental stochasticity`.
7. Ran `Catastrophe`.
8. Ran `Simple intervention`.
9. Opened Compare and confirmed five runs.
10. Downloaded comparison CSV.
11. Downloaded evidence-notes Markdown.
12. Confirmed the worksheet evidence-recording section exists.
13. Opened Transfer.

Screenshot evidence:

| Evidence | Path | Size | SHA-256 |
| --- | --- | ---: | --- |
| Start page | `/tmp/rpva-goal035-local-route/screenshots/01-start.png` | 89,741 bytes | `18844b6599cc7ac0ce1ff61225f30975dfd0fd3c3e26655a7ab094e50124b65c` |
| Concept Lab after runs | `/tmp/rpva-goal035-local-route/screenshots/02-concept-lab-after-runs.png` | 231,047 bytes | `5623bff545b9f973bd750cd388a6197d63ae64248af8769365342a068f4a1e3f` |
| Compare and exports | `/tmp/rpva-goal035-local-route/screenshots/03-compare-export.png` | 108,072 bytes | `0d49a0303f7b6e982fe6806f9af6b16c23417649ebeb12d2bba09287bc4ab91f` |
| Transfer | `/tmp/rpva-goal035-local-route/screenshots/04-transfer.png` | 70,223 bytes | `2872c3d33517ea316900e914714355cfbabdfa4626ac10f24346ec873cefb533` |

Downloaded evidence:

| Evidence | Path | Size | SHA-256 |
| --- | --- | ---: | --- |
| Comparison CSV | `/tmp/rpva-goal035-local-route/downloads/practical1-comparison-20260612.csv` | 631 bytes | `3bed5623ee8ef52da0cd7b2fa602e58df2abf3f401f5d76fc610287c3c6dd3fb` |
| Evidence notes | `/tmp/rpva-goal035-local-route/downloads/practical1-evidence-notes-20260612.md` | 4,604 bytes | `bbac0eb93b4ada10365c1b3d1227597c50c55aae079b7af519292c62b0f667b0` |

Export shape observed:

- CSV leading columns:
  `run_id, stage, label, scenario, years, reps, PE, Nmed, Nlo95, Nhi95,
  extinct_reps, surviving_reps, trajectory_available`
- CSV rows: 5 data rows plus header.
- Baseline row: run 1, `deterministic_baseline`.
- Evidence-notes Markdown rows: 5 runs.
- Evidence-notes framing: "This export is evidence, not an answer."

Browser console:

- one non-blocking `favicon.ico` 404;
- no app JavaScript failure observed.

Shutdown:

- local browser session closed;
- local Shiny process stopped;
- `lsof -nP -iTCP:3901 -sTCP:LISTEN` returned no listener.

## Hosted Route Posture

Read-only, non-secret checks were run from the Mac mini and one read-only
remote posture probe was run via `deep-server-ts`. No config, service,
certificate, account, access-detail, Moodle, student, or app state was changed.

Mac mini route checks:

| Check | Result | Interpretation |
| --- | --- | --- |
| Tailnet health with `-k` | HTTP 200, body `deep-server app gateway ok` | Gateway is reachable through the tailnet route. |
| Tailnet health with normal TLS verification | curl failed with SSL verify result 18, HTTP 000 | Current certificate remains self-signed/untrusted. |
| Tailnet login without authentication | HTTP 200 | ShinyProxy sign-in page is reachable. |
| Tailnet app path without authentication | HTTP 302 to `/login` | App path is protected as expected. |
| Campus/raw-IP health from Mac mini | timed out after 10 seconds, HTTP 000 | Mac-origin campus/public route still not proven. |
| Campus/raw-IP login from Mac mini | timed out after 10 seconds, HTTP 000 | Mac-origin campus/public login still not proven. |
| Tailnet certificate metadata | subject `CN=deep-server`; issuer `CN=deep-server`; SAN `DNS:deep-server` | Certificate does not match the IP routes and is not browser-trusted. |
| Campus/raw-IP certificate metadata from Mac mini | no certificate captured before timeout | Consistent with Mac-origin campus/public route limitation. |

Remote read-only service posture via `deep-server-ts`:

- `systemctl is-active shinyproxy`: active.
- `systemctl is-active nginx`: active.
- remote localhost gateway health: HTTP 200.
- remote localhost ShinyProxy login: HTTP 200.
- temporary remote output files from the read-only probe were removed.

Barry-provided campus evidence from Goal 026 still matters:

- from inside the University network, `https://131.217.90.193/login` reaches a
  ShinyProxy sign-in page;
- the browser still marks the page as not secure, with crossed-out HTTPS.

Authenticated `/app/practical1` testing was not attempted in Goal 035 because
that requires out-of-band non-student access details. The hosted browser pass
must be done by Barry from the Windows 11 machine only after the orchestrator
supplies the exact route and access details outside chat/repo files.

## Windows 11 Checks Reserved For Barry

Barry's later Stage B roleplay should check:

1. whether the supplied hosted route opens from Windows 11;
2. whether the browser warning appears and how disruptive it is;
3. whether warning acceptance is clear for instructor-only testing;
4. whether the non-student sign-in flow works using out-of-band access details;
5. whether `/app/practical1` opens after sign-in;
6. whether the same mission path from Stage A works;
7. whether comparison CSV and evidence-notes Markdown download on Windows 11;
8. whether any friction should block students even after the TLS gate is fixed.

Barry should not debug infrastructure during the roleplay.

## Validation Results

Completed before this final report was written:

- `Rscript -e 'source("bootstrap.R")'`: passed.
- `Rscript -e 'renv::status(sources = FALSE)'`: passed with no issues.
- `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'`:
  passed.
- `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'`:
  passed.

Final patch hygiene and scans are recorded in `Log.md`.

Final hygiene and scan results after report creation:

- `git diff --check`: passed.
- Marker scan over changed/new text: no hits.
- Secret/private-key-pattern scan over changed/new text: hits were limited to
  Goal 035 policy wording, scan-command text, class-account/token boundary
  wording, credential safety wording, and existing teaching-Shiny boundary
  wording; no secret values, private keys, student identifiers, or sensitive
  service payloads were found.
- Stricter assignment/private-key-block scan: no hits.
- Student-visible route wording check over the launch page, worksheet, Moodle
  section text, roleplay script, notes template, dual-route runbook, and
  feedback-return template: no hits.

## Readiness Judgement

Barry two-stage roleplay readiness: `GO` for orchestrator review.

Stage A local route is locally rehearsed and green. Stage B is ready to
schedule as an instructor-only warning-accepted hosted-route pass, conditional
on the orchestrator supplying the route and out-of-band access details.

Hosted student URL release readiness: `NO-GO`. The hosted route remains
warning-producing and lacks an approved browser-trusted class hostname/TLS
path, student access model, class workspace/account decision, capacity proof,
and release approval.

## Recommended Next Gate

If this report is accepted, schedule the future Barry roleplay execution goal
with two stages:

1. Stage A on the local Mac route.
2. Stage B on Barry's Windows 11 machine using the hosted warning route for
   instructor-only testing.

Keep the trusted-route/campus-IT TLS gate separate. Do not release any hosted
route to students until that infrastructure gate passes.
