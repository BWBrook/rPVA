# Goal 037: ITS ShinyProxy VM Handoff Pack

## Objective

Prepare a sanitized staging handoff pack for the ITS-managed teaching Shiny VM.

The pack should translate the existing rPVA Practical 1 ShinyProxy/Docker
scaffold away from the older `deep-server` student-hosting path and toward the
new ITS-supported platform:

- RedHat 9 VM, `x86_64/amd64`;
- rootless Docker under a dedicated service user;
- ITS-managed TLS and DNS registration;
- Gitea registry under the project/team name `ecology-teaching-shiny`;
- rPVA/KPZ308 as the first app;
- KPZ314 SDM practical as a future second app placeholder only.

This goal is a handoff/documentation and packaging goal. It does not deploy the
service, push images, request registry credentials, contact ITS, or perform
student release.

## Context

ITS no longer wants `deep-server` used as the student-hosting machine. Mark
from ITS has offered a dedicated VM running ShinyProxy, with sufficient
resources for classes. The current ITS-provided constraints are:

- OS/architecture: RedHat 9, `x86_64/amd64`;
- ITS will manage TLS and DNS registration;
- authentication is still to be decided, but the Shiny apps themselves do not
  currently implement login;
- a staging URL can be provided either on a separate dev/test server or in a
  separate namespace;
- ITS uses rootless Docker;
- Barry will not have root access to the host VM, but can have full access to
  the specific user account running ShinyProxy and Docker;
- Barry should be able to pull new images, restart services, and update
  configurations within that account;
- ITS will monitor, back up, and patch the underlying server;
- application stack maintenance and class-day application support remain with
  Barry/rPVA, with ITS assistance during setup;
- ITS can create Gitea access groups and a dedicated team/project space.

Barry has proposed `ecology-teaching-shiny` as the Gitea project/team name.

## Success Criteria

The goal is complete when the repo contains a reviewed handoff pack that:

1. States the new ITS VM platform decision and demotes `deep-server` to
   development/staging reference only, not the intended student-hosting path.
2. Provides an ITS-facing handoff document that names:
   - expected VM/platform assumptions;
   - Gitea registry naming conventions;
   - current KPZ308/rPVA Practical 1 app identity;
   - future KPZ314 SDM app placeholder;
   - image tagging/update workflow;
   - ShinyProxy auth boundary;
   - rootless Docker implications;
   - logs/monitoring/restart/rollback ownership.
3. Provides a staging `application.yml` example suitable for ITS review,
   without secrets, real students, or real credentials.
4. Provides a registry/image build handoff runbook that supports:
   - Dockerfile/build-context delivery;
   - future Gitea registry push/pull by tag or digest;
   - optional image tarball fallback for the first deployment only.
5. Preserves the existing Practical 1 app and science behavior.
6. Leaves student release blocked until an ITS staging URL has been deployed
   and tested.
7. Records validation evidence and open questions for Mark/ITS.

## In Scope

- Review of the existing Practical 1 ShinyProxy deployment scaffold:
  - `deploy/shinyproxy/practical1/README.md`;
  - `deploy/shinyproxy/practical1/Dockerfile.template`;
  - `deploy/shinyproxy/practical1/dockerignore.template`;
  - `deploy/shinyproxy/practical1/application.example.yml`;
  - `deploy/shinyproxy/practical1/staging-gate-checklist.md`;
  - `deploy/shinyproxy/practical1/validate-scaffold.sh`.
- Review of relevant Goal 025 to Goal 028, Goal 035, and Goal 036 hosted-route
  evidence.
- Creation of ITS-facing handoff docs and templates.
- Static validation of YAML/templates/scaffold.
- Optional local packaging of a sendable handoff bundle under `/tmp`, excluding
  secrets and bulky image layers.
- Narrow pointer updates in deployment and teaching docs if useful.

## Out Of Scope

- Contacting Mark, ITS, Chief, students, or Moodle administrators.
- Creating a Gitea project/team, access group, repository, or registry.
- Logging into the ITS VM.
- Pushing to Gitea, GitHub Container Registry, Docker Hub, or any registry.
- Building or exporting a production image unless a bounded local smoke is
  clearly cheap and does not require credentials or remote state.
- Copying files to an ITS VM.
- Editing live ShinyProxy, nginx, systemd, firewall, DNS, TLS, Docker daemon,
  rootless Docker service, accounts, credentials, tokens, or class workspaces.
- Creating real passwords, class accounts, student identifiers, or private-key
  material.
- App/package code changes.
- Shiny UI/CSS/server changes.
- rPVA science/YAML/model-default changes.
- Practical 2 implementation.
- KPZ314 materials or implementation beyond a placeholder app identity.
- Assessment redesign.
- Student-facing release.
- Commit, push, merge, PR, or Goal 038 work.

## Required Deliverables

Use these paths unless a better local naming pattern is clearly preferable:

