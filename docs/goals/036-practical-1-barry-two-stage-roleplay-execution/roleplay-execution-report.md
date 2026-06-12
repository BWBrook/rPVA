# Goal 036 Checkpoint A Roleplay Execution Report

## Summary

Checkpoint A prepared the two-stage Barry-as-student Practical 1 roleplay and
stops at the human-action gate. Barry's roleplay was not run.

Readiness judgement:

- Stage A local route: `GO` for Barry roleplay when the operator starts the
  local route immediately before the session.
- Stage B hosted warning route: `GO` for instructor-only Barry testing only if
  the orchestrator supplies exact route and non-student access details out of
  band.
- Student release: `NO-GO`; the hosted route remains warning-producing and is
  not a Moodle/student link.

## Starting State

- Working directory: `/Users/bwbrook/git/rPVA`
- Branch: `codex/rpva-goal036-barry-two-stage-roleplay`
- Base:
  `93601e74dfdeb0ebe5a77de6cacd0025cf9d55a2`
  (`93601e7 Add Practical 1 dual-route roleplay preflight`)
- Initial dirty state: untracked Goal 036 packet directory only.

## Sources Reviewed

- `docs/goals/036-practical-1-barry-two-stage-roleplay-execution/Goal.md`
- `docs/goals/036-practical-1-barry-two-stage-roleplay-execution/Plan.md`
- `docs/goals/036-practical-1-barry-two-stage-roleplay-execution/Runbook.md`
- `docs/goals/036-practical-1-barry-two-stage-roleplay-execution/Log.md`
- `docs/goals/035-practical-1-dual-route-roleplay-preflight/dual-route-preflight-report.md`
- `docs/teaching/woodhen/practical-1-dual-route-roleplay-runbook.md`
- `docs/teaching/woodhen/practical-1-roleplay-feedback-return-template.md`
- `docs/teaching/woodhen/practical-1-dual-route-go-no-go.md`
- `docs/teaching/woodhen/practical-1-barry-roleplay-script.md`
- `docs/teaching/woodhen/practical-1-roleplay-notes-template.md`
- `docs/teaching/woodhen/practical-1-roleplay-go-no-go.md`
- `docs/teaching/woodhen/practical-1-student-launch-page.md`
- `docs/teaching/woodhen/practical-1-mission-worksheet.md`
- `docs/teaching/woodhen/practical-1-moodle-ready-bundle/moodle-section-text.md`
- hosted-route evidence from Goals 025-028
- `inst/shiny/practical1/app.R`

## Checkpoint A Deliverables

Created:

- `docs/teaching/woodhen/practical-1-barry-roleplay-session-brief.md`
- `docs/goals/036-practical-1-barry-two-stage-roleplay-execution/post-roleplay-triage-template.md`
- `docs/goals/036-practical-1-barry-two-stage-roleplay-execution/roleplay-execution-report.md`

Updated narrowly:

- `docs/teaching/woodhen/README.md`
- `docs/teaching/woodhen/instructor-guide.md`
- `docs/teaching/woodhen/practical-1-dual-route-roleplay-runbook.md`
- `docs/goals/036-practical-1-barry-two-stage-roleplay-execution/Log.md`

The session brief separates operator route setup from Barry's student-mode
actions, names the Stage A local route, keeps Stage B instructor-only, and
states exactly what Barry should return for Checkpoint B triage.

## Stage A Local Route Proof

Local app command used:

```sh
Rscript -e 'source("bootstrap.R"); run_practical1_shiny(host = "127.0.0.1", port = 3902, launch.browser = FALSE)'
```

Local route tested:

```text
http://127.0.0.1:3902/
```

Student-mode path exercised in a real browser:

1. Opened the local app route.
2. Clicked `Start baseline`.
3. Confirmed baseline remained run 1 for comparison.
4. Ran `Ceiling carrying capacity`.
5. Ran `Environmental stochasticity`.
6. Ran `Catastrophe`.
7. Ran `Simple intervention`.
8. Opened Compare and confirmed five rows.
9. Downloaded comparison CSV.
10. Downloaded evidence-notes Markdown.
11. Confirmed the worksheet evidence-recording section exists.
12. Opened Transfer.

Screenshot evidence:

| Evidence | Path | Size | SHA-256 |
| --- | --- | ---: | --- |
| Start page | `/tmp/rpva-goal036-stage-a/screenshots/01-start.png` | 89,741 bytes | `18844b6599cc7ac0ce1ff61225f30975dfd0fd3c3e26655a7ab094e50124b65c` |
| Concept Lab after runs | `/tmp/rpva-goal036-stage-a/screenshots/02-concept-lab-after-runs.png` | 123,707 bytes | `888a1f3044945e3b2ff69c3496b0d5295a75c3545ed5358e2d69ff68babed668` |
| Compare and exports | `/tmp/rpva-goal036-stage-a/screenshots/03-compare-export.png` | 108,072 bytes | `0d49a0303f7b6e982fe6806f9af6b16c23417649ebeb12d2bba09287bc4ab91f` |
| Transfer | `/tmp/rpva-goal036-stage-a/screenshots/04-transfer.png` | 70,223 bytes | `2872c3d33517ea316900e914714355cfbabdfa4626ac10f24346ec873cefb533` |

Downloaded evidence:

| Evidence | Path | Size | SHA-256 |
| --- | --- | ---: | --- |
| Comparison CSV | `/tmp/rpva-goal036-stage-a/downloads/practical1-comparison-20260612.csv` | 631 bytes | `3bed5623ee8ef52da0cd7b2fa602e58df2abf3f401f5d76fc610287c3c6dd3fb` |
| Evidence notes | `/tmp/rpva-goal036-stage-a/downloads/practical1-evidence-notes-20260612.md` | 4,604 bytes | `0b43a595991ef634fa7299239b88af9013b9394af5eba3d865796b2948d574ed` |

