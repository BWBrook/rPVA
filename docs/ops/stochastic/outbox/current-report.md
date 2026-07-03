# Current Report From `stochastic`: Goal 042 Completed

`stochastic` completed the Goal 042 image publication and follow-on ITS
dev/prod validation on the GitHub report branch:

```text
origin/codex/rpva-stochastic-goal042-image-publication
```

Canonical rPVA-side adoption is recorded in:

```text
docs/goals/043-its-dev-prod-validation-canonicalization/its-dev-prod-validation-closeout.md
```

Raw and bulky evidence remains on the `stochastic` report branch for
provenance. It was not copied wholesale into `main`.

Durable facts adopted into `main`:

- Docker image references use the lowercase registry namespace:
  `git.its.utas.edu.au/utas/kpz308-rpva-practical:<TAG>`.
- ITS Gitea source repository references may still use:
  `https://git.its.utas.edu.au/UTAS/kpz308-rpva-practical.git`.
- The validated image was:
  `git.its.utas.edu.au/utas/kpz308-rpva-practical:dev-20260626-9524304fb748`.
- The pushed digest was:
  `sha256:7aa013152b226d5ba3fcc34d31051fe049dd0f34c2c7e0187de83580523f4340`.
- Dev and prod ShinyProxy browser smokes passed.
- Prod capacity rehearsal passed at 5, 10, 20, 40, and 60 temporary app
  containers; this was host/container/app workload capacity, not 60 distinct
  SAML identities.
- ITS promotion policy is dev first, prod second, using readable immutable
  tags in ShinyProxy config.

No active `stochastic` task is authorized by this report.