- `deploy/shinyproxy/practical1/its-vm-handoff.md`
- `deploy/shinyproxy/practical1/application.its-staging.example.yml`
- `deploy/shinyproxy/practical1/gitea-registry-runbook.md`
- `docs/goals/037-its-shinyproxy-vm-handoff-pack/its-handoff-report.md`
- `docs/goals/037-its-shinyproxy-vm-handoff-pack/mark-reply-draft.md`
- updates to `docs/goals/037-its-shinyproxy-vm-handoff-pack/Log.md`
- narrow pointer updates, if useful, in:
  - `deploy/shinyproxy/practical1/README.md`;
  - `deploy/shinyproxy/practical1/staging-gate-checklist.md`;
  - `docs/teaching/shiny/README.md`.

## Handoff Content Requirements

The ITS handoff should be concise but operationally useful. Include:

- project/team name: `ecology-teaching-shiny`;
- current app id suggestion: `kpz308-rpva-practical1`;
- future app id placeholder: `kpz314-sdm-practical`;
- image-name placeholder:
  `<GITEA_REGISTRY>/ecology-teaching-shiny/kpz308-rpva-practical1:<TAG>`;
- suggested tag patterns:
  - `kpz308-prac1-<short-sha>-staging`;
  - `kpz308-prac1-<YYYYMMDD>-candidate`;
- instruction to prefer immutable tags or image digests over `latest`;
- note that the rPVA Shiny app has no built-in auth;
- recommendation that auth sits in ShinyProxy/ITS SSO or a temporary
  ShinyProxy simple-auth staging layer;
- reminder that no secrets belong in the repo, image, or handoff docs;
- rootless Docker notes:
  - paths should live under the dedicated service user's home or ITS-approved
    app data root;
  - host bind mounts must be writable by the rootless service user;
  - restart/update commands should be run by that service user, not root;
  - privileged ports and host networking assumptions should be avoided unless
    ITS wraps them;
- division of responsibility:
  - ITS: VM, TLS/DNS, OS patching, host backup/monitoring;
  - rPVA/Barry: app image, ShinyProxy app config content, class-day app
    behavior/support, rollback decision;
  - shared: first staging proof and update workflow.

## Application YAML Requirements

The ITS staging YAML example should:

- be parseable YAML;
- use the app id `kpz308-rpva-practical1`;
- keep a future KPZ314 app as comments or prose only, not a fake runnable spec;
- use placeholder registry/image values;
- avoid real credentials and real student identifiers;
- make authentication explicitly a decision point:
  - ShinyProxy simple auth for non-student staging, or
  - ITS-managed SSO/proxy auth if available;
- use rootless-Docker-safe placeholder paths;
- preserve per-user workspace isolation;
- avoid `deep-server`-specific paths such as `/data/codex` in the ITS example;
- keep container port `3838` unless a reason to change it is documented.

## Validation

Run and report:

```sh
git diff --check
bash -n deploy/shinyproxy/practical1/validate-scaffold.sh
bash deploy/shinyproxy/practical1/validate-scaffold.sh
ruby -e 'require "yaml"; YAML.load_file(ARGV.fetch(0)); puts "ruby yaml parse ok"' deploy/shinyproxy/practical1/application.example.yml
```

Also parse the new ITS YAML example with Ruby or another available YAML parser.

Run:

```sh
Rscript -e 'renv::status(sources = FALSE)'
```

If the docs touch app-facing launch guidance or package files unexpectedly,
also run the focused teaching API and Practical 1 Shiny tests. Otherwise,
record why static/deployment-doc validation is proportionate.

Also complete:

- marker scan over changed/new text;
- secret/private-key-pattern scan over changed/new text, with hits classified;
- stricter assignment/private-key-block scan;
- route/student-release wording scan to confirm student-facing materials do not
  instruct students to use an unapproved route;
- manual check that no real credentials, private keys, registry tokens, student
  identifiers, or sensitive service payloads are present.

## Stop Rules

Stop and report to the rPVA orchestrator if:

- the starting branch/base/status differs materially from the expected state;
- preparing the handoff requires registry credentials, VM login, root access,
  or ITS-side project creation;
- the handoff would need real passwords, tokens, student identifiers, or
  private-key material;
- the ShinyProxy app cannot be represented without app/package code changes;
- validation finds non-placeholder credentials or parse-breaking YAML;
- a proposed workflow implies student release before ITS staging proof;
- the work would need to inspect KPZ314 project materials.

## Reporting

Leave the result uncommitted for orchestrator review.

Report:

- branch, HEAD, and final `git status --short --branch`;
- changed/new files;
- handoff pack summary;
- recommended first reply or file bundle for Mark;
- Gitea registry/image naming recommendations;
- validation commands and results;
- scan hit classification;
- remaining questions for ITS;
- whether this is ready for a closeout/publish goal;
- any blockers or recommended next gate.

Wake the rPVA orchestrator thread when complete or blocked.
