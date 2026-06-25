# Practical 1 ITS ShinyProxy VM Handoff

This handoff translates the Practical 1 ShinyProxy scaffold from the earlier
`deep-server` staging path to the ITS-managed teaching Shiny VM direction.

It is a sanitized coordination pack. It does not create a VM, create Gitea
resources, build or push an image, edit ShinyProxy, change DNS/TLS, create
accounts, or approve student release.

## Platform Decision

Current ITS facts to use for the next staging step:

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

Use this image-name shape once ITS creates the registry location:

```text
<ITS_GITEA_REGISTRY>/<CONFIRMED_ORG_OR_REGISTRY_NAMESPACE>/kpz308-rpva-practical:<TAG>
```

Suggested tag patterns:

```text
kpz308-rpva-<short-sha>-staging
kpz308-rpva-<YYYYMMDD>-candidate
```

Prefer immutable tags or image digests over `latest`. For ShinyProxy review and
rollback, a digest is better than a mutable tag:

```text
<ITS_GITEA_REGISTRY>/<CONFIRMED_ORG_OR_REGISTRY_NAMESPACE>/kpz308-rpva-practical@sha256:<DIGEST>
```

Confirm the registry host/path and namespace with ITS. Do not assume the HTTPS
clone URL or `UTAS` source owner/path is also the container registry endpoint or
namespace unless ITS says so.

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
<ITS_APP_DATA_ROOT>/kpz308-rpva-practical/workspaces/#{proxy.userId}
```

Do not replace that with a shared writable class directory.

## Update Workflow

Recommended staging update loop:

1. rPVA selects a reviewed source commit.
2. Build the image for `linux/amd64`.
3. Push the image to the ITS Gitea registry after registry/project access is
   created by ITS.
4. Record the pushed tag and digest.
5. ITS or the dedicated service user pulls the exact tag or digest on the VM.
6. ShinyProxy config is updated to the exact tag or digest.
7. ShinyProxy is restarted through the ITS-approved rootless service-user path.
8. Non-student staging proof checks app open, Compare, CSV export, and
   evidence-notes export.
9. Rollback is a config revert to the previous tag or digest plus restart.

For the first deployment only, an image tarball can be a fallback if Gitea
registry setup lags. Prefer registry pull by digest once Gitea is available.

## Responsibility Split

| Area | Primary owner | Notes |
| --- | --- | --- |
| VM provisioning | ITS | RedHat 9, `x86_64/amd64`, rootless Docker platform. |
| DNS and TLS | ITS | ITS manages registration, certificate issuance, renewal, and trust. |
| OS patching, host backup, host monitoring | ITS | Underlying server care stays with ITS. |
| Gitea repository/access groups | ITS | Current private repo: `UTAS/kpz308-rpva-practical`; `ecology-teaching-shiny` is only a possible coordination/access-group label unless ITS creates such a namespace. |
| App image content | Barry/rPVA | Reviewed rPVA source, Dockerfile template, package install, app behavior. |
| ShinyProxy app config content | Barry/rPVA with ITS review | App id, image tag/digest, workspace mapping, resource assumptions. |
| First staging proof | Shared | ITS platform setup plus rPVA app-path smoke and evidence export check. |
| Class-day app behavior/support | Barry/rPVA | Teaching fallback remains outside the VM platform decision. |
| Student release decision | Shared approval gate | Requires staging proof, auth, workspaces, capacity, fallback, and cleanup. |

## Open ITS Questions

1. What Gitea registry URL and package path should replace `<ITS_GITEA_REGISTRY>/<CONFIRMED_ORG_OR_REGISTRY_NAMESPACE>/kpz308-rpva-practical`?
2. What service user and app data root should replace `<ITS_APP_DATA_ROOT>`?
3. Should non-student staging use ShinyProxy simple auth, ITS SSO, or another
   ITS-managed access layer?
4. What group names should ShinyProxy use for staging and future student
   access?
5. What rootless Docker network name should replace
   `<ROOTLESS_DOCKER_NETWORK>`?
6. What command should the service user run to restart ShinyProxy?
7. Should ITS prefer tag pinning or digest pinning in the ShinyProxy config?
8. What resource limits are appropriate for a KPZ308 class session?
9. What logs can Barry read as the service user during class support?
10. What is the rollback owner and expected response time during a class?

## Student Release Boundary

This handoff prepares ITS staging. It is not a student release.

Do not publish any route to students until a later gate proves:

- ITS staging URL works without browser trust warnings;
- authentication/access model is approved;
- per-user workspace mapping works;
- expected class concurrency is tested or conservatively bounded;
- monitoring and class-day support are agreed;
- fallback and rollback are ready;
- Moodle/student-facing material uses the approved class route only.
