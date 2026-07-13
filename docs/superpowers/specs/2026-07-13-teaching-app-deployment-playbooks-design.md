# Teaching App Deployment Playbooks Design

## Purpose

Create two self-contained operational playbooks that preserve the validated
ITS ShinyProxy deployment procedure without requiring Barry or a future Codex
agent to reconstruct it from goal packets, chat history, or raw validation
evidence.

The playbooks must support one shared ITS ShinyProxy platform hosting three
applications at the same time:

1. KPZ308 Practical 1;
2. KPZ308 Practical 2;
3. the KPZ314 practical maintained in its own project.

The first playbook is optimized for a human moving between Windows, RDS,
PuTTY, WSL, Docker Desktop, and browser testing. The second is optimized for a
Codex agent coordinating the complete release procedure with explicit gates,
evidence requirements, stop conditions, and human handoffs.

## Deliverables

Create exactly two operational playbooks:

- `deploy/shinyproxy/teaching-app-human-playbook.md`
- `deploy/shinyproxy/teaching-app-codex-playbook.md`

Each playbook must be usable on its own. Limited repetition of hostnames,
paths, registry rules, and promotion policy is intentional. Existing files
under `deploy/shinyproxy/practical1/` remain supporting technical history and
templates, but neither new playbook may require the operator to read them in
order to complete an ordinary deployment.

## Shared Deployment Model

The playbooks will describe the following accepted infrastructure:

- dev host: `ecology-r-dev1.its.utas.edu.au`;
- prod host: `ecology-r1.its.utas.edu.au`;
- deployment directory on both hosts:
  `/srv/sa-container/ecology-teaching-shiny`;
- service account entered with `sudo -iu sa-container`;
- ShinyProxy container image: `openanalytics/shinyproxy:3.2.4`;
- Docker network: `shinyproxy-net`;
- registry: `git.its.utas.edu.au`;
- browser authentication: ITS SAML/SSO;
- prod access groups currently used by the KPZ308 app:
  `UNI-Ecology-Teaching-Shiny-Staff` and `KPZ308`;
- promotion policy: publish an immutable image tag, deploy and accept it on
  dev, then deploy the exact same tag on prod;
- provenance policy: keep readable immutable tags in `application.yml` and
  record image digests separately;
- browser acceptance remains a human-assisted step because access traverses
  the ITS RDS jump host and SAML/DUO flow.

Docker image references must use the lowercase registry namespace. The
existing rPVA image is
`git.its.utas.edu.au/utas/kpz308-rpva-practical:<TAG>`, while the Gitea source
repository may retain the uppercase owner path
`UTAS/kpz308-rpva-practical`.

## Multi-App Identity Model

Every simultaneously available application must have its own:

- stable ShinyProxy `id`;
- display name and description;
- immutable image repository and tag;
- host workspace subtree;
- per-user workspace interpolation using `#{proxy.userId}`;
- access-group list;
- rollback record.

The playbooks will use this inventory:

| Application | ShinyProxy ID | Status |
| --- | --- | --- |
| KPZ308 Practical 1 | `kpz308-rpva-practical` | Existing deployed identity; retain it to avoid breaking current links and workspaces. |
| KPZ308 Practical 2 | `kpz308-rpva-practical2` | Recommended new identity; block first deployment until Barry and ITS confirm it. |
| KPZ314 practical | `kpz314-sdm-practical` | Existing reserved identity; block first deployment until the KPZ314 project and ITS confirm its image path and workspace subtree. |

The new documents must correct the older assumption that one
`kpz308-rpva-practical` identity would cover both KPZ308 practicals. They must
not rename the already deployed Practical 1 app automatically.

Adding an application is an additive `proxy.specs` operation. It must not
replace or remove another teaching app. App-specific workspace paths must be
separate even when the same student belongs to more than one class.

## Human Playbook Design

The human playbook will lead with a short platform map explaining which
actions happen in each environment:

| Environment | Purpose |
| --- | --- |
| Windows browser | GlobalProtect, RDS jump-host access, DUO, and final SAML browser smoke. |
| WSL bash | Source checkout, validation, Docker build, registry login, push, and digest capture. |
| RDS/PuTTY shell | SSH to dev or prod and become `sa-container`. |
| Remote RedHat shell | Back up config, pull images, update ShinyProxy, check health/logs, and roll back. |

It will contain copy-and-paste-oriented procedures for:

1. choosing and validating a reviewed source commit;
2. starting Docker Desktop and confirming WSL integration;
3. connecting GlobalProtect where required;
4. building a Linux AMD64 image with a readable immutable tag;
5. logging in to Gitea without exposing a token;
6. pushing and recording the digest;
7. opening the ITS RDS page, completing DUO, and using PuTTY;
8. inspecting current dev state before mutation;
9. backing up `application.yml` and changing only the selected app spec;
10. pulling the exact image and restarting ShinyProxy;
11. checking health, config, containers, and recent logs;
12. completing the dev browser acceptance workflow and exports;
13. repeating the controlled update on prod with the accepted dev tag;
14. checking all simultaneously configured applications remain present;
15. performing pre-class checks and applying the student-release gate;
16. rolling back to the recorded previous tag and config backup;
17. diagnosing known failures encountered during the first publication.

