# Goal 027 Trusted Class Hostname TLS Gate Report

## Status

Goal 027 stopped before live nginx/TLS changes.

No approved class hostname and no browser-trusted certificate path were
available in the current host/repo evidence. The conditional implementation
gate therefore did not pass.

No live service, nginx config, ShinyProxy config, certificate file, private
key, DNS, firewall, Docker daemon/service, account, credential, student
workspace, app/package code, tests, science/YAML, Practical 2 mode, assessment
design, dependency, commit, push, merge, PR, or Goal 028 work was changed.

## Start State

- Local repo: `/Users/bwbrook/git/rPVA`
- Branch: `codex/rpva-goal027-trusted-class-hostname-tls`
- Start `HEAD`: `20f18c356ea5197ec75f6f415eff73149078aeb5`
- Start commit: `20f18c3 Record campus route TLS readiness diagnostics`
- Start status: only the Goal 027 packet directory was untracked
- Repo-local `AGENTS.md`: absent

## Live Service Posture

Read-only checks via `deep-server-ts` found:

- host: `deep-server`
- FQDN reported by host: `deep-server`
- ShinyProxy: active
- nginx: active
- nginx listener: `0.0.0.0:443` and `[::]:443`
- ShinyProxy listener: `[::ffff:127.0.0.1]:3838`
- tailnet gateway health:
  `https://100.96.185.60/_gateway-health` returned HTTP 200
- credential file permissions:
  `bwbrook:bwbrook 600`
- ShinyProxy config permissions:
  `root:bwbrook 640`
- public certificate permissions:
  `root:root 644 /etc/ssl/certs/ssl-cert-snakeoil.pem`
- private-key path permissions, content not printed:
  `root:ssl-cert 640 /etc/ssl/private/ssl-cert-snakeoil.key`
- ShinyProxy JAR permissions:
  `root:root 644`

Redacted live route shape:

- nginx listens on `443 ssl`.
- nginx `server_name` currently includes:
  `deep-server`, `utas-ubuntu`, `utas-ubuntu.tail77f589.ts.net`,
  `131.217.90.193`, `100.96.185.60`, and `_`.
- nginx serves:
  `/etc/ssl/certs/ssl-cert-snakeoil.pem`.
- nginx proxies `/` to:
  `http://127.0.0.1:3838`.
- ShinyProxy remains bound to:
  `127.0.0.1:3838`.
- ShinyProxy app id remains:
  `practical1`.
- ShinyProxy app image remains:
  `rpva-practical1:goal025-5c9d500`.

No credential value, private-key content, or sensitive config payload was
printed or copied into this report.

## Current Certificate

The active public certificate is:

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

This is not a browser-trusted certificate for a class URL.

## Candidate Hostnames

### `deep-server`

- Remote host reports `deep-server` as its hostname and FQDN.
- Remote `/etc/hosts` maps it to `127.0.1.1`.
- The Mac mini did not resolve `deep-server`.
- The current certificate SAN covers `DNS:deep-server`, but the certificate is
  self-signed and the name is not a class route.

Decision: not suitable for student or campus browser use.

### `utas-ubuntu` and `utas-ubuntu.tail77f589.ts.net`

- Remote and Mac mini resolution maps these names to `100.96.185.60`.
- This is the Tailscale/tailnet route.
- `curl` without `-k` to
  `https://utas-ubuntu.tail77f589.ts.net/login` failed with:
  `SSL certificate problem: self signed certificate`.
- `openssl s_client` for `utas-ubuntu.tail77f589.ts.net` reported the current
  `CN=deep-server` self-signed certificate and:
  `Verify return code: 62 (hostname mismatch)`.
- `/var/lib/tailscale/certs` was absent.
- `tailscale` is installed at `/snap/bin/tailscale`, but no existing trusted
  Tailscale certificate was present.

