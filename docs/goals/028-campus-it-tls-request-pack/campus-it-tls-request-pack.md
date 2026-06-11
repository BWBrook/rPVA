# Campus IT TLS Request Pack

## Purpose

This pack converts the Goal 027 DNS/certificate blocker into the external
questions needed before rPVA can attempt a browser-trusted teaching route on
`deep-server`.

It is a coordination document only. It does not change DNS, certificates,
nginx, ShinyProxy, accounts, credentials, student workspaces, app code, tests,
science settings, or live service state.

## Immediate Service And Future Teaching Context

rPVA Practical 1 is the immediate tested service. It is already running as a
non-student ShinyProxy staging service on `deep-server`, using the accepted
Goal 025 source/image state.

Barry also teaches KPZ314 (Fauna of Tasmania), which is expected to use an R
Shiny GUI for a species distribution modelling practical activity. That is
future shared teaching-Shiny context only. No KPZ314 materials were read for
this pack, and this request does not ask IT to support the KPZ314 app content
or implementation.

The useful IT decision is therefore not just "make rPVA work once"; it is to
identify a supportable teaching-Shiny hostname, certificate, and renewal model
that can be reused or extended for later teaching Shiny services.

## Current Accepted rPVA Staging Evidence

Accepted Goal 025-027 records establish the following state:

- Host: `deep-server`.
- Campus/public IP route under discussion: `131.217.90.193`.
- Reverse-DNS lead for that IP: `SET-BIO-2621GL2.zoo.utas.edu.au`.
- ShinyProxy staging service: active, authenticated, non-student only.
- App id: `practical1`.
- App image: `rpva-practical1:goal025-5c9d500`.
- ShinyProxy listener: localhost-bound on port `3838`.
- nginx listener: HTTPS port `443`, proxying to the local ShinyProxy service.
- Barry's campus-side browser reached a ShinyProxy sign-in page at
  `https://131.217.90.193/login`.
- The raw-IP route still showed crossed-out HTTPS / not-secure browser status.

No student accounts, class tokens, student identifiers, class workspaces, or
student release have been created or approved.

## Current TLS And Hostname Blocker

The active nginx certificate identified in Goal 026-027 is:

```text
/etc/ssl/certs/ssl-cert-snakeoil.pem
```

Read-only inspection recorded:

- subject: `CN = deep-server`;
- issuer: `CN = deep-server`;
- Subject Alternative Name: `DNS:deep-server`;
- self-signed certificate;
- no Subject Alternative Name for `131.217.90.193`;
- no Subject Alternative Name for the tailnet IP route;
- no approved class hostname or trusted certificate path available on the host.

Goal 027 stopped before live changes because the implementation gate failed:

- no approved student/supervisor hostname was explicit;
- no DNS owner or intended record was known;
- no browser-trusted certificate path for a class hostname was present;
- certificate issuance and renewal ownership were unclear.

The reverse-DNS name `SET-BIO-2621GL2.zoo.utas.edu.au` is a useful campus-IT
lead to assess, but rPVA cannot assume it is approved as a teaching URL or that
the project may obtain a trusted certificate for it.

## Why Raw IP And Tailnet Routes Are Not Enough

`https://131.217.90.193/login` is useful diagnostic evidence because Barry can
reach the ShinyProxy login page from inside the University network. It is not a
student-ready teaching URL because ordinary browsers do not trust the current
certificate for that IP route.

The tailnet route is useful for administration and supervisor staging checks,
but it is not a suitable sole route for a class. It depends on tailnet access
and still does not solve the browser-trusted class-hostname requirement.

## Decisions Needed From Campus IT

Before another implementation/proof goal can safely change nginx/TLS state, the
rPVA team needs written answers to these questions:

1. What hostname should students and demonstrators use for the teaching Shiny
   service?
2. Is `SET-BIO-2621GL2.zoo.utas.edu.au` appropriate, or should IT create or
   nominate a clearer hostname for teaching Shiny apps?
3. Who owns the DNS record for the approved hostname?
4. Should the DNS record target `131.217.90.193`, or should IT use another
   gateway, alias, or reverse-proxy path?
5. Who owns browser-trusted certificate issuance for the approved hostname?
6. Will IT place certificate and key files on `deep-server`, or provide an
   approved non-interactive issuance mechanism?
7. Who owns certificate renewal, expiry monitoring, and replacement?
8. Should IT own nginx TLS termination, or may the rPVA team make a narrow,
   reversible nginx TLS edit after IT approves the hostname and certificate
   paths?
9. What access model is approved for the class route: campus-only, VPN-gated,
   public internet with authentication, or another model?
10. Can the same hostname pattern or platform decision support later teaching
    Shiny services, including the planned KPZ314 SDM practical GUI?

## Post-Approval Implementation Outline

If IT provides a clear hostname, DNS target, certificate path or issuance
mechanism, renewal owner, and nginx/TLS ownership decision, a later bounded
rPVA implementation goal would:

1. re-check the live service posture without printing secrets;
2. inspect the approved certificate path and permissions without copying
   private-key content into the repo or chat;
3. make only the approved reversible nginx TLS change;
4. run `sudo -n nginx -t` before any reload;
5. reload nginx only after syntax validation passes;
6. prove browser-trusted access to the login page from an approved route;
7. prove authenticated non-student access to `/app/practical1`;
8. prove comparison CSV and evidence-notes downloads still work;
9. document rollback and cleanup.

That future goal would still not be a student release unless class accounts,
student workspaces, load testing, fallback materials, monitoring, cleanup, and
release approval are separately accepted.

## Safety And Non-Goals

The current safe posture is to keep rPVA at non-student staging status while
waiting for the campus IT decision, or roll back the staging service using the
Goal 025 instructions if staging is no longer needed.

This pack does not request or authorize:

- student-facing release;
- student accounts, class tokens, student identifiers, or student workspaces;
- DNS changes by the rPVA team;
- certificate issuance without IT approval;
- nginx, ShinyProxy, firewall, Docker, service, account, or credential changes;
- app/package implementation changes;
- rPVA science/YAML changes;
- Practical 2 app mode;
- assessment design changes;
- KPZ314 implementation or project-material review.

## Recommended Next Gate

Ask campus IT for the hostname/DNS/certificate/renewal/access-policy decision.
After written answers are available, create a separate implementation/proof
goal with those answers as hard gates.

If IT cannot approve a browser-trusted teaching route on `deep-server`, keep
the current service as supervisor-only staging, roll it back, or evaluate an
institutionally managed teaching platform before any student-facing release.
