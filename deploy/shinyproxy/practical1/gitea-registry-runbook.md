# Gitea Registry Runbook For KPZ308 rPVA Staging

This runbook describes the intended image handoff now that Mark has confirmed
the Gitea registry image path shape. It is not a Mac mini registry login,
source clone, source push, VM login, or deployment instruction.

## Names

Possible teaching-Shiny coordination or access-group label:

```text
ecology-teaching-shiny
```

This is not the confirmed Gitea repository owner/path. The confirmed current
repository owner/path is `UTAS/kpz308-rpva-practical` unless ITS later moves it.

Current Gitea instance:

```text
https://git.its.utas.edu.au/
```

Current private source repository:

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

The no-`1` id is deliberate because the ShinyProxy app identity should cover
both KPZ308 rPVA practical weeks, even while this scaffold currently packages
the Practical 1 app surface.

Future app identity only:

```text
kpz314-sdm-practical
```

Image name shape:

```text
git.its.utas.edu.au/UTAS/kpz308-rpva-practical:<TAG>
```

Mark has confirmed this path shape for image publication. Do not substitute
credentials, tokens, or live registry values in this repo.

Recommended tags:

```text
kpz308-rpva-<short-sha>-staging
kpz308-rpva-<YYYYMMDD>-candidate
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
  -t git.its.utas.edu.au/UTAS/kpz308-rpva-practical:<TAG> \
  .
```

The Dockerfile template installs the package and launches the installed app
entrypoint. Do not add secrets, student identifiers, registry tokens, or VM
paths to the image.

## Push From WSL On GlobalProtect

Barry's WSL lane on GlobalProtect is the intended human-assisted publisher
because it can reach ITS Gitea. The Mac mini remains the source-of-truth and
orchestration machine.

After logging in safely from WSL, an approved publisher can push:

```sh
docker push git.its.utas.edu.au/UTAS/kpz308-rpva-practical:<TAG>
```

Then record the digest:

```sh
docker image inspect \
  git.its.utas.edu.au/UTAS/kpz308-rpva-practical:<TAG> \
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
docker pull git.its.utas.edu.au/UTAS/kpz308-rpva-practical@sha256:<DIGEST>
```

The restart command is an ITS decision because the VM uses rootless Docker and
Barry may not have root access.

## Tarball Fallback For First Deployment Only

If the Gitea registry is not ready but ITS wants one initial staging import,
use an image tarball as a temporary fallback:

```sh
docker save \
  git.its.utas.edu.au/UTAS/kpz308-rpva-practical:<TAG> \
  -o /tmp/kpz308-rpva-practical-<TAG>.tar
shasum -a 256 /tmp/kpz308-rpva-practical-<TAG>.tar
```

The tarball should be transferred only through an ITS-approved channel. Do not
commit image layers or tarballs to this repo.

## Staging Proof

After pull/update/restart, prove at minimum:

- login or ITS auth reaches ShinyProxy;
- `kpz308-rpva-practical` opens;
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
