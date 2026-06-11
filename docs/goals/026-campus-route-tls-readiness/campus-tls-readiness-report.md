# Goal 026 Campus Route And TLS Readiness Report

## Status

Goal 026 completed read-only campus-route and TLS/browser-trust diagnostics for
the current non-student Practical 1 ShinyProxy staging service.

No live service, nginx, ShinyProxy, certificate, trust-store, DNS, firewall,
Docker daemon/service, account, credential, student workspace, implementation,
test, science/YAML, Practical 2, assessment, dependency, commit, push, merge,
or PR changes were made.

## Start State

- Local repo: `/Users/bwbrook/git/rPVA`
- Branch: `codex/rpva-goal026-campus-tls-readiness`
- Start `HEAD`: `7b0e3fbf9315559c8a06e77efaf4c7c5ba1fff85`
- Start commit: `7b0e3fb Record Practical 1 non-student staging bootstrap`
- Start status: only the Goal 026 packet directory was untracked
- Repo-local `AGENTS.md`: absent

## Live Service Posture

Read-only checks via `deep-server-ts` found:

- host: `deep-server`
- ShinyProxy: active
- nginx: active
- nginx listener: `0.0.0.0:443` and `[::]:443`
- ShinyProxy listener: `[::ffff:127.0.0.1]:3838`
- local ShinyProxy login route: HTTP 200 at `http://127.0.0.1:3838/login`
- Practical 1 image present:
  `rpva-practical1:goal025-5c9d500`
- image id:
  `sha256:29511a9d2e583b38c724c56b8c0f8b947d99f10e0e533c1e9a79d4127b40ab79`
- credential file permissions:
  `bwbrook:bwbrook 600`
- ShinyProxy config permissions:
  `root:bwbrook 640`
- ShinyProxy JAR permissions:
  `root:root 644`

Redacted live route shape:

- ShinyProxy is configured for `proxy.port: 3838` and
  `bind-address: "127.0.0.1"`.
- ShinyProxy uses simple authentication for the single non-student staging
  identity `rpva_goal025_nonstudent`.
- The app id is `practical1`, with container image
  `rpva-practical1:goal025-5c9d500`.
- `server.forward-headers-strategy: native` is present.
- nginx proxies `/` to `http://127.0.0.1:3838`.
- nginx sets `X-Forwarded-Proto https`.
- nginx uses the public certificate file
  `/etc/ssl/certs/ssl-cert-snakeoil.pem`.

No ShinyProxy password value, private key, or sensitive config payload was
printed or copied into this report.

## Route Evidence

Tailnet route from the Mac mini:

- `https://100.96.185.60/_gateway-health`: HTTP 200
- `https://100.96.185.60/login`: HTTP 200 ShinyProxy login response

Authenticated tailnet app smoke:

- login final URL: `https://100.96.185.60/auth-success`
- app final URL: `https://100.96.185.60/app/practical1`
- app response: HTTP 200
- app marker check: expected Practical 1/PVA/Compare/Concept Lab text present

Campus/public-IP route from the Mac mini:

- `https://131.217.90.193/_gateway-health`: timed out after 10 seconds
- `https://131.217.90.193/login`: timed out after 10 seconds
- No repeated campus/public-IP probing was attempted after the short-timeout
  result.

Barry-provided campus evidence from inside the University network:

- `https://131.217.90.193/login` reaches a ShinyProxy sign-in page.
- The browser still marks the page as not secure, with crossed-out HTTPS.

Interpretation:

- Tailnet route-to-login and authenticated app access are proven for the
  non-student staging identity.
- Campus route-to-login is proven from Barry's campus-side browser observation,
  not from the Mac mini origin.
- Campus authenticated app access is not yet proven.
- Student/class readiness is not proven.

## TLS And Browser-Trust Diagnosis

The active nginx certificate path is:

```text
/etc/ssl/certs/ssl-cert-snakeoil.pem
```

Read-only public certificate inspection reported:

- subject: `CN = deep-server`
- issuer: `CN = deep-server`
- validity: `2025-11-03 05:03:54 GMT` to `2035-11-01 05:03:54 GMT`
- Subject Alternative Name: `DNS:deep-server`
- SHA256 fingerprint:
  `87:2B:46:D8:42:F9:CA:3F:1A:33:19:FB:8D:72:CF:53:36:F4:8E:65:69:5E:E8:3F:82:DF:CF:20:7B:BF:F9:52`

Tailnet `openssl s_client` verification against `100.96.185.60` reported:

- `verify error:num=18:self-signed certificate`
- `verify error:num=64:IP address mismatch`
- `Verify return code: 64 (IP address mismatch)`

The certificate has no SAN for either IP URL:

- `100.96.185.60`
- `131.217.90.193`

Unauthenticated Chromium browser evidence for
`https://100.96.185.60/login` reported:

- page heading: `Your connection is not private`
- browser error: `net::ERR_CERT_AUTHORITY_INVALID`
- screenshot saved outside the repo:
  `/tmp/rpva-goal026-tailnet-cert-warning.png`

Barry's campus-side crossed-out HTTPS observation at
`https://131.217.90.193/login` is therefore consistent with the currently
served self-signed `deep-server` certificate and IP-name mismatch.

## What Remains Unproven

- A trusted student-facing browser URL.
- A DNS hostname approved for the class service.
- A certificate chain trusted by ordinary student browsers for that hostname.
- Campus/public-IP authenticated app access from a student-like browser path.
- Export/download behavior over the campus/public-IP route.
- Class account/token distribution.
- Per-student workspace mapping.
- Load and concurrency behavior.
- Student release readiness.

## Recommended Next Gate

Do not issue the current IP URL as a student-facing service URL.

Recommended next goal: a narrow TLS/DNS/certificate readiness or fix gate before
any student release. That gate should decide and prove:

- the approved hostname students would use;
- who owns DNS and certificate issuance;
- a trusted certificate chain for that hostname;
- nginx still routes to ShinyProxy after the certificate/hostname work;
- unauthenticated campus browser access reaches the login page without a
  browser certificate warning;
- authenticated campus browser access reaches `/app/practical1` using the
  existing non-student staging identity or another approved non-student test
  identity;
- comparison CSV and evidence-notes downloads still work from that browser
  route;
- the result remains non-student until class accounts/workspaces, load testing,
  fallback materials, cleanup, and release approval are separately accepted.

If TLS/DNS ownership is not available in time, keep the current service as
supervisor-only non-student staging or roll it back using the Goal 025 rollback
commands.

## Validation Summary

Validation commands and final posture checks are recorded in `Log.md`.
