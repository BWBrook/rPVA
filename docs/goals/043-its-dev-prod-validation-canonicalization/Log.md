# Log

## 2026-07-03

### Start Guard

- `pwd`: `/Users/bwbrook/git/rPVA`
- Starting branch before Goal 043 branch creation:
  `codex/rpva-goal042-stochastic-image-publication-task`.
- Fetched/pruned origin.
- `origin/main`: `15643e1bdd9714715bffda3b354c969c19667815`
  (`Add stochastic ITS image publication task pack`).
- Created branch:
  `codex/rpva-goal043-its-validation-canonicalization`.
- Start worktree was clean.

### Evidence Reviewed

- Read `origin/codex/rpva-stochastic-goal042-image-publication`.
- Confirmed report branch head:
  `70698cd8a8f7b8f08efc00d0fafe666328145cdc`
  (`Record ITS dev/prod validation handoff`).
- Reviewed:
  - `docs/ops/stochastic/outbox/current-report.md`;
  - `docs/ops/stochastic/outbox/evidence/goal042/its-dev-prod-validation-report.md`;
  - Dockerfile template delta from `origin/main` to the report branch.
- Did not merge the `stochastic` branch.

### Adopted

- Adopted the Dockerfile template preinstall of locked `listenv` 0.10.1 before
  `renv::restore()`, mirroring the earlier R CI workaround for the known
  `renv`/`listenv` restore edge.
- Corrected current operator/sendable Docker image references to lowercase
  `git.its.utas.edu.au/utas/kpz308-rpva-practical:<TAG>`.
- Preserved uppercase `UTAS/kpz308-rpva-practical` only for the ITS Gitea
  source repository owner/path and clone URL.
- Recorded the dev/prod/staff/capacity validation facts in the Goal 043
  closeout report.
- Reset `docs/ops/stochastic/inbox/current-task.md` to a waiting state.
- Replaced the live outbox report template with a compact Goal 042 completion
  pointer.
- After orchestrator review, corrected the staging checklist so Goal 040 is not
  described as having confirmed the lowercase Docker image namespace; Goal 043
  is now the canonical lowercase-image correction point.
- Reworked `its-vm-handoff.md` to separate resolved Goal 043 facts from
  remaining operational questions.
- Updated student-release wording to reflect that infrastructure/auth/capacity
  gates passed at staff/tester level and the remaining release gate is about
  teaching-channel text, optional final staff smoke, fallback/rollback,
  support path, cleanup/retention, and timing before `2026-07-20`.

### Deliberately Not Adopted

- Did not copy raw build logs, push logs, manifests, downloaded HTML,
  checksums, or bulky evidence from the `stochastic` report branch into
  `main`.
- Did not copy credentials, tokens, student identifiers, full environment
  dumps, Docker login config, sensitive service payloads, or live config.
- Did not access WSL, ITS Gitea, the Docker registry, dev/prod hosts, SSH,
  PuTTY, RDS, SSO, DNS/TLS, Docker service state, or ShinyProxy live state.

### Validation

- `git diff --check`: passed.
- Ruby YAML parse for
  `deploy/shinyproxy/practical1/application.its-staging.example.yml`: passed.
- `bash -n deploy/shinyproxy/practical1/validate-scaffold.sh`: passed.
- `bash deploy/shinyproxy/practical1/validate-scaffold.sh`: passed.
- `Rscript -e 'renv::status(sources = FALSE)'`: passed.
- Current operator/protocol surfaces have no uppercase Docker image references
  of the form
  `git.its.utas.edu.au/UTAS/kpz308-rpva-practical:<TAG>`.
- Current operator/protocol surfaces contain lowercase Docker image references
  of the form
  `git.its.utas.edu.au/utas/kpz308-rpva-practical:<TAG>`.
- Source repository references remain clearly source-specific:
  `https://git.its.utas.edu.au/UTAS/kpz308-rpva-practical.git` or
  `UTAS/kpz308-rpva-practical`.
- Historical uppercase Docker image references remain only in older Goal 040
  and Goal 042 evidence/packet files that were deliberately not rewritten.
- Marker scan over changed text: clean.
- Strict secret/private-key/token/student-identifier scan over changed text:
  clean.
- Broader sensitive-term scan found policy wording, SSO/SAML labels,
  angle-bracket YAML placeholders, and the existing WSL hidden-token example;
  no real credentials, tokens, private keys, student identifiers, or sensitive
  service payloads were found.
- Manual evidence review: raw build logs, push logs, manifests, downloaded
  smoke HTML, and checksum bundles remain on the `stochastic` report branch;
  `main` carries only compact canonical summaries and repo-local instructions.
- Revision validation after orchestrator review:
  - `git diff --check`: passed.
  - Ruby YAML parse for
    `deploy/shinyproxy/practical1/application.its-staging.example.yml`:
    passed.
  - `bash -n deploy/shinyproxy/practical1/validate-scaffold.sh`: passed.
  - `bash deploy/shinyproxy/practical1/validate-scaffold.sh`: passed.
  - `Rscript -e 'renv::status(sources = FALSE)'`: passed.
  - Targeted search found no current operator doc attributing the lowercase
    Docker image namespace to Goal 040.
  - Targeted search confirmed `its-vm-handoff.md` separates
    `Known ITS Facts After Goal 043` from `Remaining Operational Questions`.
  - Targeted search confirmed student-release wording now reflects
    post-validation release gating and preserves the caveat that the
    60-container test was not 60 distinct SAML identities.
  - Marker scan over changed text: clean.
  - Strict secret/private-key/token/student-identifier scan over changed text:
    clean.
  - Broader sensitive-term scan found policy wording, SSO/SAML labels,
    angle-bracket YAML placeholders, and the existing WSL hidden-token example;
    no real credentials, tokens, private keys, student identifiers, or
    sensitive service payloads were found.

### Recommendation

Ready for orchestrator review. Leave uncommitted until accepted.
