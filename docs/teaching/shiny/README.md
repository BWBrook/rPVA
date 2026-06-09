# Practical 1 Shiny Design Spike

This directory contains the design and implementation notes for the Shiny-first
Practical 1 experience in `rPVA`.

The first base-Shiny MVP scaffold now lives in `inst/shiny/practical1/` and can
be launched from R with `run_practical1_shiny()`. The documents here remain the
teaching, requirements, and deployment planning layer for future road-test work.

## Documents

- `practical-1-design-brief.md` defines the student learning experience as a
  staged concept lab before students move to the Lord Howe Island woodhen case.
- `engine-affordance-audit.md` maps the current `rPVA` engine, helpers, and
  scenarios to the concept lab and identifies the smallest app-facing API likely
  needed.
- `deployment-and-setup-options.md` compares local, hosted, server/container,
  and browser-first delivery paths for mixed student hardware.
- `implementation-roadmap.md` proposes a sequence of future bounded goals,
  separating the minimum viable teaching app from later enhancements.
- `deep-server-hosting-feasibility.md` assesses whether `deep-server` is a
  plausible four-week course Shiny platform and identifies current access
  blockers.
- `student-workspace-and-export-design.md` defines per-student workspace,
  identity, quota, export, retention, and assessment-boundary recommendations.
- `platform-options-decision-matrix.md` compares ShinyProxy, Shiny Server open
  source, Posit Connect, and custom Nginx/Docker/systemd options.
- `road-test-operations-plan.md` outlines the four-week service, load testing,
  monitoring, fallback, and cleanup model.
- `../../goals/017-practical-1-shiny-deployment-readiness/Goal.md` records the
  current pre-deployment decision package and go/no-go gates for the next
  ShinyProxy/deep-server implementation step.
- `../../goals/018-practical-1-shiny-deployment-scaffold/Goal.md` records the
  current non-live deployment scaffold package. Its templates live under
  `../../../deploy/shinyproxy/practical1/` for review before any real service
  work.
- `../../goals/020-deep-server-image-preflight/Goal.md` records the accepted
  x86_64 image-build preflight on `deep-server`.
- `../../goals/021-staging-gate-runbook/Goal.md` records the current
  pre-live staging-gate checklist and approval handoff runbook.
- `../../goals/022-local-remote-staging-validation/Goal.md` records the current
  local Shiny smoke, CI repair, and remote read-only staging discovery package.

## Design Position

The preferred direction is a hosted, browser-first Practical 1 app for the 2026
road test, backed by the current `rPVA` engine and a small teaching-facing API
layer. A local instructor/demo path should remain available for resilience and
for students who want to continue work in R after class.

The platform feasibility recommendation is to keep `deep-server` as the
preferred candidate host. After follow-up infrastructure work, an nginx HTTPS
gateway on `443` now responds to health checks from both the Tailscale route and
Barry's WSL/campus route. The preferred self-managed platform candidate is
ShinyProxy backed by Docker, with generated class accounts or tokens for the
first road test. The free Posit tier is too small for this class platform, and
UTAS-supported Posit Connect is not expected to be available.

The app should teach interpretation, not file mechanics. Students should be able
to change one concept at a time, see immediate visual and numerical outputs,
export compact evidence, and then transfer those ideas to the Woodhen Practical
2 workflow.

Goal 017 is the current pre-deployment bridge between the local MVP and any
service implementation. Its read-only refresh confirmed the tailnet health
endpoint, and a 2026-06-05 Windows/WSL campus-network follow-up confirmed the
campus/public health route. The browser still showed a red "Not secure"
warning, so TLS trust / student-friendly URL polish and eventual app-path
verification remain go/no-go gates before exposing the app.

Goal 018 adds an inert ShinyProxy/Docker/nginx scaffold for review. The
scaffold is not live configuration and must not be copied to `deep-server`
until a later implementation goal explicitly authorizes remote service work.
Goal 019 is the local, non-live preflight pass over that scaffold: static
validation, safer template assumptions, and Docker availability assessment
without remote writes or service changes.
Goal 020 verifies the scaffold image-build path on `deep-server` `x86_64` and
the `libuv1-dev` dependency fix with one localhost-only smoke. Goal 021 records
what must be approved and checked before any ShinyProxy/nginx/app-path staging
pass. Goal 022 adds the first local-plus-remote validation pass: the local Mac
mini Shiny smoke works, CI has a focused bootstrap repair on the Goal 022
branch, and remote discovery stops before staging because ShinyProxy is absent
on `deep-server`.

## Current MVP Boundary

- Practical 1 concept-lab scaffold only.
- No ShinyProxy, Docker, nginx, systemd, or other deployment implementation.
- No authentication, accounts, persistent student workspaces, quotas, or usage
  tracing.
- No Practical 2 Woodhen app mode.
- No assessment redesign, scenario YAML change, or core engine behaviour change.
- No research-grade Lord Howe Island woodhen recovery analysis. Teaching
  simplifications remain separate from future paper-facing scenario work.
- No live deployment scaffold activation. `deploy/shinyproxy/practical1/`
  contains examples/templates only.
- No Docker build/run as a default validation gate. Goal 019 keeps image-build
  testing optional and bounded because it can pull large R base images and
  restore R packages.
- No live student release yet. Goal 022 permits local Shiny smoke and
  read-only remote discovery, but stops before remote app staging until a
  separate service-bootstrap/staging package is approved.
