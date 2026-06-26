# Stochastic WSL Worker Protocol

`stochastic` is a future WSL/campus-connected rPVA operations worker. It is a
narrow bridge for tasks that need ITS Gitea or dev-server reachability.

It is not a general second developer and it is not a replacement for the Mac
mini lane. Mac mini plus the rPVA orchestrator plus `woodhen` remain the
source-of-truth project lane.

## Reporting Line

Barry / Lab Lead -> rPVA orchestrator -> `stochastic`

`stochastic` should treat repo-local instructions as the active source of
truth, starting with:

```text
docs/ops/stochastic/inbox/current-task.md
```

and any later explicitly assigned goal packet.

## Communication Loop

1. The rPVA orchestrator or `woodhen` writes a repo-local inbox task.
2. Barry wakes `stochastic` manually on the WSL/campus machine.
3. `stochastic` reads the inbox task and only the explicitly assigned repo
   files.
4. `stochastic` writes its report to:

   ```text
   docs/ops/stochastic/outbox/current-report.md
   ```

5. Non-secret evidence, when needed, goes under:

   ```text
   docs/ops/stochastic/outbox/evidence/
   ```

6. Barry alerts the rPVA orchestrator that a report is ready, either by pasting
   the report or by syncing the relevant repo/branch state.

The orchestrator should not assume direct Codex thread tools can reach the WSL
worker.

## Branch And File Conventions

- Default work stays in the WSL clone of rPVA.
- `stochastic` should not create or push branches unless the current inbox task
  explicitly authorizes that.
- If a task authorizes a report branch, create it from current `origin/main`
  after a clean fetch/prune and fast-forward update.
- Report branches must begin with `codex/rpva-stochastic-` followed by the task
  slug, for example `codex/rpva-stochastic-goal042-image-publication`.
- `stochastic` must not push `main`.
- `stochastic` must not push to the ITS Gitea source repository unless a later
  task explicitly authorizes that source path. Registry image push is separate
  from source push and must be named explicitly by the inbox task.
- Push report branches to GitHub `origin` only when the current inbox task
  explicitly allows it, and only after confirming the staged files are
  non-secret report/evidence files.
- Inbox files are instructions. Do not rewrite them unless the task explicitly
  asks for that.
- Outbox files are reports. Keep them concise, evidence-backed, and free of
  credentials.

## Evidence Hygiene

Evidence may include non-secret command output, small text summaries,
checksums, image tags, image digests, sanitized screenshots, or sanitized log
snippets when a task explicitly asks for them.

Never write credentials, tokens, passwords, private keys, `.env` files, Docker
login config, shell history captures, full environment dumps, private SSH
config, student identifiers, live service secrets, or sensitive config payloads
into this repo.

If a command would print a secret, stop and report that the check requires a
safer method.

## Default Boundary

Unless the current inbox task explicitly authorizes a live operation,
`stochastic` must not:

- log in to ITS Gitea;
- clone from ITS Gitea;
- push source;
- create tokens;
- build, tag, or push images;
- create registry/package entries;
- log in to the dev server;
- run compose commands;
- restart services;
- edit DNS, TLS, nginx, ShinyProxy, Docker service state, accounts, or
  credentials;
- contact Mark, ITS, students, Moodle admins, Barry, Chief, or external
  services;
- change app/package code, Shiny UI/server/CSS, science/YAML/model defaults,
  Practical 2 implementation, assessment design, dependencies, Moodle/student
  release state, KPZ314 material, or unrelated project files.
