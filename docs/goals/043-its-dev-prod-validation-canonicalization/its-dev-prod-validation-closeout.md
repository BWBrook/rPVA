# ITS Dev/Prod Validation Canonical Closeout

## Summary

The `stochastic` Goal 042 report branch validates the ITS Gitea image
publication path and the ITS dev/prod ShinyProxy deployment path for the KPZ308
rPVA Practical app. This Goal 043 closeout adopts the durable repo-local
lessons while leaving raw evidence on the report branch.

Infrastructure and deployment readiness for continuing container content work:

```text
PASS
```

Known infrastructure blockers to continuing KPZ308 container content work:

```text
None recorded in the reviewed report branch.
```

Student-facing release remains a separate teaching-release gate. After Goal
043, that gate is about final teaching-channel link text, optional final staff
smoke, fallback/rollback readiness, class-day support path, cleanup/retention,
and decision timing before first planned student app contact on `2026-07-20`,
not about re-proving the already-passed staff/tester infrastructure, auth, and
capacity checks.

## Source Evidence

Reviewed report branch:

```text
origin/codex/rpva-stochastic-goal042-image-publication
```

Reviewed branch head:

```text
70698cd8a8f7b8f08efc00d0fafe666328145cdc
```

Primary report path on that branch:

```text
docs/ops/stochastic/outbox/evidence/goal042/its-dev-prod-validation-report.md
```

Raw build/push/smoke evidence remains on the report branch. It was not copied
wholesale to `main`.

## Validated Image

- Image publication succeeded.
- Validated image:
  `git.its.utas.edu.au/utas/kpz308-rpva-practical:dev-20260626-9524304fb748`
- Digest:
  `sha256:7aa013152b226d5ba3fcc34d31051fe049dd0f34c2c7e0187de83580523f4340`
- Built source commit:
  `9524304fb74805baad7672f81f219b8455a4aac8`
- Docker image namespace is lowercase `utas` because Docker rejected uppercase
  `UTAS`.
- The ITS Gitea source repository remains:
  `https://git.its.utas.edu.au/UTAS/kpz308-rpva-practical.git`.

## Build Lesson Adopted

The report branch used one authorized Dockerfile template fix: preinstall the
locked `listenv` 0.10.1 source package into the active `renv` library before
`renv::restore()`.

Goal 043 adopts that Dockerfile template fix because it mirrors the previous
R CI workaround for the known `renv` restore/listenv edge and was required for
the WSL image build to complete cleanly.

## Dev Validation

Dev host:

```text
ecology-r-dev1.its.utas.edu.au
```

Reviewed outcomes:

- Dev host validation passed.
- ShinyProxy was running with `openanalytics/shinyproxy:3.2.4`.
- Deployment directory was reported as
  `/srv/sa-container/ecology-teaching-shiny`.
- Dev SAML login and browser smoke passed.
- App launch passed.
- Deterministic baseline and environmental stochasticity runs passed.
- Compare view passed.
- Comparison CSV export passed.
- Evidence-notes Markdown export passed.
- Dev CSV shape was valid: 2 rows, 13 expected columns, no empty cells.
- Dev Markdown contained timestamp, fixed teaching seed `42`, comparison table,
  settings/provenance, and interpretation prompts.

## Prod Validation

Prod host:

```text
ecology-r1.its.utas.edu.au
```

Reviewed outcomes:

- Prod host validation passed.
- ShinyProxy was running with `openanalytics/shinyproxy:3.2.4`.
- Deployment directory was reported as
  `/srv/sa-container/ecology-teaching-shiny`.
- Prod SAML URLs were set to `https://ecology-r1.its.utas.edu.au`.
- Prod used the same KPZ308 image tag as dev.
- Prod image digest matched the published digest.
- Prod SAML login and browser smoke passed.
- App launch passed.
- Deterministic baseline and environmental stochasticity runs passed.
- Compare view passed.
- Comparison CSV export passed.
- Evidence-notes Markdown export passed.
- Prod CSV shape was valid: 2 rows, 13 expected columns, no empty cells.
- Prod CSV rows matched dev for the same smoke workflow.
- Prod evidence-notes Markdown matched the expected teaching-export shape.

## Staff Access And Capacity

- Independent staff access/export check passed.
- Staff tester reported access, CSV export, and Markdown export worked.
- Capacity rehearsal on prod passed at 5, 10, 20, 40, and 60 temporary app
  containers.
- Each rung reported all rPVA workload checks OK.
- The capacity rehearsal tested host/container/app workload capacity, not 60
  distinct SAML identities.
- ITS monitoring review passed, with Mark reporting substantial CPU and RAM
  headroom.

## Access Groups And KPZ314 Boundary

Prod app access groups now include:

```text
UNI-Ecology-Teaching-Shiny-Staff
KPZ308
```

KPZ314 is present in SSO configuration but is not granted to the current
KPZ308 app. Treat KPZ314 as a later separate app/container/access task.

First planned student contact with the app:

```text
2026-07-20
```

## Promotion Policy

ITS promotion policy is now agreed:

1. Push a new readable immutable image tag to Gitea.
2. Update dev `application.yml`.
3. Smoke dev.
4. Update prod `application.yml` to the same accepted tag.

Mark prefers readable immutable tags in ShinyProxy config rather than digest
pins. Continue recording digests for provenance and rollback support.

## Canonical Repo Decisions

- Current operator Docker image references should use:
  `git.its.utas.edu.au/utas/kpz308-rpva-practical:<TAG>`.
- Current source repository references may use:
  `https://git.its.utas.edu.au/UTAS/kpz308-rpva-practical.git`.
- `docs/ops/stochastic/inbox/current-task.md` has been reset to a waiting
  state so the Goal 042 publication task is not accidentally rerun from
  `main`.
- Raw `stochastic` evidence remains on the report branch. `main` carries this
  compact canonical summary.

## Residual Risks And Questions

- Student release still requires final teaching-channel/link text, any desired
  final staff smoke, fallback/rollback readiness, class-day support path,
  cleanup/retention policy, and timing before `2026-07-20`.
- Future app iterations must preserve the dev-first/prod-second promotion path.
- KPZ314 should remain outside the current KPZ308 app and be handled as a
  separate future app/container/access-group task.
- The 60-container rehearsal tested host/container/app workload capacity, not
  60 distinct SAML identities.

## Recommendation

Accept this Goal 043 curation if validation is green. The next gate can resume
KPZ308 Practical container content/app iteration against the now-validated ITS
dev/prod promotion path, while keeping student release as a separate gate.
