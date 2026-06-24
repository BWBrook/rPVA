# Runbook

## Start Guard

```sh
pwd
git rev-parse --abbrev-ref HEAD
git rev-parse HEAD
git status --short --branch
git log -1 --oneline
```

Expected:

```text
pwd: /Users/bwbrook/git/rPVA
branch: codex/rpva-goal037-its-shinyproxy-vm-handoff
base: current origin/main after Goal 036 and the Goal 028 UTAS PKI refinement
```

Stop if there is unexpected dirty state beyond the Goal 037 packet.

## Sources To Read

Read at minimum:

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
- `docs/goals/025-nonstudent-shinyproxy-staging-bootstrap/staging-report.md`
- `docs/goals/026-campus-route-tls-readiness/campus-tls-readiness-report.md`
- `docs/goals/027-trusted-class-hostname-tls-gate/trusted-class-hostname-tls-report.md`
- `docs/goals/028-campus-it-tls-request-pack/campus-it-tls-request-pack.md`
- `docs/goals/035-practical-1-dual-route-roleplay-preflight/dual-route-preflight-report.md`
- `docs/goals/036-practical-1-barry-two-stage-roleplay-execution/roleplay-execution-report.md`
- `docs/teaching/shiny/README.md`

## ITS Facts To Encode

Use Barry-provided ITS facts only:

- RedHat 9, `x86_64/amd64`.
- Rootless Docker.
- Barry can have full access to the dedicated service user, not root.
- ITS manages TLS and DNS registration.
- ITS can provide staging via separate dev/test server or namespace.
- ITS will monitor, back up, and patch the underlying server.
- rPVA/Barry owns application stack maintenance/support, with ITS help during
  setup.
- ITS has a Gitea registry path to create.
- Project/team name: `ecology-teaching-shiny`.
- Current app: KPZ308/rPVA Practical 1.
- Future placeholder app: KPZ314 SDM practical.

Do not invent registry URLs, credentials, hostnames, or account names.

## Suggested File Shapes

### `deploy/shinyproxy/practical1/its-vm-handoff.md`

Include:

- purpose;
- current source state;
- platform assumptions;
- image/build inputs;
- app id and future app placeholder;
- auth boundary;
- rootless Docker notes;
- update workflow options;
- staging proof steps;
- responsibility split;
- open questions for ITS.

### `deploy/shinyproxy/practical1/application.its-staging.example.yml`

Use parseable placeholder YAML. Suggested app id:

```text
kpz308-rpva-practical1
```

Suggested image placeholder:

```text
<GITEA_REGISTRY>/ecology-teaching-shiny/kpz308-rpva-practical1:<TAG>
```

Keep any user/password entries as obvious placeholders only. If including
simple auth, label it as non-student staging only. If documenting SSO or
external auth, keep it as comments or decision notes unless the ShinyProxy
syntax is certain.

Use rootless-safe workspace placeholders, for example:

```text
<ITS_APP_DATA_ROOT>/kpz308-rpva-practical1/workspaces/#{proxy.userId}:/srv/rpva-workspaces/current:rw
```

### `deploy/shinyproxy/practical1/gitea-registry-runbook.md`

Include:

- recommended tag pattern;
- build command from repo root;
- push command once Gitea registry and credentials exist;
- pull/update/restart sequence at a high level for the dedicated service user;
- digest pinning recommendation;
- tarball fallback only for the first deployment if registry setup lags;
- rollback by reverting ShinyProxy config to previous tag/digest.

Do not include real credentials, registry tokens, or actual passwords.

### `docs/goals/037-its-shinyproxy-vm-handoff-pack/mark-reply-draft.md`

Write a concise Teams/email-ready reply Barry can send Mark after review. It
should mention:

- app has no built-in auth;
- prefer ShinyProxy/ITS-layer auth;
- project name `ecology-teaching-shiny`;
- first app `kpz308-rpva-practical1`;
- future app `kpz314-sdm-practical`;
- forthcoming staging snapshot contents;
- no secrets in image/config.

## Validation Commands

```sh
git diff --check
bash -n deploy/shinyproxy/practical1/validate-scaffold.sh
bash deploy/shinyproxy/practical1/validate-scaffold.sh
ruby -e 'require "yaml"; YAML.load_file(ARGV.fetch(0)); puts "ruby yaml parse ok"' deploy/shinyproxy/practical1/application.example.yml
ruby -e 'require "yaml"; YAML.load_file(ARGV.fetch(0)); puts "ruby yaml parse ok"' deploy/shinyproxy/practical1/application.its-staging.example.yml
Rscript -e 'renv::status(sources = FALSE)'
```

If Ruby is unavailable, use another available YAML parser and report the
substitution.

Marker scan:

```sh
files=$( { git diff --name-only --diff-filter=ACMRTUXB; git ls-files --others --exclude-standard; } | sort -u )
pattern="$(printf '%s|%s|%s|%s|%s|%s' 'TO''DO' 'T''BD' 'FIX''ME' 'PLACE''HOLDER' 'X''XX' 'CHANGE''ME')"
test -z "$files" || printf "%s\n" "$files" | xargs rg -n --pcre2 "(?i)($pattern)" || true
```

Secret/private-key scan:

```sh
files=$( { git diff --name-only --diff-filter=ACMRTUXB; git ls-files --others --exclude-standard; } | sort -u )
test -z "$files" || printf "%s\n" "$files" | xargs rg -n --pcre2 "(?i)(api[_-]?key|secret|token|password|credential|passwd|private[ _-]?key|BEGIN (RSA|OPENSSH|EC|PRIVATE) KEY)" || true
```

Stricter scan:

```sh
files=$( { git diff --name-only --diff-filter=ACMRTUXB; git ls-files --others --exclude-standard; } | sort -u )
test -z "$files" || printf "%s\n" "$files" | xargs rg -n --pcre2 "(?i)(api[_-]?key|secret|token|password|credential|passwd)\s*[:=]\s*['\"]?[^'\"[:space:]]{8,}|BEGIN (RSA|OPENSSH|EC|PRIVATE) KEY" || true
```

Route/student-release wording scan:

```sh
files=$( { git diff --name-only --diff-filter=ACMRTUXB; git ls-files --others --exclude-standard; } | sort -u )
test -z "$files" || printf "%s\n" "$files" | xargs rg -n --pcre2 "(?i)(student-ready|release-ready|give .* to students|publish .* to students|raw-IP|not secure|browser warning|self-signed|131\\.217\\.90\\.193|100\\.96\\.185\\.60)" || true
```

Classify all hits. Instructor/deployment warnings are acceptable; claims of
student readiness are not.

## Optional `/tmp` Bundle

If useful, create a small sendable file bundle under:

```text
/tmp/rpva-goal037-its-handoff/
```

It may contain copies of the handoff docs/templates and a checksum manifest.
Do not include image layers, registry credentials, real secrets, generated
student account lists, or private keys.

## Final Response To Orchestrator

Include:

- branch, HEAD, and final status;
- changed/new files;
- handoff pack summary;
- Gitea registry naming recommendation;
- first deployment/update workflow recommendation;
- validation results;
- scan classification;
- `/tmp` bundle path if created;
- remaining ITS questions;
- boundaries observed;
- whether the result is ready for closeout/publication.
