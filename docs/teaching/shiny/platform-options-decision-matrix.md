# Platform Options Decision Matrix

## Purpose

This note compares platform options for hosting the rPVA Shiny teaching service
on `deep-server` or an equivalent institutional Linux host.

Options compared:

- ShinyProxy,
- Shiny Server open source,
- Posit Connect,
- custom Nginx/Docker/systemd approach.

## Decision Criteria

The platform should support:

- persistent four-week teaching service,
- per-student workspaces,
- quota or resource controls,
- campus/browser access,
- reliability for under 50 students,
- manageable operations,
- reuse for a later Fauna of Tasmania SDM practical.

## Summary Matrix

| Option | Persistent service | Per-student workspaces | Quotas/resource controls | Campus access fit | Reliability | Operational burden | SDM reuse | Overall fit |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ShinyProxy | Strong | Strong | Strong through containers and Docker limits | Strong with reverse proxy/TLS | Strong if configured and load-tested | Moderate | Strong | Best open/platform candidate |
| Shiny Server OSS | Strong for simple apps | Weak to moderate | Weak without extra system work | Strong with reverse proxy/TLS | Good for simple shared apps | Low to moderate | Moderate | Too weak for workspace isolation |
| Posit Connect | Strong | Strong | Strong, depending on licence/configuration | Strong with institutional setup | Strong | Low for Barry if institution supports it; high if self-procured | Strong | Best if UTAS licence/support exists |
| Custom Nginx/Docker/systemd | Moderate to strong | Moderate | Moderate, but hand-built | Strong with enough admin work | Depends on implementation | High | Moderate | Useful fallback, not first choice |

## Option 1: ShinyProxy

ShinyProxy is a container-backed platform for Shiny applications. The Goal 012
supervisor review noted that official documentation describes per-user Docker
containers, authentication support, and CPU/memory isolation through container
technology.

### Strengths

- Natural fit for per-student or per-session containers.
- Docker is already available on `deep-server`.
- Java is already available on `deep-server`.
- Container resource limits can help bound class load.
- Authentication can be paired with generated accounts or institutional auth.
- Reusable for later teaching apps, including SDM workflows.
- Keeps app dependencies inside images rather than the host R library.

### Weaknesses

- Requires installation and service configuration in a later goal.
- Requires reverse proxy/TLS and campus firewall decisions.
- Requires Docker image build and update workflow.
- Requires workspace volume mapping design.
- Requires load testing before class.

### Fit For rPVA 2026

Best open/platform candidate. It aligns with the per-student workspace
requirement and with deep-server's live Docker/Java baseline.

## Option 2: Shiny Server Open Source

Shiny Server open source is simpler and can host Shiny apps as a conventional
server process.

### Strengths

- Simpler conceptual model.
- Common Shiny deployment path.
- Lower initial platform complexity.
- Good for a single shared app with no serious persistence requirement.

### Weaknesses

- Less naturally aligned with per-student isolation.
- Quotas and workspace separation require additional system design.
- Harder to reuse as a general teaching-app platform with heterogeneous
  dependencies.
- App dependency state can become host-level state unless carefully isolated.

### Fit For rPVA 2026

Acceptable only if Barry drops or weakens the per-student workspace requirement.
Not recommended as the main path for the current brief.

## Option 3: Posit Connect

Posit Connect is an institutional-grade publishing platform. The Goal 012
supervisor review noted official documentation for authenticated user metadata,
caching, load testing support, visit tracking, and runtime scheduling.

### Strengths

- Strong publishing and operations model.
- Good authentication and user metadata story.
- Better fit for institutional support if UTAS already uses it.
- Good monitoring and usage visibility.
- Reusable across multiple teaching apps and reports.

### Weaknesses

- Licence/support status must be checked.
- May require institutional IT ownership.
- Could be slower to adopt if Barry does not already control access.
- Might be overkill for a small R&D road test if no existing licence exists.

### Fit For rPVA 2026

Potentially the best institutional option if UTAS already has a supported
licence and deployment pathway. Without that, it is a decision blocker rather
than the fastest route.

## Option 4: Custom Nginx/Docker/Systemd

A custom deployment would use a reverse proxy, Docker containers, and systemd
units written specifically for the teaching service.

### Strengths

- Maximum control.
- Can be built to exactly match Barry's workflow.
- Avoids adopting a larger platform if only one app is needed.
- Good as a recovery or prototype path for a single service.

### Weaknesses

- Recreates platform responsibilities by hand.
- Authentication, workspace mapping, quotas, logs, restarts, upgrades, and
  cleanup all become custom operational work.
- Higher risk of subtle support problems during the teaching window.
- Less reusable than ShinyProxy or Posit Connect unless carefully engineered.

### Fit For rPVA 2026

Reasonable fallback for a tightly scoped prototype, but not the preferred
teaching-platform path.

## Recommended Candidate

Use ShinyProxy on `deep-server`, backed by Docker, with a reverse proxy/TLS
front end and generated class accounts or tokens for the first road test.

Rationale:

- deep-server already has Docker and Java,
- class size is small enough for bounded containerised Shiny sessions,
- per-student workspace mapping is central to the brief,
- the same pattern can support a later SDM teaching app,
- it avoids depending on a Posit Connect licence decision,
- it is more structured than a custom deployment.

Barry's follow-up infrastructure work has made this path more concrete:
`deep-server` now has an nginx HTTPS gateway on `443` that responds to
`/_gateway-health` from both the Tailscale route and Barry's WSL/campus route.
The gateway currently proxies app traffic to `127.0.0.1:3838`, so the next
deployment goal needs to align that upstream with the selected ShinyProxy
service port.

## Conditional Alternative

If UTAS already has Posit Connect available with institutional support, evaluate
it before installing a new ShinyProxy service. Barry currently expects that
UTAS does not have this available, and his free account is too small for a
class platform. Under that assumption, ShinyProxy should be treated as the
primary path.

## Not Recommended As Primary

Do not use an unauthenticated Shiny Server open source deployment as the primary
road-test platform if per-student recoverable exports remain a requirement. It
can host an app, but it does not naturally solve the workspace and quota model.

## Platform Decision For Barry

Barry should decide:

- whether to pursue a self-managed ShinyProxy path on `deep-server`,
- whether campus IT will approve a temporary or persistent web endpoint on
  `deep-server`,
- whether generated class accounts are acceptable for the first road test.
