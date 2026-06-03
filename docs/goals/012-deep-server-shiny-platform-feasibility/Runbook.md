# Runbook

Start in the action repo:

```sh
cd /Users/bwbrook/git/rPVA
git status --short --branch --untracked-files=all
```

Read the packet:

```sh
sed -n '1,260p' docs/goals/012-deep-server-shiny-platform-feasibility/Goal.md
sed -n '1,200p' docs/goals/012-deep-server-shiny-platform-feasibility/Plan.md
sed -n '1,220p' docs/goals/012-deep-server-shiny-platform-feasibility/Runbook.md
sed -n '1,220p' docs/goals/012-deep-server-shiny-platform-feasibility/Log.md
```

Read the current Shiny design docs:

```sh
sed -n '1,220p' docs/teaching/shiny/README.md
sed -n '1,260p' docs/teaching/shiny/deployment-and-setup-options.md
sed -n '1,260p' docs/teaching/shiny/implementation-roadmap.md
sed -n '1,260p' docs/teaching/shiny/engine-affordance-audit.md
```

Run only read-only probes. Do not use sudo to change anything, do not start
services, and do not create directories, containers, or users.

Useful probes:

```sh
ssh deep-server-ts 'hostname; nproc; free -h; df -h / /data 2>/dev/null || df -h'
ssh deep-server-ts 'docker info 2>&1 | sed -n "1,80p"; podman info 2>&1 | sed -n "1,80p"'
ssh deep-server-ts 'R --version 2>&1 | sed -n "1,6p"; java -version 2>&1 | sed -n "1,6p"'
ssh deep-server-ts 'ss -ltn | sed -n "1,80p"'
ssh deep-server-ts 'nginx -v 2>&1; apache2 -v 2>&1; caddy version 2>&1'
ssh wsl-laptop 'for p in 22 80 443 3838 8080 8787; do timeout 5 bash -lc "</dev/tcp/131.217.90.193/$p" >/dev/null 2>&1 && echo port_$p=open || echo port_$p=closed_or_filtered; done'
```

Validation:

```sh
git diff --check
rg -n "TODO|TBD|PLACEHOLDER" docs/teaching/shiny docs/goals/012-deep-server-shiny-platform-feasibility
git status --short --branch --untracked-files=all
```

If the marker scan returns intentional command-string hits, explain them in
`Log.md`.
