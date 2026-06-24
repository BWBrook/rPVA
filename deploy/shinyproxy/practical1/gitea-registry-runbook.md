# Gitea Registry Runbook For Practical 1 Staging

This runbook describes the intended image handoff once ITS creates the Gitea
team/project space and registry access. It is not a registry login, build, push,
VM login, or deployment instruction.

## Names

Gitea team/project:

```text
ecology-teaching-shiny
```

First app:

```text
kpz308-rpva-practical1
```

Future app identity only:

```text
kpz314-sdm-practical
```

Image name shape:

```text
<GITEA_REGISTRY>/ecology-teaching-shiny/kpz308-rpva-practical1:<TAG>
```

Recommended tags:

```text
kpz308-prac1-<short-sha>-staging
kpz308-prac1-<YYYYMMDD>-candidate
```

Avoid `latest` for ShinyProxy app config. Use an immutable tag or digest.

## Build From Repo Root

After rPVA selects a reviewed commit, a future approved build goal can run a
local or CI build like this:

```sh
docker build \
  --platform linux/amd64 \
  -f deploy/shinyproxy/practical1/Dockerfile.template \
  --build-arg RPVA_REF=<REVIEWED_COMMIT_OR_TAG> \
  -t <GITEA_REGISTRY>/ecology-teaching-shiny/kpz308-rpva-practical1:<TAG> \
  .
```

The Dockerfile template installs the package and launches the installed app
entrypoint. Do not add secrets, student identifiers, registry tokens, or VM
paths to the image.

## Push After ITS Creates Registry Access

Once ITS creates the Gitea project, registry, and access group, an approved
publisher can push:

```sh
docker push <GITEA_REGISTRY>/ecology-teaching-shiny/kpz308-rpva-practical1:<TAG>
```

Then record the digest:

```sh
docker image inspect \
  <GITEA_REGISTRY>/ecology-teaching-shiny/kpz308-rpva-practical1:<TAG> \
  --format '{{json .RepoDigests}}'
```

Do not write registry credentials or access tokens into this repo, image,
ShinyProxy YAML, shell history captures, reports, or support notes.

## Service-User Pull And Update

On the ITS VM, the dedicated ShinyProxy/Docker service user should use
ITS-approved rootless Docker commands or wrappers.

High-level update sequence:

1. Pull the exact tag or digest.
2. Confirm the image id/digest.
3. Update the ShinyProxy app config to the exact tag or digest.
4. Restart ShinyProxy through the ITS-approved service-user path.
5. Smoke the staging URL with a non-student account.
6. Keep the previous tag/digest available for rollback.

Example shape, to be adapted by ITS:

```sh
docker pull <GITEA_REGISTRY>/ecology-teaching-shiny/kpz308-rpva-practical1@sha256:<DIGEST>
```

The restart command is an ITS decision because the VM uses rootless Docker and
Barry may not have root access.

## Tarball Fallback For First Deployment Only

If the Gitea registry is not ready but ITS wants one initial staging import,
use an image tarball as a temporary fallback:

```sh
docker save \
  <GITEA_REGISTRY>/ecology-teaching-shiny/kpz308-rpva-practical1:<TAG> \
  -o /tmp/kpz308-rpva-practical1-<TAG>.tar
shasum -a 256 /tmp/kpz308-rpva-practical1-<TAG>.tar
```

The tarball should be transferred only through an ITS-approved channel. Do not
commit image layers or tarballs to this repo.

## Staging Proof

After pull/update/restart, prove at minimum:

- login or ITS auth reaches ShinyProxy;
- `kpz308-rpva-practical1` opens;
- `Start baseline` works;
- one Concept Lab stage runs;
- Compare displays baseline plus the changed run;
- comparison CSV downloads;
- evidence-notes Markdown downloads;
- logs are available to the service user or ITS support contact;
- rollback owner and command path are known.

## Rollback

Rollback should be a ShinyProxy app config revert to the previous tag/digest,
followed by the ITS-approved restart path.

Record before each update:

- previous tag or digest;
- new tag or digest;
- source commit;
- restart owner;
- smoke result;
- rollback decision owner.
