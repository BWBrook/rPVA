# Log

## 2026-06-11 - Orchestrator Packet Creation

- Goal 025 was accepted, committed, and published to `origin/main` before this
  branch was created.
- Starting base for Goal 026:
  - branch: `codex/rpva-goal026-campus-tls-readiness`;
  - base commit:
    `7b0e3fb Record Practical 1 non-student staging bootstrap`;
  - source: `origin/main`.
- Barry reported a campus-side route observation from inside the University
  network:
  - `https://131.217.90.193/login` reaches a ShinyProxy sign-in page;
  - the browser still marks the HTTPS connection as not secure, with crossed-out
    HTTPS.
- Goal purpose:
  - diagnose campus-route and TLS/browser-trust readiness;
  - keep tailnet-staging, campus-login, authenticated-campus-app, and
    student-release evidence separate;
  - recommend the next gate before any broader student-facing use.
- Boundary:
  - diagnostic/readiness only;
  - no DNS, firewall, TLS certificate/trust-chain, nginx, ShinyProxy, Docker
    daemon/service, account, credential, student workspace, student release,
    implementation, science/YAML, dependency, commit, push, merge, or PR work.
- Packet files:
  - `docs/goals/026-campus-route-tls-readiness/Goal.md`
  - `docs/goals/026-campus-route-tls-readiness/Plan.md`
  - `docs/goals/026-campus-route-tls-readiness/Runbook.md`
  - `docs/goals/026-campus-route-tls-readiness/Log.md`

Status: packet ready for `woodhen`; execution not yet started.

## 2026-06-11 - Woodhen Execution Start

- Read the active Goal 026 packet first:
  - `Goal.md`;
  - `Plan.md`;
  - `Runbook.md`;
  - `Log.md`.
- Read required local context before live diagnostics:
  - project `README.md`;
  - `docs/codex/thread-handoff-2026-06-04.md`;
  - Goal 025 `Goal.md`, `Log.md`, and `staging-report.md`;
  - Shiny teaching/deployment notes under `docs/teaching/shiny/`;
  - Practical 1 ShinyProxy scaffold files under
    `deploy/shinyproxy/practical1/`.
- Reconfirmed starting local state:
  - `pwd`: `/Users/bwbrook/git/rPVA`;
  - branch: `codex/rpva-goal026-campus-tls-readiness`;
  - `HEAD`: `7b0e3fbf9315559c8a06e77efaf4c7c5ba1fff85`;
  - short status:
    `## codex/rpva-goal026-campus-tls-readiness`
    plus untracked `docs/goals/026-campus-route-tls-readiness/`.
- Confirmed the Goal 025 closeout commit is present:
  `7b0e3fb Record Practical 1 non-student staging bootstrap`.
- Ignored local artefacts observed with ignored-status reporting:
  `docs/teaching/woodhen/.gitignore` and `renv/staging/`.
- No unexpected tracked or non-packet dirty state was present before Goal 026
  edits.
- Boundary being followed:
  diagnostic/readiness only, with no service, config, certificate, trust-store,
  DNS, firewall, Docker daemon/service, account, credential, student-workspace,
  implementation-code, test-code, science/YAML, dependency, commit, push, PR,
  merge, or student-release changes.

## 2026-06-11 - Read-Only Live Posture

- Remote posture check via `deep-server-ts`:
  - host: `deep-server`;
  - `systemctl is-active shinyproxy`: `active`;
  - `systemctl is-active nginx`: `active`;
  - nginx listener: `0.0.0.0:443` and `[::]:443`;
  - ShinyProxy listener: `[::ffff:127.0.0.1]:3838`;
  - local ShinyProxy login route:
    `http://127.0.0.1:3838/login` returned HTTP 200.
- Goal 025 image remains present:
  - tag: `rpva-practical1:goal025-5c9d500`;
  - image id:
    `sha256:29511a9d2e583b38c724c56b8c0f8b947d99f10e0e533c1e9a79d4127b40ab79`;
  - size: `1794286296` bytes;
  - created: `2026-06-11T11:59:12.91499559+10:00`.
- Metadata checks without printing credential content:
  - credential path:
    `/data/codex/teaching/rpva-2026/staging/credentials/goal025-nonstudent-password.txt`;
  - credential permissions: `bwbrook:bwbrook 600`;
  - ShinyProxy config permissions:
    `root:bwbrook 640 /etc/shinyproxy/application.yml`;
  - ShinyProxy JAR permissions:
    `root:root 644 /opt/shinyproxy/shinyproxy-3.2.4.jar`.
- Redacted ShinyProxy route/config shape:
  - `proxy.port: 3838`;
  - `bind-address: "127.0.0.1"`;
  - `authentication: "simple"`;
  - single non-student staging identity name:
    `rpva_goal025_nonstudent`;
  - app id: `practical1`;
  - app image: `rpva-practical1:goal025-5c9d500`;
  - `server.forward-headers-strategy: native`.
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
- No secret value, private key, or sensitive config payload was printed or
  copied into repo files.

## 2026-06-11 - Route, TLS, And Browser Evidence

- Tailnet route from the Mac mini:
  - `https://100.96.185.60/_gateway-health`: HTTP 200;
  - `https://100.96.185.60/login`: HTTP 200 ShinyProxy login response.
