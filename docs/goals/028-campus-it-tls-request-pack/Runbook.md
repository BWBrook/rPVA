# Runbook

Goal 028 is a docs-only coordination package. Do not run live service changes
or contact campus IT.

## Local Guard

```sh
pwd
git branch --show-current
git rev-parse HEAD
git rev-parse origin/main
git status --short --branch
```

Expected:

```text
branch: codex/rpva-goal028-campus-it-tls-request-pack
HEAD/origin-main base: 2843b0d Record trusted class hostname TLS gate blocker
```

## Source Facts To Use

Use accepted repo-local records:

- `docs/goals/025-nonstudent-shinyproxy-staging-bootstrap/staging-report.md`
- `docs/goals/026-campus-route-tls-readiness/campus-tls-readiness-report.md`
- `docs/goals/027-trusted-class-hostname-tls-gate/trusted-class-hostname-tls-report.md`
- `docs/teaching/shiny/README.md`

Do not read KPZ314 materials. Use only Barry's supplied note:

```text
KPZ314 (Fauna of Tasmania) will also use an R Shiny GUI for a practical
activity on species distribution models.
```

## Draft Structure

`campus-it-email-draft.md` should contain:

1. subject line;
2. short context paragraph;
3. current tested state;
4. problem statement;
5. specific request;
6. questions for IT;
7. short note that rPVA is immediate and KPZ314 is a likely future shared-use
   teaching Shiny service;
8. proposed next step.

`campus-it-tls-request-pack.md` should contain:

1. purpose;
2. current rPVA staging state;
3. current DNS/certificate blocker;
4. candidate/lead hostname facts;
5. required IT decisions;
6. post-approval implementation outline;
7. safety and non-goals;
8. questions Barry needs answered before launching the next implementation
   goal.

## Tone Rules

- Be concise and sendable.
- Do not sound like an ultimatum.
- Do not ask IT to debug R or Shiny.
- Ask for hostname, DNS, certificate, and permission decisions.
- Mention that no student data is currently involved.
- Mention that the service is non-student staging until later release approval.
- Keep the KPZ314 reference as future planning context.

## Validation

```sh
git status --short --branch
git diff --check
Rscript -e 'renv::status(sources = FALSE)'
```

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

Manually confirm scan hits are policy wording, command text, path references,
or redacted diagnostics only.
