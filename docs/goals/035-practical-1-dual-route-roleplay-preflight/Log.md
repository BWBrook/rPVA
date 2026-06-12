# Log

## 2026-06-12 - Orchestrator Packet Creation

- Goal 034 was accepted, committed, and published to `origin/main`.
- Starting base for Goal 035:
  - branch: `codex/rpva-goal035-dual-route-roleplay-preflight`;
  - base commit:
    `dfe4be4 Add Practical 1 roleplay readiness pack`;
  - source: `origin/main`.
- Barry approved a two-route path while IT/TLS remains pending:
  - first, test the Practical 1 experience through a local route controlled on
    macOS;
  - second, test the hosted deep-server route from Barry's Windows 11 machine,
    accepting the current browser warning for Barry/instructor testing only;
  - later, if IT/TLS is still pending after Practical 1 is tested and amended,
    move forward into Practical 2 pedagogy and assessment planning.
- Goal purpose:
  - convert that strategy into a concrete preflight and runbook;
  - verify the local Mac route before asking Barry to spend human-test time;
  - document hosted deep-server readiness and the remaining Windows 11 human
    checks;
  - keep student release blocked until the trusted-route gate is passed.
- Boundary:
  - goal packet, route-aware docs, local browser rehearsal, read-only hosted
    route posture checks, validation, and report only;
  - no Barry roleplay, student contact, Moodle state, app/package code,
    Shiny UI/CSS/server edits, science/YAML/model defaults, Practical 2,
    assessment redesign, KPZ314, dependency, DNS/TLS/nginx/ShinyProxy/systemd/
    firewall/Docker/account/credential/student-workspace changes, public or
    student release, remote service edits, commit, push, merge, PR, or Goal 036
    work.
- Packet files:
  - `docs/goals/035-practical-1-dual-route-roleplay-preflight/Goal.md`
  - `docs/goals/035-practical-1-dual-route-roleplay-preflight/Plan.md`
  - `docs/goals/035-practical-1-dual-route-roleplay-preflight/Runbook.md`
  - `docs/goals/035-practical-1-dual-route-roleplay-preflight/Log.md`

Status: packet ready for `woodhen`; execution not yet started.

## 2026-06-12 - Execution Start

- Start guard matched the packet:
  - working directory: `/Users/bwbrook/git/rPVA`;
  - branch: `codex/rpva-goal035-dual-route-roleplay-preflight`;
  - HEAD: `dfe4be4079d049b8bdbfc544c1043191a048446f`;
  - status: only `docs/goals/035-practical-1-dual-route-roleplay-preflight/`
    was untracked.
- Read the packet files:
  - `Goal.md`
  - `Plan.md`
  - `Runbook.md`
  - `Log.md`
- Read current teaching and hosted-route source files listed in `Runbook.md`,
  including the launch page, worksheet, Barry roleplay materials, Moodle-ready
  bundle, Goal 025 to Goal 028 route evidence, Goal 033/034 reports, and the
  Practical 1 app file for control/export labels.
- Created first-pass route-aware roleplay materials:
  - `docs/teaching/woodhen/practical-1-dual-route-roleplay-runbook.md`
  - `docs/teaching/woodhen/practical-1-roleplay-feedback-return-template.md`
  - `docs/teaching/woodhen/practical-1-dual-route-go-no-go.md`
- Added narrow discoverability pointers in the existing teaching docs.

Status: route-aware materials drafted; local route rehearsal and hosted
read-only posture checks still pending.

## 2026-06-12 - Local And Hosted Preflight

- Local route rehearsal used:
  `http://127.0.0.1:3901/`.
- Evidence directory:
  `/tmp/rpva-goal035-local-route/`.
- Browser path exercised:
  - Start page;
  - `Start baseline`;
  - `Ceiling carrying capacity`;
  - `Environmental stochasticity`;
  - `Catastrophe`;
  - `Simple intervention`;
  - Compare;
  - comparison CSV download;
  - evidence-notes Markdown download;
  - worksheet evidence-recording section check;
  - Transfer.
