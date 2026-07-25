# Practical 2 Gate Justification And Review Notes

## Purpose

This document explains why each gate exists, what it enables, which alternatives
remain available, and which criticism belongs in its review. It is the
interpretive companion to
`2026-07-22-practical2-woodhen-management-lab-revised.md`.

The division of labour is deliberate:

- **Codex owns engineering assurance:** code correctness, regression tests,
  state integrity, browser automation, export structure, container identity,
  deployment safety, rollback evidence, and the final technical acceptance
  record.
- **Barry owns scientific judgement:** parameter meaning, biological mechanisms,
  empirical and pedagogical provenance, ecological bounds, assumptions,
  omissions, and whether model evidence supports the intended inference.
- **Barry owns the student-facing judgement:** pedagogy, language, visualisation,
  workflow, cognitive load, interface taste, and whether scaffolding supports
  rather than replaces student thought.

Passing tests cannot establish that a plot teaches the right lesson. Conversely,
Barry is not expected to infer software quality from test counts or review
backend architecture.

## Two-Checkpoint Student-Facing Gates

Each substantially new student-facing surface uses two checkpoints.

### Design Probe

The design probe presents the complete visible teaching model using cached,
representative, or stubbed evidence. It includes final-form controls, copy,
contextual help, plots, tables, prompts, and visual hierarchy. Simulation wiring,
project persistence, ancestry, and exhaustive tests may remain incomplete.

This checkpoint answers the expensive questions early:

- Does the student understand the scientific purpose before seeing controls?
- Are baseline values, units, and held-constant assumptions visible?
- Do the plots and tables expose the right comparison?
- Is the language natural for a third-year ecology student?
- Is the degree of scaffolding appropriate?
- Is the page calm enough to use while thinking?

The review package names every deliberately unfinished behaviour so Barry can
judge the intended surface without mistaking a stub for a finished feature.

### Working Implementation

After design approval, Codex connects the surface to simulations, progress,
project state, ancestry, evidence selection, exports, and focused tests. Barry's
second look is brief: it confirms that the real workflow still matches the
approved design and has not acquired confusing engineering leakage.

## Required Codex Self-Review

Before either student-facing checkpoint, Codex runs at least one representative
workflow and inspects the rendered screen at the principal desktop resolutions.
It does not treat a rendered DOM element or `ggplot` object as visual acceptance.

The single focused self-review checks:

- plot width and height are sufficient for interpretation;
- uncertainty is not clipped;
- probability axes span 0-1 with useful ticks;
- bird counts are whole numbers and intervals avoid false precision;
- tables avoid page-level horizontal scrolling where a clearer layout is
  available;
- labels describe ecology rather than internal IDs or objects;
- explanation precedes controls;
- realistic slow runs show continuous, honest progress;
- help answers what the feature is, why it matters, and how to interpret it;
- 1366x768 and 1440x900 work as the release viewports; and
- the page makes sense to a student who completed Practical 1 but has never seen
  the implementation plan.

This is one walkthrough and one material self-repair, not a screenshot-polishing
marathon.

## How Barry Reviews A Student-Facing Gate

Useful criticism is concrete and experience-based:

- “This ecological assumption is wrong or inadequately qualified.”
- “A student will not know what this term means at this point.”
- “This plot scale hides the important pattern.”
- “The interface gives the wrong lesson through false precision.”
- “This control appears before its conceptual justification.”
- “The page is too dense to scan during a practical.”
- “This amount of scaffolding prevents independent thought.”

Normally out of scope for Barry's review:

- R function decomposition or Shiny module architecture;
- internal scenario IDs, storage schemas, fingerprints, and event contracts;
- the number or organisation of automated tests;
- library choices that do not affect the student experience;
- container layers, registry mechanics, and deployment scripts; and
- source-file naming or code style.

These internal matters become legitimate student-facing criticism when they
leak into visible text, cause delay without feedback, lose evidence, constrain a
scientifically necessary action, or otherwise alter the experience.

## Gate A1: Scientific Engine And Risk Evidence

**Why this gate exists:** Later interfaces require consistent annual threats,
interventions, extinction risk, and warning-threshold calculations.

**What it sets up:** Historical, sensitivity, prospective, and optional advanced
scenarios can use one tested engine without changing Practical 1.

**Alternatives:** A separate Practical 2 simulator would isolate code but create
duplicated logic and divergent teaching results. Hand-calculated UI summaries
would be quicker initially but scientifically fragile. The shared engine remains
the better implementation.

