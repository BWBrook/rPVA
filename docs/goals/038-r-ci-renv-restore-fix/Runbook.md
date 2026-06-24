# Runbook

## Start Guard

```sh
pwd
git fetch --prune origin
git status --short --branch
git rev-parse origin/main
git switch -c codex/rpva-goal038-r-ci-renv-restore-fix origin/main
```

Stop if the repo is dirty or `origin/main` is not
`8210219e8fca21238ca668a88250112a4a3e4c1c`.

## CI Evidence

```sh
gh auth status
gh run view 28076391436 --json name,workflowName,conclusion,status,url,event,headBranch,headSha,createdAt,updatedAt,jobs
gh run view 28076391436 --job 83122453023 --log > /tmp/rpva-goal038-ci-logs/run-28076391436-job-83122453023.log
gh run view 27519468070 --json name,workflowName,conclusion,status,url,event,headBranch,headSha,createdAt,updatedAt,jobs
gh run view 27519468070 --job 81334420719 --log > /tmp/rpva-goal038-ci-logs/run-27519468070-job-81334420719.log
```

## Diagnostics

```sh
git diff --name-only 70dca13ce4934dfbd68072cfad41ff27c81cd3a2..8210219e8fca21238ca668a88250112a4a3e4c1c

Rscript - <<'RS'
lock <- renv::lockfile_read("renv.lock")
records <- get("renv_lockfile_records", asNamespace("renv"))(lock)
desc <- get("renv_graph_init", asNamespace("renv"))(
  names(records),
  records = records,
  project = getwd()
)
graph <- get("renv_graph_adjacency", asNamespace("renv"))(desc)
for (pkg in c("listenv", "future", "future.apply")) {
  cat(pkg, "indegree", graph$indegree[[pkg]], "\n")
  cat(pkg, "dependents", paste(graph$revadj[[pkg]], collapse = ", "), "\n")
}
RS
```

## Validation

```sh
git diff --check
actionlint .github/workflows/r-ci.yaml
Rscript -e 'source("bootstrap.R")'
Rscript -e 'renv::status(sources = FALSE)'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_dir("tests/testthat", reporter = "summary")'
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

## Closeout

Leave the repair uncommitted. Wake the orchestrator with:

- branch/status;
- root-cause judgement;
- changed files;
- validation results;
- residual risk, especially whether final proof requires a post-publication
  `main` CI run.