Decision: useful as an admin/supervisor tailnet route, but not suitable as the
only trusted class route. The Goal 027 stop rule explicitly excludes a
tailnet-only trusted route as sufficient for student use.

### `131.217.90.193`

- This is the raw campus/public IP route.
- Goal 026 and Barry's campus-side observation show this can reach the login
  page from inside the University network.
- A raw IP URL is not a class-appropriate hostname and is not covered by the
  current certificate SAN.

Decision: not suitable for student use.

### `SET-BIO-2621GL2.zoo.utas.edu.au`

- Reverse lookup for `131.217.90.193` returns:
  `SET-BIO-2621GL2.zoo.utas.edu.au`.
- The Mac mini and `deep-server` both resolve this name to `131.217.90.193`.
- A Mac mini TLS socket check to port `443` timed out after 12 seconds, matching
  the previously observed local-origin campus/public route limitation.
- This name is not currently in the live nginx `server_name` list.
- No trusted certificate for this name was found on the host.
- Ownership and certificate authority for this institutional DNS name are not
  established in the Goal 027 packet or repo-local docs.

Decision: possible institutional lead for Barry/campus IT to assess, but not
approved or cert-ready for Goal 027 live changes.

## Certificate Mechanism Discovery

Read-only host discovery found:

- `certbot`: absent
- `acme.sh`: absent
- `caddy`: absent
- `tailscale`: `/snap/bin/tailscale`
- `/etc/letsencrypt/live`: absent
- `/var/lib/tailscale/certs`: absent
- targeted SSL files found only the current snakeoil certificate and key paths

No non-interactive, approved certificate issuance path was available for a
class-appropriate hostname.

## Gate Decision

The conditional implementation gate failed before live changes:

- Gate 1 failed: no approved class/supervisor hostname is explicit.
- Gate 2 failed for class use: no approved class hostname is known to resolve
  to the intended gateway from the relevant student-like network.
- Gate 3 failed: no browser-trusted certificate path for an approved hostname
  is present.
- Gate 4 cannot be satisfied until hostname and certificate ownership are
  known.

Because these gates failed, no nginx, TLS, DNS, ShinyProxy, account,
credential, firewall, trust-store, Docker, or service-state changes were made.

## Exact Blocker

Goal 027 is blocked on external DNS/certificate ownership:

1. Barry or the relevant campus IT owner must approve the hostname students
   should use.
2. DNS must point that hostname at the intended gateway route.
3. A browser-trusted certificate and private key for that hostname must be
   provided on `deep-server`, or an approved non-interactive issuance mechanism
   must be documented.
4. The certificate owner must define renewal and rollback expectations.

The likely institutional lead to investigate is the reverse-DNS name
`SET-BIO-2621GL2.zoo.utas.edu.au`, but this goal cannot assume that name is
approved for teaching or that rPVA may obtain a certificate for it.

## Recommended Next Gate

Keep the current service at non-student staging status, or roll it back using
the Goal 025 rollback instructions if supervisor staging is no longer needed.

Before another implementation attempt, obtain a short written decision with:

- approved class/supervisor hostname;
- DNS owner and intended record;
- certificate owner and issuance mechanism;
- certificate file path and private-key path on `deep-server`, or approved
  non-interactive commands to create them;
- renewal owner;
- permission to make a narrow nginx TLS edit with rollback.

After that, a future goal can make the minimal reversible nginx/TLS change,
run `sudo -n nginx -t`, reload nginx only after syntax validation, and prove:

- browser-trusted login page;
- authenticated non-student `/app/practical1`;
- comparison CSV download;
- evidence-notes Markdown download;
- no student-facing release until class accounts, workspaces, load testing,
  fallback, cleanup, and release approval are separately complete.

## Rollback

No live change was made in Goal 027, so no Goal 027 rollback is required.

Existing Goal 025 rollback instructions remain the rollback path for stopping
or removing the non-student staging service.

## Validation Summary

Validation commands and final posture checks are recorded in `Log.md`.
