# Log

## 2026-06-12 - Orchestrator Packet Creation

- Goal 035 was accepted, committed, and published to `origin/main`.
- Starting base for Goal 036:
  - branch: `codex/rpva-goal036-barry-two-stage-roleplay`;
  - base commit:
    `93601e7 Add Practical 1 dual-route roleplay preflight`;
  - source: `origin/main`.
- Barry approved moving into the actual two-stage Practical 1 roleplay path:
  - Stage A on a controlled local Mac route;
  - Stage B on the hosted deep-server route from Windows 11, accepting the
    browser warning for Barry/instructor testing only;
  - keep TLS/IT as a separate infrastructure lane;
  - keep student release no-go until the trusted-route gate passes.
- Goal purpose:
  - prepare a human-ready roleplay handoff;
  - verify the local route is worth Barry's time;
  - reconfirm hosted route posture without changing infrastructure;
  - stop at a clear human-action gate for Barry;
  - later, after Barry returns notes, triage the findings into next work.
- Boundary:
  - Goal 036 packet, session brief, local route proof, read-only hosted posture
    checks, report, and validation only for Checkpoint A;
  - no Barry roleplay during Checkpoint A, student contact, Moodle state,
    app/package code, Shiny UI/CSS/server edits, science/YAML/model defaults,
    Practical 2, assessment redesign, KPZ314, dependency, DNS/TLS/nginx/
    ShinyProxy/systemd/firewall/Docker/account/credential/student-workspace
    changes, public or student release, remote service edits, commit, push,
    merge, PR, or Goal 037 work.
- Packet files:
  - `docs/goals/036-practical-1-barry-two-stage-roleplay-execution/Goal.md`
  - `docs/goals/036-practical-1-barry-two-stage-roleplay-execution/Plan.md`
  - `docs/goals/036-practical-1-barry-two-stage-roleplay-execution/Runbook.md`
  - `docs/goals/036-practical-1-barry-two-stage-roleplay-execution/Log.md`

Status: packet ready for `woodhen`; Checkpoint A execution not yet started.

## 2026-06-12 - Checkpoint A Start Guard And Source Review

- Start guard matched the packet:
  - working directory: `/Users/bwbrook/git/rPVA`;
  - branch: `codex/rpva-goal036-barry-two-stage-roleplay`;
  - HEAD: `93601e74dfdeb0ebe5a77de6cacd0025cf9d55a2`
    (`93601e7 Add Practical 1 dual-route roleplay preflight`);
  - dirty state: untracked Goal 036 packet directory only.
- Read the Goal 036 packet:
  - `Goal.md`
  - `Plan.md`
  - `Runbook.md`
  - `Log.md`
- Reviewed the Goal 035 dual-route materials, Practical 1 roleplay materials,
  student launch/worksheet/Moodle text, hosted-route evidence from Goals
  025-028, and the Practical 1 Shiny app surface needed for the Checkpoint A
  proof pass.
- Added the Checkpoint A human handoff docs:
  - `docs/teaching/woodhen/practical-1-barry-roleplay-session-brief.md`
  - `docs/goals/036-practical-1-barry-two-stage-roleplay-execution/post-roleplay-triage-template.md`
- Narrowly updated roleplay discoverability and local-route wording so the
  operator starts/stops the local route and Barry can remain in student mode.

Status: ready to run the local Stage A proof and hosted read-only posture
checks.

## 2026-06-12 - Checkpoint A Route Proof And Hosted Posture

- Local Stage A proof used:
  - app route: `http://127.0.0.1:3902/`;
  - command:
    `Rscript -e 'source("bootstrap.R"); run_practical1_shiny(host = "127.0.0.1", port = 3902, launch.browser = FALSE)'`;
  - browser evidence directory: `/tmp/rpva-goal036-stage-a/`.
- Browser path exercised:
  - `Start baseline`;
  - `Ceiling carrying capacity`;
  - `Environmental stochasticity`;
  - `Catastrophe`;
  - `Simple intervention`;
  - Compare;
  - comparison CSV download;
  - evidence-notes Markdown download;
  - worksheet evidence section check;
  - Transfer.
