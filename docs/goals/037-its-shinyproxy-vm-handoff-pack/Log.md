# Log

## 2026-06-24 - Orchestrator Packet Creation

- Goal 036 Checkpoint A was accepted, committed, and published before this
  branch was created.
- `origin/main` had also advanced with:
  `70dca13 Refine campus TLS request with UTAS PKI evidence`.
- Starting base for Goal 037:
  - branch: `codex/rpva-goal037-its-shinyproxy-vm-handoff`;
  - base commit:
    `70dca13 Refine campus TLS request with UTAS PKI evidence`;
  - source: current `origin/main`.
- Barry reported the latest ITS position:
  - ITS is not happy using `deep-server` for students;
  - ITS can provide a dedicated RedHat 9 `x86_64/amd64` VM running ShinyProxy;
  - ITS will manage TLS and DNS registration;
  - authentication is undecided;
  - a staging URL can be provided via dev/test server or namespace;
  - VM will use rootless Docker;
  - Barry can have full access to the specific service user running ShinyProxy
    and Docker, but not host root;
  - ITS will monitor, back up, and patch the underlying server;
  - Barry/rPVA owns application stack maintenance/support, with ITS help during
    setup;
  - ITS can create Gitea access groups and a dedicated team/project space.
- Barry accepted `ecology-teaching-shiny` as the preferred Gitea project/team
  name.
- Goal purpose:
  - prepare a sanitized ITS handoff pack;
  - update deployment docs/templates for the new ITS VM and Gitea registry
    path;
  - keep `deep-server` as development/staging reference rather than student
    hosting target;
  - define KPZ308/rPVA Practical 1 as the first app and KPZ314 SDM practical
    as future placeholder only;
  - preserve app/science behavior and avoid deployment/state changes.
- Boundary:
  - docs/templates/static validation only;
  - no ITS contact, registry push, Gitea project creation, VM login, image push,
    live service change, credential/account/student-workspace work, app/package
    code change, Shiny UI/CSS/server change, science/YAML change, Practical 2,
    KPZ314 implementation, assessment redesign, student release, commit, push,
    merge, PR, or Goal 038 work.
- Packet files:
  - `docs/goals/037-its-shinyproxy-vm-handoff-pack/Goal.md`
  - `docs/goals/037-its-shinyproxy-vm-handoff-pack/Plan.md`
  - `docs/goals/037-its-shinyproxy-vm-handoff-pack/Runbook.md`
  - `docs/goals/037-its-shinyproxy-vm-handoff-pack/Log.md`

Status: packet ready for `woodhen`; execution not yet started.

## 2026-06-24 - Start Guard And Source Review

- Start guard matched the packet:
  - working directory: `/Users/bwbrook/git/rPVA`;
  - branch: `codex/rpva-goal037-its-shinyproxy-vm-handoff`;
  - HEAD: `70dca13ce4934dfbd68072cfad41ff27c81cd3a2`
    (`70dca13 Refine campus TLS request with UTAS PKI evidence`);
  - dirty state: untracked Goal 037 packet directory only.
- Read the Goal 037 packet:
  - `Goal.md`
  - `Plan.md`
  - `Runbook.md`
  - `Log.md`
- Reviewed the Practical 1 ShinyProxy scaffold:
  - `deploy/shinyproxy/practical1/README.md`
  - `deploy/shinyproxy/practical1/Dockerfile.template`
  - `deploy/shinyproxy/practical1/dockerignore.template`
  - `deploy/shinyproxy/practical1/application.example.yml`
  - `deploy/shinyproxy/practical1/staging-gate-checklist.md`
  - `deploy/shinyproxy/practical1/validate-scaffold.sh`
- Reviewed hosted-route and handoff context from Goals 025, 026, 027, 028,
  035, and 036, plus `docs/teaching/shiny/README.md`.
