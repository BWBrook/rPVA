# Goal 039: Gitea Handoff Identity Refresh

## Objective

Refresh the repo-local ITS ShinyProxy VM/Gitea handoff materials so the current
operator-facing package uses Barry's confirmed ITS Gitea repository and
canonical app/repo id:

- Gitea instance: `https://git.its.utas.edu.au/`
- private source repository: `https://git.its.utas.edu.au/UTAS/kpz308-rpva-practical.git`
- repository owner/path: `UTAS/kpz308-rpva-practical`
- app/repo id: `kpz308-rpva-practical`

The previous `kpz308-rpva-practical1` name is stale. The no-`1` id is
intentional because the ShinyProxy app identity should cover both KPZ308 rPVA
practical weeks, even though the current repo-local app surface is Practical 1.

## Context

ITS has provided access to its Gitea instance. Barry can access it from WSL on
GlobalProtect VPN, but the Mac mini currently cannot see it. This goal must not
require Mac mini Gitea access and must not test or alter live Gitea, registry,
VM, or ShinyProxy state.

The coordination/access-group concept `ecology-teaching-shiny` remains useful
where clearly labelled that way, but it is not the actual current Gitea
repository namespace. The actual current Gitea repository is
`UTAS/kpz308-rpva-practical` unless ITS later moves it to a different
namespace.

## In Scope

- Create this Goal 039 packet and a concise handoff-refresh report.
- Update current ITS handoff/operator surfaces that still use the stale
  `kpz308-rpva-practical1` id.
- Include the confirmed Gitea clone URL where it belongs.
- Use neutral registry placeholders until ITS confirms the container registry
  host/path and namespace.
- Preserve Goal 037 as historical context rather than rewriting accepted
  history.
- Regenerate a non-secret handoff bundle under `/tmp/rpva-goal039-its-handoff/`.
- Run static validation, YAML parsing, renv status, stale-name searches, and
  text scans.

## Out Of Scope

- Logging in to Gitea, cloning from Gitea, pushing to Gitea, creating tokens,
  creating registry entries, building images, pushing images, or testing
  network access to `git.its.utas.edu.au`.
- App/package code, Shiny UI/server/CSS, tests unless needed for docs
  validation, science/YAML/model defaults, Practical 2 implementation,
  assessment design, dependencies, Docker build artefacts, live ShinyProxy
  state, DNS/TLS/nginx/systemd/firewall, accounts, credentials, tokens,
  Moodle/student-facing release state, KPZ314 materials, PRs, or Goal 040.

## Deliverables

- Updated current deploy/handoff docs and ITS staging YAML.
- `handoff-refresh-report.md`.
- `mark-update-draft.md`.
- `README-send-to-ITS.md`.
- Updated `Log.md`.
- `/tmp/rpva-goal039-its-handoff/` bundle with refreshed copies and
  `SHA256SUMS.txt`; the sendable bundle should exclude internal review reports.

## Validation

- `git diff --check`
- YAML parse/syntax check for modified ShinyProxy YAML examples
- `bash -n deploy/shinyproxy/practical1/validate-scaffold.sh`
- `bash deploy/shinyproxy/practical1/validate-scaffold.sh`
- `Rscript -e 'renv::status(sources = FALSE)'`
- Targeted stale-name searches over current handoff surfaces
- Marker scan over changed text and generated bundle manifest
- Secret/private-key/token scan over changed text and generated bundle manifest

## Completion

Leave the result uncommitted for orchestrator review and wake the rPVA
orchestrator with branch/status, changed files, stale-name search results,
bundle path/checksums, validation results, residual ITS/Barry questions, and an
accept/revise recommendation.
