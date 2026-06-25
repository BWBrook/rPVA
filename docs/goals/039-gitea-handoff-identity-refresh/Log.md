# Log

## 2026-06-25

### Start Guard

- `pwd`: `/Users/bwbrook/git/rPVA`
- Started from clean current `origin/main` at
  `6133239977cfb3c83ce1e4a3a57fbc97cb5ccde8`.
- Created branch `codex/rpva-goal039-gitea-handoff-identity-refresh`.
- No repo-local `AGENTS.md` was present.

### Work In Progress

- Inventoried current ITS/Gitea handoff references.
- Updated current deploy/handoff surfaces from stale
  `kpz308-rpva-practical1` to canonical `kpz308-rpva-practical`.
- Added the confirmed private ITS Gitea clone URL to current handoff docs:
  `https://git.its.utas.edu.au/UTAS/kpz308-rpva-practical.git`.
- Preserved Goal 037 as historical context rather than rewriting accepted
  records.

### Bundle

- Regenerated non-secret bundle at `/tmp/rpva-goal039-its-handoff/`.
- Bundle files:
  - `README-send-to-ITS.md`
  - `application.its-staging.example.yml`
  - `gitea-registry-runbook.md`
  - `its-vm-handoff.md`
  - `mark-update-draft.md`
  - `SHA256SUMS.txt`
- The sendable bundle excludes internal review reports.
- Checksums:

```text
002bdc19f45145967d573a93ba4728df1288d3056d2468ebebbcdeee304d27a6  README-send-to-ITS.md
270733587301c16835d5f4b7ee823f5e95429b7b441be35e10c9a3bdb920a0da  application.its-staging.example.yml
81f6e8a732d1a41a2b93bda8e61aec87fb921cb53b9dc0aef22c69ef2e94eb58  gitea-registry-runbook.md
95105d150e724a30289e6b7ec715226c8071784045d2f842e2a6104a6bdd8c9a  its-vm-handoff.md
0d2668d982bfe60a4d175e6a655e47dd83ebcbab703d84dbdd238c76dad49c2b  mark-update-draft.md
```

### Audience-Polish Revision

- Replaced internal Goal 037 phrasing in the ITS-facing handoff with neutral
  external wording: this handoff does not change app code, Shiny UI/CSS/server
  code, science/YAML/model defaults, dependencies, or tests.
- Added `README-send-to-ITS.md` so the `/tmp` bundle is clearly sendable and
  does not present repo-internal Goal 039 review material as part of the ITS
  handoff.

### Validation

- `git diff --check`: passed.
- Ruby YAML parse for `deploy/shinyproxy/practical1/application.its-staging.example.yml`: passed.
- `bash -n deploy/shinyproxy/practical1/validate-scaffold.sh`: passed.
- `bash deploy/shinyproxy/practical1/validate-scaffold.sh`: passed.
- `Rscript -e 'renv::status(sources = FALSE)'`: passed.
- Targeted stale-name search over current deploy/teaching handoff surfaces:
  no `kpz308-rpva-practical1` hits.
- Search including the Goal 039 packet found only correction/search wording.
- Historical Goal 037 packet still contains `kpz308-rpva-practical1` references
  as accepted historical evidence.
- Registry placeholder search over current deploy and Goal 039 surfaces found
  no old `<GITEA_REGISTRY>/UTAS` or
  `<GITEA_REGISTRY>/ecology-teaching-shiny/...` paths.
- Marker scan over changed text and bundle manifest: no hits.
- Marker scan over changed text and sendable bundle files: no hits.
- Secret/private-key/token scan over changed text and sendable bundle files:
  safety wording plus the two non-live
  `password: "<ITS_APPROVED_SECRET_SOURCE_OR_HASH>"` stand-ins in the YAML
  example; no secret values, private keys, real tokens, student identifiers, or
  sensitive payloads.
- Stricter assignment/private-key-block scan over changed text and sendable
  bundle files: the same two YAML password-source stand-ins only; no real
  secret/private-key block.

### Boundary Notes

- Did not log in to Gitea, clone from Gitea, push to Gitea, create tokens,
  create registry entries, build images, push images, test Mac mini network
  access to Gitea, contact ITS/Barry/Chief/students, or touch VM/ShinyProxy,
  DNS/TLS, Docker, account, credential, Moodle, student-release, app, package,
  science, YAML scenario, dependency, Practical 2, assessment, or KPZ314 state.

### Recommendation

Ready for orchestrator review. The next gate should be ITS/Barry confirmation
of the container registry host/path, registry namespace, access group shape,
service-user paths, auth model, and staging URL ownership.