Export shape observed:

- CSV leading columns:
  `run_id, stage, label, scenario, years, reps, PE, Nmed, Nlo95, Nhi95,
  extinct_reps, surviving_reps, trajectory_available`
- CSV rows: 5 data rows plus header.
- Baseline row: run 1, `deterministic_baseline`.
- Evidence-notes rows: 5 runs.
- Evidence-notes framing: "This export is evidence, not an answer."

Browser console:

- one non-blocking `favicon.ico` 404;
- no app JavaScript failure observed.

Shutdown:

- browser session closed;
- local Shiny process stopped;
- `lsof -nP -iTCP:3902 -sTCP:LISTEN` returned no listener.

## Stage B Hosted Warning-Route Posture

Read-only, non-secret checks were run. No DNS, TLS, certificate, nginx,
ShinyProxy, service, account, credential, Moodle, student, or app state was
changed. Login and app response bodies were discarded instead of stored.

Mac mini route checks:

| Check | Result | Interpretation |
| --- | --- | --- |
| Tailnet health with `-k` | HTTP 200, body `deep-server app gateway ok` | Gateway is reachable through the tailnet route. |
| Tailnet health with normal TLS verification | curl failed with SSL verify result 18, HTTP 000 | Certificate remains self-signed/untrusted. |
| Tailnet login without authentication | HTTP 200 | ShinyProxy sign-in page is reachable. |
| Tailnet app path without authentication | HTTP 302 to `/login` | App path is protected as expected. |
| Campus/raw-IP health from Mac mini | timed out after 10 seconds, HTTP 000 | Mac-origin campus/public route still not proven. |
| Campus/raw-IP login from Mac mini | timed out after 10 seconds, HTTP 000 | Mac-origin campus/public login still not proven. |
| Tailnet certificate metadata | subject `CN=deep-server`; issuer `CN=deep-server`; SAN `DNS:deep-server` | Certificate does not match IP routes and is not browser-trusted. |
| Campus/raw-IP certificate metadata from Mac mini | no certificate captured before timeout | Consistent with the Mac-origin campus/public route limitation. |

Remote read-only service posture via `deep-server-ts`:

- `systemctl is-active shinyproxy`: active.
- `systemctl is-active nginx`: active.
- remote localhost gateway health: HTTP 200.
- remote localhost ShinyProxy login: HTTP 200.

Barry-provided campus evidence from Goal 026 remains part of the decision:

- from inside the University network, `https://131.217.90.193/login` reaches a
  ShinyProxy sign-in page;
- the browser still marks the page as not secure, with crossed-out HTTPS.

Authenticated Stage B testing was not attempted during Checkpoint A because it
requires out-of-band non-student access details. Do not place those details in
chat, repo files, reports, logs, or screenshots.

## Human-Action Gate

Barry can now be asked to perform Stage A. Barry can also perform Stage B only
if the orchestrator supplies the exact hosted route and non-student access
details out of band and explicitly frames browser-warning acceptance as
instructor-only.

Do not ask Barry to debug infrastructure. If Stage B hits warning, login,
route, speed, or app-access friction, record it and stop.

For Checkpoint B triage, Barry should return:

- completed `practical-1-roleplay-notes-template.md`;
- completed `practical-1-roleplay-feedback-return-template.md`;
- evidence folder path;
- Stage A comparison CSV and evidence-notes Markdown filenames;
- Stage B comparison CSV and evidence-notes Markdown filenames, if Stage B is
  run;
- any blocker screenshots;
- one overall recommendation: `GO`, `REVISE`, or `STOP`;
- one sentence confirming whether the hosted route still feels
  student-release no-go.

## Validation Results

Completed before this report was finalized:

- `Rscript -e 'source("bootstrap.R")'`: passed.
- `Rscript -e 'renv::status(sources = FALSE)'`: passed with no issues.
- `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'`:
  passed.
- `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'`:
  passed.

Final hygiene and scan results after report/log creation:

- `git diff --check`: passed.
- Marker scan over changed/new text: no hits.
- Secret/private-key-pattern scan over changed/new text: hits were limited to
  Goal 036 policy wording, scan-command text, credential/private-key safety
  wording, and the new session brief stop-rule wording; no secret values,
  private keys, student identifiers, or sensitive service payloads were found.
- Stricter assignment/private-key-block scan: no hits.
- Student-visible route wording check: no route/warning hits in the student
  launch page, mission worksheet, or Moodle section text; route/warning hits
  were limited to instructor/orchestrator-facing roleplay materials.

## Boundaries Observed

- No Barry roleplay was run.
- No Moodle, student, student-release, account, credential, token, class
  workspace, DNS, TLS, certificate, nginx, ShinyProxy, systemd, firewall,
  Docker-service, or remote service-state change was made.
- No app/package code, Shiny UI/CSS/server code, tests, science/YAML/model
  defaults, dependencies, Practical 2 materials, assessment materials, or
  KPZ314 materials were changed.
- No real secret, private key, student identifier, or sensitive service payload
  was written to repo files, logs, screenshots, reports, or terminal output.
- No commit, push, merge, PR, or Goal 037 work was performed.

## Recommended Next Gate

Orchestrator review of this uncommitted Checkpoint A package should decide
whether to send Barry the session brief and run the human roleplay. The next
woodhen work should be Checkpoint B only after Barry returns the roleplay notes
and evidence.
