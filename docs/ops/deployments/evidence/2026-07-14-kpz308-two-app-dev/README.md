# KPZ308 Two-App Dev Evidence

Date: 2026-07-14
Environment: `ecology-r-dev1.its.utas.edu.au`
Result: passed

This directory preserves the evidence used to accept concurrent Practical 1
and Practical 2 operation on the UTAS development ShinyProxy host. It is an
intermediate evidence packet for the final production-proof report.

## Image identity

| App | ShinyProxy ID | OCI revision | Immutable image | Build-host local ID | Dev-host `.Id` | Registry manifest digest |
| --- | --- | --- | --- | --- | --- | --- |
| Practical 1 | `kpz308-rpva-practical` | `02b09aeed4f033ac8a68e3e3c1927f878b3242c9` | `git.its.utas.edu.au/utas/kpz308-rpva-practical:dev-20260713-02b09aeed4f0` | Not part of this run | `sha256:3b69050e1091fa3e521e345328341b982d6b7d4739d441d740300de0c75e2f9b` | `sha256:3b69050e1091fa3e521e345328341b982d6b7d4739d441d740300de0c75e2f9b` |
| Practical 2 | `kpz308-rpva-practical2` | `8aada69b0ac35ee1994e86e5199b38047fdd3efe` | `git.its.utas.edu.au/utas/kpz308-rpva-practical2:dev-20260714-8aada69b0ac3` | `sha256:7acc8ed81f245ff15329238b3ae03e746c992c32770ff176267ac08a7ebdca55` | `sha256:e7d997f0ce52b22c30747a3b83cbf771e4124e5065010a9212479a53ffc96721` | `sha256:e7d997f0ce52b22c30747a3b83cbf771e4124e5065010a9212479a53ffc96721` |

The local `.Id` field is recorded per engine and is not treated as the
cross-host registry identity. Practical 2's WSL build engine returned
`7acc8ed...`; the dev engine returned `e7d997...` after pull. Cross-host
identity is established by the immutable tag, OCI revision, and `RepoDigests`
manifest digest, all of which agree with the accepted Task 2 publication.

The dev host runs Docker Engine 29.6.1 rootless with containerd 2.2.5 and the
`overlayfs` driver. Docker documents the containerd image store as the default
for fresh Engine 29 installations and `overlayfs` as its default snapshotter:
<https://docs.docker.com/engine/storage/containerd/>. Docker's Buildx metadata
documentation separately records `containerimage.config.digest` and the image
descriptor/manifest `digest`, illustrating why a build-host local identifier
must not be conflated with a registry manifest digest:
<https://docs.docker.com/reference/cli/docker/buildx/build/#write-build-result-metadata-to-a-file>.

## Bundle contents

- `build-and-registry.txt`: clean-source build target, image inspection,
  local smoke, and immutable registry publication evidence.
- `dev-config-diff.txt`: redacted configuration change and rollback metadata.
- `dev-server-snapshot.txt`: exact accepted health, container, resource,
  engine, image, workspace, and proxy-event output with usernames redacted.
- `browser-result.json`: machine-readable Playwright result. Temporary local
  paths are retained as execution provenance; the corresponding files are in
  this directory.
- `browser/`: launcher and app screenshots, including a mobile P2 evidence
  view.
- `exports/`: downloaded CSV and Markdown evidence from both apps.
- `validation.txt`: structured row, missing-value, interpretation, image, and
  checksum checks.

## Acceptance summary

- Real UTAS SAML and Duo authentication completed.
- Both launcher tiles were visible.
- Two app pages and two `/app_proxy/` frames remained active concurrently.
- Practical 1 completed baseline and environmental-stochasticity comparison.
- Practical 2 completed five management and four bounded-sensitivity runs.
- All CSV and Markdown downloads validated.
- Both app containers were simultaneously healthy on their distinct images.
- P1 and P2 used separate host workspace roots.
- No console errors, warnings, or page exceptions occurred in the accepted
  browser run.

## Redaction

Staff usernames in server paths and proxy logs are replaced with
`<staff-user>`. No passwords, cookies, tokens, SAML assertions, or student
identifiers are included.

## Lifecycle observation

One earlier harness retry requested P2 while its prior proxy was being released
and received `410 Gone`. The old proxy was released after about 65 seconds.
Returning to the launcher after that interval created a fresh proxy, and the
complete accepted run passed. This is recorded as a residual operational
observation, not an image failure.
