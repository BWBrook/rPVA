# Draft Update For Mark / ITS

Hi Mark,

Thanks for confirming the dev-server publication details. I have updated the
rPVA/ShinyProxy handoff material to use:

- source repository:
  `https://git.its.utas.edu.au/UTAS/kpz308-rpva-practical.git`
- registry image path:
  `git.its.utas.edu.au/UTAS/kpz308-rpva-practical:<TAG>`
- Docker network: `shinyproxy-net`
- app/repo id: `kpz308-rpva-practical`

We are keeping the Mac mini as the rPVA source-of-truth and orchestration
machine. WSL on GlobalProtect will be used only as the narrow publishing lane
for building and pushing the dev image to ITS Gitea.

The attached WSL push runbook keeps credentials out of shell history and docs,
builds a `linux/amd64` image from a reviewed rPVA source ref, pushes an
immutable tag to:

```text
git.its.utas.edu.au/UTAS/kpz308-rpva-practical:<TAG>
```

and records the digest to send back for the dev-server config.

The staging YAML still leaves these values for ITS to merge or confirm:

1. exact service-user home path to replace `<SERVICE_USER_HOME>`;
2. final SSO/group names for non-student dev access;
3. tag versus digest pinning for ShinyProxy;
4. deployment directory where Barry should run `docker compose down` and
   `docker compose up -d`;
5. any extra non-secret evidence you want after the first WSL push.

I will keep authentication at the ITS/ShinyProxy layer and will not publish a
student-facing route until the separate staging, TLS/browser-trust, auth,
workspace, monitoring, rollback, and cleanup gates are accepted.

Regards,

Barry
