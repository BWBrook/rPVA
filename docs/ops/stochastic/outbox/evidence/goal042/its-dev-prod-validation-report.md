# ITS Dev And Prod Validation Report For KPZ308 rPVA Practical

## Executive Summary

The KPZ308 rPVA Practical ShinyProxy deployment path is validated through
image publication, dev-server smoke, prod-server smoke, capacity rehearsal, ITS
monitoring review, and an independent non-Barry access/export check.

The deployment and infrastructure gate is passed. The rPVA orchestrator can
move forward with container content iteration using the agreed promotion path:
build and push a new immutable image tag to Gitea, update dev
`application.yml`, smoke dev, then update prod to the same tag when accepted.

No further infrastructure blocker is known for continuing work on the content
inside the container. Student-facing distribution should still wait for the
normal teaching-release steps described below.

## Validated Image

- Image tag:
  `git.its.utas.edu.au/utas/kpz308-rpva-practical:dev-20260626-9524304fb748`
- Published digest:
  `sha256:7aa013152b226d5ba3fcc34d31051fe049dd0f34c2c7e0187de83580523f4340`
- Source commit used for the image:
  `9524304fb74805baad7672f81f219b8455a4aac8`
- Registry namespace deviation:
  the image uses lowercase `utas` because Docker rejected the uppercase
  repository path.

## Dev Server Outcome

Dev host:

```text
ecology-r-dev1.its.utas.edu.au
```

Validated facts:

- Barry reached the host through the UTAS RDS jump host and PuTTY.
- `sudo -iu sa-container` worked.
- Deployment directory was confirmed:
  `/srv/sa-container/ecology-teaching-shiny`
- `docker compose ps` showed ShinyProxy running with
  `openanalytics/shinyproxy:3.2.4`.
- `application.yml` already contained the `kpz308-rpva-practical` app spec.
- Dev ShinyProxy config used SAML authentication.
- The service user could pull and inspect the KPZ308 image.
- The image digest on the dev server matched the published digest.
- ShinyProxy management health on `127.0.0.1:9090` returned `UP`.
- Browser smoke from Barry's Windows desktop passed:
  - SAML login;
  - app launch;
  - deterministic baseline run;
  - environmental stochasticity run;
  - Compare view;
  - comparison CSV export;
  - evidence-notes Markdown export.
- Exported dev CSV was structurally valid:
  - 2 rows;
  - 13 expected columns;
  - no empty cells.
- Exported dev Markdown contained:
  - generated timestamp;
  - fixed teaching seed `42`;
  - comparison table;
  - settings/provenance;
  - interpretation prompts.

## Prod Server Outcome

Prod host:

```text
ecology-r1.its.utas.edu.au
```

Validated facts:

- Barry reached the host through the UTAS RDS jump host and PuTTY.
- `sudo -iu sa-container` worked.
- Deployment directory was confirmed:
  `/srv/sa-container/ecology-teaching-shiny`
- `docker compose ps` showed ShinyProxy running with
  `openanalytics/shinyproxy:3.2.4`.
- Prod SAML URLs were correctly set to:
  `https://ecology-r1.its.utas.edu.au`
- Prod used the same KPZ308 image tag as dev.
- The service user could pull and inspect the KPZ308 image.
- The image digest on prod matched the published digest.
- ShinyProxy management health on `127.0.0.1:9090` returned `UP`.
- Browser smoke from Barry's Windows desktop passed:
  - SAML login;
  - app launch;
  - deterministic baseline run;
  - environmental stochasticity run;
  - Compare view;
  - comparison CSV export;
  - evidence-notes Markdown export.
- Exported prod CSV was structurally valid:
  - 2 rows;
  - 13 expected columns;
  - no empty cells.
- Prod CSV rows matched the dev CSV rows exactly for the same smoke workflow.
- Prod evidence-notes Markdown was structurally valid and matched the expected
  teaching-export shape.

## Independent Access Check

An independent colleague who was allow-listed by Mark tested the prod app and
reported that:

- access worked;
- CSV export was good;
- Markdown export was good.

This passes the non-Barry access/export gate at staff-tester level.

## Capacity Rehearsal

Mark approved using prod for concurrency testing and confirmed afterwards that
ITS monitoring looked good, with substantial CPU and RAM capacity remaining.

The capacity rehearsal used direct temporary app containers plus in-container
rPVA teaching workloads. This is a host/container/app-capacity rehearsal, not a
test of 60 distinct SAML user identities.

Rungs completed:

