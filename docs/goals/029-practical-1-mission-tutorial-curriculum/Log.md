# Log

## 2026-06-11 - Orchestrator Packet Creation

- Goal 028 was accepted, committed, and published to `origin/main` before this
  branch was created.
- Starting base for Goal 029:
  - branch: `codex/rpva-goal029-practical1-mission-tutorial`;
  - base commit:
    `7fb56fb Add campus IT TLS request pack`;
  - source: `origin/main`.
- Barry supplied the pedagogy direction:
  - Practical 1 should be app-led;
  - a lightweight mission worksheet should support observation and critical
    thinking;
  - students should learn by doing, testing, and playing with the model rather
    than only reading or memorising;
  - fallback remains useful but should not dominate this goal because the
    deep-server-hosted Shiny path has been proven in the general sense.
- Goal purpose:
  - design the two-hour student mission/tutorial arc;
  - map that arc to the existing Practical 1 Shiny screens and implemented
    stages;
  - produce a lightweight worksheet and instructor beat sheet;
  - record endpoint skills and later app-support gaps.
- Boundary:
  - docs-only pedagogy design;
  - no app/package code, Shiny UI/CSS/server edits, model/science/YAML changes,
    assessment redesign, hosting/service/deployment/TLS/account/credential work,
    student release, KPZ314 materials, commit, push, merge, or PR work.
- Packet files:
  - `docs/goals/029-practical-1-mission-tutorial-curriculum/Goal.md`
  - `docs/goals/029-practical-1-mission-tutorial-curriculum/Plan.md`
  - `docs/goals/029-practical-1-mission-tutorial-curriculum/Runbook.md`
  - `docs/goals/029-practical-1-mission-tutorial-curriculum/Log.md`

Status: packet ready for `woodhen`; execution not yet started.

## 2026-06-11 - Action-Agent Execution

Starting state:

- `pwd`: `/Users/bwbrook/git/rPVA`
- branch: `codex/rpva-goal029-practical1-mission-tutorial`
- `HEAD`: `7fb56fba9197f2840f3fdcccc2e956142863f689`
- `git status --short --branch`:
  - `## codex/rpva-goal029-practical1-mission-tutorial`
  - `?? docs/goals/029-practical-1-mission-tutorial-curriculum/`

Guard outcome:

- The branch and base match the Goal 029 packet.
- The Goal 028 closeout commit is present at the expected base.
- The only starting dirty state is the untracked Goal 029 packet directory.
- No Chief of Staff, Goal Composer, sibling project folder, KPZ314, archive, or
  external material was read.

Repo-local sources read:

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

Drafted deliverables:

- `docs/teaching/shiny/practical-1-mission-tutorial.md`
- `docs/teaching/woodhen/practical-1-mission-worksheet.md`
- `docs/teaching/woodhen/practical-1-instructor-beat-sheet.md`
- `docs/goals/029-practical-1-mission-tutorial-curriculum/pedagogy-review.md`

Narrow discoverability updates:

- `docs/teaching/shiny/README.md`
- `docs/teaching/woodhen/README.md`
- `docs/teaching/woodhen/instructor-guide.md`

Key design choices:

- The class keeps the Shiny app as the main teaching surface.
- The worksheet is a compact observation log, not a heavy handout.
- The two-hour mission arc sits inside a three-hour practical with Barry
  priming, recap pauses, export/transfer time, and wrap-up.
- The mission sequence maps only to current implemented stages:
  deterministic baseline, carrying capacity, demographic stochasticity,
  environmental stochasticity, genetic stochasticity, catastrophe, simple
  intervention, and extinction-vortex comparison.
- Allee effects and correlated events remain future concepts only.
- Fallback material remains a contingency path, not the centre of Practical 1.

No app/package code, Shiny UI/CSS/server file, test, science/YAML, model
default, assessment design, hosting, ShinyProxy/nginx/systemd/firewall/DNS/TLS,
Docker, service, account, student workspace, student-release, KPZ314, commit,
push, merge, PR, or Goal 030 work was done.

