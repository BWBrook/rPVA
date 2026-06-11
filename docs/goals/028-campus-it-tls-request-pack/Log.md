# Log

## 2026-06-11 - Orchestrator Packet Creation

- Goal 027 was accepted, committed, and published to `origin/main` before this
  branch was created.
- Starting base for Goal 028:
  - branch: `codex/rpva-goal028-campus-it-tls-request-pack`;
  - base commit:
    `2843b0d Record trusted class hostname TLS gate blocker`;
  - source: `origin/main`.
- Barry added planning context:
  - KPZ314 (Fauna of Tasmania) will also use an R Shiny GUI for a practical
    activity on species distribution models;
  - the campus IT request should therefore be useful beyond rPVA alone, without
    reading or implementing KPZ314 materials.
- Goal purpose:
  - produce a sendable campus-IT request and technical appendix;
  - convert the Goal 027 DNS/certificate blocker into concrete external
    questions;
  - frame rPVA as the immediate tested service and KPZ314 as a likely future
    teaching-Shiny use case.
- Boundary:
  - docs-only coordination pack;
  - no campus IT contact, live infrastructure changes, DNS changes, certificate
    changes, nginx/ShinyProxy changes, account/credential/student-workspace
    work, app/package changes, science/YAML changes, KPZ314 project work,
    commit, push, merge, or PR work.
- Packet files:
  - `docs/goals/028-campus-it-tls-request-pack/Goal.md`
  - `docs/goals/028-campus-it-tls-request-pack/Plan.md`
  - `docs/goals/028-campus-it-tls-request-pack/Runbook.md`
  - `docs/goals/028-campus-it-tls-request-pack/Log.md`

Status: packet ready for `woodhen`; execution not yet started.

## 2026-06-11 - Action-Agent Execution

Starting state:

- `pwd`: `/Users/bwbrook/git/rPVA`
- branch: `codex/rpva-goal028-campus-it-tls-request-pack`
- `HEAD`: `2843b0d6717d2993a495752371d656d4ef9aea0a`
- `origin/main`: `2843b0d6717d2993a495752371d656d4ef9aea0a`
- `git status --short --branch`:
  - `## codex/rpva-goal028-campus-it-tls-request-pack...origin/main`
  - `?? docs/goals/028-campus-it-tls-request-pack/`

Guard outcome:

- The branch and base match the Goal 028 packet.
- The Goal 027 closeout commit is present at the expected base.
- Goal 025, Goal 026, and Goal 027 accepted records are present.
- The only starting dirty state is the untracked Goal 028 packet directory.
- No sibling project folders, Chief of Staff, Goal Composer, or KPZ314
  materials were read.

Repo-local sources read:

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

Drafted deliverables:

- `docs/goals/028-campus-it-tls-request-pack/campus-it-email-draft.md`
- `docs/goals/028-campus-it-tls-request-pack/campus-it-tls-request-pack.md`
- narrow pointer in `docs/teaching/shiny/README.md`

Key content recorded:

- rPVA Practical 1 is the immediate tested Shiny service.
- KPZ314 is framed only as future shared teaching-Shiny context, using Barry's
  supplied note and no KPZ314 project materials.
- The current service remains non-student staging on `deep-server`.
- Barry's campus-side browser can reach the ShinyProxy login page at the raw
  IP route, but the browser still does not trust the HTTPS route.
- Goal 027 remains blocked on external hostname, DNS, certificate issuance,
  renewal, nginx/TLS ownership, and access-policy decisions.

No live infrastructure, DNS, certificate, nginx, ShinyProxy, firewall, Docker,
service, account, credential, student workspace, app/package, science/YAML,
Practical 2, assessment, dependency, commit, push, merge, PR, or KPZ314
implementation work was done.

Changed/new repo-local files:

- `docs/teaching/shiny/README.md`
- `docs/goals/028-campus-it-tls-request-pack/Goal.md`
- `docs/goals/028-campus-it-tls-request-pack/Plan.md`
- `docs/goals/028-campus-it-tls-request-pack/Runbook.md`
- `docs/goals/028-campus-it-tls-request-pack/Log.md`
- `docs/goals/028-campus-it-tls-request-pack/campus-it-email-draft.md`
- `docs/goals/028-campus-it-tls-request-pack/campus-it-tls-request-pack.md`

Validation:

- `git status --short --branch`: expected uncommitted review state with
  `docs/teaching/shiny/README.md` modified and the Goal 028 packet directory
  untracked.
- `git diff --check`: passed.
- `Rscript -e 'renv::status(sources = FALSE)'`: passed; no issues found.
- marker scan over changed/untracked text: no hits.
- secret/private-key-pattern scan over changed/untracked text: hits were only
  policy wording, command text, class-account/token boundary wording,
  credential/path-reference wording, and private-key safety wording; no secret
  values or private-key material found.
- stricter scan for assignment-like secret values and private-key blocks:
  no hits.
- manual email review: sendable as a campus IT request; no bracketed blanks,
  no secret values, no private-key material, no student identifiers, and no
  request for IT to debug R/Shiny internals.

Recommended next gate:

- Barry or the rPVA orchestrator can send the email draft to campus IT.
- A later implementation/proof goal should start only after IT provides the
  approved hostname, DNS target, certificate issuance/path, renewal owner,
  nginx/TLS ownership decision, and access-policy decision.