- Key interpretation:
  - `deep-server` remains useful as prior non-student staging evidence;
  - ITS VM/rootless-Docker/Gitea is now the student-hosting direction;
  - Goal 037 must stay docs/templates/static-validation only.

## 2026-06-24 - Handoff Pack Created

- Added ITS handoff materials:
  - `deploy/shinyproxy/practical1/its-vm-handoff.md`
  - `deploy/shinyproxy/practical1/application.its-staging.example.yml`
  - `deploy/shinyproxy/practical1/gitea-registry-runbook.md`
  - `docs/goals/037-its-shinyproxy-vm-handoff-pack/mark-reply-draft.md`
  - `docs/goals/037-its-shinyproxy-vm-handoff-pack/its-handoff-report.md`
- Added narrow pointers in:
  - `deploy/shinyproxy/practical1/README.md`
  - `deploy/shinyproxy/practical1/staging-gate-checklist.md`
  - `docs/teaching/shiny/README.md`
- Encoded the requested ITS facts:
  - RedHat 9, `x86_64/amd64`;
  - rootless Docker under a dedicated service user;
  - ITS-managed TLS/DNS;
  - undecided auth at ShinyProxy/ITS layer where possible;
  - staging through dev/test server or namespace;
  - Barry may have service-user access but not VM root;
  - ITS owns VM monitoring, backup, and patching;
  - Barry/rPVA owns application-stack maintenance and class-day app support;
  - Gitea project/team recommendation `ecology-teaching-shiny`;
  - first app `kpz308-rpva-practical1`;
  - future app identity only `kpz314-sdm-practical`.
- Created optional sanitized review bundle:
  - `/tmp/rpva-goal037-its-handoff/`
  - includes handoff docs/templates plus `SHA256SUMS.txt`;
  - excludes image layers, credentials, registry tokens, student identifiers,
    private keys, and sensitive service payloads.

Status: handoff materials ready for final validation and scans.

## 2026-06-24 - Validation

- Static validation passed:
  - `git diff --check`
  - `bash -n deploy/shinyproxy/practical1/validate-scaffold.sh`
  - `bash deploy/shinyproxy/practical1/validate-scaffold.sh`
  - Ruby YAML parse for `deploy/shinyproxy/practical1/application.example.yml`
  - Ruby YAML parse for
    `deploy/shinyproxy/practical1/application.its-staging.example.yml`
  - `Rscript -e 'renv::status(sources = FALSE)'`
- Focused teaching API and Practical 1 Shiny tests were not run because the
  goal changed deployment docs/templates and teaching-platform pointers only;
  no package files, app-facing launch guidance, Shiny code, tests, or science
  settings were changed.
- Marker scan over changed/new text:
  - hits were limited to existing packet/README wording about placeholder
    values and validation marker policy;
  - no action-marker instruction requiring follow-up work was found.
- Secret/private-key-pattern scan over changed/new text:
  - hits were limited to policy wording, scan-command text, credential/token/
    private-key safety wording, and the non-live ITS YAML angle-bracket secret
    source examples;
  - no real secret values, private keys, registry tokens, student identifiers,
    or sensitive service payloads were found.
- Stricter assignment/private-key-block scan:
  - two hits were the ITS YAML non-live simple-auth stand-ins:
    `password: "<ITS_APPROVED_SECRET_SOURCE_OR_HASH>"`;
  - no real assigned secret or private-key block was found.
- Route/student-release wording scan:
  - hits were limited to existing planning text about the old not-secure/
    self-signed `deep-server` posture, scan-command text, and the new handoff
    boundary saying not to publish a route to students until a later gate;
  - no student-facing instruction to use an unapproved route was found.
- Manual review confirmed:
  - no real credentials, private keys, registry tokens, student identifiers,
    or sensitive service payloads in repo changes or the `/tmp` bundle;
  - no ITS contact, Gitea/registry access, VM login, image build/export, or
    live service/state change.

Status: Goal 037 deliverables are ready for orchestrator review and
closeout/publication if accepted.
