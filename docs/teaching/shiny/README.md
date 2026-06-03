# Practical 1 Shiny Design Spike

This directory contains the Goal 011 design package for a future Shiny-first
Practical 1 experience in `rPVA`.

This is not an implemented Shiny app. It is a teaching, requirements, and
deployment design spike intended to help Barry and the supervisor decide what
to build next.

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

## Non-Goals For This Spike

- No Shiny implementation.
- No package dependency changes.
- No package code, scenario, test, CI, or metadata changes.
- No edits to Goal 010 assessment drafts.
- No commit or push.
