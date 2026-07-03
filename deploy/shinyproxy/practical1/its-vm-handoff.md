# Practical 1 ITS ShinyProxy VM Handoff

This handoff translates the Practical 1 ShinyProxy scaffold from the earlier
`deep-server` staging path to the ITS-managed teaching Shiny VM direction.

It is a sanitized coordination pack. It does not create a VM, create Gitea
resources, build or push an image, edit ShinyProxy, change DNS/TLS, create
accounts, or approve student release.

## Platform Decision

Current ITS facts and validation results:

- ITS does not want `deep-server` used as the student-hosting machine.
- ITS can provide a dedicated ShinyProxy VM.
- VM operating system and architecture: RedHat 9, `x86_64/amd64`.
- ITS will manage TLS and DNS registration.
- ITS can provide staging through a dev/test server or a separate namespace.
- ITS uses rootless Docker.
- Barry may have full access to the dedicated service user that runs
  ShinyProxy and Docker, but not root on the VM.
- ITS monitors, backs up, and patches the underlying server.
- Barry/rPVA owns application-stack maintenance and class-day application
  support, with ITS help during setup.
- ITS can create Gitea access groups and a team/project space.
- ITS has provided Gitea at `https://git.its.utas.edu.au/`.
- Barry has created the uninitialized private repository
  `UTAS/kpz308-rpva-practical`.
- Docker image references use the lowercase registry namespace:
  `git.its.utas.edu.au/utas/kpz308-rpva-practical:<TAG>`.
- The ITS Gitea source repository owner/path remains
  `UTAS/kpz308-rpva-practical`.
- Mark says the pushed image can then be linked to the Gitea repository, and
  Gitea permissions handle source and registry access natively.
- Dev host validation has passed on `ecology-r-dev1.its.utas.edu.au`.
- Prod host validation has passed on `ecology-r1.its.utas.edu.au`.
- ITS Docker network: `shinyproxy-net`.
- Reported deployment directory on dev/prod:
  `/srv/sa-container/ecology-teaching-shiny`.
- Persistent app data lives under the service-user controlled deployment/data
  area configured by ITS.
- Barry will be able to run `docker compose down` and
  `docker compose up -d` in the deployment directory to pull new images and
  restart the proxy.
- Mark will merge `application.its-staging.example.yml` with the testing
  config.

The older `deep-server` work remains useful as development/staging evidence,
but it is no longer the intended student-hosting target.

## Project And App Names

Possible teaching-Shiny coordination or access-group label:

```text
ecology-teaching-shiny
```

This is not the confirmed Gitea repository owner/path. The confirmed current
repository owner/path is `UTAS/kpz308-rpva-practical` unless ITS later moves it.

Current Gitea source repository:

```text
https://git.its.utas.edu.au/UTAS/kpz308-rpva-practical.git
```

Repository owner/path:

```text
UTAS/kpz308-rpva-practical
```

Canonical app and repository id:

```text
kpz308-rpva-practical
```

The no-`1` id is intentional: this ShinyProxy app is the KPZ308 rPVA practical
container identity for both rPVA teaching weeks, even though the first packaged
teaching surface is the Practical 1 concept lab.

Future app identity only:

```text
kpz314-sdm-practical
```

The KPZ314 name is reserved as future shared teaching-Shiny context. This pack
does not inspect or implement KPZ314 materials.

## Image Naming

Use this confirmed registry image path shape:

```text
git.its.utas.edu.au/utas/kpz308-rpva-practical:<TAG>
```

Use lowercase `utas` for Docker image references. The uppercase
`UTAS/kpz308-rpva-practical` string is for the Gitea source repository
owner/path, not the Docker registry namespace.

Suggested tag patterns:

```text
dev-<YYYYMMDD>-<SHORT_SHA>
```

Prefer readable immutable tags over `latest`. Mark prefers readable immutable
tags in ShinyProxy config rather than digest pins. After dev smoke, promote the
same accepted tag to prod. Record digests for provenance and rollback evidence:

```text
git.its.utas.edu.au/utas/kpz308-rpva-practical@sha256:<DIGEST>
```

The source clone URL remains
`https://git.its.utas.edu.au/UTAS/kpz308-rpva-practical.git`. Do not log in to
Gitea, clone from Gitea, or push source/images from the Mac mini in this
preflight.

## Source And Build Inputs

Current repo inputs for Practical 1:

- package source and `renv.lock` from a reviewed rPVA commit;
- `inst/shiny/practical1/` as the installed Shiny app surface;
- `deploy/shinyproxy/practical1/Dockerfile.template`;
- `deploy/shinyproxy/practical1/dockerignore.template`;
- `deploy/shinyproxy/practical1/application.its-staging.example.yml`.

The Dockerfile template currently uses `rocker/r-ver:4.6.0` and installs the
package before launching:

```r
rPVA::run_practical1_shiny(...)
```

That preserves the accepted app behavior. This handoff does not change app
code, Shiny UI/CSS/server code, science/YAML/model defaults, dependencies, or
tests.

## Authentication Boundary

The rPVA Shiny app has no built-in login. Keep authentication outside the app
where possible:

- preferred: ITS/ShinyProxy/SSO or reverse-proxy authentication managed by ITS;
- acceptable for non-student staging only: ShinyProxy simple auth with
  ITS-approved secret handling;
