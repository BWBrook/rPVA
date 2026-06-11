# Log

## 2026-06-11 - Orchestrator Packet Creation

- Goal 026 was accepted, committed, and published to `origin/main` before this
  branch was created.
- Starting base for Goal 027:
  - branch: `codex/rpva-goal027-trusted-class-hostname-tls`;
  - base commit:
    `20f18c3 Record campus route TLS readiness diagnostics`;
  - source: `origin/main`.
- Goal purpose:
  - establish a browser-trusted non-student staging URL if a safe, authorized
    class-hostname/certificate path already exists;
  - otherwise produce a precise DNS/certificate/ownership blocker report;
  - avoid issuing raw IP URLs or certificate-warning flows to students.
- Boundary:
  - TLS/DNS/certificate gate for non-student staging only;
  - no student release, class accounts, student workspaces, assessment changes,
    Practical 2 mode, science/YAML changes, app/package changes, dependencies,
    firewall changes, broad host maintenance, public announcement, credential
    exposure, commit, push, merge, or PR work.
- Packet files:
  - `docs/goals/027-trusted-class-hostname-tls-gate/Goal.md`
  - `docs/goals/027-trusted-class-hostname-tls-gate/Plan.md`
  - `docs/goals/027-trusted-class-hostname-tls-gate/Runbook.md`
  - `docs/goals/027-trusted-class-hostname-tls-gate/Log.md`

Status: packet ready for `woodhen`; execution not yet started.

## 2026-06-11 - Woodhen Execution Start

- Read the active Goal 027 packet first:
  - `Goal.md`;
  - `Plan.md`;
  - `Runbook.md`;
  - `Log.md`.
- Read required local context before live diagnostics:
  - project `README.md`;
  - Goal 025 `Goal.md`, `Log.md`, and `staging-report.md`;
  - Goal 026 `Goal.md`, `Log.md`, and
    `campus-tls-readiness-report.md`;
  - Shiny teaching/deployment notes under `docs/teaching/shiny/`;
  - Practical 1 ShinyProxy scaffold files under
    `deploy/shinyproxy/practical1/`.
- Reconfirmed starting local state:
  - `pwd`: `/Users/bwbrook/git/rPVA`;
  - branch: `codex/rpva-goal027-trusted-class-hostname-tls`;
  - `HEAD`: `20f18c356ea5197ec75f6f415eff73149078aeb5`;
  - short status:
    `## codex/rpva-goal027-trusted-class-hostname-tls...origin/main`
    plus untracked `docs/goals/027-trusted-class-hostname-tls-gate/`.
- Confirmed the Goal 026 closeout commit is present:
  `20f18c3 Record campus route TLS readiness diagnostics`.
- Ignored local artefacts observed with ignored-status reporting:
  `docs/teaching/woodhen/.gitignore` and `renv/staging/`.
- No unexpected tracked or non-packet dirty state was present before Goal 027
  edits.
- Boundary being followed:
  start read-only, with live nginx/TLS changes allowed only if every
  conditional implementation gate is satisfied; no student release, class
  accounts/tokens, student identifiers, student workspaces, app/package/test
  code changes, science/YAML changes, Practical 2 mode, assessment changes,
  dependency changes, firewall changes, broad host maintenance, public
  announcement, credential exposure, private-key exposure, commit, push, PR,
  merge, or Goal 028 work.

## 2026-06-11 - Read-Only Live Posture

- Remote posture check via `deep-server-ts`:
  - host: `deep-server`;
  - host FQDN: `deep-server`;
  - `systemctl is-active shinyproxy`: `active`;
  - `systemctl is-active nginx`: `active`;
  - nginx listener: `0.0.0.0:443` and `[::]:443`;
  - ShinyProxy listener: `[::ffff:127.0.0.1]:3838`;
  - tailnet gateway health:
    `https://100.96.185.60/_gateway-health` returned HTTP 200.
