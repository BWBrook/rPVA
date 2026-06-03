# Goal 012: Deep-Server Shiny Platform Feasibility

## Objective

Assess and document the feasibility of using `deep-server` as a persistent
course Shiny platform for rPVA, including per-student workspaces, exports,
quotas, and a four-week teaching/assessment service window.

This is a feasibility and architecture goal only. Do not install software,
open ports, edit services, change firewall rules, implement Shiny, edit package
code, or commit/push.

## Context

Barry has approved the Goal 011 direction and identified `deep-server` as the
preferred candidate host. The service should remain available across:

- Practical 1
- one-week break
- Practical 2
- two-week report-writing period
- cleanup after semester

Class size is under 50 students. `deep-server` has 64 logical CPUs and about
128 GB RAM, so hardware should be sufficient if the app is bounded and
load-tested.

Barry would like students to have per-student workspaces for saving and
recovering exports. These can be ephemeral, wiped after semester, and capped at
about 1 GB per student.

Barry also wants the same deployment pattern to be reusable for a later Fauna
of Tasmania species distribution modelling practical. Treat this as a small
teaching-app platform design, not a one-off rPVA demo.

Live supervisor probes before this goal:

- Mac mini direct SSH to `deep-server` campus IP timed out.
- Mac mini `deep-server-ts` over Tailscale worked.
- `deep-server-ts` reported 64 logical CPUs and about 123 GiB available RAM.
- From Barry's Windows/WSL campus/VPN path, port 22 to `131.217.90.193` was
  open, while ports 80, 443, 3838, and 8787 were closed or filtered.

Official documentation checked by the supervisor before this goal:

- ShinyProxy documents per-user Docker containers, authentication support, and
  CPU/memory isolation through container technology.
- ShinyProxy deployment docs describe resource management, service enablement,
  Redis/session persistence options, TLS-related deployment options, and
  Docker requirements.
- Posit Connect docs describe authenticated user metadata, caching, load
  testing support, visit tracking, and runtime scheduling, but institutional
  licensing/support needs to be checked.
- Shiny Server open source is simpler and can host Shiny apps on port 3838, but
  it is less naturally aligned with per-student workspace isolation and quotas.

## Required Sources

Read and use:

- `docs/teaching/shiny/README.md`
- `docs/teaching/shiny/deployment-and-setup-options.md`
- `docs/teaching/shiny/implementation-roadmap.md`
- `docs/teaching/shiny/engine-affordance-audit.md`
- this Goal 012 packet

Use official upstream documentation only if checking platform details online or
with `curl`. Do not rely on forum summaries for platform decisions.

## Permitted Live Probes

You may run read-only probes from the Mac mini to inspect `deep-server` and the
campus/VPN route. Examples:

```sh
ssh deep-server-ts 'hostname; nproc; free -h; df -h / /data 2>/dev/null || df -h'
ssh deep-server-ts 'docker info 2>&1 | sed -n "1,80p"; podman info 2>&1 | sed -n "1,80p"'
ssh deep-server-ts 'R --version 2>&1 | sed -n "1,6p"; java -version 2>&1 | sed -n "1,6p"'
ssh deep-server-ts 'ss -ltn | sed -n "1,80p"'
ssh deep-server-ts 'nginx -v 2>&1; apache2 -v 2>&1; caddy version 2>&1'
ssh wsl-laptop 'for p in 22 80 443 3838 8080 8787; do timeout 5 bash -lc "</dev/tcp/131.217.90.193/$p" >/dev/null 2>&1 && echo port_$p=open || echo port_$p=closed_or_filtered; done'
```

Do not use `sudo` for changes. If a read-only command needs elevated access,
record that it was not available rather than changing host state.

## Deliverables

Create or update only files under:

- `docs/teaching/shiny/`
- `docs/goals/012-deep-server-shiny-platform-feasibility/Log.md`

Create:

1. `docs/teaching/shiny/deep-server-hosting-feasibility.md`
   - live host/resource/network findings
   - whether `deep-server` is plausible for the four-week rPVA service
   - what blocks student web access today
   - what needs campus/firewall/reverse-proxy work

2. `docs/teaching/shiny/student-workspace-and-export-design.md`
   - per-student workspace model
   - identity options: unlisted URL, generated class accounts, UTAS SSO/LDAP,
     reverse-proxy auth, or other reasonable options
   - quota strategy around 1 GB/student
   - export types and retention/cleanup policy
   - privacy and assessment-boundary considerations

3. `docs/teaching/shiny/platform-options-decision-matrix.md`
   - compare ShinyProxy, Shiny Server open source, Posit Connect, and a
     custom Nginx/Docker/systemd approach
   - assess each against persistent service, per-student workspaces, quotas,
     campus access, reliability, operational burden, and reuse for SDM
   - recommend the best candidate for rPVA 2026

4. `docs/teaching/shiny/road-test-operations-plan.md`
   - four-week operating model
   - pre-class load testing plan for under 50 students
   - monitoring and recovery plan
   - fallback materials
   - cleanup/end-of-semester plan
   - where Barry's Windows 11/WSL campus/VPN testing fits

Update:

- `docs/teaching/shiny/README.md` with links to these new docs.

## Boundaries

Do not:

- install ShinyProxy, Shiny Server, Posit Connect, Nginx, Caddy, Docker, or any
  new package
- start, stop, restart, enable, or edit services
- change firewall rules
- open ports
- create users or directories on `deep-server`
- create Docker containers/images
- implement Shiny
- edit package code, scenarios, tests, dependencies, CI, or metadata
- edit Goal 010 assessment files
- commit or push

## Validation

Before reporting back:

- run `git diff --check`
- run `rg -n "TODO|TBD|PLACEHOLDER" docs/teaching/shiny docs/goals/012-deep-server-shiny-platform-feasibility`
  and either remove placeholders or explain intentional hits in the log
- run `git status --short --branch --untracked-files=all`
- confirm Goal 012 changes are limited to the allowed paths

## Report Back

Report:

- files created or changed
- whether `deep-server` remains the recommended host
- recommended platform option and why
- student workspace/export recommendation
- blockers or decisions for Barry
- validation results
- current git status
- confirmation that no install, service change, commit, or push occurred