- not acceptable for student release: unauthenticated shared access, secrets in
  repo files, or app-embedded login logic added only for hosting.

Student accounts, access groups, and class workspace decisions remain a
separate release gate.

## Rootless Docker Notes

Assume all app paths and commands run as the dedicated ShinyProxy/Docker
service user, not root.

Implications for the ITS example config:

- host paths should live under the service user's home or an ITS-approved app
  data root;
- bind mounts must be writable by the rootless service user;
- per-user workspaces should remain isolated with `#{proxy.userId}`;
- avoid host networking and privileged-port assumptions unless ITS wraps them;
- restart/update commands should use ITS-approved service-user commands or
  wrappers.

The ITS staging YAML example uses an angle-bracket path such as:

```text
<SERVICE_USER_HOME>/kpz308-rpva-practical/workspaces/#{proxy.userId}
```

Do not replace that with a shared writable class directory.

## Update Workflow

Agreed promotion loop:

1. rPVA selects a reviewed source commit.
2. Build the image for `linux/amd64`.
3. Push the image from the approved WSL/GlobalProtect publishing lane to
   `git.its.utas.edu.au/utas/kpz308-rpva-practical:<TAG>`.
4. Record the pushed tag and digest.
5. Mark links the pushed image to the Gitea repository if required.
6. Update dev `application.yml` to the readable immutable tag.
7. Smoke dev.
8. When accepted, update prod `application.yml` to the same tag.
9. Smoke prod.
10. Rollback is a config revert to the previous tag plus restart.

For the first deployment only, an image tarball can be a fallback if Gitea
registry setup lags. Prefer registry pull by the approved readable immutable
tag once Gitea is available, with the digest recorded for provenance.

## Responsibility Split

| Area | Primary owner | Notes |
| --- | --- | --- |
| VM provisioning | ITS | RedHat 9, `x86_64/amd64`, rootless Docker platform. |
| DNS and TLS | ITS | ITS manages registration, certificate issuance, renewal, and trust. |
| OS patching, host backup, host monitoring | ITS | Underlying server care stays with ITS. |
| Gitea repository/access groups | ITS | Current private repo: `UTAS/kpz308-rpva-practical`; `ecology-teaching-shiny` is only a possible coordination/access-group label unless ITS creates such a namespace. |
| App image content | Barry/rPVA | Reviewed rPVA source, Dockerfile template, package install, app behavior. |
| WSL image publication | Barry/rPVA using WSL on GlobalProtect | Build/tag/push image to `git.its.utas.edu.au/utas/kpz308-rpva-practical:<TAG>` and report tag/digest back to Mark. |
| ShinyProxy app config content | Barry/rPVA with ITS review | App id, readable immutable image tag, digest record, `shinyproxy-net`, workspace mapping, resource assumptions. |
| First staging proof | Shared | ITS platform setup plus rPVA app-path smoke and evidence export check. |
| Class-day app behavior/support | Barry/rPVA | Teaching fallback remains outside the VM platform decision. |
| Student release decision | Shared approval gate | Requires staging proof, auth, workspaces, capacity, fallback, and cleanup. |

## Known ITS Facts After Goal 043

- Dev validation passed on `ecology-r-dev1.its.utas.edu.au`.
- Prod validation passed on `ecology-r1.its.utas.edu.au`.
- Dev and prod use SAML/SSO rather than app-embedded login.
- Reported dev/prod deployment directory:
  `/srv/sa-container/ecology-teaching-shiny`.
- Docker network: `shinyproxy-net`.
- Prod app access groups include:
  - `UNI-Ecology-Teaching-Shiny-Staff`;
  - `KPZ308`.
- KPZ314 is present in SSO configuration but is not granted to the current
  KPZ308 app. Treat KPZ314 as a later separate app/container/access task.
- Prod capacity rehearsal passed at 5, 10, 20, 40, and 60 temporary app
  containers with ITS monitoring headroom. This was host/container/app workload
  capacity, not 60 distinct SAML identities.
- Mark prefers readable immutable tags in `application.yml`; record digests
  for provenance and rollback evidence rather than pinning config by digest by
  default.
- First planned student contact with the app is `2026-07-20`.

## Remaining Operational Questions

1. Who owns class-day support escalation and rollback decisions, and what is
   the expected response path during a live class?
2. Which logs and health checks can Barry/rPVA read directly during class
   support, and which must be requested from ITS?
3. What workspace cleanup and retention policy should apply after the KPZ308
   practical period?
4. Where should ITS/rPVA record promoted image digests if not solely in repo
   notes and goal packets?
5. Should one final staff smoke through `UNI-Ecology-Teaching-Shiny-Staff` be
   run immediately before releasing the teaching-channel link?

## Student Release Boundary

The ITS infrastructure, auth, dev/prod smoke, staff access/export, monitoring,
and capacity gates have passed at staff/tester level. This handoff is still not
itself a student release.

Before students receive the route, run a separate teaching-release gate focused
on:

- final teaching-channel or Moodle link text;
- optional final staff smoke through the staff access group;
- fallback and rollback are ready;
- class-day support and log/health-check response path;
- cleanup/retention policy;
- release timing before the first planned student app contact on `2026-07-20`.
