# Current Task For `stochastic`: Bootstrap Orientation Only

## Objective

Orient the WSL/campus rPVA worker and report whether the environment appears
ready for a future, separately authorized image publication task.

This task is read-only orientation. It does not authorize image build, tag,
push, registry publication, dev-server access, deployment, compose commands,
service restart, source push, token creation, credential capture, or live state
changes.

## Boundaries

- Work only inside the WSL clone of the rPVA repository.
- Do not read Chief of Staff, Goal Composer, sibling projects, archive folders,
  or any non-rPVA repository.
- Do not contact Barry, Chief, Mark, ITS, students, Moodle admins, or campus
  staff from this agent.
- Do not write credentials, tokens, passwords, private keys, shell history
  captures, Docker login config, `.env` files, full environment dumps, student
  identifiers, live service secrets, or sensitive config payloads into repo
  files, reports, screenshots, transcripts, markdown, logs, or chat.
- Do not change app/package code, Shiny UI/server/CSS, science/YAML/model
  defaults, Practical 2 implementation, assessment design, dependencies,
  Moodle/student-facing release state, KPZ314 material, or unrelated project
  files.

## Read First

```text
docs/ops/stochastic/README.md
docs/ops/stochastic/inbox/current-task.md
```

## Checks To Run

Use non-secret commands only. Suggested checks:

```sh
pwd
git branch --show-current
git rev-parse HEAD
git status --short --branch
uname -a
cat /etc/os-release
git --version
docker --version
docker info --format 'server={{.ServerVersion}} arch={{.Architecture}} cpus={{.NCPU}}'
curl -I --max-time 10 https://git.its.utas.edu.au/
```

If any command would prompt for credentials or reveal a secret, stop that check
and report the blocker instead.

For Gitea reachability, report only non-credential host reachability and the
HTTP/TLS result class. Do not log in and do not test private repository access
unless a later task explicitly authorizes it.

## Report

Write the report to:

```text
docs/ops/stochastic/outbox/current-report.md
```

Include:

- `pwd`;
- branch, HEAD, and `git status --short --branch`;
- host/OS summary;
- Git availability;
- Docker CLI/daemon availability;
- non-secret Gitea host reachability;
- any missing tools or blockers;
- whether the environment appears ready for a future explicitly authorized
  Goal 042-style image publication task;
- boundary confirmation.

After writing the report, wait for Barry to relay it back to the rPVA
orchestrator.
