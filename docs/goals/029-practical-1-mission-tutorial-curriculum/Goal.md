# Goal 029: Practical 1 Mission Tutorial Curriculum

## Objective

Design the Practical 1 student learning experience as an app-led, two-hour
mission tutorial with a lightweight worksheet that helps students record
observations, compare evidence, and think critically while they are doing,
testing, and playing with PVA concepts.

The completed state is a repo-local pedagogy package that gives Barry and
demonstrators a coherent Practical 1 classroom path:

1. a 2-hour student-facing mission/tutorial arc mapped to the existing Shiny
   screens and current implemented stages;
2. a lightweight mission worksheet or worksheet specification for observations,
   checkpoints, and evidence notes;
3. an instructor beat sheet showing where Barry's priming, class recaps, roaming
   prompts, and wrap-up fit around the student-led work;
4. clear endpoint learning outcomes: what students should be able to explain,
   compare, export, and transfer into the Woodhen practical by the end of
   Practical 1;
5. a concise gap list for any later app-text or UI-support goal, without making
   app-code changes in this goal.

This is a pedagogy and teaching-materials goal. It is not a hosting,
deployment, service, assessment-redesign, or app-implementation goal.

## Why This Matters

The Practical 1 Shiny app already has the main functional surfaces: Start,
Concept Lab, Compare, evidence export, and Transfer. The next bottleneck is the
student experience around those surfaces. Students should not merely read about
PVA mechanisms or follow a recipe. They should learn by changing one ecological
assumption at a time, seeing the model respond, comparing runs, recording
evidence, and explaining what changed and why.

Barry's teaching design intent is app-led learning supported by a light mission
worksheet. The worksheet should gently force observation and critical thinking,
not become a heavy reading pack or an assessment answer template.

Fallback material remains useful as a contingency, but Goal 029 should treat the
hosted or locally available Shiny app as the mainline Practical 1 teaching
experience. Do not recenter the goal around fallback recovery.

## Operating Mode

Docs-only pedagogy design and teaching-materials synthesis.

Do not implement app code. Do not change hosting or live services.

## Review Surface

The rPVA orchestrator will review:

- Goal 029 `Log.md`;
- the main mission tutorial curriculum document;
- the mission worksheet or worksheet specification;
- the instructor beat sheet or narrow instructor-guide update;
- any narrow README or teaching-doc pointers;
- the final changed-file list and validation evidence.

## Scope

In scope:

- read-only synthesis of existing rPVA teaching, Shiny, goal, and app-surface
  documentation;
- light read-only inspection of the current Practical 1 Shiny app text and
  teaching-stage catalog so the curriculum maps to what exists now;
- a two-hour student-guided learning path inside a three-hour practical;
- clear sequencing from baseline to carrying capacity, stochasticity,
  compounding small-population risk, intervention, comparison, and transfer;
- mission/tutorial language that makes the class feel interactive, purposeful,
  and exploratory without trivialising the ecology;
- lightweight worksheet prompts that capture observations, evidence exports,
  and scientific reasoning;
- Barry-facing instructor beats for priming discussion, recap moments,
  walk-around prompts, and wrap-up;
- a short "later app support" gap list for future UI text, progression, or
  checkpoint improvements if the curriculum reveals useful changes;
- narrow pointers from existing teaching indexes if needed.

Out of scope:

- app/package implementation changes;
- Shiny UI/CSS/server edits;
- tests, science/YAML, model-parameter, or scenario changes;
- hosting, ShinyProxy, nginx, systemd, firewall, DNS, TLS, Docker,
  certificate, account, credential, student-workspace, or public-release work;
- contacting Barry, Chief, campus IT, students, or external services;
- assessment redesign, grading-rubric changes, or AT1 policy changes;
- Practical 2 implementation;
- KPZ314 materials or implementation;
- new dependencies, generated binary artefacts, commits, pushes, PRs, or
  merges.

## Read First

- `README.md`
- `docs/teaching/shiny/README.md`
- `docs/teaching/shiny/practical-1-design-brief.md`
- `docs/teaching/shiny/implementation-roadmap.md`
- `docs/teaching/shiny/student-workspace-and-export-design.md`
- `docs/teaching/shiny/road-test-operations-plan.md`
- `docs/teaching/woodhen/README.md`
- `docs/teaching/woodhen/practical-1-pva-foundations.md`
- `docs/teaching/woodhen/practical-1-fallback-pack.md`
- `docs/teaching/woodhen/practical-2-woodhen-management.md`
- `docs/teaching/woodhen/classroom-dry-run-checklist.md`
- `docs/teaching/woodhen/instructor-guide.md`
- `docs/teaching/woodhen/expected-outputs.md`
- `docs/teaching/woodhen/troubleshooting.md`
- `docs/teaching/woodhen/assessment-design-crosswalk-2026.md`
- `docs/goals/024-practical-1-classroom-dry-run-fallback/dry-run-report.md`
- `inst/shiny/practical1/README.md`
- `inst/shiny/practical1/app.R`
- `R/teaching_api.R`