- Campus/public-IP route from the Mac mini:
  - `https://131.217.90.193/_gateway-health`: timed out after 10 seconds;
  - `https://131.217.90.193/login`: timed out after 10 seconds;
  - no repeated campus/public-IP probing was attempted after the short-timeout
    result.
- Barry-provided campus-side observation incorporated as separate evidence:
  - from inside the University network,
    `https://131.217.90.193/login` reaches a ShinyProxy sign-in page;
  - the browser still marks HTTPS as not secure, with crossed-out HTTPS.
- Read-only public certificate inspection:
  - active nginx certificate path:
    `/etc/ssl/certs/ssl-cert-snakeoil.pem`;
  - subject: `CN = deep-server`;
  - issuer: `CN = deep-server`;
  - validity: `Nov  3 05:03:54 2025 GMT` to
    `Nov  1 05:03:54 2035 GMT`;
  - Subject Alternative Name: `DNS:deep-server`;
  - SHA256 fingerprint:
    `87:2B:46:D8:42:F9:CA:3F:1A:33:19:FB:8D:72:CF:53:36:F4:8E:65:69:5E:E8:3F:82:DF:CF:20:7B:BF:F9:52`.
- Tailnet `openssl s_client` against `100.96.185.60` reported:
  - `verify error:num=18:self-signed certificate`;
  - `verify error:num=64:IP address mismatch`;
  - `Verify return code: 64 (IP address mismatch)`.
- Unauthenticated Chromium browser evidence for
  `https://100.96.185.60/login`:
  - navigation failed with `net::ERR_CERT_AUTHORITY_INVALID`;
  - browser page heading: `Your connection is not private`;
  - screenshot saved outside the repo:
    `/tmp/rpva-goal026-tailnet-cert-warning.png`;
  - browser session closed after capture.
- Interpretation:
  - tailnet route-to-login and authenticated app access are proven for
    non-student staging;
  - Barry's campus-side browser observation proves route-to-login from inside
    the University network;
  - campus/public-IP route from the Mac mini remains timed out and is not a
    contradiction of Barry's campus-origin evidence;
  - browser-trusted service readiness is blocked by the current self-signed
    `deep-server` certificate and lack of SAN coverage for the IP URLs;
  - campus authenticated app access and student/class readiness remain
    unproven.

## 2026-06-11 - Authenticated Tailnet App Smoke

- Used the existing non-student staging credential from the remote credential
  file in process only.
- Did not print, copy into the repo, rotate, or expose the credential value.
- Temporary local files were created under `/tmp` and removed by shell trap.
- Results:
  - login final URL: `https://100.96.185.60/auth-success`;
  - app final URL: `https://100.96.185.60/app/practical1`;
  - app HTTP: 200;
  - marker check: `tailnet_app_marker_ok`.

## 2026-06-11 - Report And Teaching Boundary Update

- Created:
  `docs/goals/026-campus-route-tls-readiness/campus-tls-readiness-report.md`.
- Updated:
  `docs/teaching/shiny/README.md`.
- README update was limited to the campus-route/TLS readiness boundary:
  campus route-to-login is a useful signal, but the service remains
  non-student staging until a trusted URL/certificate route and campus
  authenticated app path are separately proven.

## 2026-06-11 - Validation And Final Posture

- Changed files:
  - `docs/goals/026-campus-route-tls-readiness/Goal.md`
  - `docs/goals/026-campus-route-tls-readiness/Plan.md`
  - `docs/goals/026-campus-route-tls-readiness/Runbook.md`
  - `docs/goals/026-campus-route-tls-readiness/Log.md`
  - `docs/goals/026-campus-route-tls-readiness/campus-tls-readiness-report.md`
  - `docs/teaching/shiny/README.md`
- Required validation:
  - `git status --short --branch`: expected Goal 026 packet plus
    `docs/teaching/shiny/README.md`;
  - `git diff --check`: passed;
  - `bash -n deploy/shinyproxy/practical1/validate-scaffold.sh`: passed;
  - `bash deploy/shinyproxy/practical1/validate-scaffold.sh`: passed;
  - `Rscript -e 'renv::status(sources = FALSE)'`: passed, reporting
    `No issues found -- the project is in a consistent state.`
- Marker scan over changed/untracked text:
  - no unresolved marker hits.
- Secret-pattern scan over changed/untracked text:
  - hits were policy wording, validation-command text, class account/token
    boundary wording, credential-path references, and redacted diagnostic
    statements only;
  - no real secret values, private keys, tokens, passwords, or sensitive config
    payloads were found in changed repo text.
- Final read-only live posture:
  - ShinyProxy active;
  - nginx active;
  - ShinyProxy listener remains `[::ffff:127.0.0.1]:3838`;
  - nginx listener remains on `443`;
  - credential file metadata remains `bwbrook:bwbrook 600`;
  - `https://100.96.185.60/_gateway-health`: HTTP 200.
- Final recommendation:
  - do not use the current IP URL for students;
  - keep the service at non-student staging status or roll it back using Goal
    025 instructions;
  - run a separate TLS/DNS/certificate gate before any student-facing release;
  - after TLS/DNS is fixed, prove campus browser login, authenticated
    `/app/practical1`, and evidence downloads from a student-like route without
    sharing credential values in chat or repo files.
