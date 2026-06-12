# Goal 035: Practical 1 Dual-Route Roleplay Preflight

## Objective

Prepare the next Practical 1 human roleplay checkpoint by proving and
documenting two controlled routes for Barry's later student-role simulation:

1. a local Mac route under our control; and
2. a hosted deep-server route for Barry/instructor testing only, accepting the
   current browser security warning while IT/TLS work remains pending.

This goal does **not** run the Barry roleplay itself. It makes that roleplay
safe to schedule by producing exact route instructions, note-capture
expectations, pass/fail criteria, and current route evidence.

## Context

Goals 029 to 034 brought Practical 1 to a strong pedagogical delivery
candidate:

- mission tutorial curriculum;
- mission-mode app affordances;
- delivery-candidate rehearsal pack;
- student launch pack;
- Moodle-ready artefact bundle;
- Barry-as-student roleplay readiness pack.

The remaining infrastructure risk is not the app itself, but the hosted route:
Goals 025 to 028 established a non-student ShinyProxy staging service, proved
tailnet-hosted access, diagnosed the browser-trust problem, identified the lack
of approved class hostname/TLS ownership, and produced an IT request pack. IT
may take one or two weeks to respond. The project should keep moving by testing
what we can control now, while keeping the TLS gap explicit and quarantined
from student release.

## Success Criteria

The goal is complete when:

1. The local Mac route has been preflighted with the current Practical 1 app,
   launch materials, roleplay script, worksheet, Compare exports, and Transfer
   path.
2. The hosted deep-server route has been checked as far as possible with
   read-only, non-secret probes, with current TLS/browser-warning status
   recorded.
3. A route-aware Barry roleplay runbook exists that separates:
   - Stage A: local Mac route;
   - Stage B: hosted deep-server route on Barry's Windows 11 machine with the
     warning accepted by Barry only;
   - student release, which remains no-go until a trusted route is approved and
     proven.
4. A compact feedback-return template exists for Barry's notes from both route
   tests.
5. The runbook gives exact stop/report points for Barry rather than asking him
   to debug infrastructure or app internals.
6. No student-facing material presents the raw-IP, self-signed, browser-warning,
   or otherwise untrusted hosted route as release-ready.
7. The result gives the orchestrator a clear next gate:
   - schedule Barry's local-route roleplay;
   - schedule Barry's hosted warning-accepted route roleplay;
   - or request a narrow corrective goal before using Barry's time.

## In Scope

- Review of the current Practical 1 roleplay, launch, Moodle bundle, go/no-go,
  and Shiny teaching materials.
- Review of repo-local hosted-route evidence from Goals 025 to 028.
- Creation of a route-aware roleplay runbook for Barry.
- Creation of a feedback-return template for Barry's local and hosted tests.
- Creation or update of a dual-route go/no-go checklist if that is cleaner than
  overloading the existing roleplay checklist.
- Local browser rehearsal of the current Practical 1 student path using a Mac
  local route.
- Read-only hosted-route posture checks from the Mac/deep-server context as far
  as non-secret access allows.
- Narrow discoverability pointers in existing teaching docs if useful.
- A dual-route preflight report and updated goal log.

## Out Of Scope

- Barry performing the roleplay.
- Contacting Barry, Chief, IT, students, Moodle administrators, or campus staff.
- Moodle upload or any external LMS edit.
- Student contact or student release.
- Public release of the raw-IP, browser-warning, or self-signed hosted route.
- DNS, TLS, certificate, nginx, ShinyProxy, systemd, firewall, Docker service,
  account, credential, token, class workspace, or remote service state changes.
- Installing services, issuing certificates, changing reverse-proxy config, or
  changing authentication configuration.
- App/package code changes.
- Shiny UI/CSS/server changes unless the app is merely run for local rehearsal.
- Science/YAML/model-default changes.
- Practical 2 pedagogy or assessment design.
- KPZ314 material.
- Dependency changes.
- Commit, push, merge, PR, or Goal 036 work.

## Required Deliverables

Use these paths unless a better existing naming pattern is clearly preferable:

