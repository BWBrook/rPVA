# Goal 027: Trusted Class Hostname TLS Gate

## Objective

Establish, or precisely block, a browser-trusted HTTPS route for the current
Practical 1 non-student ShinyProxy staging service using a class-appropriate
hostname rather than a raw IP URL.

The completed state is either:

1. a working, trusted, non-student staging URL with documented rollback and
   browser-smoke evidence; or
2. a precise blocker report identifying the DNS/certificate/ownership action
   needed before any trusted class URL can exist.

This goal is a TLS/DNS/certificate gate for non-student staging. It is not a
student release.

## Why This Matters

Goal 025 proved Practical 1 can run behind ShinyProxy on `deep-server`. Goal
026 proved the campus route can reach the ShinyProxy sign-in page from inside
the University network, but the current gateway serves
`/etc/ssl/certs/ssl-cert-snakeoil.pem`, with subject/issuer `CN=deep-server`
and SAN only `DNS:deep-server`. Browsers therefore warn on the tailnet and
campus IP URLs.

Before any student-facing road test, students need a trusted HTTPS URL that
does not train them to click through certificate warnings.

## Operating Mode

Bounded discovery plus conditional reversible TLS/nginx work.

Start read-only. Move to live configuration only if the hostname and trusted
certificate path are clear, authorized, reversible, and do not require
student-release work.

## Review Surface

The rPVA orchestrator will review:

- Goal 027 `Log.md`;
- a TLS gate report under this goal directory;
- any narrow update to Shiny/deployment docs;
- remote command/evidence summaries with secrets and private-key material
  redacted;
- final local and remote service state;
- final git status and changed-file list;
- rollback instructions if any live change is made.

## Scope

In scope:

- local repository branch/status checks;
- read-only inspection of Goal 025 and Goal 026 records;
- read-only live checks of current ShinyProxy/nginx/TLS posture;
- discovery of currently configured hostnames, DNS behavior, certificate
  material, and non-interactive certificate tooling on `deep-server`;
- determination of whether a trusted class-appropriate hostname is already
  available or can be safely configured now;
- if and only if all implementation gates pass, a minimal reversible nginx/TLS
  configuration update for the existing non-student staging service;
- `nginx -t` validation before any nginx reload;
- browser or HTTP evidence that the candidate trusted URL reaches ShinyProxy
  login without a certificate warning;
- authenticated non-student app smoke and evidence export check from the
  trusted route if the route becomes available;
- rollback/cleanup documentation;
- a clear next recommendation.

Out of scope:

- student-facing release;
- class account creation, class tokens, student identifiers, or student
  workspaces;
- assessment redesign;
- Practical 2 Shiny app mode;
- scenario/YAML or science changes;
- app/package implementation changes;
- new R package dependencies;
- broad host maintenance, apt upgrade, reboot, or unrelated package installs;
- firewall changes;
- DNS changes unless an already-approved, non-interactive, reversible mechanism
  is present and clearly documented;
- certificate work requiring new external accounts, manual institutional
  approval, payment, private-key disclosure, or interactive credential entry;
- replacing or deleting existing private keys without explicit rollback;
- changing ShinyProxy authentication or app configuration except where a
  proxy-header setting is demonstrably required and reversible;
- load testing beyond tiny smoke checks;
- public announcement or distribution of URL/credential;
- committing, pushing, opening a PR, or merging.

## Conditional Implementation Gate

Do not modify live nginx, certificate files, DNS, or ShinyProxy until all of
these are true and recorded in `Log.md`:

1. The candidate hostname is explicit and appropriate for class/supervisor
   testing.
2. The hostname resolves to the intended gateway from the relevant network, or
   the exact missing DNS action is identified.
3. A browser-trusted certificate path for that hostname is available without
   printing private keys or relying on credentials in chat.
4. The change can be made by editing only narrow, known nginx/TLS paths and can
   be rolled back exactly.
5. `sudo -n nginx -t` passes before any reload.
6. The existing Goal 025 non-student staging route remains recoverable.

If any gate fails, stop before live changes and produce a blocker report.

## Read First

- `README.md`
- `docs/goals/025-nonstudent-shinyproxy-staging-bootstrap/Goal.md`
- `docs/goals/025-nonstudent-shinyproxy-staging-bootstrap/Log.md`
- `docs/goals/025-nonstudent-shinyproxy-staging-bootstrap/staging-report.md`
- `docs/goals/026-campus-route-tls-readiness/Goal.md`
- `docs/goals/026-campus-route-tls-readiness/Log.md`
- `docs/goals/026-campus-route-tls-readiness/campus-tls-readiness-report.md`
- `docs/teaching/shiny/README.md`
- `docs/teaching/shiny/deep-server-hosting-feasibility.md`
- `docs/teaching/shiny/implementation-roadmap.md`
- `docs/teaching/shiny/platform-options-decision-matrix.md`
- `docs/teaching/shiny/road-test-operations-plan.md`
- `deploy/shinyproxy/practical1/README.md`
- `deploy/shinyproxy/practical1/application.example.yml`
- `deploy/shinyproxy/practical1/nginx-practical1.example.conf`
- `deploy/shinyproxy/practical1/staging-gate-checklist.md`
- `deploy/shinyproxy/practical1/validate-scaffold.sh`

There is no repo-local `AGENTS.md` in this checkout. Use the repo-local files
above plus Barry's global Mac mini instructions and this Goal 027 packet.

## Starting State Checks

Before diagnostics, report in `Log.md` and final response:

