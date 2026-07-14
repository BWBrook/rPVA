# Practical 2 ShinyProxy Deployment Scaffold

This directory contains the reviewed image and ShinyProxy spec inputs for the
KPZ308 Practical 2 Woodhen Management Lab.

- `Dockerfile.template` installs the locked rPVA package and launches
  `rPVA::run_practical2_shiny()` on port 3838.
- `dockerignore.template` is copied to `.dockerignore` only in an approved
  image-build workspace.
- `application.spec.example.yml` records the stable app identity, registry
  repository, access groups, and separate per-user workspace path.
- `validate-scaffold.sh` performs static and YAML checks.

Use an immutable `dev-YYYYMMDD-SHORTSHA` image tag. Accept the image on dev,
then promote that exact tag and digest to production. During infrastructure
validation the production tile is visible briefly to Staff and KPZ308, then
returned to Staff-only access until teaching-content signoff.

The authoritative operational sequence is in the human and Codex teaching app
deployment playbooks one directory above.