Changed/new repo-local files:

- `docs/teaching/shiny/README.md`
- `docs/teaching/shiny/practical-1-mission-tutorial.md`
- `docs/teaching/woodhen/README.md`
- `docs/teaching/woodhen/instructor-guide.md`
- `docs/teaching/woodhen/practical-1-instructor-beat-sheet.md`
- `docs/teaching/woodhen/practical-1-mission-worksheet.md`
- `docs/goals/029-practical-1-mission-tutorial-curriculum/Goal.md`
- `docs/goals/029-practical-1-mission-tutorial-curriculum/Plan.md`
- `docs/goals/029-practical-1-mission-tutorial-curriculum/Runbook.md`
- `docs/goals/029-practical-1-mission-tutorial-curriculum/Log.md`
- `docs/goals/029-practical-1-mission-tutorial-curriculum/pedagogy-review.md`

Validation:

- `git status --short --branch`: expected uncommitted review state with the
  new Goal 029 packet, mission tutorial, worksheet, beat sheet, pedagogy
  review, and narrow index updates.
- `git diff --check`: passed.
- `Rscript -e 'renv::status(sources = FALSE)'`: passed; no issues found.
- marker scan over changed/untracked text: no hits.
- secret/private-key-pattern scan over changed/untracked text: hits were only
  packet boundary wording, command text, existing class-account/token wording,
  credential boundary wording, and private-key safety wording; no secret
  values, private-key material, student identifiers, or sensitive service
  payloads found.
- stricter scan for assignment-like secret values and private-key blocks:
  no hits.
- manual boundary review: changed files are docs-only curriculum and narrow
  pointers; no app code, Shiny UI/CSS/server, test, science/YAML, assessment,
  deployment, service, account, student-workspace, release, or KPZ314 work was
  touched.

Recommended next gate:

- Orchestrator review for classroom tone and pacing.
- If accepted, a later human read-through with Barry/demonstrators or a narrow
  app-support goal could add small in-app mission/progress affordances, but no
  implementation is required by Goal 029.

## 2026-06-11 - Revision For Duplicate-Baseline Instruction

The rPVA orchestrator requested one narrow correction before final acceptance:
Mission 1 should not tell students to click `Start baseline` and then run the
`Deterministic baseline` stage again, because `Start baseline` initializes the
baseline as run 1 and resets the comparison history to that single run.

Changes made:

- `docs/teaching/shiny/practical-1-mission-tutorial.md`: Mission 1 now tells
  students to click `Start baseline`, inspect the baseline/current run, and
  keep that baseline as run 1 for later comparison.
- `docs/teaching/woodhen/practical-1-mission-worksheet.md`: the first worksheet
  prompt now tells students to click `Start baseline` and inspect the
  baseline/current run.
- `docs/goals/029-practical-1-mission-tutorial-curriculum/pedagogy-review.md`:
  wording now describes Start-screen baseline initialization rather than a
  separate baseline run.

The instructor beat sheet did not need a change; its wording already says to
get students through the baseline rather than to rerun the deterministic stage.

Revision validation:

- `git status --short --branch`: expected uncommitted Goal 029 review state.
- `git diff --check`: passed.
- `Rscript -e 'renv::status(sources = FALSE)'`: passed; no issues found.
- marker scan over changed/untracked text: no hits.
- secret/private-key-pattern scan over changed/untracked text: hits were only
  packet boundary wording, command text, existing class-account/token wording,
  credential boundary wording, and private-key safety wording; no secret
  values, private-key material, student identifiers, or sensitive service
  payloads found.
- stricter scan for assignment-like secret values and private-key blocks:
  no hits.
- duplicate-baseline wording check: no remaining instruction was found telling
  students to run `Deterministic baseline` again after `Start baseline`.