```sh
pwd
git branch --show-current
git rev-parse --short HEAD
git status --short --branch
```

Expected branch at handoff:

```text
codex/rpva-goal027-trusted-class-hostname-tls
```

Expected starting base:

```text
20f18c3 Record campus route TLS readiness diagnostics
```

Treat any unexpected dirty state as project state. Do not clean, restore, or
overwrite it unless it is clearly your own failed intermediate output.

## Git And Publication Policy

- Work on `codex/rpva-goal027-trusted-class-hostname-tls`.
- Do not commit.
- Do not push.
- Do not open a PR.
- Keep a precise changed-file list in `Log.md` and final response.

The orchestrator will review the uncommitted result before deciding whether a
separate closeout commit/publish goal is needed.

## Secret And Private-Key Policy

Do not write real secrets, private keys, student identifiers, or credential
values into the git repo, logs, terminal summaries, screenshots, or chat.

For TLS material:

- never cat or print private-key content;
- report paths, ownership, permissions, subject, issuer, SAN, dates, and
  fingerprints for public certificates only;
- if a new private key is generated as part of an approved non-interactive
  certificate path, report only path/ownership/permissions and rollback steps;
- do not move, delete, or expose existing private keys without an exact backup
  and rollback plan.

For the existing non-student ShinyProxy credential:

- use it only if needed for bounded authenticated app/export smoke;
- read it from the existing remote credential path without printing it;
- keep it in process/local temp state only as needed;
- remove any local temporary copy immediately;
- report only the path and permissions, never the value.

Do not ask Barry to paste credentials into chat.

## Required Work

1. Prove current starting state.
   - Verify the action repo branch/status and expected base.
   - Confirm the Goal 026 closeout commit is present.
   - Confirm no unexpected dirty state exists before editing Goal 027 files.

2. Re-check live staging posture without changing it.
   - Verify ShinyProxy and nginx are active.
   - Verify ShinyProxy remains localhost/gateway scoped.
   - Verify current nginx TLS certificate and route shape.
   - Verify current credential/config permissions without printing contents.

3. Discover hostname options.
   - Inspect current nginx `server_name` entries.
   - Check DNS resolution and certificate status for existing names, including
     any campus, tailnet, or host-local names already present.
   - Determine whether any candidate is suitable for a class-facing or
     supervisor-facing trusted URL.
   - Do not invent a student URL if DNS/certificate ownership is unknown.

4. Discover certificate mechanisms.
   - Check for existing trusted certificates on the host by path and metadata.
   - Check whether a non-interactive certificate mechanism is already available
     and appropriate.
   - Do not install certbot, alter DNS, open firewall, or create external
     accounts in this goal unless the packet's conditional gate is fully met.

5. Decide live-change path.
   - If no approved hostname/certificate route is available, stop before live
     changes and write a blocker report.
   - If an approved route is available and all conditional gates pass, make the
     smallest reversible nginx/TLS change.
   - Back up any edited config first.
   - Validate with `sudo -n nginx -t` before reload.
   - Reload nginx only after syntax validation passes.
   - Record exact rollback.

6. Prove the result or blocker.
   - If implemented:
     - verify browser-trusted login page for the candidate URL;
     - verify authenticated `/app/practical1`;
     - verify comparison CSV and evidence-notes downloads;
     - confirm the result remains non-student staging.
   - If blocked:
     - identify the missing owner/action, such as DNS record, certificate
       issuance, hostname approval, or network policy.

7. Update repo-local records.
   - Update Goal 027 `Log.md`.
   - Create `trusted-class-hostname-tls-report.md`.
   - Update Shiny/deployment docs narrowly if the live boundary or next gate
     changes.
   - Do not store credentials, private keys, or sensitive config payloads.

## Validation Gates

The goal is not complete until these pass, or a blocker is logged with exact
evidence:

```sh
git status --short --branch
git diff --check
bash -n deploy/shinyproxy/practical1/validate-scaffold.sh
bash deploy/shinyproxy/practical1/validate-scaffold.sh
Rscript -e 'renv::status(sources = FALSE)'
```

Also complete:

- marker scan over changed/new tracked text;
- secret/private-key-pattern scan over changed/new tracked text;
- manual review that no credential value, private key, or sensitive config
  payload appears in changed files or screenshots;
- final read-only live posture check if the remote service is reachable;
- if nginx was touched, final `sudo -n nginx -t`, service status, and rollback
  instructions.

Focused R tests are optional and should only be run if app/package/test code is
changed. Do not change those surfaces in this goal.

## Stop Rules

Stop and report to the orchestrator if:

- the starting branch/base/status is not as expected;
- ShinyProxy or nginx is unexpectedly down;
- DNS or certificate authority is unclear;
- the only available trusted hostname is tailnet-only and therefore not
  suitable for student use;
- certificate issuance requires external accounts, manual institutional
  approval, payment, interactive credentials, or firewall/DNS changes outside
  this goal;
- a live config edit would require printing private-key material or secret
  values;
- `sudo -n nginx -t` fails after any candidate edit;
- authenticated browser proof would require sending credentials through chat;
- any validation gate fails;
- a real secret or private key appears in repo files or terminal output.

## Expected Final Report

Report:

- final branch, HEAD, and status;
- changed files;
- service posture;
- candidate hostname(s) inspected;
- DNS/certificate ownership findings;
- whether any live change was made;
- if implemented, trusted URL and smoke evidence;
- if blocked, exact missing action/owner;
- validation commands and results;
- explicit confirmation that no student release/account/workspace/app/science
  changes were made.