**Review boundary:** Hard engineering. Barry does not review API structure,
profile validation, scalar-path equivalence, or tests here. Passing this gate
does not approve the biological meaning of the catalogue; that is Gate A2.

## Gate A2: Ecological Assumptions And Catalogue Audit

**Why this gate exists:** Parameter values, sensitivity bounds, threats,
interventions, temporal assumptions, stage meanings, and warning thresholds are
scientific content even when their implementation is already tested.

**What it sets up:** Gates F and G can use an explicitly reviewed ecological
vocabulary and value set. Student help can distinguish empirical evidence,
historical tuning, inherited practical settings, and bounded exploration.

**Alternatives:** Barry could review controls after they appear in Investigate,
but that would allow interface design to harden questionable assumptions. Reading
the R catalogues directly would obscure provenance and model meaning. A compact
human-readable audit is lower cost and earlier.

**Barry should critique:** Every baseline value and unit; both proposed altered
sensitivity settings; threat and intervention mechanisms; timing; source or
rationale; omitted processes; the independence of historical observations; the
biological conversion from model stages to breeding pairs; and the status of the
100-pair value.

**Out of scope for Barry:** Catalogue data structures, validators, profile
objects, fingerprints, and unit-test implementation unless they impose a wrong
biological constraint.

**Epistemic rule:** Strictly fewer than 100 modelled territory-holding breeding
pairs is a shared working warning threshold for this practical. It is
approximately the population scale that preceded rodent eradication, but it is
not a direct conversion of historical total-bird counts. It is not described as
a universal minimum viable population or proven tipping point.

## Gate B: Durable Projects And Compact Evidence

**Why this gate exists:** Students continue after class and may move between SSO
and off-campus hosts. Evidence must survive without relying on one browser or
server workspace.

**What it sets up:** Every later tab can add runs, notes, selections, and exports
to one portable investigation record.

**Alternatives:** Server accounts or cloud sync would improve convenience but add
authentication, privacy, and operational complexity. Full trajectory storage
would make packages large. Compact portable evidence is the appropriate first
release compromise.

**Review boundary:** Hard engineering. Barry reviews only whether Create,
Resume, Download, and Import are understandable when they appear on Start and in
the export workflow.

## Gate C: Start

**Why this gate exists:** Start establishes role, motivation, prior knowledge,
and expectations. Errors here distort every later task even when the software
works perfectly.

**What it sets up:** Students understand the Woodhen case, two phases,
core-versus-extension philosophy, and how to preserve their work.

**Alternatives:** The background could live only in a handout, or Start could be
minimal. The chosen design keeps the page scannable while making deeper history
available in context.

**Barry should critique:** Biological accuracy, tone, narrative emphasis, image
suitability, expected knowledge, cognitive load, and project-action language.

**Out of scope for Barry:** Autosave internals, ZIP validation, modal plumbing,
and JavaScript storage mechanics.

**Checkpoint note:** Start, the 1980 reconstruction, and the recovery/future
section receive separate labelled commits from this revision onward. The existing
combined pre-review checkpoint remains as history rather than being rewritten.

## Gate D: Calibrate - 1980 Management Alternatives

**Why this gate exists:** The first scientific lesson is a controlled historical
reconstruction of choices available during the 1980 crisis. It is narrower than
the full Calibrate tab and therefore reviewable on its own.

**What it sets up:** Students learn why comparable starting conditions and
horizons matter, how interventions alter trajectories and risk, and why model
agreement is evidence of plausibility rather than proof.

**Alternatives:** Showing scenarios sequentially is simpler, but weakens direct
comparison. A single combined plot is compact, but can conceal intervention
timing and extinction evidence. The stable evidence grid balances these needs.

**Barry should critique:** The management story, scenario assumptions, plot
choice and scale, uncertainty, intervention timing, extinction evidence, and
whether model/data agreement is described with appropriate caution.

**Out of scope for Barry:** Progress callbacks, module events, cached evidence,
and insertion mechanics unless they cause visible failure.

## Gate E: Calibrate - Rodent Recovery And Common Future Comparison

**Why this gate exists:** The short recovery consistency check and 75-year future
comparison serve different inferences and must not be visually conflated.

**What it sets up:** Students see what historical consistency can and cannot
support, then begin Phase 2 from one shared future comparison.

