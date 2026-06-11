# Goal 028: Campus IT TLS Request Pack

## Objective

Prepare a concise, sendable campus-IT request pack that turns the Goal 027
DNS/certificate blocker into an actionable external decision.

The completed state is a repo-local coordination package containing:

1. a polished email/ticket Barry can send to campus IT;
2. a technical appendix listing the exact hostname, DNS, certificate, nginx,
   renewal, and permission details needed before another implementation goal;
3. a short record explaining why this matters for rPVA now and may also support
   KPZ314 teaching Shiny work later.

This goal is documentation and coordination only. It is not an infrastructure
implementation goal.

## Why This Matters

Goal 027 found no approved class hostname or browser-trusted certificate path
on `deep-server`. The likely institutional lead is the reverse-DNS name
`SET-BIO-2621GL2.zoo.utas.edu.au`, but that name is not yet approved as a
teaching URL and no certificate/ownership path exists on the host.

Barry has also noted that KPZ314 (Fauna of Tasmania) will use an R Shiny GUI
for a practical activity on species distribution models. That means the
hostname/TLS decision should not be framed as a one-off rPVA oddity. It should
ask for a reusable teaching-Shiny pattern, with rPVA Practical 1 as the
immediate tested service and KPZ314 as a likely future consumer.

## Operating Mode

Docs-only coordination pack.

Do not contact campus IT. Do not change live service state.

## Review Surface

The rPVA orchestrator will review:

- Goal 028 `Log.md`;
- `campus-it-tls-request-pack.md`;
- `campus-it-email-draft.md`;
- any narrow update to Shiny/deployment docs;
- final git status and changed-file list.

## Scope

In scope:

- local repository branch/status checks;
- read-only review of Goals 025-027 reports and Shiny deployment docs;
- concise summary of current rPVA staging status;
- concise summary of why raw IP and tailnet routes are not student-suitable;
- explicit inclusion of Barry's KPZ314 note as a future shared teaching-Shiny
  requirement, without implementing or inspecting KPZ314 project materials;
- draft email/ticket text Barry can send to campus IT;
- technical appendix listing exact decisions and evidence needed from IT;
- a checklist of what would unblock a later implementation/proof goal;
- a recommendation for the safest current posture while waiting.

Out of scope:

- contacting Barry, campus IT, or external services;
- reading any KPZ314 repo or project folder;
- changing DNS, certificates, nginx, ShinyProxy, firewall, Docker, service
  state, accounts, credentials, or student workspaces;
- app/package implementation changes;
- tests, science/YAML, Practical 2 mode, assessment design, or dependency
  changes;
- student-facing release;
- committing, pushing, opening a PR, or merging.

## Read First

- `README.md`
- `docs/goals/025-nonstudent-shinyproxy-staging-bootstrap/Goal.md`
- `docs/goals/025-nonstudent-shinyproxy-staging-bootstrap/staging-report.md`
- `docs/goals/026-campus-route-tls-readiness/campus-tls-readiness-report.md`
- `docs/goals/027-trusted-class-hostname-tls-gate/trusted-class-hostname-tls-report.md`
- `docs/teaching/shiny/README.md`
- `docs/teaching/shiny/deep-server-hosting-feasibility.md`
- `docs/teaching/shiny/implementation-roadmap.md`
- `docs/teaching/shiny/platform-options-decision-matrix.md`
- `docs/teaching/shiny/road-test-operations-plan.md`

There is no repo-local `AGENTS.md` in this checkout. Use the repo-local files
above plus Barry's global Mac mini instructions and this Goal 028 packet.

Do not read sibling project folders, Chief of Staff, Goal Composer, or any
KPZ314 project materials.

## Starting State Checks

Before editing beyond this packet, report in `Log.md` and final response:

```sh
pwd
git branch --show-current
git rev-parse --short HEAD
git status --short --branch
```

Expected branch at handoff:

```text
codex/rpva-goal028-campus-it-tls-request-pack
```

Expected starting base:

```text
2843b0d Record trusted class hostname TLS gate blocker
```

Treat any unexpected dirty state as project state. Do not clean, restore, or
overwrite it unless it is clearly your own failed intermediate output.

## Git And Publication Policy

- Work on `codex/rpva-goal028-campus-it-tls-request-pack`.
- Do not commit.
- Do not push.
- Do not open a PR.
- Keep a precise changed-file list in `Log.md` and final response.

The orchestrator will review the uncommitted result before deciding whether a
separate closeout commit/publish goal is needed.

## Required Work

1. Prove current starting state.
   - Verify the action repo branch/status and expected base.
   - Confirm the Goal 027 closeout commit is present.
   - Confirm no unexpected dirty state exists before editing Goal 028 files.

2. Summarize the current technical state.
   - Use only repo-local Goal 025-027 records and Shiny docs.
   - State that rPVA Practical 1 has non-student ShinyProxy staging running on
     `deep-server`.
   - State that campus login is reachable from Barry's campus browser, but the
     current TLS route is not browser-trusted.
   - State that Goal 027 found no approved hostname/certificate path and no
     local certificate tooling or cert store ready for class use.

3. Draft the campus-IT request.
   - Create `campus-it-email-draft.md`.
   - Make it sendable by Barry with minimal editing.
   - Ask for an approved teaching-Shiny hostname or hostname pattern.
   - Ask whether `SET-BIO-2621GL2.zoo.utas.edu.au` is appropriate, or whether a
     better hostname should be created.
   - Ask for DNS owner, certificate owner/issuance mechanism, renewal owner,
     and permission for a narrow reversible nginx TLS edit.
   - Mention that rPVA is the immediate tested service and KPZ314 is a likely
     future R Shiny teaching use case.

4. Build the technical appendix.
   - Create `campus-it-tls-request-pack.md`.
   - Include:
     - current host/IP/name evidence;
     - current certificate problem;
     - what exact answers IT must provide;
     - what implementation work would happen after approval;
     - what will not happen without later approval;
     - current rollback/safety posture.

5. Update Shiny docs narrowly if useful.
   - Add a brief pointer from `docs/teaching/shiny/README.md` to the Goal 028
     coordination pack.
   - Do not turn the README into the full IT request.

6. Validate.
   - Run the validation gates listed below.
   - Confirm no secret values, private keys, credentials, or sensitive config
     payloads appear in changed text.

## Validation Gates

The goal is not complete until these pass, or a blocker is logged with exact
evidence:

```sh
git status --short --branch
git diff --check
Rscript -e 'renv::status(sources = FALSE)'
```

Also complete:

- marker scan over changed/new tracked text;
- secret/private-key-pattern scan over changed/new tracked text;
- manual review that no credential value, private key, or sensitive config
  payload appears in changed files.

Do not run remote service commands unless needed to resolve a documentation
ambiguity; Goal 028 should be answerable from the accepted Goal 025-027
records.

## Stop Rules

Stop and report to the orchestrator if:

- the starting branch/base/status is not as expected;
- repo-local Goal 025-027 records are missing or inconsistent;
- the IT request would require assumptions about KPZ314 beyond Barry's note;
- the work would require contacting IT, changing live infrastructure, reading
  sibling project folders, or exposing secrets/private keys;
- any validation gate fails;
- a real secret or private key appears in repo files or terminal output.

## Expected Final Report

Report:

- final branch, HEAD, and status;
- changed files;
- where the sendable IT draft lives;
- the core IT asks;
- how KPZ314 was framed;
- validation commands and results;
- explicit confirmation that no live infrastructure, student-release, account,
  credential, app, science, or KPZ314 implementation work was done.
