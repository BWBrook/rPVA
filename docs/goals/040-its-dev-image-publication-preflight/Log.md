# Log

## 2026-06-25

### Start Guard

- `pwd`: `/Users/bwbrook/git/rPVA`
- Started from clean current `origin/main` at
  `4bc8c9f6ba550690d088467faac7f65b7d502e3e`.
- Created branch `codex/rpva-goal040-its-dev-image-preflight`.
- No repo-local `AGENTS.md` was present.

### Work In Progress

- Updated current ITS handoff/operator surfaces with Mark's confirmed registry
  image path:
  `git.its.utas.edu.au/UTAS/kpz308-rpva-practical:<TAG>`.
- Updated the ITS staging YAML example to use `shinyproxy-net`.
- Kept the service-user-home workspace root as
  `<SERVICE_USER_HOME>/kpz308-rpva-practical/workspaces/#{proxy.userId}` until
  ITS supplies the exact home path.
- Added a WSL/GlobalProtect image push runbook for Barry's narrow publication
  lane.
- Kept Mac mini as source-of-truth/orchestration; no Gitea login, source clone,
  source push, registry entry, image push, or live service work was attempted.

### Validation

- `git diff --check`: passed.
- Ruby YAML parse for
  `deploy/shinyproxy/practical1/application.its-staging.example.yml`: passed.
- `bash -n deploy/shinyproxy/practical1/validate-scaffold.sh`: passed.
- `bash deploy/shinyproxy/practical1/validate-scaffold.sh`: passed.
- `Rscript -e 'renv::status(sources = FALSE)'`: passed.
- Focused R tests were not run because this goal changed docs/templates and a
  non-live ShinyProxy YAML example only; no R package, Shiny app, workflow, or
  executable build surface changed.
- Read-only Docker availability check passed:
  `server=29.5.3 arch=aarch64 cpus=10 mem=8321515520`.
- Local Mac mini Docker build was skipped: the target image is `linux/amd64`,
  the local engine is Apple Silicon/aarch64, and the build would require a
  sizeable cross-platform R/Shiny image build and package restore. Static
  validation is the appropriate proof for this docs/templates handoff.
- Targeted stale registry stand-in search over current sendable/operator
  surfaces and `/tmp` bundle: no hits for `<ITS_GITEA_REGISTRY>`,
  `<CONFIRMED_ORG_OR_REGISTRY_NAMESPACE>`, `<ROOTLESS_DOCKER_NETWORK>`, or
  `<ITS_APP_DATA_ROOT>`.
- Targeted stale app-id search over current sendable/operator surfaces and
  `/tmp` bundle: no `kpz308-rpva-practical1` hits.
- Sendable bundle audience scan: no hits for internal goal/orchestrator
  wording, `woodhen`, repo-local wording, internal reports, or review-note
  scaffolding.
- Marker scan over changed text and `/tmp` bundle files: no hits.
- Secret/private-key/token scan over changed text and `/tmp` bundle files:
  only the two non-live YAML `password` fields pointing at
  `<ITS_APPROVED_SECRET_SOURCE_OR_HASH>`, duplicated in the generated bundle;
  no real secret values, tokens, private keys, student identifiers, or
  sensitive service payloads.
- Stricter assignment/private-key-block scan over changed text and `/tmp`
  bundle files: the same two YAML stand-ins only; no real secret/private-key
  block.

### Bundle

- Regenerated sendable bundle:
  `/tmp/rpva-goal040-its-dev-image-preflight/`.
- Mirrored bundle:
  `/Users/bwbrook/Library/CloudStorage/OneDrive-UniversityofTasmania/EXCHANGE/rPVA/goal040-its-dev-image-preflight-2026-06-25/`.
- Bundle contents:
  - `README-send-to-ITS.md`
  - `mark-dev-image-message-draft.md`
  - `its-vm-handoff.md`
  - `gitea-registry-runbook.md`
  - `wsl-image-push-runbook.md`
  - `application.its-staging.example.yml`
  - `SHA256SUMS.txt`
- `/tmp` and OneDrive copies both passed `shasum -a 256 -c SHA256SUMS.txt`.
- `diff -qr` found no differences between the `/tmp` and OneDrive bundle
  copies.
- Checksums:

```text
1d2f0d67e1e1a1cdada9a1f80546b8b8ee9136997e4d2c6c793dcaf77a125deb  README-send-to-ITS.md
81817b4c6f965f956c615d96427da137930c44b01991135bdd2ac9a4b64d2a17  mark-dev-image-message-draft.md
12ab3ea65085042ec0176471990964cc69f918096ba6fed2dc67647d2e39b4cd  its-vm-handoff.md
3e47ed34f666c5f94be53aabab2c06111b8479e0ef4961136a5d75737f8245b0  gitea-registry-runbook.md
722715ec41b857fc804975e11844ffce833d08d877216613f2da9cbec10fe814  wsl-image-push-runbook.md
fddbf2baaef9db93a75f9187bb9eb78f42c550e01d13b5fa7ad00258c8a9f3ad  application.its-staging.example.yml
```

### Residual Questions

- Exact service-user home path to replace `<SERVICE_USER_HOME>`.
- First immutable tag convention for the dev-server image.
- Whether ITS wants ShinyProxy pinned to tag or digest after first publication.
- Final SSO/group names for non-student dev access.
- Dev-server deployment directory for `docker compose down` and
  `docker compose up -d`.
- Preferred non-secret evidence to send Mark after the first WSL push.

### Recommendation

Ready for orchestrator review. The next gate should be a separate
human-assisted WSL publication goal once the reviewed source ref, immutable tag,
and remaining ITS merge values are chosen.
