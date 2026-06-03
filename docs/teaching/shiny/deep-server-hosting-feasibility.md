# Deep-Server Shiny Hosting Feasibility

## Purpose

This note assesses whether `deep-server` is a plausible persistent course
platform for the 2026 rPVA Shiny teaching sequence. It covers live host
findings, current access constraints, and the platform work needed before
students can use the app in a browser.

This is a feasibility note only. No software was installed, no services were
changed, no ports were opened, and no directories, users, or containers were
created during this assessment.

## Summary Finding

`deep-server` remains the preferred host for the four-week rPVA teaching
service.

The host has enough CPU, memory, storage, Docker support, R, and Java for a
ShinyProxy-style deployment. After a follow-up infrastructure fix by Barry's
HPC agent, an HTTPS app gateway is now reachable on port `443` from both the
Mac mini Tailscale path and Barry's WSL/campus route. The main remaining
deployment work is therefore the app platform behind the gateway, identity,
workspace mapping, quotas, and load testing.

## Live Read-Only Probe Evidence

Read-only probes were run from the Mac mini. No elevated or state-changing
commands were used.

### Host Resources

`ssh deep-server-ts 'hostname; nproc; free -h; df -h / /data 2>/dev/null || df -h'`
reported:

- hostname: `deep-server`
- logical CPUs: `64`
- memory: `125Gi` total, `123Gi` available at probe time
- swap: `8.0Gi`
- root filesystem: `937G` total, `831G` available
- `/data`: `13T` total, `4.5T` available

This is comfortably sized for a class under 50 students if the app uses bounded
replicate counts, sampled trajectories, and sensible per-session limits.

### Container Runtime

`docker info` reported:

- Docker Engine Community `29.5.2`
- Docker server active
- zero running containers at probe time
- `overlay2` storage driver
- cgroup version 2
- 64 CPUs and 125.8 GiB total memory visible to Docker
- Docker root directory: `/var/lib/docker`

`podman` was not installed on the visible path.

Docker availability strongly favours ShinyProxy or another container-backed
deployment model.

### R And Java

`R --version` reported:

- R `4.6.0`
- platform `x86_64-pc-linux-gnu`

`java -version` reported:

- OpenJDK `21.0.11`

This is a good baseline for a ShinyProxy feasibility path because ShinyProxy
needs Java, and the rPVA work is already aligned with R 4.6.0.

### Listening Ports

`ss -ltn` showed:

- `0.0.0.0:22` and `[::]:22`
- `127.0.0.1:8787`
- `127.0.0.1:2222`
- local resolver ports
- Tailscale/tailnet listener addresses

No student-facing listener was visible on ports `80`, `443`, `3838`, or `8080`
at probe time.

`nginx`, `apache2`, and `caddy` were not found on the visible path.

### Network Route Checks

Mac mini direct SSH to the campus IP:

- `ssh deep-server 'hostname'` timed out connecting to
  `131.217.90.193:22`.

Mac mini direct TCP probe:

- `nc` to `131.217.90.193:22` timed out.

Barry's WSL/campus route probe:

- `22`: open
- `80`: closed or filtered
- `443`: closed or filtered
- `3838`: closed or filtered
- `8080`: closed or filtered
- `8787`: closed or filtered

Interpretation: administrative access is available over Tailscale and appears
available from at least one campus/VPN route for SSH, but ordinary web access
for students is not currently exposed.

### Gateway Update After Infrastructure Fix

After Goal 012, Barry's HPC agent installed and enabled `nginx`, opened
`443/tcp` for campus/private ranges, configured `/_gateway-health`, and left
RStudio Server local-only on `127.0.0.1:8787`.

Supervisor verification after that update:

- Mac mini Tailscale path:
  - `curl -k https://100.96.185.60/_gateway-health`
  - returned `deep-server app gateway ok`
- Barry's WSL/campus route:
  - `curl -k https://131.217.90.193/_gateway-health`
  - returned `deep-server app gateway ok`
  - port scan: `22` open, `443` open, `80`, `3838`, and `8787` closed or
    filtered

This removes the largest network blocker identified in Goal 012. The root
route currently proxies to `http://127.0.0.1:3838`, so it may show a backend
error until a Shiny/app service is listening there. If the final platform is
ShinyProxy, the deployment goal should either adjust the nginx upstream to the
chosen ShinyProxy internal port or deliberately configure ShinyProxy to match
the current gateway target.

## Four-Week Service Feasibility

The proposed service window covers:

1. Practical 1,
2. one-week break,
3. Practical 2,
4. two-week report-writing period,
5. cleanup after semester.

`deep-server` is a good fit for this because it is:

- physical and persistent,
- already reachable over Tailscale for administration,
- large enough for bounded teaching workloads,
- equipped with Docker,
- equipped with R 4.6.0 and Java 21,
- backed by ample `/data` storage for temporary per-student workspaces.

The four-week window increases the importance of:

- stable URL and TLS,
- service restart behaviour,
- log and disk monitoring,
- quota enforcement,
- backup/export expectations,
- clear cleanup date.

## What Blocks Student Web Access Today

The previous port-443 web-access blocker has been resolved for the tested
Tailscale and WSL/campus routes. Current blockers are now app/platform-oriented:

- no rPVA/Shiny service is listening behind the gateway yet,
- the gateway upstream currently points at `127.0.0.1:3838`,
- ShinyProxy installation/configuration has not been performed,
- student identity, workspace mapping, quotas, and cleanup are not yet
  implemented,
- DNS and certificate polish may still be needed for a student-friendly URL.

## Campus, Firewall, And Reverse-Proxy Work Needed

Before implementation, Barry or the relevant campus IT owner still needs to
decide:

- whether student access should be campus-only, VPN-only, public internet, or
  UTAS-authenticated,
- whether TLS certificates are managed by campus infrastructure, a reverse
  proxy, or another service,
- whether a DNS name can be assigned for the class service,
- whether a reverse proxy should terminate TLS and forward to ShinyProxy,
- how service logs and access logs should be retained and cleaned.

## Recommendation

Keep `deep-server` as the preferred candidate host for rPVA 2026. The successful
port-443 gateway check makes a self-managed pilot realistic.

The best technical platform candidate is ShinyProxy backed by Docker, with a
reverse proxy on `443` and a simple identity/workspace model. Posit Connect may
be preferable only if UTAS already has a supported licence and can host this
teaching service within institutional operations. Barry has indicated that this
is unlikely, and the free Posit tier is too constrained for a class platform.
Shiny Server open source remains less aligned with the per-student workspace and
quota requirement.

## Practical Next Checks

Future implementation or operations goals should check, without changing this
goal's no-change boundary:

- approved hostname/DNS,
- allowed firewall path,
- TLS certificate ownership,
- ShinyProxy installation route,
- Docker image build route,
- authentication mode,
- per-student workspace root under `/data`,
- backup and cleanup policy,
- class-size load test target.
