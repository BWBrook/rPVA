# KPZ308 Two-App Production Proof

Date: 2026-07-13 to 2026-07-15
Status: passed

## Scope

This deployment proved that KPZ308 Practical 1 and Practical 2 can remain
deployed as separate ShinyProxy applications on the shared UTAS infrastructure.
It covered a distinct P2 image/scaffold, dev acceptance, production promotion,
concurrent Staff browser workflows, real KPZ308 student access, and return of
P2 to Staff-only for continued content refinement.

The proof did not retest 60-container capacity. The earlier production capacity
result remains applicable because runtime limits and the base deployment model
did not materially change. KPZ314 is outside this deployment.

## Source and image identity

| App | ShinyProxy ID | Source commit / OCI revision | Immutable image | Accepted host image ID | Registry digest |
| --- | --- | --- | --- | --- | --- |
| KPZ308 Practical 1 | `kpz308-rpva-practical` | `02b09aeed4f033ac8a68e3e3c1927f878b3242c9` | `git.its.utas.edu.au/utas/kpz308-rpva-practical:dev-20260713-02b09aeed4f0` | `sha256:3b69050e1091fa3e521e345328341b982d6b7d4739d441d740300de0c75e2f9b` | `sha256:3b69050e1091fa3e521e345328341b982d6b7d4739d441d740300de0c75e2f9b` |
| KPZ308 Practical 2 | `kpz308-rpva-practical2` | `8aada69b0ac35ee1994e86e5199b38047fdd3efe` | `git.its.utas.edu.au/utas/kpz308-rpva-practical2:dev-20260714-8aada69b0ac3` | `sha256:e7d997f0ce52b22c30747a3b83cbf771e4124e5065010a9212479a53ffc96721` | `sha256:e7d997f0ce52b22c30747a3b83cbf771e4124e5065010a9212479a53ffc96721` |

P2's WSL Buildx local ID was
`sha256:7acc8ed81f245ff15329238b3ae03e746c992c32770ff176267ac08a7ebdca55`.
Engine-local IDs are recorded separately; immutable tag, OCI revision, and
`RepoDigests` establish cross-host identity. Dev and production matched the
same accepted registry manifests.

## Practical 2 scaffold verification

The permanent P2 identity is:

- app ID `kpz308-rpva-practical2`;
- image repository `git.its.utas.edu.au/utas/kpz308-rpva-practical2`;
- host workspace `data/kpz308-rpva-practical2/workspaces`;
- container workspace `/srv/rpva-workspaces/current`;
- runtime port `3838`;
- final normal access `UNI-Ecology-Teaching-Shiny-Staff` until student release.

Focused P2 API and Shiny tests passed. Practical 1 and Practical 2 scaffold
validators passed. The P2 validator's full mount/`:z` assertion can be made
more exact in a later maintenance pass; this did not block deployment.

## Local image acceptance

The P2 image was built from clean, synchronized source with the
`linux/amd64` target using the committed Dockerfile and exact source revision.
Buildx completed, installed the locked R environment, and produced the local
image ID recorded above. Image inspection recorded `arch=amd64` and the exact
OCI source revision.

Local container acceptance passed:

- HTTP and container health succeeded;
- the app listened on `0.0.0.0:3838`;
- a two-scenario Woodhen API smoke returned the expected labels;
- the temporary container was removed; and
- push, registry inspection, and fresh pull agreed on the immutable digest.

## Dev configuration and rollback

Host: `ecology-r-dev1.its.utas.edu.au`

Backup:
`application.yml.before-kpz308-rpva-practical2-20260714-144335`.

The redacted diff added one P2 spec using the immutable P2 image, dev Admins
access, the shared network, the 1 GiB/1 CPU limits, and its separate workspace
mount. P1 remained on its accepted image and workspace. File owner/mode and
SELinux context remained `sa-container:sa-container`, 0640, and
`unconfined_u:object_r:var_t:s0`.

ShinyProxy restarted successfully and actuator health returned `UP` on attempt
4. Rollback was not triggered. The exact backup metadata, diff, restore
commands, image identities, and checksums are preserved in
[`evidence/2026-07-14-kpz308-two-app-dev/`](evidence/2026-07-14-kpz308-two-app-dev/README.md).

## Dev concurrent browser and container evidence

Real SAML/Duo Staff authentication displayed both app tiles. Separate P1 and
P2 pages remained active concurrently.

- P1 ran baseline plus environmental stochasticity and exported a 2-row CSV
  and Markdown notes.
- P2 ran five management scenarios plus four bounded-sensitivity scenarios and
  exported 5-row and 4-row CSVs plus Markdown notes.