- Stage A evidence:
  - screenshots:
    - `/tmp/rpva-goal036-stage-a/screenshots/01-start.png`
    - `/tmp/rpva-goal036-stage-a/screenshots/02-concept-lab-after-runs.png`
    - `/tmp/rpva-goal036-stage-a/screenshots/03-compare-export.png`
    - `/tmp/rpva-goal036-stage-a/screenshots/04-transfer.png`
  - downloads:
    - `/tmp/rpva-goal036-stage-a/downloads/practical1-comparison-20260612.csv`
    - `/tmp/rpva-goal036-stage-a/downloads/practical1-evidence-notes-20260612.md`
  - CSV shape: header plus 5 data rows; baseline is run 1; later rows are
    carrying capacity, environmental stochasticity, catastrophe, and simple
    intervention.
  - Evidence-notes framing retained: "This export is evidence, not an answer."
  - Browser console: one non-blocking `favicon.ico` 404 only.
- Shutdown:
  - browser closed;
  - local Shiny process stopped;
  - `lsof -nP -iTCP:3902 -sTCP:LISTEN` returned no listener.
- Hosted Stage B read-only posture:
  - tailnet health with `-k`: HTTP 200, `deep-server app gateway ok`;
  - tailnet health with normal TLS verification: curl SSL verify result 18,
    HTTP 000, self-signed certificate;
  - tailnet login without authentication: HTTP 200;
  - tailnet app path without authentication: HTTP 302 to `/login`;
  - campus/raw-IP health from Mac mini: timed out, HTTP 000;
  - campus/raw-IP login from Mac mini: timed out, HTTP 000;
  - tailnet certificate metadata: subject `CN=deep-server`; issuer
    `CN=deep-server`; SAN `DNS:deep-server`;
  - campus/raw-IP certificate metadata from Mac mini: no certificate captured
    before timeout.
- Optional remote read-only posture via `deep-server-ts`:
  - ShinyProxy active;
  - nginx active;
  - remote localhost gateway health HTTP 200;
  - remote localhost ShinyProxy login HTTP 200.
- No login/app response bodies, credentials, private keys, secrets, or
  sensitive service payloads were written to repo files or reports.

Status: Stage A is worth Barry's time; Stage B remains instructor-only and
requires exact hosted route and access details out of band.

## 2026-06-12 - Checkpoint A Validation

- Required R validation passed:
  - `Rscript -e 'source("bootstrap.R")'`
  - `Rscript -e 'renv::status(sources = FALSE)'`
  - `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'`
  - `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'`
- Patch hygiene and safety scans after report/log creation:
  - `git diff --check`: passed;
  - marker scan over changed/new text: no hits;
  - secret/private-key-pattern scan over changed/new text: hits were limited
    to Goal 036 policy wording, scan-command text, credential/private-key
    safety wording, and session brief stop-rule wording; no secret values,
    private keys, student identifiers, or sensitive service payloads were
    found;
  - stricter assignment/private-key-block scan: no hits;
  - route wording check: no route/warning hits in the student launch page,
    mission worksheet, or Moodle section text; hits were limited to
    instructor/orchestrator-facing roleplay materials.
- Boundaries observed:
  - no Barry roleplay, student contact, Moodle state, service state, remote
    service-state change, DNS/TLS/certificate/nginx/ShinyProxy/systemd/
    firewall/Docker/account/credential/token/class-workspace change,
    app/package code, Shiny UI/CSS/server code, science/YAML/model-default,
    dependency, Practical 2, assessment, KPZ314, student-release, commit, push,
    merge, PR, or Goal 037 work.

Status: Checkpoint A is complete for orchestrator review. Human-action gate:
Barry can perform Stage A; Barry can perform Stage B only if exact hosted route
and access details are supplied out of band with instructor-only warning-route
framing. Barry should return the completed notes template, feedback-return
template, evidence folder path, CSV/Markdown evidence filenames for each stage
run, any blocker screenshots, one `GO`/`REVISE`/`STOP` recommendation, and one
sentence on hosted student-release no-go for later Checkpoint B triage.
