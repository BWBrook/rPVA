# Practical 1 Shiny Deployment Scaffold

This directory is a non-live deployment scaffold for reviewing how the
Practical 1 Shiny concept lab could be packaged for ShinyProxy on
`deep-server`.

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

7. In a later implementation goal, copy reviewed templates into the approved
   remote/deployment location and replace placeholders with approved values.
8. Test a non-student staging URL before any live class URL is issued.

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

The later implementation goal should decide and record:

- exact image tag or source commit;
- whether the final build uses `rocker/r-ver:4.6.0` or a locally approved
  mirror/base image;
- final ShinyProxy internal port;
- whether nginx keeps proxying to `127.0.0.1:3838` or is updated to the chosen
  ShinyProxy port;
- TLS certificate and student-friendly URL ownership;
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
