# Road-Test Operations Plan

## Purpose

This plan outlines how a `deep-server`-hosted Shiny teaching platform could run
through the 2026 rPVA practical and assessment window.

It is an operations design, not an implementation script. No services were
created or changed during Goal 012.

## Service Window

Target service window:

1. pre-class readiness period,
2. Practical 1,
3. one-week break,
4. Practical 2,
5. two-week report-writing period,
6. post-semester cleanup.

For the first road test, plan for fewer than 50 students.

## Pre-Class Readiness

Before students receive the URL:

- select platform: recommended default is ShinyProxy on `deep-server`;
- decide identity model: generated class accounts/tokens or institutional auth;
- confirm DNS/hostname;
- confirm TLS and reverse-proxy ownership;
- confirm the existing nginx gateway on `443` is the intended front door;
- align the gateway upstream target with the chosen app service port;
- build the Shiny app image or deployment bundle in a future implementation
  goal;
- define workspace root and quota model under `/data`;
- prepare static fallback materials;
- prepare demonstrator recovery notes;
- rehearse the full student path in Chrome.

## Load Testing Plan

Class target:

- under 50 students.

Suggested load-test ladder:

1. single instructor session completes the full Practical 1 path;
2. five concurrent sessions run the baseline and compare screens;
3. ten concurrent sessions run stochastic scenarios;
4. twenty-five concurrent sessions run a typical mid-practical sequence;
5. fifty simulated or human sessions run bounded workloads if feasible.

Measure:

- app response time,
- CPU load,
- memory use,
- container count,
- disk writes per workspace,
- failed runs,
- export creation time,
- log size.

Teaching guardrails:

- bound replicate counts,
- sample displayed trajectories,
- cache common default runs if appropriate,
- avoid allowing all students to trigger very expensive runs repeatedly,
- keep raw trajectory exports disabled by default.

## Monitoring During The Service Window

Minimum operational checks:

- service process status,
- container count,
- CPU and memory pressure,
- root disk and `/data` disk use,
- per-student workspace growth,
- error logs,
- network reachability from a student-like browser path.

Suggested cadence:

- before Practical 1,
- during Practical 1,
- after Practical 1,
- before Practical 2,
- after Practical 2,
- midway through report-writing period,
- before cleanup.

Monitoring can start simple for the first road test. It does not need a full
observability stack if Barry or the demonstrator has a practical checklist and
the platform is bounded.

## Recovery Plan

Likely problems and responses:

| Problem | First response | Fallback |
| --- | --- | --- |
| Student cannot open URL | check browser, VPN/campus route, DNS, and class URL | use static fallback worksheet |
| Login fails | check account/token spelling and expiry | issue spare generated token |
| App is slow | reduce active runs, switch to instructor-led pacing | use prepared outputs |
| Export fails | retry export, check workspace quota | provide table/plot from class fallback bundle |
| Service unavailable | instructor switches to static/precomputed materials | local instructor demo if available |
| Disk quota reached | delete old exports with student consent or increase after approval | provide manual download from current session only |

The fallback should preserve the teaching objective even if live modelling is
temporarily unavailable.

## Fallback Materials

Prepare before class:

- static practical worksheet,
- screenshots of each concept stage,
- precomputed scenario comparison table,
- representative trajectory/summary/extinction plots,
- short explanation of how to interpret zero observed extinction,
- compact export bundle that mirrors expected app outputs,
- demonstrator notes for running an instructor-led live demo.

The fallback should be browser-first or PDF/DOCX-friendly, so it works on
Windows, macOS, older laptops, and Chromebook-like setups.

## Workspace Operations

Before Practical 1:

- create account/workspace map in a future implementation goal;
- set or test quota strategy;
- create a small spare-account pool;
- verify an export can be created, recovered, and downloaded.

During the teaching window:

- retain student exports;
- clean temporary files;
- watch for workspaces approaching quota;
- avoid treating workspace contents as formal submissions unless explicitly
  approved.

After report due date:

- freeze or announce final access period;
- retrieve any instructor-needed support records;
- delete or archive workspaces according to the announced policy;
- remove generated class accounts/tokens.

## Barry's Windows 11 And WSL Testing Role

Barry's Windows 11/WSL campus/VPN path should be part of deployment readiness
because it approximates a non-Mac student route better than the Mac mini
tailnet path.

Use it to test:

- port reachability to the campus IP or DNS name,
- browser access to the student URL,
- login/account flow,
- export download,
- class network/VPN assumptions,
- fallback materials on Windows.

The Goal 012 read-only route probe from WSL saw SSH open but student web ports
closed or filtered. A later gateway fix opened `443`, and WSL/campus-path
health checks now return `deep-server app gateway ok`. WSL/campus-path
retesting remains a required gate after the app service is connected behind the
gateway.

## Cleanup Plan

After the teaching window:

- stop accepting new sessions,
- export or archive only approved operational records,
- remove temporary files,
- remove student workspaces after the announced retention period,
- remove generated class accounts/tokens,
- prune old containers/images only in a future maintenance goal,
- document what worked and what needs changing before reuse.

## Reuse For Fauna Of Tasmania SDM

The same platform should be reusable if it is designed as a small teaching-app
platform rather than a one-off rPVA endpoint.

Reusable pieces:

- reverse proxy and TLS,
- identity model,
- workspace root and quota pattern,
- deployment runbook,
- load-test checklist,
- fallback-materials pattern,
- cleanup policy.

App-specific pieces:

- Docker image or app bundle,
- teaching controls,
- export schema,
- assessment-boundary wording,
- load profile.

## Acceptance Gate Before Road Test

Do not rely on the platform for a live class until:

- the student-facing URL works from a non-admin route,
- TLS is in place or the risk is explicitly accepted for a private pilot,
- identity/workspace mapping has been tested,
- at least one student-like export survives logout/relogin,
- load testing reaches a conservative class-size target,
- fallback materials are ready,
- cleanup policy is written into the teaching notes.
