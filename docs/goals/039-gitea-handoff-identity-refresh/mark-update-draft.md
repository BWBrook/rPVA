# Draft Update For Mark / ITS

Hi Mark,

Thanks again for the Gitea access path. I have refreshed the rPVA/ShinyProxy
handoff material to use the repository Barry created:

- Gitea instance: `https://git.its.utas.edu.au/`
- private source repository:
  `https://git.its.utas.edu.au/UTAS/kpz308-rpva-practical.git`
- current repository owner/path: `UTAS/kpz308-rpva-practical`
- ShinyProxy app/repo id: `kpz308-rpva-practical`

The no-`1` name is intentional. The first packaged app surface is the Practical
1 concept lab, but the app/repo identity should cover both KPZ308 rPVA
practical weeks.

For the next staging step, could ITS please confirm:

1. The container registry host and package path we should use for this repo.
2. Whether the repository should stay under `UTAS/`, and whether
   `ecology-teaching-shiny` should be used only as an access-group or
   coordination label unless ITS later creates a matching namespace.
3. The source/registry access-group shape Barry/rPVA should use.
4. The dedicated service-user app data root and rootless Docker network name.
5. The ShinyProxy restart/update path available to the service user.
6. Whether non-student staging should use ITS SSO/proxy auth or temporary
   ITS-approved ShinyProxy simple auth.

I will keep the rPVA app free of built-in login logic and treat authentication
as an ITS/ShinyProxy-layer concern unless you advise otherwise. I also will not
publish student-facing links until the ITS staging URL, TLS/browser trust,
auth, per-user workspaces, monitoring, rollback, and cleanup gates are all
accepted.

Regards,

Barry