- `docs/teaching/woodhen/practical-1-dual-route-roleplay-runbook.md`
- `docs/teaching/woodhen/practical-1-roleplay-feedback-return-template.md`
- `docs/teaching/woodhen/practical-1-dual-route-go-no-go.md`
- `docs/goals/035-practical-1-dual-route-roleplay-preflight/dual-route-preflight-report.md`
- updates to `docs/goals/035-practical-1-dual-route-roleplay-preflight/Log.md`
- narrow pointers, if needed, in:
  - `docs/teaching/woodhen/README.md`
  - `docs/teaching/woodhen/instructor-guide.md`
  - `docs/teaching/shiny/README.md`
  - `docs/teaching/woodhen/practical-1-barry-roleplay-script.md`
  - `docs/teaching/woodhen/practical-1-roleplay-go-no-go.md`

## Route Policy

Treat the two routes differently:

- Local Mac route: controlled rehearsal route for Barry's first roleplay pass.
  It may use localhost or another explicitly controlled local route and should
  be shut down after testing.
- Hosted deep-server route: Barry/instructor-only route for a second roleplay
  pass while IT/TLS is pending. It may document the browser warning and the
  warning-acceptance step for Barry, but must not imply the route is suitable
  for students.
- Student route: no-go until the project has an approved hostname, trusted
  certificate, tested student access path, access model, and recovery path.

## Local Route Rehearsal Requirements

Run a local Practical 1 browser rehearsal that exercises at least:

1. open the route-aware roleplay runbook and current launch/worksheet materials;
2. start baseline as run 1;
3. run carrying capacity;
4. run at least one stochasticity stage;
5. run at least one risk-pressure stage;
6. run one intervention or vortex comparison;
7. use Compare;
8. save comparison CSV and evidence-notes Markdown;
9. inspect the worksheet evidence-recording section;
10. reach Transfer.

Save screenshots and downloads outside the repo, preferably under
`/tmp/rpva-goal035-local-route/`, and record paths in the report.

## Hosted Route Check Requirements

Use read-only, non-secret checks only. Do not repair the route.

Check and report, as far as possible:

- tailnet gateway health;
- campus/public raw-IP gateway health;
- login page reachability;
- trusted versus warning-producing TLS state;
- whether authenticated `/app/practical1` testing is possible without exposing
  or storing credentials;
- what must be tested by Barry from the Windows 11 machine.

If any hosted test requires a secret, token, password, class-account decision,
student-workspace decision, or infrastructure edit, stop that subcheck and
report it as a gate. Do not print, write, screenshot, or commit secret values.

## Validation

Run and report:

```sh
git diff --check
Rscript -e 'source("bootstrap.R")'
Rscript -e 'renv::status(sources = FALSE)'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'
```

Also complete:

- local browser smoke/rehearsal with screenshots and export inspection;
- hosted read-only route posture checks;
- final local port-closed check;
- marker scan over changed/new text;
- secret/private-key-pattern scan over changed/new text, with hits classified;
- stricter assignment/private-key-block scan;
- student-visible route wording check over launch page, worksheet, Moodle
  section text, roleplay script, notes template, dual-route runbook, and
  feedback-return template;
- explicit check that no student identifiers, real credentials, private keys,
  or sensitive service payloads are present.

## Stop Rules

Stop and report to the rPVA orchestrator if:

- the starting branch/base/status differs materially from the expected state;
- the task would require Barry to perform the roleplay now;
- a route check requires a service/config/DNS/TLS/account/credential/student
  workspace change;
- a route check requires exposing or storing a secret;
- the local app flow fails in a way that needs app/package code changes;
- the runbook would direct students to use an untrusted hosted route;
- the hosted route appears to have changed in a way that invalidates the Goal
  025 to 028 evidence and needs a new infrastructure decision;
- any real secret, private key, student identifier, or sensitive service
  payload appears in changed files.

## Reporting

Leave the result uncommitted for orchestrator review.

Report:

- branch, HEAD, and final `git status --short --branch`;
- changed/new files;
- local route evidence paths;
- hosted route posture evidence and caveats;
- runbook/template summary;
- validation commands and results;
- scan hit classification;
- whether the result is ready for Barry's two-stage human roleplay;
- any blockers or recommended next gate.

Wake the rPVA orchestrator thread when complete or blocked.