The human playbook will distinguish three common tasks at the start:

- refresh an existing app with a new image;
- add another app for the first time;
- recover or roll back an app.

Expected outputs and explicit stop conditions will accompany high-risk steps.
The document will never contain real tokens, passwords, student identifiers,
or private key material.

## Codex Playbook Design

The Codex playbook will be an execution protocol rather than a narrative. It
will define:

- mission and scope;
- repo-local sources of truth;
- live-state discovery before any change;
- authority boundaries and actions requiring Barry as eyes and hands;
- a parameter block for the selected app, source ref, image repository, tag,
  hosts, groups, and workspace path;
- clean-tree, branch, test, and scaffold-validation gates;
- image build, local container smoke, registry login, push, digest, and
  evidence capture;
- dev config backup, app-spec update, pull, restart, health, and log checks;
- a human browser/SAML acceptance script with exact pass criteria;
- prod promotion using the exact dev-accepted image tag;
- cross-app regression checks so deployment of one app does not remove or
  break the others;
- student-release readiness, class-day monitoring, fallback, and cleanup
  prompts;
- rollback decision points and exact evidence to preserve;
- final deployment report structure for handoff to another agent;
- known failure signatures and their established remedies.

The protocol will require observation and inference to be reported
separately. A Codex agent must not claim browser, SAML, or student-access
success from container health alone. It must obtain and record the human smoke
result.

The playbook will also prevent unnecessary repetition. The validated
5/10/20/40/60-container capacity rehearsal need not be rerun for every content
update. It should be repeated only when the image runtime, resource limits,
ShinyProxy version, host capacity, or expected concurrency changes materially.

## Deployment Safety

Both playbooks will enforce these invariants:

- never deploy `latest`;
- never expose a registry token in command arguments, logs, chat, or repo
  files;
- never edit prod before the same image passes dev;
- never deploy during active teaching sessions;
- always record the previous tag before changing config;
- always make a timestamped server-side config backup;
- always check that unrelated app specs remain after editing
  `application.yml`;
- always use separate app and workspace identities;
- always confirm ShinyProxy health after restart;
- always perform a real browser acceptance check before student release;
- always preserve a static teaching fallback;
- never treat host health as proof that the Shiny app workflow works;
- never grant KPZ314 access to a KPZ308 app merely because both use the same
  platform.

Commands that may terminate active containers or sessions will be clearly
labelled and guarded by a no-active-users check. The normal update path will
prefer the least disruptive approved ShinyProxy restart that reloads
`application.yml`; the playbooks will retain the ITS-confirmed
`docker compose down` followed by `docker compose up -d` path as the known
fallback.

## Verification Design

Documentation validation will include:

- Markdown links resolve to current repo files;
- all commands use the confirmed lowercase Docker namespace;
- dev and prod hostnames and deployment paths match the accepted Goal 043
  evidence;
- app IDs are internally consistent;
- the existing Practical 1 ID is not silently renamed;
- all live config examples preserve multiple `proxy.specs` entries;
- secrets are represented only by prompts or obvious placeholders;
- shell snippets pass syntax checks where they form complete scripts;
- no stale claim says one KPZ308 app ID covers both practicals;
- rollback restores both the prior config and prior image tag;
- dev acceptance precedes prod mutation in every workflow;
- browser acceptance includes app launch, baseline, changed run, comparison,
  CSV export, and Markdown export;
- the student-release checklist includes SSO groups, route, fallback,
  monitoring, and support ownership.

The final implementation will run `git diff --check`, targeted `rg` scans,
the deployment scaffold validator, and any lightweight Markdown/link checks
available in the repository. Documentation-only changes do not require a new
Docker image or a live server restart.

## Maintenance Model

The top of both playbooks will include a small "update this document when"
section. It will name the facts most likely to drift: hostnames, deployment
directory, ShinyProxy version, app inventory, access groups, registry paths,
workspace policy, and restart procedure.

When a new app is introduced, update the inventory in both playbooks in the
same commit. Historical goal packets remain evidence; these two playbooks
become the first operational entry point.

## Out Of Scope

This work will not:

- deploy or restart a live ITS service;
- build or push a new image;
- choose the final KPZ308 Practical 2 image repository;
- choose the final KPZ314 image repository;
- create Gitea repositories, SSO groups, DNS records, or TLS certificates;
- alter Shiny application code or scientific behavior;
- replace the existing teaching, fallback, or assessment documents;
- store credentials or student data.

## Acceptance Criteria

The design is implemented when:

1. both playbooks exist at the specified paths and are self-contained;
2. a human can identify the correct environment for every command;
3. a fresh Codex agent can execute the release as gated phases without chat
   archaeology;
4. both documents support three simultaneous teaching applications;
5. existing Practical 1 deployment facts and validated failure remedies are
   preserved accurately;
6. first-time app addition, ordinary image refresh, browser acceptance,
   rollback, and student-release readiness are each documented;
7. all documentation checks pass;
8. no live infrastructure is changed while creating the playbooks.