There is no repo-local `AGENTS.md` in this checkout. Use the repo-local files
above plus Barry's global Mac mini instructions and this Goal 029 packet.

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
codex/rpva-goal029-practical1-mission-tutorial
```

Expected starting base:

```text
7fb56fb Add campus IT TLS request pack
```

Treat any unexpected dirty state as project state. Do not clean, restore, or
overwrite it unless it is clearly your own failed intermediate output.

## Git And Publication Policy

- Work on `codex/rpva-goal029-practical1-mission-tutorial`.
- Do not commit.
- Do not push.
- Do not open a PR.
- Keep a precise changed-file list in `Log.md` and final response.

The orchestrator will review the uncommitted result before deciding whether a
separate closeout commit/publish goal is needed.

## Required Work

1. Prove current starting state.
   - Verify branch/status and expected base.
   - Confirm the Goal 028 closeout commit is present.
   - Confirm no unexpected dirty state exists before editing Goal 029 outputs.

2. Synthesize the existing Practical 1 teaching intent.
   - Use the Shiny design brief and existing Woodhen teaching docs as the main
     source of truth.
   - Identify what the current app already supports versus what must remain a
     later UI-support gap.
   - Preserve the core framing: app-led exploration with a light observation
     worksheet.

3. Design the two-hour mission arc.
   - Fit the student-led work inside a three-hour practical that also includes
     Barry's priming discussion, class recap moments, and wrap-up.
   - Sequence the learning so students start with a simple baseline and then
     scale toward stochasticity, compounded risk, and intervention.
   - Give each mission a purpose, student action, expected observation,
     comparison task, and checkpoint question.
   - Avoid cramming every possible concept into the first class. Prefer a clean
     progression students can finish and understand.

4. Draft the student mission worksheet.
   - Create a lightweight student-facing worksheet or worksheet specification.
   - Keep it short, active, and evidence-oriented.
   - Include prompts that make students record:
     - what they changed;
     - what output moved;
     - which evidence supports their explanation;
     - what uncertainty or caveat remains.
   - Make clear that app exports are evidence, not answers.

5. Draft the instructor beat sheet.
   - Show where Barry can prime the room, pause for class recaps, roam with
     prompts, and wrap up.
   - Include likely student misconceptions and concise coaching prompts.
   - Include timing guidance that protects the student-led app work from being
     swallowed by setup or lecture.

6. Record endpoint outcomes.
   - By the end of Practical 1, students should be able to:
     - distinguish extinction probability, median abundance, and uncertainty;
     - compare scenarios rather than describe runs in isolation;
     - explain one-factor assumption changes;
     - recognise why zero observed extinction is not proof of safety;
     - describe how stochasticity and small-population processes can compound;
     - use evidence exports to support interpretation;
     - enter Practical 2 ready to reason about the Woodhen case.

7. Update indexes narrowly if useful.
   - Add small pointers from existing teaching README/index files only if the
     new documents would otherwise be hard to find.
   - Do not broadly rewrite existing teaching docs.

8. Validate.
   - Run the validation gates listed below.
   - Confirm no secrets, credentials, private keys, student identifiers, or
     sensitive service details appear in changed text.

## Suggested Output Files

Use these paths unless a better existing naming pattern is clearly preferable:

- `docs/teaching/shiny/practical-1-mission-tutorial.md`
- `docs/teaching/woodhen/practical-1-mission-worksheet.md`
- `docs/teaching/woodhen/practical-1-instructor-beat-sheet.md`
- `docs/goals/029-practical-1-mission-tutorial-curriculum/pedagogy-review.md`

Small, focused updates to existing README or instructor index files are allowed
if needed for discoverability.

## Validation Gates

The goal is not complete until these pass, or a blocker is logged with exact
evidence:

```sh
git status --short --branch
git diff --check
Rscript -e 'renv::status(sources = FALSE)'
```

Also complete:

- marker scan over changed/new tracked text;
- secret/private-key-pattern scan over changed/new tracked text;
- manual review that no credential value, private key, student identifier, or
  sensitive service payload appears in changed files.

Do not run browser, Shiny, remote, service, or deployment checks unless needed
to resolve a documentation ambiguity. This is a curriculum design goal, not an
operational dry run.

## Stop Rules

Stop and report to the orchestrator if:

- the starting branch/base/status is not as expected;
- repo-local teaching docs or app files are missing or inconsistent in a way
  that blocks the curriculum map;
- the work would require app implementation, model/science changes, assessment
  redesign, service changes, student release, or external IT action;
- the work would require reading sibling project folders, Chief of Staff, Goal
  Composer, KPZ314 materials, or archive material;
- any validation gate fails;
- a real secret, private key, credential, student identifier, or sensitive
  service payload appears in repo files or terminal output.

## Expected Final Report

Report:

- final branch, HEAD, and status;
- changed files;
- where the main mission tutorial, worksheet, instructor beat sheet, and
  pedagogy review live;
- the high-level student learning arc;
- endpoint take-away skills and knowledge;
- any later app-support gaps identified;
- validation commands and results;
- explicit confirmation that no app code, science/YAML, assessment redesign,
  hosting, service, account, credential, student-release, KPZ314, commit, push,
  PR, or merge work was done.
