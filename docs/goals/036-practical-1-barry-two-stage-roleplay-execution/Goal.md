# Goal 036: Practical 1 Barry Two-Stage Roleplay Execution

## Objective

Coordinate the first real Barry-as-student Practical 1 roleplay checkpoint.

This goal turns the Goal 035 dual-route preflight into a human-ready session:

1. Stage A: Barry roleplays a student on the controlled local Mac route.
2. Stage B: Barry roleplays the same student path on the hosted deep-server
   route from his Windows 11 machine, accepting the current browser warning for
   this instructor-only test while IT/TLS remains pending.

The goal is not complete until Barry's notes can be turned into a triaged
recommendation set. However, the first execution pass should stop at a clear
human-action gate: prepare the session package, verify the routes as far as
possible, and wake the orchestrator with exact instructions for Barry.

## Context

Goal 035 established that:

- the local Mac route is green for a controlled roleplay;
- the hosted deep-server route is reachable through the tailnet and protected
  by login, but still uses a self-signed/untrusted certificate;
- Barry previously confirmed the campus/raw-IP route reaches a ShinyProxy
  sign-in page from inside the University network, with browser trust warnings;
- the hosted warning route is acceptable for Barry/instructor testing only;
- student release remains no-go until the trusted-route/campus-IT gate passes.

Barry has approved moving forward without waiting for IT/TLS. The teaching
product should keep advancing while the TLS problem remains a separate
infrastructure lane.

## Success Criteria

Checkpoint A is complete when `woodhen` has:

1. Confirmed the repo branch/base/status and read the Goal 036 packet plus the
   Goal 035 dual-route materials.
2. Prepared a concise roleplay session brief for the orchestrator/Barry that:
   - keeps Barry in student mode;
   - separates operator setup from student action;
   - gives the exact Stage A local route instructions;
   - gives Stage B warning-route instructions without representing them as
     student-ready;
   - names the notes and evidence Barry should return.
3. Reconfirmed the local app can launch and the Stage A path still works, then
   stopped the app and confirmed no listener remains.
4. Reconfirmed hosted route posture with read-only, non-secret checks only.
5. Produced a roleplay execution report that states whether Barry can now be
   asked to perform:
   - Stage A only;
   - Stage A then Stage B;
   - or neither, because a blocker must be fixed first.
6. Left all changes uncommitted for orchestrator review.

Checkpoint B is complete only after the orchestrator supplies Barry's returned
notes/evidence in a later message. At that point `woodhen` should triage the
human feedback into:

- must-fix before students;
- should-fix if time permits;
- acceptable friction;
- infrastructure/TLS/access-only issues;
- recommended next goal.

Do **not** start Checkpoint B without a separate orchestrator message supplying
Barry's roleplay notes or evidence.

## In Scope

- Review of:
  - Goal 035 packet and report;
  - dual-route roleplay runbook;
  - Barry roleplay script;
  - roleplay notes and feedback templates;
  - student launch page and mission worksheet;
  - hosted-route evidence from Goals 025 to 028.
- Creation of a human-ready roleplay session brief.
- Creation of a roleplay execution report.
- Optional creation of a post-roleplay triage template, if useful.
- Local route launch/smoke check and shutdown.
- Read-only hosted route posture checks.
- Narrow pointer updates in existing roleplay docs if useful.

## Out Of Scope

- Barry's actual roleplay during Checkpoint A.
- Contacting Barry, Chief, IT, students, Moodle administrators, or campus staff.
- Moodle upload or any LMS edit.
- Student contact or student release.
- DNS, TLS, certificate, nginx, ShinyProxy, systemd, firewall, Docker service,
  account, credential, token, class workspace, or remote service state changes.
- Installing services, issuing certificates, changing reverse-proxy config, or
  changing authentication configuration.
- Printing, committing, screenshotting, or otherwise recording credentials or
  secret values.
- App/package code changes.
- Shiny UI/CSS/server changes.
- Science/YAML/model-default changes.
- Practical 2 pedagogy or assessment design.
- KPZ314 material.
- Dependency changes.
- Commit, push, merge, PR, or Goal 037 work.

## Required Deliverables

Use these paths unless a better existing naming pattern is clearly preferable:

- `docs/teaching/woodhen/practical-1-barry-roleplay-session-brief.md`
- `docs/goals/036-practical-1-barry-two-stage-roleplay-execution/roleplay-execution-report.md`
- `docs/goals/036-practical-1-barry-two-stage-roleplay-execution/Log.md`
- optional:
  - `docs/goals/036-practical-1-barry-two-stage-roleplay-execution/post-roleplay-triage-template.md`
- narrow pointers, if useful, in:
  - `docs/teaching/woodhen/README.md`
  - `docs/teaching/woodhen/instructor-guide.md`
  - `docs/teaching/woodhen/practical-1-dual-route-roleplay-runbook.md`
  - `docs/teaching/woodhen/practical-1-barry-roleplay-script.md`

## Session Brief Requirements

The session brief should be written for the orchestrator and Barry, not for
students. It should:

- separate "operator starts/stops the app route" from "Barry acts as a
  student";
- tell Barry what to open before Stage A;
- tell Barry what to save during Stage A;
- tell Barry what to return after Stage A;
- explain that Stage B is instructor-only and warning-accepted;
- state that Stage B should be run only if exact route/access details are
  supplied out of band;
- tell Barry not to debug app or infrastructure during either stage;
- keep student release explicitly no-go.

Do not place real credentials in this brief.

## Route Requirements

Stage A:

- use a controlled local route, preferably `http://127.0.0.1:3902/`;
- launch and test it before asking Barry to use it;
- stop it after the proof pass and confirm no listener remains.

Stage B:

- use read-only checks only during Checkpoint A;
- document the current hosted warning-route posture;
- do not authenticate unless an already-authorised non-student flow is
  available without printing or storing secrets;
- if access details are needed, record that they must be supplied out of band
  for Barry's Windows 11 pass.

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
  section text, roleplay docs, session brief, and any triage template;
- explicit check that no student identifiers, real credentials, private keys,
  or sensitive service payloads are present.

## Stop Rules

Stop and report to the rPVA orchestrator if:

- the starting branch/base/status differs materially from the expected state;
- the local app cannot be launched or the Stage A path fails in a way that
  would waste Barry's roleplay time;
- the hosted route has changed in a way that invalidates the Goal 035 posture
  and needs a new infrastructure decision;
- any check requires a service/config/DNS/TLS/account/credential/student
  workspace change;
- any check requires exposing or storing a secret;
- the session brief would direct students to use the warning route;
- any real secret, private key, student identifier, or sensitive service
  payload appears in changed files.

## Reporting

Leave the Checkpoint A result uncommitted for orchestrator review.

Report:

- branch, HEAD, and final `git status --short --branch`;
- changed/new files;
- session brief summary;
- local route proof evidence;
- hosted route posture evidence and caveats;
- validation commands and results;
- scan hit classification;
- whether Barry can now perform Stage A, Stage B, both, or neither;
- exact human-action gate for the orchestrator;
- any blockers or recommended next gate.

Wake the rPVA orchestrator thread when Checkpoint A is complete or blocked.
