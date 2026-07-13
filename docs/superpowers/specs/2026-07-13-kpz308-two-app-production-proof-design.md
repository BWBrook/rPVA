# KPZ308 Two-App Production Proof Design

Date: 2026-07-13

## Purpose

Prove, one week before the first KPZ308 class, that the UTAS production
ShinyProxy service can expose and run KPZ308 Practical 1 and Practical 2 at
the same time. The proof must cover distinct immutable images, stable app
identities, separate per-user workspace paths, concurrent browser sessions,
and production access through the KPZ308 Entra ID group.

This is an infrastructure release gate. It is not final teaching-content
signoff for Practical 2.

## Context

Practical 1 has already passed image publication, dev deployment, browser
interaction, export, and capacity checks. Its stable ShinyProxy app ID is
`kpz308-rpva-practical`.

The repository also contains a functional Practical 2 Woodhen Management Lab
under `inst/shiny/practical2`. It has an exported
`rPVA::run_practical2_shiny()` entry point, bounded scenario choices, CSV and
Markdown exports, and dedicated tests. Using this app is a stronger production
canary than cloning Practical 1 or building a throwaway diagnostic GUI because
it exercises the real Practical 2 package and runtime path.

## Permanent Identities

| Property | Practical 1 | Practical 2 |
|---|---|---|
| ShinyProxy app ID | `kpz308-rpva-practical` | `kpz308-rpva-practical2` |
| Registry repository | `git.its.utas.edu.au/utas/kpz308-rpva-practical` | `git.its.utas.edu.au/utas/kpz308-rpva-practical2` |
| Host workspace subtree | `data/kpz308-rpva-practical/workspaces` | `data/kpz308-rpva-practical2/workspaces` |
| Runtime workspace mount | `/srv/rpva-workspaces/current` | `/srv/rpva-workspaces/current` |
| Student group | `KPZ308` | `KPZ308` during the canary and final release |
| Staff group | `UNI-Ecology-Teaching-Shiny-Staff` | `UNI-Ecology-Teaching-Shiny-Staff` |

The app IDs, image repositories, and host workspace subtrees are independent.
The common in-container workspace mount is safe because each app container has
its own host source path.

## Image Design

Practical 2 receives a dedicated Docker recipe based on the proven Practical 1
runtime pattern. It will:

- use the repository root as build context;
- restore the locked R environment and install the `rPVA` package;
- verify that the installed Practical 2 app directory exists;
- expose port 3838 and retain the same HTTP health check;
- launch `rPVA::run_practical2_shiny()`;
- carry the exact source commit in the OCI revision label; and
- be published only with an immutable source-derived tag.

Practical 1 and Practical 2 must use distinct registry repositories. Publishing
the same image under two tags does not satisfy this proof.

## Deployment Sequence

### 1. Practical 2 source and image gate

Run the Practical 2 API and Shiny tests, validate the new Docker recipe, build
for `linux/amd64`, and run a local browser/container smoke test. Push the image
to the Practical 2 registry repository and record the immutable tag and
registry digest.

### 2. Dev two-app gate

Inspect the dev service before mutation. Back up `application.yml`, create the
Practical 2 workspace subtree, add the second app spec, and restart ShinyProxy.
Practical 1 keeps its existing stable ID and current image.

Open both apps concurrently in separate browser tabs. The proof must show:

- ShinyProxy health is `UP`;
- one healthy Practical 1 app container is running;
- one healthy Practical 2 app container is running;
- the app containers use the expected distinct images;
- a bounded workflow completes in each app;
- each app produces its own CSV and Markdown exports; and
- the host workspace paths remain separate.

Failure restores the dev backup and confirms Practical 1 still opens.

### 3. Production rollout gate

Perform read-only production discovery first. Confirm current app IDs, image
tags, access groups, workspace paths, running containers, and actuator health.

Back up production `application.yml`. In one reviewed configuration change:

- update Practical 1 to the immutable image already accepted on dev;
- add Practical 2 using the dev-accepted immutable tag and digest;
- retain `UNI-Ecology-Teaching-Shiny-Staff` and `KPZ308` on Practical 1;
- apply both groups to Practical 2 for the canary window; and
- create the separate Practical 2 workspace subtree with matching ownership,
  permissions, and SELinux handling.

