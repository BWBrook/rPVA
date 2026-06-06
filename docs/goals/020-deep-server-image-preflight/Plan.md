# Plan

1. Report branch/worktree state before editing.
2. Fetch/prune and confirm `origin/main` is `38ef13f` or newer.
3. Create `codex/rpva-goal020-deep-server-image-preflight` from `origin/main`.
4. Read Goal 019, the Practical 1 scaffold, teaching Shiny planning docs, and
   app context.
5. Create the Goal 020 packet.
6. Create a disposable remote workspace under `/data/codex` on
   `deep-server-ts`.
7. Transfer the reviewed rPVA source at the current `origin/main` commit into
   that disposable workspace.
8. Copy the scaffold ignore template to `.dockerignore` inside the disposable
   remote workspace only.
9. Capture remote hostname, architecture, Docker version, Docker info summary,
   disk context, workspace path, and source commit.
10. Run one bounded `x86_64` Docker build with the Practical 1 Dockerfile
    template and a temporary local tag.
11. If the image builds, run one short local-only container smoke bound to
    `127.0.0.1`, curl it from `deep-server` localhost, and stop/remove the
    container.
12. Record image/container cleanup state and any build or smoke defects.
13. Refine repo-local scaffold docs/templates only if the preflight reveals a
    clear repo-local defect.
14. Run local validation: status, diff whitespace check, marker scan,
    scaffold validator, YAML parse, secret scan, and final status.
15. Report back to CoS without commit, push, live service changes, deployment,
    or public/student-facing exposure.
