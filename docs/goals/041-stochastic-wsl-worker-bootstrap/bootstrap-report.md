# Goal 041 Bootstrap Report

## Summary

Goal 041 adds a repo-local markdown communication scaffold for a future
WSL/campus-connected worker named `stochastic`.

The scaffold preserves the existing rPVA architecture: Mac mini plus the rPVA
orchestrator plus `woodhen` remain the source-of-truth project lane.
`stochastic` is a narrow operations bridge for tasks that need campus/VPN
reachability, especially future ITS Gitea image publication, registry proof,
and dev-server smoke evidence.

## Scaffold

New files:

- `.gitignore` exception for `docs/ops/`
- `docs/ops/stochastic/README.md`
- `docs/ops/stochastic/priming-prompt.md`
- `docs/ops/stochastic/inbox/current-task.md`
- `docs/ops/stochastic/outbox/current-report.md`
- `docs/ops/stochastic/outbox/evidence/README.md`

## Communication Model

1. The rPVA orchestrator or `woodhen` prepares a repo-local inbox task.
2. Barry wakes `stochastic` manually on the WSL/campus machine.
3. `stochastic` reads only the assigned inbox task and any explicitly named
   goal packet.
4. `stochastic` writes a report to the outbox and places only non-secret
   evidence under the evidence folder.
5. Barry alerts the rPVA orchestrator by pasting or syncing the report.
6. The orchestrator reviews the report from repo/branch updates or pasted
   content, not direct WSL thread tools.

## Initial Task

The first inbox task is bootstrap/orientation only. It asks `stochastic` to
report:

- working directory, branch, HEAD, and git status;
- host/OS details at a non-secret level;
- Git, Docker, and basic shell-tool availability;
- non-credential reachability to `https://git.its.utas.edu.au/`;
- whether future image publication appears feasible after a separate explicit
  goal.

It does not authorize build, tag, push, deploy, service restart, source push,
registry push, token creation, credential capture, or dev-server work.

## Residual Questions

- Should future `stochastic` tasks use a dedicated report branch naming pattern
  when branch push is explicitly authorized?
- Should future WSL evidence be committed to the repo, pasted back by Barry, or
  transferred as a tarball depending on task sensitivity?
- What exact non-secret evidence should the first image publication goal
  require from WSL?

## Recommendation

Accept if validation remains green. The next gate should be Barry launching
`stochastic` manually on WSL with `priming-prompt.md`, then asking it to execute
the bootstrap inbox task only.
