# Goal 039 Handoff Identity Refresh Report

## Summary

Goal 039 refreshed the repo-local ITS ShinyProxy VM/Gitea handoff package with
Barry's confirmed app/repo identity and ITS Gitea source repository.

Canonical current values:

- Gitea instance: `https://git.its.utas.edu.au/`
- private source repository: `https://git.its.utas.edu.au/UTAS/kpz308-rpva-practical.git`
- repository owner/path: `UTAS/kpz308-rpva-practical`
- ShinyProxy app/repo id: `kpz308-rpva-practical`

The no-`1` id is intentional. It is the KPZ308 rPVA practical app identity for
both rPVA practical weeks, even though the current repo-local Shiny surface is
the Practical 1 concept lab.

## Updated Current Handoff Surfaces

- `deploy/shinyproxy/practical1/its-vm-handoff.md`
- `deploy/shinyproxy/practical1/gitea-registry-runbook.md`
- `deploy/shinyproxy/practical1/application.its-staging.example.yml`
- `deploy/shinyproxy/practical1/README.md`
- `deploy/shinyproxy/practical1/staging-gate-checklist.md`
- `docs/teaching/shiny/README.md`

The refreshed deploy scaffold now uses:

- app path `/app/kpz308-rpva-practical`;
- app spec id `kpz308-rpva-practical`;
- image-name shape
  `<ITS_GITEA_REGISTRY>/<CONFIRMED_ORG_OR_REGISTRY_NAMESPACE>/kpz308-rpva-practical:<TAG>`;
- digest shape
  `<ITS_GITEA_REGISTRY>/<CONFIRMED_ORG_OR_REGISTRY_NAMESPACE>/kpz308-rpva-practical@sha256:<DIGEST>`;
- workspace path
  `<ITS_APP_DATA_ROOT>/kpz308-rpva-practical/workspaces/#{proxy.userId}`.

The registry host/path and namespace are still ITS confirmation points. This
goal does not assume the HTTPS clone URL or confirmed `UTAS` source owner/path
is also the registry endpoint or namespace.

## Historical Records

Goal 037 remains an accepted historical packet. Its stale
`kpz308-rpva-practical1` references are preserved as historical evidence rather
than silently rewritten. Current sendable/operator surfaces and the Goal 039
packet use `kpz308-rpva-practical`.

## Bundle

The non-secret bundle is regenerated at:

```text
/tmp/rpva-goal039-its-handoff/
```

It contains refreshed copies of:

- `README-send-to-ITS.md`
- `its-vm-handoff.md`
- `gitea-registry-runbook.md`
- `application.its-staging.example.yml`
- `mark-update-draft.md`
- `SHA256SUMS.txt`

No image layers, registry tokens, credentials, private keys, student
identifiers, live ShinyProxy config, VM payloads, or internal review reports
are included.

## Residual Questions For ITS/Barry

1. What exact container registry host and package path should be used for
   `UTAS/kpz308-rpva-practical`?
2. Should the source repository stay under `UTAS/`, and should
   `ecology-teaching-shiny` be used only as an access-group or coordination
   label unless ITS creates a matching namespace?
3. What access group should Barry/rPVA use for source and registry publishing?
4. What service user, app data root, rootless Docker network, and restart path
   should replace the remaining angle-bracket placeholders?
5. Should non-student staging use ITS SSO/proxy auth or temporary
   ITS-approved ShinyProxy simple auth?

## Validation Summary

- Patch hygiene, YAML parse, deploy scaffold syntax/static checks, and
  `renv::status(sources = FALSE)` passed.
- Current deploy/teaching handoff surfaces have no stale
  `kpz308-rpva-practical1` hits.
- Goal 039 contains stale-name mentions only as correction/search wording.
- Goal 037 retains stale-name hits as historical evidence.
- Changed text and bundle manifest scans found no marker hits, no assignment
  style secret/private-key block, and only safety-wording hits for
  credentials/tokens.

## Boundary Confirmation

This goal did not test Mac mini access to Gitea, log in to Gitea, clone from
Gitea, push to Gitea, create tokens, create registry entries, build images,
push images, contact ITS, or touch any live VM/ShinyProxy/DNS/TLS/Docker state.

## Recommendation

Accept for orchestrator review if validation remains green. The next gate is a
human/ITS confirmation pass for registry host/path, access group shape, service
user paths, auth model, and staging URL ownership.
