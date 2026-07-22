# Practical 2 Gate Justification And Review Notes

## Purpose

This document explains why the revised gates exist, what each gate enables, what
alternatives remain available, and which criticism belongs in its review. It is
the interpretive companion to
`2026-07-22-practical2-woodhen-management-lab-revised.md`.

The central division of labour is deliberate:

- **Codex owns engineering assurance:** code correctness, regression tests,
  state integrity, browser automation, export structure, container identity,
  deployment safety, and rollback evidence.
- **Barry owns the student-facing judgement:** ecology, pedagogy, language,
  visualisation, workflow, cognitive load, and interface taste.

Barry is never expected to infer software quality from test counts or review
backend design. Conversely, automated tests cannot establish that a plot teaches
the right lesson or that student language is comprehensible.

## How To Review A Student-Facing Gate

Useful criticism is concrete and experience-based:

- “This ecological assumption is wrong or inadequately qualified.”
- “A student will not know what this term means at this point.”
- “This plot scale hides the important pattern.”
- “The interface gives the wrong lesson through false precision.”
- “This control appears before its conceptual justification.”
- “The page is too dense to scan during a practical.”
- “This amount of scaffolding prevents independent thought.”

Normally unnecessary criticism concerns internal matters Barry cannot observe
or should not need to manage:

- R function decomposition or module architecture;
- internal scenario IDs, storage schemas, fingerprints, and event contracts;
- the number or organisation of automated tests;
- library or framework choices that do not affect the student experience;
- container-layer implementation; and
- source-file naming or code style.

These internal matters become legitimate student-facing criticism if they leak
into visible text, cause delay without feedback, lose evidence, constrain a
scientifically necessary action, or otherwise alter the experience.

## Gate A: Scientific Engine And Risk Evidence

**Why this gate exists:** Later interfaces are meaningless unless annual threats,
interventions, extinction risk, and 50-pair risk are computed consistently.

**What it sets up:** Every historical, sensitivity, prospective, and advanced
scenario can use one validated scientific engine without changing Practical 1.

**Alternatives:** A separate Practical 2 simulator would isolate risk but create
duplicated logic and divergent teaching results. Hand-calculated UI summaries
would be faster initially but scientifically fragile. The shared validated
engine is preferable.

**Review boundary:** Hard engineering. Barry is consulted only about biological
meaning, such as whether stages 2 onward represent territory-holding pairs or
whether a scenario bound is ecologically defensible.

## Gate B: Durable Projects And Compact Evidence

**Why this gate exists:** Students will continue after class and may move between
the SSO and off-campus hosts. Evidence must survive without relying on one
browser or server workspace.

**What it sets up:** Every later tab can add runs, notes, selections, and exports
to one portable investigation record.

**Alternatives:** Server accounts or cloud sync would improve convenience but
add authentication, privacy, and operational complexity. Full raw trajectory
storage would make packages large. Compact portable evidence is the appropriate
first-release compromise.

**Review boundary:** Hard engineering. Barry reviews only whether Create,
Resume, Download, and Import are understandable and useful when they appear on
Start and Evidence Studio.

## Gate C: Start

**Why this gate exists:** Start establishes role, motivation, prior knowledge,
and expectations. Errors here distort every later task even when the software
works perfectly.

**What it sets up:** Students understand the Woodhen case, the two phases, the
core-versus-extension philosophy, and how to preserve their work.

**Alternatives:** The full background could live in a static handout, or the
Start page could be minimal. The selected design keeps the page scannable while
making deeper history available in context.

**Barry should critique:** biological accuracy, tone, narrative emphasis, image
suitability, expected student knowledge, cognitive load, and project-action
language.

**Barry need not critique:** autosave implementation, ZIP validation, modal
plumbing, or JavaScript storage mechanics.

## Gate D: Calibrate - 1980 Management Alternatives

**Why this gate exists:** The first scientific lesson is a controlled comparison
of decisions available during the 1980 crisis. Combining it with later recovery
and future work made the original review too broad.

**What it sets up:** Students learn why comparable starting conditions and
horizons matter, how interventions alter trajectories and risk, and why model
agreement is evidence rather than proof.

**Alternatives:** One combined plot could compare all scenarios more compactly,
but separate scenario evidence teaches each mechanism before synthesis. The
compatible comparison table then closes the loop. Tabs within each scenario
remain available if the two-by-two evidence layout proves too long.

**Barry should critique:** scenario assumptions, carrying-capacity explanation,
intervention timing, plot selection and scaling, numerical precision,
interpretive prompts, comparison logic, and visual density.

**Barry need not critique:** compact-run structures, progress callbacks, run
identity, or project activation mechanics unless visible behaviour is wrong.

## Gate E: Calibrate - Rodent Recovery And Future Comparison

**Why this gate exists:** A five-year historical recovery check and a 75-year
prospective comparison answer different questions from the 1980 decision cases.
They deserve a separate conceptual review.

**What it sets up:** Students see calibration against observed recovery and gain
the common no-change future against which Phase 2 scenarios are compared.

**Alternatives:** The rodent scenario could be excluded because its horizon is
incompatible with 1980. That would lose the strongest recent empirical check.
The future comparison could move to Investigate, but keeping it in Calibrate
makes the historical-to-prospective transition explicit.

**Barry should critique:** legitimacy of the survey comparison, wording of
historical compatibility, observed-data overlay, short-horizon warning,
50-pair rationale, future framing, and plot readability.

**Barry need not critique:** the internal locked-anchor contract or exact
versioning machinery.

## Gate F: Investigate - One-Factor Sensitivity

**Why this gate exists:** Sensitivity analysis is compulsory and conceptually new
for many students. It cannot be treated as merely another scenario selector.

