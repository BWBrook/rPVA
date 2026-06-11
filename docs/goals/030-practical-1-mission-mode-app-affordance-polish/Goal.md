# Goal 030: Practical 1 Mission-Mode App Affordance Polish

## Objective

Make the existing Practical 1 Shiny app visibly support the Goal 029 mission
tutorial by adding small, classroom-facing app affordances and tests, without
changing the science, export contract, hosting, assessment, or deployment
surface.

The completed state is that a student using the browser app can see the mission
path, understand that `Start baseline` creates run 1, change one thing at a
time in the Concept Lab, choose a clean comparison in Compare, export the same
evidence artefacts as before, and transfer those habits into the Woodhen
practical.

This is a narrow app-polish implementation goal. It is not a redesign, not a
new teaching module, and not a service/readiness goal.

## Why This Matters

Goal 029 turned Practical 1 into an app-led mission tutorial with a lightweight
worksheet. The app already works, but the browser surface still reads more like
a generic concept lab than a mission-guided class experience. A small UI/text
pass can reduce student hesitation during the first class by making the intended
learning path visible in the app itself.

The most important classroom friction to prevent is duplicate or unfocused
comparison runs. The app should make it obvious that the Start screen creates
the baseline run, that each Concept Lab run should change one assumption, and
that Compare is for selecting evidence, not filling a table with repeated
clicks.

## Operating Mode

Small local Shiny implementation plus tests, docs, and browser-visible smoke.

No live service changes.

## Review Surface

The rPVA orchestrator will review:

- Goal 030 `Log.md`;
- diffs for `inst/shiny/practical1/app.R` and any CSS changes;
- focused tests in `tests/testthat/test-13_practical1_shiny.R` or a clearly
  related test file;
- narrow documentation updates;
- local browser smoke evidence through Start, Concept Lab, Compare/export, and
  Transfer;
- validation output and final changed-file list.

## Scope

In scope:

- small Shiny UI/text changes that make the Goal 029 mission path visible;
- stage-specific mission/progress labels or equivalent lightweight cues;
- Start-screen wording that clearly states the baseline is created as run 1;
- Concept Lab guidance that reinforces one-factor changes and comparison;
- Compare-screen guidance that helps students choose a clean baseline/risk/
  intervention comparison and avoid duplicate reruns;
- narrowly scoped CSS if needed for readable mission cues;
- focused tests proving the app contains the new affordances and preserves the
  existing export/download wiring;
- a local browser smoke of the mission path, including evidence downloads;
- targeted app/teaching documentation updates if the app wording changes.

Out of scope:

- new PVA mechanisms, new model stages, or new scientific defaults;
- changes to stochastic engine behaviour, teaching API semantics, scenarios, or
  YAML files;
- changes to export file shape, filenames, or public package APIs unless
  already covered by existing tests and accepted by the orchestrator;
- student accounts, persistence, analytics, server-side workspaces, or note
  storage;
- Practical 2 app mode;
- assessment redesign, grading-rubric changes, or AT1 policy changes;
- hosting, ShinyProxy, nginx, systemd, firewall, DNS, TLS, Docker,
  certificates, credentials, class accounts, student workspaces, public/student
  release, or remote state;
- KPZ314 materials or implementation;
- broad visual redesign, new dependencies, generated binary artefacts, commits,
  pushes, PRs, or merges.

## Read First

- `README.md`
- `docs/teaching/shiny/README.md`
- `docs/teaching/shiny/practical-1-design-brief.md`
- `docs/teaching/shiny/practical-1-mission-tutorial.md`
- `docs/teaching/shiny/implementation-roadmap.md`
- `docs/teaching/woodhen/practical-1-mission-worksheet.md`
- `docs/teaching/woodhen/practical-1-instructor-beat-sheet.md`
- `docs/goals/029-practical-1-mission-tutorial-curriculum/Goal.md`
- `docs/goals/029-practical-1-mission-tutorial-curriculum/pedagogy-review.md`
- `inst/shiny/practical1/README.md`
- `inst/shiny/practical1/app.R`
- `inst/shiny/practical1/www/styles.css`
- `R/teaching_api.R`
- `tests/testthat/test-12_teaching_api.R`
- `tests/testthat/test-13_practical1_shiny.R`

There is no repo-local `AGENTS.md` in this checkout. Use the repo-local files
above plus Barry's global Mac mini instructions and this Goal 030 packet.

Do not read sibling project folders, Chief of Staff, Goal Composer, KPZ314
materials, or archive material.

## Starting State Checks

Before editing beyond this packet, report in `Log.md` and final response:

```sh
pwd
git branch --show-current
git rev-parse --short HEAD
git status --short --branch
```

Expected branch at handoff:

```text
codex/rpva-goal030-mission-app-affordances
```