- All CSVs parsed without missing values; both interpretations survived export.
- Browser console warnings/errors and page exceptions were empty.
- Both distinct image containers were simultaneously healthy.
- P1 and P2 used 326.6 MiB/1 GiB and 171.7 MiB/1 GiB during the evidence
  snapshot; ShinyProxy used 410.8 MiB/2 GiB.
- Browser frame proxy IDs matched container names and activation logs.
- Workspace parents, per-user directories, ownership, modes, SELinux context,
  and distinct `:z` mappings were captured.

An earlier harness retry requested P2 during inactive-proxy release and received
`410 Gone`. The old proxy released after about 65 seconds; returning to the
launcher created a fresh proxy and the accepted run passed. This is an
operational lifecycle observation, not an image failure.

## Production configuration and rollback

Host: `ecology-r1.its.utas.edu.au`

Initial discovery found healthy ShinyProxy, P1 on the June image, Staff plus
KPZ308 access, no P2 spec, and no active app container. Both accepted images
were pulled and their revisions/digests verified before mutation.

Canary backup:
`application.yml.before-two-app-canary-20260715-120812`.

The exact production diff changed one P1 image line and added one P2 spec. Both
apps had Staff plus KPZ308 during the canary, with separate workspace roots.
Owner, mode, and SELinux context were preserved. ShinyProxy restarted and
returned `UP` on attempt 3 with clean OpenSAML, authentication-provider,
Undertow, and ShinyProxy startup logs.

Rollback was not triggered because all configuration, health, browser, export,
container, and workspace gates passed. The backup and exact restore/health
commands remain on the host and in the evidence packet.

## Production concurrent browser and container evidence

Production Staff acceptance repeated the complete two-tab dev workflow:

- both launcher tiles and both `/app/<id>` routes were visible;
- P1 produced `practical1-comparison.csv` with 2 rows and
  `practical1-evidence.md`;
- P2 produced `practical2-core-comparison.csv` with 5 rows,
  `practical2-sensitivity-comparison.csv` with 4 rows, and
  `practical2-evidence.md`;
- all exports parsed with no missing values and retained interpretations;
- browser console and page-error arrays were empty; and
- desktop and mobile screenshots were nonblank and legible.

At `2026-07-15T02:27:11Z`, actuator status was `UP` and both exact app images
were simultaneously healthy. ShinyProxy, P1, and P2 used 672.4 MiB/2 GiB,
320.1 MiB/1 GiB, and 175.4 MiB/1 GiB. Browser proxy IDs matched container and
activation-log IDs. P1 and P2 workspace roots were distinct.

The redacted, checksum-verified packet is
[`evidence/2026-07-15-kpz308-two-app-prod/`](evidence/2026-07-15-kpz308-two-app-prod/README.md).

## KPZ308 student access result

Status: passed on 2026-07-15.

One current KPZ308 student confirmed that:

1. both canary tiles were visible;
2. Practical 1 opened; and
3. Practical 2 opened to Woodhen Management Lab.

The tester is recorded by role only. No student identity, credential,
screenshot, or model work is retained.

## Infrastructure monitoring

Independent UTAS host-level monitoring feedback was unavailable because the
normal infrastructure contact was on leave. This was an allowed missing item,
not a functional blocker.

Captured evidence showed actuator `UP`, healthy containers, ample memory
headroom, live CPU/process/network statistics, clean activation logs, and
complete concurrent workflows. Compose printed the known rootless
`IPv4 forwarding is disabled` message during restart, but both application
network paths activated and completed their browser workflows.

## Canary closeout state

Closeout backup:
`application.yml.before-practical2-staff-only-20260715-124929`.

The exact closeout diff removed only P2's `KPZ308` access-group line. P1
retained Staff plus KPZ308. P2 retained Staff only. Both immutable images,
app IDs, and workspace mounts remained unchanged.

ShinyProxy restarted and actuator health returned `UP` on attempt 3. Final
Staff Playwright smoke confirmed both launcher tiles, P1's `Start baseline`
control, and P2's `Woodhen Management Lab` heading in separate app pages. The
browser reported no console warning/error or page exception. The temporary
authenticated profile was removed.

Final production state:

- P1 is available to Staff and KPZ308 students.
- P2 remains deployed, persistent, and available to Staff for refinement.
- P2 is not currently visible to KPZ308 students.

## Remaining actions before 20 July

- No infrastructure action remains for the P1 class on 20 July.
- Continue teaching-content refinement through the Staff-only P2 route.
- At final P2 content signoff, replace the canary display text if appropriate,
  restore `KPZ308` to P2, and repeat the normal configuration, health, Staff,
  and student acceptance gates before its teaching release.
- Retain the existing backups and static teaching fallback.
- The validator's exact full P2 mount/`:z` assertion can be strengthened as a
  low-risk maintenance improvement; it is not a deployment blocker.
