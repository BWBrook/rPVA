# Goal 043: ITS Dev/Prod Validation Canonicalization

## Objective

Review the completed `stochastic` Goal 042 report branch and adopt the durable
ITS dev/prod validation and build/deploy lessons into the rPVA repo without
merging raw evidence wholesale.

## Source Evidence

- Base for this curation pass:
  `15643e1bdd9714715bffda3b354c969c19667815`
  (`Add stochastic ITS image publication task pack`).
- `stochastic` report branch:
  `origin/codex/rpva-stochastic-goal042-image-publication`.
- Report branch head reviewed:
  `70698cd8a8f7b8f08efc00d0fafe666328145cdc`
  (`Record ITS dev/prod validation handoff`).
- Main report path on the report branch:
  `docs/ops/stochastic/outbox/evidence/goal042/its-dev-prod-validation-report.md`.
- Current report path on the report branch:
  `docs/ops/stochastic/outbox/current-report.md`.

## Deliverables

- Adopt the bounded Dockerfile template `listenv` restore fix.
- Correct current operator/sendable Docker image references to lowercase
  `git.its.utas.edu.au/utas/kpz308-rpva-practical:<TAG>`.
- Preserve uppercase `UTAS/kpz308-rpva-practical` only for the Gitea source
  repository owner/path and clone URL.
- Record dev/prod browser smoke, export-shape, staff-access, capacity, access
  group, and promotion-policy outcomes in a compact canonical closeout report.
- Reset `docs/ops/stochastic/inbox/current-task.md` to a waiting state.
- Keep raw `stochastic` evidence on the report branch unless a small
  non-secret pointer is useful on `main`.

## Boundaries

- No WSL, ITS Gitea, Docker registry, ITS VM/dev/prod host, SSH, PuTTY, RDS,
  SSO, DNS/TLS, Docker daemon/service, or live ShinyProxy access.
- No image build, pull, push, login, service restart, compose command, or live
  configuration change.
- No contact with Barry, Mark, ITS, Chief, students, or Moodle admins.
- No app/package/Shiny UI/server/CSS behavior changes.
- No science/YAML/model default, Practical 2 implementation, KPZ314
  implementation, assessment, Moodle, dependency, student-release, PR, or Goal
  044 work.

## Acceptance Checks

- Static diff hygiene.
- ShinyProxy YAML parse and scaffold validation.
- `renv::status(sources = FALSE)`.
- Text searches proving lowercase Docker image path usage on current
  operator/sendable surfaces and correct separation from the uppercase source
  repo path.
- Marker and secret/private-key/token/student-identifier scans over changed
  text.
- Manual review that raw bulky or sensitive report-branch evidence was not
  copied into `main`.