Expected starting base:

```text
9d2504b Add Practical 1 mission tutorial curriculum
```

Treat any unexpected dirty state as project state. Do not clean, restore, or
overwrite it unless it is clearly your own failed intermediate output.

## Git And Publication Policy

- Work on `codex/rpva-goal030-mission-app-affordances`.
- Do not commit.
- Do not push.
- Do not open a PR.
- Keep a precise changed-file list in `Log.md` and final response.

The orchestrator will review the uncommitted result before deciding whether a
separate closeout commit/publish goal is needed.

## Required Work

1. Prove current starting state.
   - Verify branch/status and expected base.
   - Confirm the Goal 029 closeout commit is present.
   - Confirm no unexpected dirty state exists before editing Goal 030 outputs.

2. Write focused tests first or alongside implementation.
   - Extend `tests/testthat/test-13_practical1_shiny.R` or create a narrow
     companion test if cleaner.
   - Tests should prove:
     - mission/progress text or equivalent cues are present;
     - `Start baseline` wording makes clear it creates or keeps run 1;
     - Compare guidance encourages a clean comparison and discourages duplicate
       or unfocused reruns;
     - the existing comparison CSV and evidence-notes download wiring remains
       present;
     - app construction remains non-writing.

3. Add minimal mission-mode app affordances.
   - Keep the existing Start -> Concept Lab -> Compare -> Transfer flow.
   - Prefer small text/structure additions over layout redesign.
   - Add a mission/progress cue that maps implemented stages to the Goal 029
     mission arc.
   - Add a short "why this mission matters" or equivalent stage-specific cue if
     it helps students connect the selected stage to the worksheet.
   - Make one-factor-change guidance visible before students run a stage.
   - Make duplicate-baseline and duplicate-rerun avoidance clear without adding
     hard blocking logic unless it is trivial and safe.

4. Preserve the export and science contracts.
   - Do not change export filenames, exported column shape, or evidence-notes
     content unless the existing tests are updated and the change is justified
     as app wording only.
   - Do not change `teaching_stage_catalog()` semantics, model defaults,
     scenario/YAML files, or PVA engine behaviour.
   - Do not add dependencies.

5. Update narrow documentation.
   - Update `inst/shiny/practical1/README.md` or teaching docs only if the app
     affordances change what students or demonstrators should expect.
   - Keep Goal 029 curriculum documents as the source of the learning arc; do
     not rewrite them broadly.

6. Prove the result in a browser.
   - Launch Practical 1 Shiny locally on `127.0.0.1`.
   - Use Chrome plugin, in-app Browser, or Playwright/Chromium; record which
     path was used.
   - Exercise:
     - Start baseline;
     - at least carrying capacity, environmental or demographic stochasticity,
       catastrophe or genetics, and intervention or extinction vortex;
     - Compare guidance;
     - comparison CSV download;
     - evidence-notes Markdown download;
     - Transfer.
   - Inspect downloaded artefacts enough to prove export shape is unchanged.
   - Stop the app and confirm the port is closed.

7. Validate.
   - Run the validation gates listed below.
   - Confirm no secrets, credentials, private keys, student identifiers, or
     sensitive service details appear in changed text.

## Validation Gates

The goal is not complete until these pass, or a blocker is logged with exact
evidence:

```sh
git status --short --branch
git diff --check
Rscript -e 'source("bootstrap.R")'
Rscript -e 'renv::status(sources = FALSE)'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'
Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'
```

Also complete:

- marker scan over changed/new tracked text;
- secret/private-key-pattern scan over changed/new tracked text;
- stricter assignment/private-key-block scan;
- browser-visible local Shiny smoke described above.

Do not run remote, service, deployment, or campus-route checks for this goal.

## Stop Rules

Stop and report to the orchestrator if:

- the starting branch/base/status is not as expected;
- the requested affordances require more than small UI/text/CSS changes;
- preserving the export contract would require substantial refactoring;
- the browser smoke cannot prove the visible mission affordances or downloads;
- the work would require app persistence, accounts, analytics, new
  dependencies, model/science changes, assessment redesign, service changes,
  student release, or external IT action;
- the work would require reading sibling project folders, Chief of Staff, Goal
  Composer, KPZ314 materials, or archive material;
- any validation gate fails;
- a real secret, private key, credential, student identifier, or sensitive
  service payload appears in repo files or terminal output.

## Expected Final Report

Report:

- final branch, HEAD, and status;
- changed files;
- app affordances added;
- tests added or changed;
- browser path used and evidence locations;
- confirmation that export shape remains unchanged;
- validation commands and results;
- explicit confirmation that no science/YAML, Practical 2, assessment,
  hosting/service, account/credential/student-workspace, student-release,
  KPZ314, commit, push, PR, merge, or Goal 031 work was done.
