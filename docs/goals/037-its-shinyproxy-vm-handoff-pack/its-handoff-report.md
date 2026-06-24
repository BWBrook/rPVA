# Goal 037 ITS ShinyProxy VM Handoff Report

## Summary

Goal 037 prepared a sanitized ITS handoff pack for moving Practical 1 student
hosting away from `deep-server` and toward the ITS-managed teaching Shiny VM.

Readiness judgement: ready for orchestrator review and closeout/publication.
The pack is docs/templates only. It does not contact ITS, create Gitea
resources, log into a VM, build or push images, edit live services, or approve
student release.

## Starting State

- Working directory: `/Users/bwbrook/git/rPVA`
- Branch: `codex/rpva-goal037-its-shinyproxy-vm-handoff`
- Base:
  `70dca13ce4934dfbd68072cfad41ff27c81cd3a2`
  (`70dca13 Refine campus TLS request with UTAS PKI evidence`)
- Initial dirty state: untracked Goal 037 packet directory only.

## Sources Reviewed

- `docs/goals/037-its-shinyproxy-vm-handoff-pack/Goal.md`
- `docs/goals/037-its-shinyproxy-vm-handoff-pack/Plan.md`
- `docs/goals/037-its-shinyproxy-vm-handoff-pack/Runbook.md`
- `docs/goals/037-its-shinyproxy-vm-handoff-pack/Log.md`
- `deploy/shinyproxy/practical1/README.md`
- `deploy/shinyproxy/practical1/Dockerfile.template`
- `deploy/shinyproxy/practical1/dockerignore.template`
- `deploy/shinyproxy/practical1/application.example.yml`
- `deploy/shinyproxy/practical1/staging-gate-checklist.md`
- `deploy/shinyproxy/practical1/validate-scaffold.sh`
- Goal 025 non-student ShinyProxy staging report
- Goal 026 campus-route/TLS readiness report
- Goal 027 trusted-hostname TLS blocker report
- Goal 028 campus IT TLS request pack and email draft
- Goal 035 dual-route roleplay preflight report
- Goal 036 Checkpoint A roleplay execution report
- `docs/teaching/shiny/README.md`

## Deliverables Created

- `deploy/shinyproxy/practical1/its-vm-handoff.md`
- `deploy/shinyproxy/practical1/application.its-staging.example.yml`
- `deploy/shinyproxy/practical1/gitea-registry-runbook.md`
- `docs/goals/037-its-shinyproxy-vm-handoff-pack/mark-reply-draft.md`
- `docs/goals/037-its-shinyproxy-vm-handoff-pack/its-handoff-report.md`

Narrow pointer updates:

- `deploy/shinyproxy/practical1/README.md`
- `deploy/shinyproxy/practical1/staging-gate-checklist.md`
- `docs/teaching/shiny/README.md`
- `docs/goals/037-its-shinyproxy-vm-handoff-pack/Log.md`

## ITS Handoff Summary

The pack records these Barry/ITS facts without broadening them:

- ITS does not want `deep-server` as the student-hosting machine.
- ITS can provide a dedicated ShinyProxy VM.
- VM platform: RedHat 9, `x86_64/amd64`.
- ITS manages TLS and DNS registration.
- ITS can provide staging through a dev/test server or namespace.
- ITS uses rootless Docker.
- Barry may have full access to the dedicated ShinyProxy/Docker service user,
  but not root on the VM.
- ITS monitors, backs up, and patches the underlying server.
- Barry/rPVA owns application-stack maintenance and class-day app support,
  with ITS help during setup.
- ITS can create Gitea access groups and a team/project space.

The handoff demotes `deep-server` to development and non-student staging
evidence. It keeps student release blocked until ITS staging, auth, workspaces,
capacity, monitoring, fallback, rollback, cleanup, and release approval are
separately proven.

## Gitea And Image Naming Recommendations

Recommended Gitea team/project:

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

Suggested tags:

```text
kpz308-prac1-<short-sha>-staging
kpz308-prac1-<YYYYMMDD>-candidate
```

Recommendation: prefer immutable tags or image digests over `latest`.

## Application YAML

`application.its-staging.example.yml` is parseable YAML and uses:

- app id `kpz308-rpva-practical1`;
- image stand-in:
  `<GITEA_REGISTRY>/ecology-teaching-shiny/kpz308-rpva-practical1:<TAG>`;