- Local evidence files:
  - `/tmp/rpva-goal035-local-route/screenshots/01-start.png`
  - `/tmp/rpva-goal035-local-route/screenshots/02-concept-lab-after-runs.png`
  - `/tmp/rpva-goal035-local-route/screenshots/03-compare-export.png`
  - `/tmp/rpva-goal035-local-route/screenshots/04-transfer.png`
  - `/tmp/rpva-goal035-local-route/downloads/practical1-comparison-20260612.csv`
  - `/tmp/rpva-goal035-local-route/downloads/practical1-evidence-notes-20260612.md`
- Export inspection:
  - CSV leading columns matched the accepted evidence-export shape;
  - CSV contained five data rows, with baseline as run 1;
  - evidence-notes Markdown contained five runs and retained the
    evidence-not-answer framing.
- Browser console classification:
  - one non-blocking `favicon.ico` 404;
  - no app JavaScript failure observed.
- Local cleanup:
  - Playwright browser closed;
  - local Shiny process stopped;
  - `lsof -nP -iTCP:3901 -sTCP:LISTEN` returned no listener.
- Hosted read-only posture:
  - tailnet health returned HTTP 200 with `-k`;
  - normal TLS verification still failed as self-signed/untrusted;
  - tailnet login returned HTTP 200 without authentication;
  - tailnet app path without authentication redirected to login;
  - Mac-origin campus/raw-IP health and login timed out after 10 seconds;
  - tailnet certificate metadata remained `CN=deep-server`, self-signed, with
    SAN `DNS:deep-server`;
  - read-only `deep-server-ts` posture found ShinyProxy active, nginx active,
    remote localhost gateway health HTTP 200, and remote localhost ShinyProxy
    login HTTP 200.
- Hosted authenticated app testing was not attempted because it requires
  out-of-band non-student access details and Barry's Windows 11 pass.
- R validation run:
  - `Rscript -e 'source("bootstrap.R")'`: passed;
  - `Rscript -e 'renv::status(sources = FALSE)'`: passed with no issues;
  - `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'`:
    passed;
  - `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'`:
    passed.
- Report written:
  `docs/goals/035-practical-1-dual-route-roleplay-preflight/dual-route-preflight-report.md`.

Status: deliverables and route evidence are in place; final patch hygiene and
scans still pending.

## 2026-06-12 - Final Validation

- `git diff --check`: passed.
- Marker scan over changed/new text: no hits.
- Secret/private-key-pattern scan over changed/new text: hits classified as
  Goal 035 policy wording, scan-command text, class-account/token boundary
  wording, credential safety wording, and existing teaching-Shiny boundary
  wording only; no secret values, private keys, student identifiers, or
  sensitive service payloads were found.
- Stricter assignment/private-key-block scan: no hits.
- Student-visible route wording check over:
  - `docs/teaching/woodhen/practical-1-student-launch-page.md`;
  - `docs/teaching/woodhen/practical-1-mission-worksheet.md`;
  - `docs/teaching/woodhen/practical-1-moodle-ready-bundle/moodle-section-text.md`;
  - `docs/teaching/woodhen/practical-1-barry-roleplay-script.md`;
  - `docs/teaching/woodhen/practical-1-roleplay-notes-template.md`;
  - `docs/teaching/woodhen/practical-1-dual-route-roleplay-runbook.md`;
  - `docs/teaching/woodhen/practical-1-roleplay-feedback-return-template.md`;
  returned no hits.

Readiness judgement:

- Stage A local Mac route: green for orchestrator review.
- Stage B hosted deep-server route: ready for a future Barry Windows 11
  instructor-only warning-accepted roleplay, with route/access details supplied
  out of band.
- Hosted student URL release: no-go until the trusted-route/campus-IT gate
  separately passes.

Status: Goal 035 deliverables complete and left uncommitted for orchestrator
review.
