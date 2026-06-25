# Goal 040 Dev Image Publication Preflight Report

## Summary

Goal 040 prepares the next ITS dev-server image publication step using Mark's
confirmed Gitea registry target while keeping the Mac mini as the rPVA
source-of-truth and orchestration machine.

The WSL/GlobalProtect lane is treated as a narrow human-assisted publishing
path because it can reach ITS Gitea. This goal did not log in to ITS Gitea,
clone from ITS Gitea, create tokens, build or push ITS images, contact ITS, or
alter any live VM/service state.

## Confirmed Values

- Source repo:
  `https://git.its.utas.edu.au/UTAS/kpz308-rpva-practical.git`
- Registry image path:
  `git.its.utas.edu.au/UTAS/kpz308-rpva-practical:<TAG>`
- ITS Docker network: `shinyproxy-net`
- App id/repo id: `kpz308-rpva-practical`
- Dev server: Mark is building a staging/testing server with SSO initially
  limited to Barry/ITS/rPVA operators.
- App data: persistent app data should live under the OS user's home directory
  on the ITS dev server; exact path still needs ITS confirmation.

## Updated Current Handoff Surfaces

- `deploy/shinyproxy/practical1/README.md`
- `deploy/shinyproxy/practical1/application.its-staging.example.yml`
- `deploy/shinyproxy/practical1/gitea-registry-runbook.md`
- `deploy/shinyproxy/practical1/its-vm-handoff.md`
- `deploy/shinyproxy/practical1/staging-gate-checklist.md`
- `deploy/shinyproxy/practical1/wsl-image-push-runbook.md`
- `docs/teaching/shiny/README.md`

The staging YAML now uses:

```text
container-image: git.its.utas.edu.au/UTAS/kpz308-rpva-practical:<TAG>
container-network: shinyproxy-net
workspace root: <SERVICE_USER_HOME>/kpz308-rpva-practical/workspaces/#{proxy.userId}
```

## WSL Publication Posture

The WSL runbook provides non-secret commands for:

- preparing or receiving a reviewed rPVA source tree;
- building a `linux/amd64` image;
- logging in to the Gitea registry using standard input rather than command
  line credentials;
- tagging and pushing
  `git.its.utas.edu.au/UTAS/kpz308-rpva-practical:<TAG>`;
- recording the pushed digest;
- reporting tag, digest, source ref, and non-secret smoke evidence back to
  Mark.

## Mac Mini Docker Build Decision

Read-only Docker checks showed Docker Desktop is available on the Mac mini.
The engine is Apple Silicon/aarch64, while the ITS target image is
`linux/amd64`. A local proof build would require cross-platform image build
work for a sizeable R/Shiny image and package restore. Because this goal is a
docs/templates/handoff preflight, and because the intended publication lane is
WSL on GlobalProtect, the Mac mini build was skipped in favor of static
validation.

## Sendable Bundle

The sendable bundle is generated at:

```text
/tmp/rpva-goal040-its-dev-image-preflight/
```

and mirrored to OneDrive at:

```text
/Users/bwbrook/Library/CloudStorage/OneDrive-UniversityofTasmania/EXCHANGE/rPVA/goal040-its-dev-image-preflight-2026-06-25/
```

The sendable subset contains:

- `README-send-to-ITS.md`
- `mark-dev-image-message-draft.md`
- `its-vm-handoff.md`
- `gitea-registry-runbook.md`
- `wsl-image-push-runbook.md`
- `application.its-staging.example.yml`
- `SHA256SUMS.txt`

It excludes internal report material, image layers, registry tokens,
credentials, private keys, student identifiers, live service config, and VM
payloads.

## Residual Questions For ITS/Barry

1. What exact service-user home path should replace `<SERVICE_USER_HOME>`?
2. What immutable tag convention should Barry use for the first dev-server
   image push?
3. Should Mark pin ShinyProxy to the pushed tag or to a digest after first
   publication?
4. Which SSO/group names should replace the current non-live access-group
   stand-ins?
5. What dev-server deployment directory should Barry use for
   `docker compose down` and `docker compose up -d`?
6. What non-secret evidence does Mark want back after the first WSL push?

## Validation Summary

Final validation results are recorded in `Log.md`.

## Boundary Confirmation

No Gitea login, ITS clone, ITS source push, token creation, registry/package
entry, image push, external contact, VM/service/TLS/DNS/Docker state change,
app/package/Shiny behavior change, science/YAML/model change, dependency
change, Moodle/student-facing release change, KPZ314 work, PR, commit, or push
was performed.

## Recommendation

Ready for orchestrator review if final validation remains green. The next gate
should be Barry/orchestrator review of the sendable bundle, then a separate
human-assisted WSL publication goal once the reviewed source ref and tag are
chosen.