- non-student simple-auth staging entries with angle-bracket secret sources;
- comments stating that ITS SSO/proxy auth is preferred for class release;
- rootless-Docker-safe app data path:
  `<ITS_APP_DATA_ROOT>/kpz308-rpva-practical1/workspaces/#{proxy.userId}`;
- container port `3838`;
- KPZ314 as a commented future identity only, not a runnable app spec.

The ITS example avoids `deep-server`-specific paths such as `/data/codex`.

## Optional `/tmp` Bundle

Created a small sendable review bundle:

```text
/tmp/rpva-goal037-its-handoff/
```

Contents:

- `its-vm-handoff.md`
- `application.its-staging.example.yml`
- `gitea-registry-runbook.md`
- `mark-reply-draft.md`
- `SHA256SUMS.txt`

Checksums:

```text
8fe2eedbe88449616135b5949392e5ccd72732b2605ed208290e2d3d0c8db43c  application.its-staging.example.yml
985c797ddb62a9e6829f64540ef905250445fd6603c7a1a9e5bb031d56ff10a3  gitea-registry-runbook.md
917da2797be0a3b6f753c1df8a80c3ef2dde83b0a8dc8d1e74ece3023e898d21  its-vm-handoff.md
16bacd34e2128b58013e4385968d3feb1d62bece082839f4e054e212dcf165c1  mark-reply-draft.md
```

The bundle contains no image layers, credentials, student identifiers,
registry tokens, private keys, or sensitive service payloads.

## Remaining ITS Questions

1. What Gitea registry URL should replace `<GITEA_REGISTRY>`?
2. What service user and app data root should replace `<ITS_APP_DATA_ROOT>`?
3. Should non-student staging use ShinyProxy simple auth, ITS SSO, or another
   ITS-managed access layer?
4. What group names should ShinyProxy use for staging and future student
   access?
5. What rootless Docker network name should replace
   `<ROOTLESS_DOCKER_NETWORK>`?
6. What command should the service user run to restart ShinyProxy?
7. Should ITS prefer tag pinning or digest pinning in the ShinyProxy config?
8. What CPU/memory limits are appropriate for the first KPZ308 class session?
9. What logs can Barry read as the service user during class support?
10. What is the rollback owner and expected response time during a class?

## Validation Results

Completed before this report was finalized:

- `git diff --check`: passed.
- `bash -n deploy/shinyproxy/practical1/validate-scaffold.sh`: passed.
- `bash deploy/shinyproxy/practical1/validate-scaffold.sh`: passed.
- Ruby YAML parse for `application.example.yml`: passed.
- Ruby YAML parse for `application.its-staging.example.yml`: passed.
- `Rscript -e 'renv::status(sources = FALSE)'`: passed with no issues.

Focused teaching API and Practical 1 Shiny tests were not run because the goal
changed deployment docs/templates and teaching-platform pointers only. No
app-facing launch guidance, package files, app code, tests, or science settings
were changed.

Final marker, secret/private-key, stricter assignment/private-key, and
route/student-release wording scans are recorded in `Log.md` after the final
text settled.

## Boundaries Observed

- No ITS, Mark, Barry, Chief, student, Moodle admin, or campus staff contact.
- No Gitea project/group/registry/credential access or creation.
- No VM login, registry push, production image build/export, or remote state.
- No DNS, TLS, certificate, nginx, ShinyProxy, systemd, firewall, Docker
  service, rootless Docker service, account, credential, token, class
  workspace, or student-release change.
- No app/package code, Shiny UI/CSS/server code, tests, science/YAML/model
  defaults, dependencies, Practical 2 materials, assessment materials, or
  KPZ314 implementation materials were changed.
- No real credential, private key, registry token, student identifier, or
  sensitive service payload was written to repo files, logs, reports, or the
  `/tmp` bundle.
- No commit, push, merge, PR, or Goal 038 work was performed.

## Recommended Next Gate

If the orchestrator accepts this pack, close it out and use
`mark-reply-draft.md` plus the `/tmp` bundle or repo paths as the next Mark/ITS
coordination surface. A later implementation goal should wait for ITS answers
on registry URL, service user, app data root, auth model, rootless Docker
network/restart path, resource limits, log access, rollback owner, and staging
URL.