**Alternatives:** The recovery run could be omitted because it is short, but it
anchors the scenario to observed history. Combining it with the future case
would blur reconstruction and projection.

**Barry should critique:** Whether “Calibrate” is explained as reconstruction or
plausibility checking rather than independent validation; whether 2019 and 2024
observations are represented with their correct independence; survey overlay;
warning-threshold rationale; future framing; and plot readability.

**Out of scope for Barry:** Run caching, project insertion, and plot-construction
code.

## Gate F: One-Factor Sensitivity

**Why this gate exists:** Sensitivity analysis is compulsory and likely the
first time students independently alter model assumptions. The current draft's
generic controls are not an acceptable teaching model.

**What it sets up:** Students can ask how one uncertain assumption changes risk
while holding the rest of the future constant, then retain useful evidence.
The baseline is bracketed by one higher and one lower setting, with deliberately
wide bounded exploratory ranges that are teaching assumptions rather than
empirical forecasts.

**Alternatives:** A general parameter table offers flexibility but too much early
cognitive load. A fixed demonstration is safer but limits ownership. One named
factor with two alternatives is the appropriate compulsory structure.

**Design-probe review:** Barry judges whether the varied quantity, units,
baseline, held-constant assumptions, one-factor logic, response plot, warning
threshold, prompts, and help are understandable. Simulation and persistence may
still be stubbed and are not reviewed then.

**Working confirmation:** Barry checks only that the real 1,000-future workflow
still looks and behaves like the approved probe. Codex owns ancestry, progress,
round trips, and tests.

## Gate G: Threat And Intervention

**Why this gate exists:** The compulsory prospective comparison must distinguish
a threat from a management response and apply the response to the threatened
future rather than silently replacing it.

**What it sets up:** Students can compare no change, threat, and intervention,
then reason from relative improvement to qualified advice.

**Alternatives:** Independent scenario cards are easier to implement but obscure
ancestry. A fully free multi-factor builder offers more headroom but invites
fantasy scenarios before the core reasoning is secure.

**Design-probe review:** Barry judges mechanism credibility, baseline visibility,
units, comparison logic, degree of choice, plot suite, prompts, and the caution
that simulated improvement is not proof of real-world effectiveness.

**Working confirmation:** Barry checks that real runs preserve the approved
logic and remain readable. Codex owns validation, ancestry, persistence,
progress, and tests.

## Gate I: Compare

**Why this gate exists:** Students need to synthesize runs rather than merely
generate them. Compare is also where incompatible evidence must become obvious.

**What it sets up:** Students can identify a defensible contrast, accumulate
observations and caveats, and nominate evidence deliberately for the dossier.

**Alternatives:** A full run-history table is easy but makes navigation dominate
interpretation. Automatic comparison is convenient but removes student choice.
The selected-workspace plus compact library preserves agency.

**Design-probe review:** Barry judges hierarchy, plot modes, compatibility
warnings, note accumulation, evidence nomination, and whether the interface
supports synthesis rather than output collection. Stubbed state is declared.

**Working confirmation:** Barry checks that real project data did not distort the
approved surface. Codex owns filtering, compatibility rules, provenance, and
round trips.

## Gate J1: Evidence Selection And Preview

**Why this gate exists:** Selection is an intellectual act. Students should see
exactly what they are preparing without the app deciding what their report must
contain.

**What it sets up:** J2 can generate artefacts from an intentional, previewed
evidence set rather than exporting everything.

**Alternatives:** Automatic export is simpler but rewards accumulation. A blank
export builder offers freedom but little support. A restrained preview provides
useful scaffolding without prescribing the report.

**Design-probe review:** Barry judges selection friction, preview clarity,
provenance visibility, sparse/excessive guidance, and whether the app leaves
room for student judgement.

**Working confirmation:** Barry checks the live project selection behaves like
the approved probe. Codex owns persistence and state integrity.

## Gate J2: Dossier And Essential Outputs

**Why this gate exists:** A sound selection interface does not guarantee that
the resulting files are readable, editable, or useful in report preparation.

**What it sets up:** Students can move a portable project between hosts and use
an editable Word dossier, figures, and tables while retaining provenance.

**Alternatives:** PDF is visually stable but awkward for reuse. Markdown is
machine-friendly but unfamiliar to many students. Word is the core human-facing
format; PNG and CSV are useful companions. Markdown is secondary and must not
delay release.