**What it sets up:** Students learn to change one assumption, hold others
constant, anticipate direction, and interpret response and uncertainty.

**Alternatives:** A fixed precomputed sensitivity panel would be easier but would
remove active inquiry. Fully free parameter editing would create confusion and
fantasy scenarios. Named factors with bounded values preserve agency and
discipline.

**Barry should critique:** factor choice, baseline visibility, value labels and
units, explanation of held-constant assumptions, 50-pair teaching, plot/table
interpretation, and whether the workflow fits prior Practical 1 knowledge.

**Barry need not critique:** scenario builders, ancestry validation, or how the
three runs are stored.

## Gate G: Investigate - Threat And Intervention

**Why this gate exists:** Prospective management advice requires a causal chain:
baseline, threat, then intervention against that threatened future. This is more
complex than sensitivity and warrants its own review.

**What it sets up:** Students can test at least one plausible future pressure and
compare management response, directly supporting C2-C4.

**Alternatives:** Threat and intervention could be selected independently and
compared afterward, but that obscures parentage and encourages invalid
comparisons. A wizard would enforce sequence more strongly but might feel
over-prescriptive. The planned explicit family keeps structure visible without
locking students into one question.

**Barry should critique:** ecological mappings, plausible bounds, causal logic,
timing language, intervention meaning, comparison outputs, degree of freedom,
and the limits placed on advice.

**Barry need not critique:** family IDs, versioning, or conflict-detection code.

## Gate H: Investigate - Advanced Sandbox

**Why this gate exists:** The compulsory route should support a basic defensible
investigation, while higher-quality reports need room for timing, interacting
pressures, alternative actions, and robustness checks.

**What it sets up:** Ambitious students can develop distinctive analyses without
leaving the Woodhen case or entering arbitrary code.

**Alternatives:** Defer all advanced work for the first release; allow only one
extra intervention; or expose fully free parameter editing. Deferral is valid if
time threatens core quality. A bounded multi-factor layer is preferred if it
can remain understandable and optional.

**Barry should critique:** intellectual headroom, ecological realism, guardrail
strength, discoverability, cognitive load, multi-factor warnings, and whether
the sandbox supports individual work rather than arbitrary tinkering.

**Barry need not critique:** temporal-profile representation or internal
component-conflict algorithms.

## Gate I: Compare

**Why this gate exists:** Running scenarios is not the same as synthesising
evidence. Students need a workspace that privileges a chosen comparison rather
than dumping their full history onto the screen.

**What it sets up:** Students can compare compatible evidence, accumulate
observations, identify caveats, and nominate material for their report dossier.

**Alternatives:** Evidence could be selected directly from Investigate, saving a
tab but weakening synthesis. A spreadsheet-like run table would be powerful but
repeat the crowded Practical 1 problem. The planned focused comparison with a
compact library is more teachable.

**Barry should critique:** hierarchy, compatibility warnings, plot modes, note
accumulation, evidence-selection behaviour, density, and whether the tab teaches
reasoned comparison.

**Barry need not critique:** filtering implementation, provenance IDs, or
round-trip serialization.

## Gate J: Evidence Studio And Guidance

**Why this gate exists:** Students need reusable evidence and substantial advice
for a 2,000-word assessment, but the app must not compose their report or erase
the opportunity for judgement and mark separation.

**What it sets up:** Selective Word/CSV/PNG/Markdown outputs, a portable project
copy, report-planning guidance, research encouragement, and explicit assessment
alignment.

**Alternatives:** PDF-only export is visually stable but difficult to reuse.
Markdown-only export helps AI workflows but is unfamiliar to many students. A
fixed report template would be convenient but overly prescriptive. Editable Word
plus companion evidence best fits the intended use.

**Barry should critique:** dossier usefulness, evidence selectivity, display-item
advice, assessment-language fidelity, scaffolding level, research guidance,
individuality, and whether the outputs support rather than write the report.

**Barry need not critique:** document XML, Pandoc invocation, archive structure,
or filename sanitisation.

## Gate K: Integrated Local Acceptance

**Why this gate exists:** Focused gates prove components; they do not prove the
complete journey, cross-tab state, export/import round trip, or responsive
layout.

**What it sets up:** A candidate credible enough to spend time building and
deploying as an immutable container.

**Alternatives:** Run the full suite after every surface, which is slower and
adds little decision value, or rely only on manual checks, which misses state
and packaging failures. Focused tests during development plus one integrated
acceptance is the 80/20 balance.

**Review boundary:** Hard engineering. Barry receives only material visible
regressions or decisions; test counts are evidence for Codex, not a requested
review surface.

## Gate L: Production Release

**Why this gate exists:** Local success does not prove container architecture,
registry identity, ShinyProxy behaviour, SSO access, exports through the live
route, or rollback readiness.

**What it sets up:** Staff beta followed by controlled KPZ308 access, with
Practical 1 remaining available and a precise rollback target.

**Alternatives:** Open directly to KPZ308 or continue using the canary. Direct
opening is unnecessarily risky; retaining the canary does not deliver the real
practical. Staff-only production beta is the appropriate final boundary.

**Review boundary:** Codex owns image, digest, configuration, health, access, and
rollback evidence. Barry performs the final human browser smoke because only a
real user can confirm that the production teaching experience is acceptable.

## Review Economy

The revised gates are deliberately numerous but lightweight. They are not
meetings or formal reports. A gate can close with “approved, continue.” The
extra boundaries prevent a technically mature but pedagogically weak interface
from spreading across several tabs before Barry sees it.

When time compresses, preserve Gates C-G, I-J, K, and L. Gate H is the primary
candidate for scope reduction because advanced breadth must not displace the
compulsory route, evidence workflow, or safe delivery.
