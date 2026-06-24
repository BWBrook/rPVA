# Draft Reply To Mark / ITS

Subject: rPVA/KPZ308 teaching Shiny VM handoff details

Hi Mark,

Thanks for the update. We can work with the dedicated ITS ShinyProxy VM path
and will stop treating `deep-server` as the intended student-hosting machine.

For the first app, I suggest:

- Gitea team/project: `ecology-teaching-shiny`
- first app id: `kpz308-rpva-practical1`
- future app id to reserve only: `kpz314-sdm-practical`

The current rPVA/KPZ308 Practical 1 Shiny app has no built-in login. My
preference is to keep authentication at the ShinyProxy/ITS layer if possible,
either through ITS-managed SSO/proxy auth or, for non-student staging only, an
ITS-approved ShinyProxy simple-auth setup. I do not want passwords, tokens, or
student identifiers stored in the app image or repo.

The handoff snapshot I can provide for ITS review contains:

- the current Practical 1 Dockerfile template;
- the `.dockerignore` template;
- an ITS RedHat 9/rootless-Docker ShinyProxy YAML example;
- a Gitea image naming and update runbook;
- a responsibility split and remaining questions.

Suggested image name shape once ITS creates the Gitea registry is:

```text
<GITEA_REGISTRY>/ecology-teaching-shiny/kpz308-rpva-practical1:<TAG>
```

Suggested tag patterns are:

```text
kpz308-prac1-<short-sha>-staging
kpz308-prac1-<YYYYMMDD>-candidate
```

I would prefer ShinyProxy config to pin an immutable tag or digest rather than
`latest`.

Could ITS please confirm these remaining setup details?

1. Gitea registry URL and project/access-group shape.
2. Dedicated service user name and approved app data root for rootless Docker.
3. Preferred auth model for non-student staging and later class release.
4. Rootless Docker network name and service-user restart/update command path.
5. Whether ShinyProxy app config should pin image tags or digests.
6. Initial CPU/memory limits and any class-concurrency assumptions.
7. Log access, monitoring alerts, backup boundary, and class-day support path.

I will keep the rPVA side limited to the app image/config content, staging proof,
and class-day app behavior. ITS can continue to own the VM, TLS/DNS, OS
patching, backup, monitoring, and platform access model.

Regards,

Barry
