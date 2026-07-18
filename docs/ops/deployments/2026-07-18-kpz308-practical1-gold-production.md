# KPZ308 Practical 1 Gold Production Deployment

Status: **accepted in production on 2026-07-18**

## Release identity

| Field | Value |
|---|---|
| App ID | `kpz308-rpva-practical` |
| Source commit | `4139e61f95277dbcdda1faa3cdf9f09578c63ec1` |
| Source commit subject | `Align Practical 1 evidence guidance` |
| Source branch state | clean `main`, equal to `origin/main`, at build time |
| Immutable image | `git.its.utas.edu.au/utas/kpz308-rpva-practical:dev-20260718-4139e61f9527` |
| Registry digest | `sha256:2feca9dcdfb522474c49d5ff97f1584eec46f40b816ca4e07e5f5bf31fffaad6` |
| Production image ID | `sha256:2feca9dcdfb522474c49d5ff97f1584eec46f40b816ca4e07e5f5bf31fffaad6` |
| Local build image ID | `sha256:00d03cfec10b870d2088cc0138df875a741aaea5e6b45c84a8eef3d042bcca3f` |
| OCI source revision | `4139e61f95277dbcdda1faa3cdf9f09578c63ec1` |
| Target platform | `linux/amd64` |
| Build window | `2026-07-18T13:12:38Z` to `2026-07-18T13:19:37Z` |
| Publication window | `2026-07-18T13:21:36Z` to `2026-07-18T13:24:44Z` |

The `dev-` prefix is part of the established immutable-tag convention. The
tag was not moved or reused during promotion.

## Release scope

This release is the signed-off Practical 1 teaching surface for the KPZ308
class on Monday 2026-07-20. It includes the final Start, Concept Lab, Compare,
and Transfer workflows, including the three-run evidence comparison,
observation notebook, final synthesis, CSV export, and Markdown evidence pack.

Practical 2 source and image content were outside this release. Its existing
production canary specification and workspace remained unchanged and
Staff-only. The KPZ314 application was also left unchanged.

## Local build and image acceptance

The gold source was built from clean, synchronized `main` with the Practical 1
deployment scaffold for `linux/amd64`. Static deployment checks passed before
the build.

The resulting image passed:

- a bounded container health and HTTP smoke check;
- exact architecture and OCI source-revision inspection;
- full browser acceptance against the built container;
- 151 of 151 browser assertions;
- validation of 18 non-empty generated artifacts; and
- checks for browser console errors, console warnings, and page errors, all of
  which were empty.

The temporary smoke and browser-acceptance containers were removed after the
checks. The pushed registry manifest and local `RepoDigests` resolved to the
same recorded digest.

## Promotion decision

The normal dev-first promotion was deliberately skipped at Barry Brook's
direction. The deployment pipeline, authentication, workspace mounts,
concurrent application operation, rollback method, and earlier Practical 1
images had already been proven on dev and production. The gold image itself
had also passed complete containerized browser acceptance locally. Production
therefore received the immutable gold image directly.

This was an explicit promotion decision, not an omitted or failed gate.

## Production preflight

Target host and service context:

- host: `ecology-r1.its.utas.edu.au`;
- operator identity: `sa-container`;
- working directory: `/srv/sa-container/ecology-teaching-shiny`;
- ShinyProxy image: `openanalytics/shinyproxy:3.2.4`; and
- actuator health before mutation: `UP`.

The preflight confirmed that no application containers were active and that
the production inventory contained Practical 1, the Staff-only Practical 2
canary, and the KPZ314 practical.

Production pulled the exact gold tag. Remote inspection confirmed:

- architecture `amd64`;
- OCI revision `4139e61f95277dbcdda1faa3cdf9f09578c63ec1`; and
- repository digest
  `sha256:2feca9dcdfb522474c49d5ff97f1584eec46f40b816ca4e07e5f5bf31fffaad6`.

## Production configuration change

Permission-preserving backup:

`application.yml.before-kpz308-practical1-gold-20260718-233123`

The backup and live configuration retained mode `0640`, owner and group
`sa-container:sa-container`, and SELinux type `var_t`.

The reviewed diff changed exactly one setting: Practical 1's
`container-image` moved from
`dev-20260713-02b09aeed4f0` to
`dev-20260718-4139e61f9527`.

The change preserved:

- app ID `kpz308-rpva-practical`;
- access groups `UNI-Ecology-Teaching-Shiny-Staff` and `KPZ308`;
- the per-user Practical 1 workspace mount;
- the Practical 2 image, Staff-only access, and separate workspace root; and
- the complete KPZ314 specification.

## Restart and service acceptance

ShinyProxy was restarted with `docker compose down` followed by
`docker compose up -d`. Actuator health returned `UP` on bounded attempt 5.
Startup logs showed successful OpenSAML initialization, authentication-manager
configuration, Undertow startup on ports 8080 and 9090, and ShinyProxy 3.2.4
startup without a deployment error.

## Human browser acceptance

Barry Brook completed the complete authenticated production route through
UTAS SAML and Duo. All 12 acceptance steps passed:

1. the launcher showed Practical 1, the Staff-only Practical 2 canary, and
   KPZ314 to the Staff account;
2. Practical 1 opened successfully;
3. the revised Start surface rendered correctly;
4. the baseline workflow completed;
5. Core 2 completed;
6. Core 5 completed;
7. Compare supported the three evidence roles, outcome matrix, notebook entry,
   and final synthesis;
8. an observation and synthesis were recorded;
9. the evidence pack review completed;
10. CSV and Markdown notebook downloads completed;
11. Current and Evidence pack completion states were correct; and
12. both exported files opened and were non-empty.

Proxy logs recorded the gold Practical 1 proxy starting and activating. The
session was then released normally after browser inactivity; this is expected
ShinyProxy lifecycle behaviour rather than a failure.

## Final closeout state

At `2026-07-18T13:44:13Z`:

- actuator health was `UP` with liveness and readiness groups;
- production configuration still pointed to the exact gold tag;
- production image architecture, revision, and digest matched the release
  record;
- Practical 1 retained Staff plus KPZ308 access;
- Practical 2 retained Staff-only access, with no `KPZ308` group;
- no Practical 2 application container was active; and
- the closeout validation returned `PROD_GOLD_CLOSEOUT_READONLY=passed`.

Practical 2 does not need a persistent stopped container. ShinyProxy creates
its per-user container only when an authorized Staff user opens the app and
releases it after inactivity. KPZ308 students do not see or launch its tile in
the current configuration.

## Student access boundary

The gold workflow was directly accepted with a Staff account. The unchanged
`KPZ308` access-group line, earlier enrolled-student infrastructure proof, and
successful SAML service route provide the student-access basis for Monday.
A fresh enrolled-student login against this exact gold image was not performed,
so student visibility is configuration-preserved rather than directly
retested for this image.

## Operational caveat

Practical 1 session state is held in memory. Students must download their
comparison CSV and Markdown evidence notes before closing the browser tab if
they wish to retain the evidence from that session.

## Freeze and rollback

Practical 1 is now frozen for the Monday 2026-07-20 class. Avoid further
production changes unless they address a material teaching or operational
defect.

Rollback image:

`git.its.utas.edu.au/utas/kpz308-rpva-practical:dev-20260713-02b09aeed4f0`

Rollback procedure:

1. restore only the Practical 1 image line from
   `application.yml.before-kpz308-practical1-gold-20260718-233123`;
2. preserve Practical 2 and KPZ314 unchanged;
3. restart ShinyProxy;
4. wait for actuator health `UP`; and
5. repeat the Staff browser acceptance route.

No rollback was required during this deployment.
