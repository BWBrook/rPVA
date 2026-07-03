# Current Task For `stochastic`: Waiting

No active task is currently authorized for `stochastic`.

`stochastic` must wait for a new repo-local inbox task and, if applicable, an
explicit goal packet before doing work. This waiting state intentionally does
not authorize image builds, registry login, registry push, source push, report
branch push, dev/prod host login, compose commands, service restart, app/source
edits, ShinyProxy/nginx/systemd/firewall/DNS/TLS changes, credential handling,
student/Moodle contact, KPZ314 work, Practical 2 implementation, external
contact, or public exposure.

The next authorized task must name:

- the branch/report protocol;
- the source ref to use;
- any permitted GitHub report branch push;
- any permitted ITS Gitea host/registry operation;
- the exact evidence and report paths;
- the boundaries and stop rules.

Until then, only read this file and the protocol overview:

```text
docs/ops/stochastic/README.md
```