**Barry should critique:** One realistic DOCX and representative PNG/CSV pair:
usefulness, legibility, false precision, provenance, selection burden, and
whether the files support rather than compose the report.

**Out of scope for Barry:** OOXML structure, Pandoc invocation, temporary files,
archive validation, and browser round-trip mechanics. Codex validates these.

## Gate J3: Report, Research, And Assessment Guidance

**Why this gate exists:** Guidance has a different pedagogical risk from either
the Evidence Studio or file generation. It can be too vague or inadvertently
write the assignment for students.

**What it sets up:** App and teaching documents consistently explain the locked
criteria, approximately 2,000-word scope, evidence selectivity, literature
research, uncertainty, display restraint, and ways to deepen the investigation.

**Alternatives:** A fixed report template would be easy to follow but suppress
individual judgement. Minimal advice preserves freedom but disadvantages students
who need orientation. Structured questions and possibilities are the intended
middle ground.

**Barry should critique:** Language, criteria alignment, degree of prescription,
research encouragement, display guidance, and whether the advice helps without
becoming a report template.

**Out of scope for Barry:** Content-contract implementation and Markdown loading
mechanics.

## Gate H: Optional Advanced Sandbox

**Why this gate moved:** Building delayed profiles, compound threats, multiple
interventions, and robustness controls before Compare and Evidence Studio risks
spending scarce time on controls that do not create useful evidence.

**What it sets up when included:** Ambitious students gain bounded intellectual
headroom after the compulsory evidence journey is already complete.

**Alternatives:** Defer the entire sandbox for the first release while preserving
data-model hooks; implement only one or two high-value extensions revealed by
Compare; or implement the full planned set later. None blocks core success.

**Design-probe review if scheduled:** Barry judges whether the proposed subset
enables meaningful Woodhen questions without encouraging fantasy scenarios,
concealing interactions, or overwhelming the compulsory route.

**Out of scope for Barry:** Profile validators, conflict algorithms, and ancestry
serialization unless they prevent a scientifically defensible investigation.

## Gate K: Integrated Local Acceptance And Classroom Dry Run

**Why this gate exists:** Individually accepted tabs can still fail as a journey.
Automated clicking also cannot show that reading, thinking, running, and recording
fit the three-hour class.

**What it sets up:** Production receives one integrated candidate with verified
project portability, exports, desktop behaviour, and realistic classroom timing.

**Alternatives:** Per-tab checks alone are faster but miss cross-tab state and
timing. A full student pilot is stronger but may not be available before class.
A fresh-project human-paced dry run is the minimum release evidence.

**Codex owns:** Full suite, browser automation, fresh-context import, export
validation, desktop checks, container scaffold, and the timing record.

**Barry should critique:** Whether the recorded compulsory route is realistic for
students, where interpretation time is needed, whether anything is repetitive,
and which work belongs after class.

**Mobile boundary:** 390x844 is a non-blocking catastrophic-failure check. The
release requirement is the normal university laptop/desktop experience.

## Gate L: Staff Beta And Production Release

**Why this gate exists:** Local success does not establish registry identity,
ShinyProxy launch, SSO access, per-user workspaces, export behaviour, or rollback
safety.

**What it sets up:** Staff beta first, then KPZ308 access to an immutable,
recoverable production deployment without disturbing Practical 1 or KPZ314.

**Alternatives:** Direct student release is quicker but removes the final
environment-specific check. Mutable tags simplify commands but weaken rollback
evidence. Immutable tags and a short staff beta remain preferable.

**Codex owns:** Build architecture, source and OCI identity, digest equality,
backup metadata, restart health, unchanged neighbouring apps, and rollback
record.

**Barry should critique:** The real SSO-launched student experience and exported
artefacts. Barry is not asked to assess image layers, registry mechanics, YAML,
or container logs unless they cause a visible failure.

## Review Economy

These checkpoints are not additional meetings or invitations to polish every
surface repeatedly. A design probe is the earliest useful moment to reject a
teaching model. The working confirmation is deliberately brief. Each gate gets
one Codex self-review and one consolidated response to Barry; further work is
justified only by a remaining material scientific, comprehension, or use problem.

When time compresses, preserve A2, C-G, I, J1-J3, K, and L. Gate H is optional.
Within J2, preserve the portable project, Word dossier, PNG, and CSV before
spending time on Markdown convenience.
