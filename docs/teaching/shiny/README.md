# Practical 1 Shiny Design Spike

This directory contains the design and implementation notes for the Shiny-first
Practical 1 experience in `rPVA`.

The first base-Shiny MVP scaffold now lives in `inst/shiny/practical1/` and can
be launched from R with `run_practical1_shiny()`. The documents here remain the
teaching, requirements, and deployment planning layer for future road-test work.

## Documents

- `practical-1-design-brief.md` defines the student learning experience as a
  staged concept lab before students move to the Lord Howe Island woodhen case.
- `practical-1-mission-tutorial.md` maps the current Shiny screens and
  implemented stages to a two-hour app-led Practical 1 mission arc.
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
- `../../goals/023-practical-1-evidence-export-road-test-hardening/Goal.md`
  records the compact session-local evidence export hardening package.
- `../../goals/025-nonstudent-shinyproxy-staging-bootstrap/Goal.md` records
  the current non-student ShinyProxy staging bootstrap on `deep-server`.
- `../../goals/026-campus-route-tls-readiness/Goal.md` records the current
  campus-route and TLS/browser-trust diagnostic boundary for the non-student
  staging service.
- `../../goals/027-trusted-class-hostname-tls-gate/Goal.md` records the
  trusted class-hostname TLS gate and current DNS/certificate ownership
  blocker.
- `../../goals/028-campus-it-tls-request-pack/Goal.md` records the campus IT
  request pack that turns the Goal 027 DNS/certificate blocker into concrete
  hostname, DNS, certificate, renewal, nginx/TLS ownership, and access-policy
  questions.
- `../../goals/029-practical-1-mission-tutorial-curriculum/Goal.md` records
  the app-led Practical 1 mission tutorial, lightweight worksheet, instructor
  beat sheet, and later app-support gap list.
- `../../goals/030-practical-1-mission-mode-app-affordance-polish/Goal.md`
  records the small app-visible mission cues, run-1 baseline wording,
  one-factor-change guidance, and Compare guidance added for the Goal 029
  tutorial path.
- `../../goals/031-practical-1-delivery-candidate-rehearsal-pack/Goal.md`
  records the local delivery-candidate rehearsal, day-of-class pack, and
  go/no-go checklist separating local readiness from hosted student URL
  release readiness.

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
2 workflow. Goal 029 turns that design position into a mission tutorial: the
app remains the main classroom surface, while the worksheet records observations
and caveats without becoming a heavy handout.

Goal 017 is the current pre-deployment bridge between the local MVP and any
service implementation. Its read-only refresh confirmed the tailnet health
endpoint, and a 2026-06-05 Windows/WSL campus-network follow-up confirmed the
campus/public health route. The browser still showed a red "Not secure"
warning, so TLS trust / student-friendly URL polish and eventual app-path
verification remain go/no-go gates before exposing the app.

Goal 018 adds an inert ShinyProxy/Docker/nginx scaffold for review. The
scaffold remains repo-local design material, but Goal 025 explicitly authorized
the first non-student remote staging bootstrap on `deep-server`.
Goal 019 is the local, non-live preflight pass over that scaffold: static
validation, safer template assumptions, and Docker availability assessment
without remote writes or service changes.
Goal 020 verifies the scaffold image-build path on `deep-server` `x86_64` and
the `libuv1-dev` dependency fix with one localhost-only smoke. Goal 021 records
what must be approved and checked before any ShinyProxy/nginx/app-path staging
pass. Goal 022 adds the first local-plus-remote validation pass: the local Mac
mini Shiny smoke works, CI has a focused bootstrap repair on the Goal 022
branch, and remote discovery stops before staging because ShinyProxy is absent
on `deep-server`. Goal 023 adds compact session-local evidence downloads before
any service-bootstrap/staging work resumes. Goal 025 installs and configures a
single non-student authenticated ShinyProxy staging service for Practical 1 at
commit `5c9d500`, with rollback details in its staging report; it is not a
student release. Goal 026 confirms that Barry can reach the ShinyProxy login
page from inside the University network at the campus IP route, but the current
browser-trust state is still not student-ready because the gateway serves a
self-signed certificate for `deep-server`, not a trusted class hostname. Goal
027 finds no approved class hostname or browser-trusted certificate path
available on `deep-server`; the reverse-DNS name
`SET-BIO-2621GL2.zoo.utas.edu.au` is a campus-IT lead to assess, not an
approved teaching URL. Goal 028 packages that blocker into a sendable campus
IT request and technical appendix, with rPVA Practical 1 as the immediate
tested service and KPZ314 as future shared teaching-Shiny context only.

## Current MVP Boundary

- Practical 1 concept-lab scaffold only.
- No student-facing ShinyProxy release.
- One non-student authenticated ShinyProxy staging surface now exists on
  `deep-server` under Goal 025 for Practical 1 inspection only.
- No class accounts, class tokens, student identifiers, persistent student
  workspaces, quotas, or usage tracing.
- No Practical 2 Woodhen app mode.
- No assessment redesign, scenario YAML change, or core engine behaviour change.
- No research-grade Lord Howe Island woodhen recovery analysis. Teaching
  simplifications remain separate from future paper-facing scenario work.
- No live deployment scaffold activation. `deploy/shinyproxy/practical1/`
  contains examples/templates only.
- No Docker build/run as a default validation gate. Goal 019 keeps image-build
  testing optional and bounded because it can pull large R base images and
  restore R packages.
- No live student release yet. Goal 025 permits only authenticated non-student
  staging and keeps exports local to the browser session. Student/class
  authentication, persistent student workspaces, campus/TLS polish, and any
  student-facing rollout remain separate approval gates. Goal 026 keeps the
  current service at non-student staging status until a trusted URL/certificate
  route and campus authenticated app path are separately proven. Goal 027 adds
  that a future TLS implementation needs an approved hostname, DNS owner,
  certificate owner/issuance mechanism, renewal owner, and permission for a
  narrow reversible nginx TLS edit.