- Metadata checks without printing credential or private-key content:
  - credential path:
    `/data/codex/teaching/rpva-2026/staging/credentials/goal025-nonstudent-password.txt`;
  - credential permissions: `bwbrook:bwbrook 600`;
  - ShinyProxy config permissions:
    `root:bwbrook 640 /etc/shinyproxy/application.yml`;
  - public certificate permissions:
    `root:root 644 /etc/ssl/certs/ssl-cert-snakeoil.pem`;
  - private-key path permissions:
    `root:ssl-cert 640 /etc/ssl/private/ssl-cert-snakeoil.key`;
  - ShinyProxy JAR permissions:
    `root:root 644 /opt/shinyproxy/shinyproxy-3.2.4.jar`.
- Redacted nginx route shape:
  - `listen 443 ssl`;
  - `server_name` includes `deep-server`, `utas-ubuntu`,
    `utas-ubuntu.tail77f589.ts.net`, `131.217.90.193`, `100.96.185.60`,
    and `_`;
  - certificate path:
    `/etc/ssl/certs/ssl-cert-snakeoil.pem`;
  - `location /` proxies to `http://127.0.0.1:3838`;
  - forwarded headers include `Host`, `X-Real-IP`, `X-Forwarded-For`, and
    `X-Forwarded-Proto https`.
- Redacted ShinyProxy route/config shape:
  - `proxy.port: 3838`;
  - `bind-address: "127.0.0.1"`;
  - `authentication: "simple"`;
  - single non-student staging identity name:
    `rpva_goal025_nonstudent`;
  - app id: `practical1`;
  - app image: `rpva-practical1:goal025-5c9d500`;
  - `server.forward-headers-strategy: native`.
- Current public certificate metadata:
  - subject: `CN = deep-server`;
  - issuer: `CN = deep-server`;
  - validity: `Nov  3 05:03:54 2025 GMT` to
    `Nov  1 05:03:54 2035 GMT`;
  - Subject Alternative Name: `DNS:deep-server`;
  - SHA256 fingerprint:
    `87:2B:46:D8:42:F9:CA:3F:1A:33:19:FB:8D:72:CF:53:36:F4:8E:65:69:5E:E8:3F:82:DF:CF:20:7B:BF:F9:52`.
- No credential value, private-key content, or sensitive config payload was
  printed or copied into repo files.

## 2026-06-11 - Hostname And Certificate Discovery

- Current nginx `server_name` entries:
  - `deep-server`;
  - `utas-ubuntu`;
  - `utas-ubuntu.tail77f589.ts.net`;
  - `131.217.90.193`;
  - `100.96.185.60`;
  - `_`.
- Remote name resolution:
  - `deep-server`: `127.0.1.1`;
  - `utas-ubuntu`: `100.96.185.60 utas-ubuntu.tail77f589.ts.net`;
  - `utas-ubuntu.tail77f589.ts.net`:
    `100.96.185.60 utas-ubuntu.tail77f589.ts.net`;
  - `131.217.90.193`:
    `131.217.90.193 SET-BIO-2621GL2.zoo.utas.edu.au`;
  - `100.96.185.60`:
    `100.96.185.60 utas-ubuntu.tail77f589.ts.net`.
- Mac mini name resolution:
  - `deep-server`: did not resolve;
  - `utas-ubuntu`: resolved to `100.96.185.60`;
  - `utas-ubuntu.tail77f589.ts.net`: resolved to `100.96.185.60`;
  - `SET-BIO-2621GL2.zoo.utas.edu.au`: resolved to
    `131.217.90.193`.
- `SET-BIO-2621GL2.zoo.utas.edu.au` also resolves to
  `131.217.90.193` from `deep-server`.
- Candidate HTTPS checks:
  - `curl` without `-k` to
    `https://utas-ubuntu.tail77f589.ts.net/login` failed with
    `SSL certificate problem: self signed certificate`;
  - `openssl s_client` for `utas-ubuntu.tail77f589.ts.net` saw the current
    `CN=deep-server` certificate and reported
    `Verify return code: 62 (hostname mismatch)`;
  - a Mac mini TLS socket check to
    `SET-BIO-2621GL2.zoo.utas.edu.au:443` timed out after 12 seconds.
- Certificate mechanism discovery:
  - `certbot`: absent;
  - `acme.sh`: absent;
  - `caddy`: absent;
  - `tailscale`: `/snap/bin/tailscale`;
  - `/etc/letsencrypt/live`: absent;
  - `/var/lib/tailscale/certs`: absent;
  - targeted SSL-file search found only:
    `/etc/ssl/certs/ssl-cert-snakeoil.pem` and
    `/etc/ssl/private/ssl-cert-snakeoil.key`.

