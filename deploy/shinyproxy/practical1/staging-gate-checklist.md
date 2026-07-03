# Practical 1 Shiny Staging Gate Checklist

This is an inert checklist for a future approved staging pass. It is not an
operations script and must not be treated as authorization to install,
configure, restart, expose, or edit any live service.

## Evidence Already Accepted

- Goal 017 selected ShinyProxy backed by Docker on `deep-server` as the leading
  self-managed path.
- Goal 018 created the inert ShinyProxy/Docker/nginx scaffold.
- Goal 019 tightened the scaffold locally.
- Goal 020 proved that image `rpva-practical1:goal020-6ed2445` builds on
  `deep-server` `x86_64` and returns the Practical 1 PVA page from a
  localhost-only smoke.
- Goal 037 records the newer ITS direction: `deep-server` is no longer the
  intended student-hosting machine, and the next staging handoff should target
  the ITS-managed RedHat 9 `x86_64/amd64` VM with rootless Docker, ITS-managed
  TLS/DNS, and a possible teaching-Shiny coordination/access-group label
  `ecology-teaching-shiny`.
- Goal 039 refreshes the current handoff identity to Barry's confirmed private
  ITS Gitea repo `UTAS/kpz308-rpva-practical` and canonical ShinyProxy app id
  `kpz308-rpva-practical`. The no-`1` app id is intentional because the app
  identity should cover both KPZ308 rPVA practical weeks.
- Goal 040 records the WSL/GlobalProtect publication lane, `shinyproxy-net`,
  service-user-home app data direction, ITS/Gitea handoff, and future
  dev-server compose restart path from the pre-publication handoff.
- Goal 043 records the lowercase Docker image namespace
  `git.its.utas.edu.au/utas/kpz308-rpva-practical:<TAG>` after `stochastic`
  proved Docker rejects the uppercase namespace; it also adopts the Dockerfile
  `listenv` restore fix and records dev/prod browser smoke, export-shape,
  staff-access, capacity, monitoring, access-group, and dev-first/prod-second
  promotion evidence.

## Future Promotion And Release Handoff

Before any future image promotion or student-release step, Barry/SRF should
confirm:

- reviewed source commit and readable immutable image tag;
- dev-first, prod-second promotion using
  `git.its.utas.edu.au/utas/kpz308-rpva-practical:<TAG>`;
- source repo `UTAS/kpz308-rpva-practical` remains the source owner/path, not
  the Docker image namespace;
- final teaching-channel link text and Moodle wording;
- optional final staff smoke through `UNI-Ecology-Teaching-Shiny-Staff`;
- workspace cleanup/retention policy;
- monitoring owner and class-day check cadence;
- rollback owner and exact stop rule;
- support/fallback materials location;
- decision timing before first planned student app contact on `2026-07-20`.

## Student Release Go/No-Go Checklist

The ITS infrastructure, SSO/auth, staff access, dev/prod browser smokes,
exports, monitoring, and host/container/app capacity gates have passed at
staff/tester level. The 60-container capacity rehearsal was not a test of 60
distinct SAML identities.

| Gate | Go condition | Stop condition |
| --- | --- | --- |
| Image | Exact source commit and readable immutable image tag are approved | Image provenance or rebuild path is ambiguous |
| Dev/prod promotion | Dev smoke has passed and prod is updated to the same accepted tag | Prod tag differs from accepted dev tag without explanation |
| Staff smoke | Optional final staff login/app/export smoke is accepted or explicitly skipped | Staff tester cannot open the app or export evidence |
| Student link text | Moodle/teaching-channel text points only to the approved route | Students would receive a raw, warning, or unapproved route |
| Monitoring | Status, container count, resource, disk, log, and workspace checks are ready for class day | No one can detect overload or failed sessions |
| Rollback | Stop/revert commands, owner, and response path are written before release | Rollback depends on improvisation |
| Cleanup | Workspace retention and cleanup owner/date are written | Cleanup is unspecified |
| Fallback | Static worksheet, precomputed outputs, demonstrator notes, and support path are ready | Live app is the only teaching path |

## Future Staging Evidence To Capture

Capture in the future approved promotion or release goal:

- branch and source commit;
- approved image tag and image ID;
- ShinyProxy config path and redacted config summary;
- nginx app path/upstream summary;
- dev/prod staff or student-like route outcomes;
- browser screenshot or text marker from the app path;
- service status and log excerpts;
- container count and resource snapshot;
- workspace mapping proof using a non-student test identity;
- rollback test or rollback dry-run evidence;
- cleanup state.

## Do Not Do From This Checklist

- Do not install ShinyProxy.
- Do not edit nginx, systemd, firewall, DNS, TLS, Docker daemon/service,
  accounts, credentials, class workspaces, or external-access settings.
- Do not build an image.
- Do not push to Gitea or any registry.
- Do not launch a container.
- Do not expose a public, campus, tailnet, or student-facing service.
- Do not create or store real passwords, tokens, student identifiers, private
  TLS material, or plausible credentials.

## Teaching And Research Boundary

This checklist is for Practical 1 teaching delivery only. It must not encode
future Lord Howe Island woodhen recovery research assumptions, data choices,
scenario parameters, or manuscript-analysis decisions.
