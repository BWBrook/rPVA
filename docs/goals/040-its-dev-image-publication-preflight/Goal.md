# Goal 040: ITS Dev Image Publication Preflight

## Objective

Prepare the next ITS dev-server image publication step now that Mark has
confirmed the Gitea registry push target, while keeping the Mac mini as the
rPVA source-of-truth and orchestration machine.

WSL on GlobalProtect is the narrow human-assisted publication path because it
can reach ITS Gitea. This goal prepares documents, templates, and a sendable
handoff bundle only.

## Current Facts

- Confirmed ITS Gitea source repo:
  `https://git.its.utas.edu.au/UTAS/kpz308-rpva-practical.git`.
- Confirmed registry image path shape:
  `git.its.utas.edu.au/UTAS/kpz308-rpva-practical:<TAG>`.
- Mark says the pushed image can then be linked to the Gitea repo.
- Gitea permissions handle source and registry access natively.
- ITS Docker network: `shinyproxy-net`.
- Persistent app data will live in the OS user's home directory on the ITS dev
  server.
- Barry will be able to run `docker compose down` and
  `docker compose up -d` in the deployment directory to pull new images and
  restart the proxy.
- Mark is building a dev server for staging/testing with SSO initially limited
  to Barry/ITS/rPVA operators.
- Mark will merge `application.its-staging.example.yml` with the testing
  config.

## In Scope

- Create this Goal 040 packet and a concise internal report.
- Update current ITS deploy/handoff docs and staging YAML with Mark's confirmed
  registry path, `shinyproxy-net`, and service-user-home data direction.
- Add a WSL-oriented image build/push runbook with non-secret commands and safe
  token-entry guidance.
- Decide whether a local Mac mini Docker build is useful and record the result.
- Regenerate a non-secret sendable bundle under `/tmp` and OneDrive.
- Run static validation, YAML parsing, scaffold validation, renv status, stale
  naming/registry searches, and text scans.

## Out Of Scope

- Logging in to ITS Gitea from the Mac mini.
- Cloning from ITS Gitea, pushing source, creating tokens, creating registry or
  package entries, building/pushing images to ITS, or contacting Mark/ITS.
- VM/service/TLS/DNS/nginx/ShinyProxy/systemd/firewall/Docker state changes.
- App/package/Shiny UI/server/CSS behavior, science/YAML/model defaults,
  Practical 2 implementation, assessment design, dependency changes,
  Moodle/student-facing release state, KPZ314 material, PRs, commits, pushes,
  or Goal 041 work.

## Deliverables

- Updated current deploy/handoff docs and ITS staging YAML.
- `deploy/shinyproxy/practical1/wsl-image-push-runbook.md`.
- `dev-image-publication-preflight-report.md`.
- `README-send-to-ITS.md`.
- `mark-dev-image-message-draft.md`.
- Updated `Log.md`.
- Sendable bundles at:
  - `/tmp/rpva-goal040-its-dev-image-preflight/`
  - `/Users/bwbrook/Library/CloudStorage/OneDrive-UniversityofTasmania/EXCHANGE/rPVA/goal040-its-dev-image-preflight-2026-06-25/`

## Validation

- `git diff --check`
- Ruby YAML parse for modified ShinyProxy YAML example
- `bash -n deploy/shinyproxy/practical1/validate-scaffold.sh`
- `bash deploy/shinyproxy/practical1/validate-scaffold.sh`
- `Rscript -e 'renv::status(sources = FALSE)'`
- Local Docker build decision recorded; build only if feasible and bounded
- Targeted stale registry/name searches over current sendable/operator surfaces
  and bundle
- Marker scan over changed text and bundle files
- Secret/private-key/token scan over changed text and bundle files

## Completion

Leave the result uncommitted for orchestrator review and wake the rPVA
orchestrator with branch/status, changed files, updated registry/tag/runbook
posture, bundle paths/checksums, validation results, Docker build decision,
residual ITS/Barry questions, and an accept/revise recommendation.