## 2026-06-11 - Gate Decision And Report

- Conditional implementation gate outcome: failed before live changes.
- Gate failure details:
  - no approved class/supervisor hostname is explicit in the packet or current
    repo-local records;
  - no browser-trusted certificate path exists for an approved hostname;
  - the tailnet name is useful for supervisor/admin staging but is not
    student-suitable as the only trusted route;
  - the reverse-DNS name `SET-BIO-2621GL2.zoo.utas.edu.au` resolves to the
    campus/public IP, but ownership, approval for teaching use, and certificate
    authority are unclear;
  - no existing non-interactive certificate mechanism was available for a
    class-appropriate hostname.
- Stop rule reached:
  DNS/certificate authority is unclear.
- Live-change decision:
  no nginx, TLS, certificate, private-key, DNS, trust-store, ShinyProxy,
  account, credential, firewall, Docker, or service-state change was made.
- Created:
  `docs/goals/027-trusted-class-hostname-tls-gate/trusted-class-hostname-tls-report.md`.
- Blocker summary:
  Barry or the relevant campus IT owner must approve the hostname, DNS target,
  certificate ownership/issuance path, renewal owner, and permission for a
  narrow reversible nginx TLS edit before another implementation attempt.

## 2026-06-11 - Teaching Boundary Update And Validation

- Updated:
  `docs/teaching/shiny/README.md`.
- README update was limited to the Goal 027 boundary:
  no approved class hostname or browser-trusted certificate path is currently
  available on `deep-server`; `SET-BIO-2621GL2.zoo.utas.edu.au` is a
  campus-IT lead to assess, not an approved teaching URL; a future TLS
  implementation needs hostname, DNS owner, certificate owner/issuance,
  renewal owner, and permission for a narrow reversible nginx TLS edit.
- Changed files:
  - `docs/goals/027-trusted-class-hostname-tls-gate/Goal.md`
  - `docs/goals/027-trusted-class-hostname-tls-gate/Plan.md`
  - `docs/goals/027-trusted-class-hostname-tls-gate/Runbook.md`
  - `docs/goals/027-trusted-class-hostname-tls-gate/Log.md`
  - `docs/goals/027-trusted-class-hostname-tls-gate/trusted-class-hostname-tls-report.md`
  - `docs/teaching/shiny/README.md`
- Required validation:
  - `git status --short --branch`: expected Goal 027 packet plus
    `docs/teaching/shiny/README.md`;
  - `git diff --check`: passed;
  - `bash -n deploy/shinyproxy/practical1/validate-scaffold.sh`: passed;
  - `bash deploy/shinyproxy/practical1/validate-scaffold.sh`: passed;
  - `Rscript -e 'renv::status(sources = FALSE)'`: passed, reporting
    `No issues found -- the project is in a consistent state.`
- Marker scan over changed/untracked text:
  - no unresolved marker hits.
- Secret/private-key-pattern scan over changed/untracked text:
  - hits were policy wording, command text, class account/token boundary
    wording, credential-path references, private-key path references, and
    redacted diagnostic statements only;
  - no real secret values, private keys, tokens, passwords, or sensitive config
    payloads were found in changed repo text.
- Final read-only live posture:
  - ShinyProxy active;
  - nginx active;
  - ShinyProxy listener remains `[::ffff:127.0.0.1]:3838`;
  - nginx listener remains on `443`;
  - `https://100.96.185.60/_gateway-health`: HTTP 200.
- `nginx` was not touched, so no Goal 027 rollback is required and the
  conditional post-edit `sudo -n nginx -t` gate did not apply.
- Final recommendation:
  - keep the current service at non-student staging status or roll it back
    using Goal 025 instructions if staging is no longer needed;
  - obtain an approved hostname, DNS owner/record, certificate owner/issuance
    mechanism, renewal owner, and permission for a narrow reversible nginx TLS
    edit before another implementation attempt;
  - after that, run a separate implementation/proof goal for browser-trusted
    login, authenticated `/app/practical1`, comparison CSV download, and
    evidence-notes Markdown download.
