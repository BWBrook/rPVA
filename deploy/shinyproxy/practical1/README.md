# Practical 1 Shiny Deployment Scaffold

This directory is a non-live deployment scaffold for reviewing how the
Practical 1 Shiny concept lab could be packaged for ShinyProxy. The older
`deep-server` work remains development/staging evidence; the current
student-hosting direction is the ITS-managed RedHat 9/rootless-Docker VM.

Nothing in this directory is active configuration. The files are examples and
templates only. They must be reviewed, copied into an approved deployment
workspace, edited with real institutional values, and tested under a separate
implementation goal before any student-facing service is exposed.

## Contents

- `Dockerfile.template`: reviewable container-image template for the Practical
  1 Shiny app.
- `dockerignore.template`: reviewable `.dockerignore` content for keeping
  local caches, VCS metadata, rendered evidence, and generated teaching
  artefacts out of the image build context.
- `application.example.yml`: ShinyProxy application example with inert
  placeholders for class accounts, image names, workspace mapping, and
  resource limits.
- `application.its-staging.example.yml`: ITS VM staging example using the
  `kpz308-rpva-practical1` app id, Gitea image-name shape, rootless-Docker
  path assumptions, and non-student auth decision points.
- `its-vm-handoff.md`: ITS-facing handoff for the dedicated teaching Shiny VM.
- `gitea-registry-runbook.md`: Gitea image naming, tag/digest, update, tarball
  fallback, and rollback guidance for future approved staging work.
- `nginx-practical1.example.conf`: nginx location/upstream example showing how
  the existing HTTPS gateway could proxy to ShinyProxy.
- `validate-scaffold.sh`: local static validation helper for the scaffold
  files. It checks file presence, placeholder markers, shell syntax, and YAML
  parseability when a local parser is available.

## Boundaries

This scaffold does not:

- install or configure ShinyProxy;
- build or pull Docker images;
- edit nginx, systemd, firewall, DNS, TLS, or Docker service configuration;
- create users, tokens, workspaces, directories, containers, or volumes;
- write to `deep-server`;
- create or access ITS VM, Gitea, registry, rootless Docker, or service-user
  state;
- expose a public or student-facing service;
- change app, package, scenario, dependency, or test code.

The scaffold is repo-local design material. Treat it like a reviewed runbook
draft, not an operations script.

## Review Sequence

1. Confirm Goal 017 readiness gates are accepted by CoS/BB.
2. Review `Dockerfile.template` for dependency, source-ref, and app-launch
   assumptions.
3. Review `dockerignore.template`, then copy it to `.dockerignore` only inside
   an approved build workspace.
4. Review `application.example.yml` for authentication, image, memory/CPU,
   workspace-volume, and URL-path assumptions.
5. Review `nginx-practical1.example.conf` for upstream alignment with the
   existing gateway.
6. Run local static checks only:

   ```sh
   bash deploy/shinyproxy/practical1/validate-scaffold.sh
   ```

7. Review `its-vm-handoff.md`, `application.its-staging.example.yml`, and
   `gitea-registry-runbook.md` before asking ITS to create the VM/Gitea
   staging surface.
8. In a later implementation goal, copy reviewed templates into the approved
   deployment location and replace placeholders with approved values.
9. Test a non-student staging URL before any live class URL is issued.

## Image Runtime Model

The Dockerfile template is intended to install `rPVA` into the image and run
the installed package entrypoint:

```r
rPVA::run_practical1_shiny(...)
```

That is preferable to running an app from a mutable source-tree checkout,
because the deployed service should be tied to a reviewed commit/tag and a
repeatable image build. The source tree is still copied into the image during
build so `renv.lock`, package source, `inst/shiny/practical1/`, and
documentation metadata are available to the installer.

## Placeholder Policy

Angle-bracket values such as `<COURSE_DOMAIN>`, `<RPVA_IMAGE>`, and
`<GENERATED_USER_001>` are intentional placeholders. Replace them only in a
later approved implementation goal. Do not commit secrets, real passwords,
student identifiers, private TLS material, or plausible credentials.

## Teaching And Research Boundary

This scaffold serves the Practical 1 teaching app only. It uses the current
bounded concept-lab flow and must not be treated as a research-grade workflow
for future Lord Howe Island woodhen recovery analysis. Paper-facing work will
need separate data provenance, scenario definitions, uncertainty treatment,
sensitivity analysis, and manuscript review.

## Expected Later Deployment Shape

The later ITS implementation goal should decide and record:

- exact image tag or source commit;
- whether the final build uses `rocker/r-ver:4.6.0` or a locally approved
  mirror/base image;
- final ShinyProxy internal port;
- ITS VM service-user name, app data root, and rootless Docker network;
- Gitea registry URL, access group, and image tag/digest convention;
- TLS certificate, DNS, and student-friendly URL ownership;
- generated account/token list process;
- workspace root and quota enforcement;
- load-test ladder and monitoring cadence;
- rollback and cleanup procedure.

## Local Preflight

Docker is not required for the static preflight. If Docker is available, a
later local-build goal may choose to run a bounded build with:

```sh
docker build \
  --platform linux/amd64 \
  -f deploy/shinyproxy/practical1/Dockerfile.template \
  --build-arg RPVA_REF=<REVIEWED_COMMIT_OR_TAG> \
  -t <LOCAL_REVIEW_IMAGE_TAG> \
  .
```

That build may pull a sizeable R base image and restore R packages, so it is
intentionally not part of the default scaffold validation.