Pull both images before restart, review the exact diff, then restart ShinyProxy
once. Actuator health must return `UP` before browser testing begins.

### 4. Production concurrency gate

Repeat the two-tab functional test on production while both sessions remain
active. Capture:

- both browser routes and visible app identities;
- successful bounded interactions and exports from both apps;
- ShinyProxy plus two healthy app containers;
- the exact image tag used by each app container;
- relevant `Starting proxy` and `Proxy activated` log lines;
- absence of unexplained error or warning lines;
- distinct host workspace paths; and
- UTAS infrastructure monitoring feedback for the test window when available.

This is a concurrency and routing proof, not a capacity retest. The earlier
60-container capacity evidence remains applicable unless runtime resource
limits or the base image materially change.

### 5. Student access gate

During a short, announced canary window, display Practical 2 as
`KPZ308 Practical 2 - Infrastructure Canary`. A current KPZ308 student should
confirm that both KPZ308 tiles are visible and that both apps launch.

The student is not required to complete model runs. The purpose is to prove the
Entra ID group, ShinyProxy access group, launcher visibility, and proxy launch
path using a real student identity.

If no student is available immediately, Staff testing may complete the
production concurrency gate, but the student-access gate remains explicitly
pending. Configuration inspection alone must not be reported as empirical
student-access proof.

### 6. Canary closeout

After the student-access proof:

- remove `KPZ308` from the Practical 2 spec;
- retain `UNI-Ecology-Teaching-Shiny-Staff`;
- restart ShinyProxy and verify health;
- confirm Practical 1 remains available to KPZ308;
- confirm Practical 2 remains available to Staff; and
- retain the Practical 2 spec, image, workspace, and rollback evidence for
  continued content refinement.

At final Practical 2 teaching-content signoff, restore `KPZ308`, replace the
canary display name with the final student-facing name, and repeat the normal
refresh and browser acceptance gates.

## Rollback

Every server mutation starts with a timestamped `application.yml` backup that
preserves owner, group, and mode. Images use immutable tags, so rollback does
not depend on registry tag movement.

Rollback is triggered by any of the following:

- ShinyProxy fails to return `UP`;
- either app fails to launch or becomes unhealthy;
- an app uses an unexpected image;
- the configuration diff changes an unrelated app or access group;
- exports or the bounded browser workflow fail;
- workspace ownership, permissions, or SELinux handling are wrong; or
- Practical 1 regresses after Practical 2 is added.

Rollback restores the previous `application.yml`, restarts ShinyProxy, confirms
actuator health, and opens Practical 1. A failed Practical 2 proof must not
leave Practical 1 impaired.

## Evidence Record

The final repository report will include:

- source commits, immutable tags, image IDs, and registry digests;
- local, dev, and production verification commands and results;
- redacted configuration diffs;
- browser screenshots and export summaries for both apps;
- concurrent container names, images, and health states;
- workspace separation evidence;
- student and Staff access outcomes;
- infrastructure monitoring feedback;
- canary-closeout state; and
- exact rollback files and commands.

No passwords, tokens, session cookies, SAML assertions, or unnecessary user
identifiers belong in the repository report.

## Success Criteria

The infrastructure proof is complete when:

1. two distinct immutable image repositories have accepted images;
2. dev runs both apps concurrently and both workflows pass;
3. production runs both apps concurrently and both workflows pass;
4. two healthy app containers are observed simultaneously on production;
5. separate per-app workspace paths are confirmed;
6. a current KPZ308 student launches both apps, or that gate is clearly left
   pending with an owner and deadline;
7. Practical 2 is returned to Staff-only access after the canary; and
8. the durable evidence and rollback report is committed for the orchestrator.

## Non-Goals

- Final Practical 2 scientific or pedagogical content signoff.
- KPZ314 deployment or access testing.
- A repeat of the 60-container capacity test without a material runtime change.
- Refactoring Practical 1 or changing its stable identity.
- Permanent student exposure of provisional Practical 2 content.