| Rung | Result | Health timing | Workload result | Notes |
| --- | --- | --- | --- | --- |
| 5 | Pass | 5 healthy by 10 seconds | 5/5 OK | ShinyProxy health remained `UP` |
| 10 | Pass | 10 healthy by 10 seconds | 10/10 OK | ShinyProxy health remained `UP` |
| 20 | Pass | 20 healthy by 10 seconds | 20/20 OK | One-minute steady check passed |
| 40 | Pass | 40 healthy by 10 seconds | 40/40 OK | Realistic class-size target passed |
| 60 | Pass | 60 healthy by 10 seconds | 60/60 OK | Headroom run above expected maximum passed |

Each workload check ran the installed app package logic in the container:

- `rPVA::run_teaching_pva("deterministic_baseline", ...)`
- `rPVA::run_teaching_pva("environmental_stochasticity", controls = list(env_sd = 0.25, K = 35), ...)`
- `rPVA::compare_teaching_runs(...)`

Each successful workload check produced:

```text
OK rows=2 Nmed_env=94
```

Observed steady-state app-container memory was approximately 129 MiB per app
container. ShinyProxy itself was approximately 1001-1002 MiB of a 2 GiB
container limit during these checks.

Temporary capacity-test containers were removed after the headroom run. A
post-cleanup check showed ShinyProxy still running and only the normal
ShinyProxy-managed app session remaining.

## Operational Caveats

- The capacity rehearsal did not use 40 or 60 separate SAML identities.
- Direct `docker run --cpus=1.0` failed on the prod rootless Docker/kernel
  setup because NanoCPUs are unsupported there. The test was rerun without the
  CPU-quota flag.
- Direct capacity containers emitted:
  `WARNING: IPv4 forwarding is disabled. Networking will not work.`
  This did not block in-container workload testing. Browser-to-app routing via
  ShinyProxy was separately validated by the dev and prod browser smokes.
- Capacity-test containers used one temporary workspace per test container
  under the deployment data tree.
- No student identifiers, passwords, tokens, private keys, Docker credentials,
  live service secrets, full environment dumps, or sensitive config payloads
  are recorded in this report.

## Access And Release State

Mark confirmed:

- the KPZ308 group is active;
- it is automatically populated from the UTAS identity management platform;
- ITS monitoring during the capacity run looked good;
- there was substantial CPU and RAM capacity left.

Mark subsequently confirmed that the separate staff group is set up and applied
to both the prod SSO configuration and prod `application.yml`:

```text
UNI-Ecology-Teaching-Shiny-Staff
```

The prod app access groups are now:

```text
UNI-Ecology-Teaching-Shiny-Staff
KPZ308
```

Mark also added KPZ314 to the SSO configuration, but not to the current
application. This leaves KPZ314 ready for a future ShinyProxy app/container
without granting KPZ314 access to the current KPZ308 application.

The first planned student contact with the app is:

```text
2026-07-20
```

Recommended release posture:

- Do not broaden distribution until the teaching team is ready to release the
  link.
- Before broad release, optionally ask one or more staff members in
  `UNI-Ecology-Teaching-Shiny-Staff` to do a final login/app/export smoke now
  that the staff group is applied.
- Treat KPZ314 as a later separate app/container and access-group exercise; do
  not grant KPZ314 students to the current KPZ308 app.

## ITS Promotion Policy Now Agreed

Mark's preferred image pinning and promotion approach:

- Use immutable tags in `application.yml`, not digest pins, because tags make
  the config easier to read.
- Keep promotion simple:
  1. push a new versioned image tag to Gitea;
  2. update the tag in dev `application.yml`;
  3. smoke dev;
  4. when accepted, update prod `application.yml` to the same tag.

## Readiness Judgement

Infrastructure and deployment readiness:

```text
PASS
```

Known infrastructure blockers to continuing container content work:

```text
None
```

Recommended next work for the rPVA orchestrator:

1. Resume content/app iteration inside the containerized KPZ308 Practical app.
2. Keep each promotable app state tied to an immutable image tag.
3. Use the agreed dev-first, prod-second promotion path.
4. Preserve the release gate for July 2026 teaching distribution:
   final optional staff smoke, final student link text, and teaching fallback
   materials.

## Boundary Confirmation

Confirmed for this validation pass:

- no source push to ITS Gitea was performed;
- no credentials or tokens were written to the repo;
- no private keys, Docker login config, `.env` files, full environment dumps,
  student identifiers, live service secrets, or sensitive config payloads were
  written to the repo;
- no DNS, TLS, firewall, Docker daemon, account, or identity-platform changes
  were made by this agent;
- no KPZ314 app/container work was started;
- temporary capacity-test containers were removed after testing.
