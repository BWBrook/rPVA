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

## Approval Handoff

Before any future staging goal starts, Barry/SRF must approve:

- source commit or image tag for staging;
- DNS/URL and app path;
- TLS/certificate owner and acceptable trust state;
- identity model and account/token distribution channel;
- per-student workspace root, quota target, and retention period;
- ShinyProxy internal port and nginx upstream alignment;
- monitoring owner and check cadence;
- rollback owner and exact stop rule;
- cleanup owner and cleanup date;
- support/fallback materials location;
- decision that staging remains non-student until an explicit release gate is
  accepted.

## Go/No-Go Checklist

| Gate | Go condition | Stop condition |
| --- | --- | --- |
| TLS and URL | Student-facing URL is trusted or exception is explicitly accepted | Browser shows unacceptable warning or DNS ownership is unclear |
| Identity | Generated accounts/tokens or approved institutional auth are ready and revocable | Shared unauthenticated access is required for recoverable exports |
| Workspaces | One host workspace per authenticated student is mapped read/write | One shared writable class directory would be used |
| Quotas | Per-student target and cleanup policy are approved | Unlimited workspace growth is possible during class |
| Image | Exact image tag/source commit is approved | Image provenance or rebuild path is ambiguous |
| ShinyProxy config | Application config has reviewed concrete values outside the repo | Real credentials or student identifiers would be committed |
| nginx route | Upstream and app path match ShinyProxy and are reversible | Gateway route is edited without rollback notes |
| Local test | `deep-server` localhost app-path smoke passes | Local path fails or container/service state is unclear |
| Tailnet test | Admin/tailnet app-path smoke passes | Only localhost works |
| Student route | Windows/WSL or equivalent student-like browser path passes | Only admin routes work, or TLS warning is unacceptable |
| Monitoring | Status, container count, resource, disk, log, and workspace checks are ready | No one can detect overload or failed sessions |
| Rollback | Stop/revert commands and owner are written before service edits | Rollback depends on improvisation |
| Cleanup | Accounts/tokens, workspaces, logs, containers, and image policy are written | Cleanup is unspecified |
| Fallback | Static worksheet, precomputed outputs, and demonstrator notes are ready | Live app is the only teaching path |

## Future Staging Evidence To Capture

Capture in the future approved staging goal:

- branch and source commit;
- approved image tag and image ID;
- ShinyProxy config path and redacted config summary;
- nginx app path/upstream summary;
- local, tailnet, campus/student-like route outcomes;
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
- Do not launch a container.
- Do not expose a public, campus, tailnet, or student-facing service.
- Do not create or store real passwords, tokens, student identifiers, private
  TLS material, or plausible credentials.

## Teaching And Research Boundary

This checklist is for Practical 1 teaching delivery only. It must not encode
future Lord Howe Island woodhen recovery research assumptions, data choices,
scenario parameters, or manuscript-analysis decisions.
