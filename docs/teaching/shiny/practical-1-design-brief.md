# Practical 1 Shiny Design Brief

## Purpose

Practical 1 should give students a low-friction way to understand population
viability analysis before they touch the Woodhen case study. The learning
experience should feel like a guided concept lab: students change one idea at a
time, inspect the population response, and write down what the model helped them
understand.

The app should serve students who have little or no prior PVA background and may
not be comfortable with R, YAML, terminals, or package installation. The aim is
not to hide ecology. The aim is to hide avoidable setup and syntax friction so
the first contact with PVA is about population dynamics, uncertainty, and
conservation decisions.

## Recommended Framing

Use a simple invented species for Practical 1, such as an island rail or small
island bird with three life stages:

- juveniles,
- subadults,
- adults.

The invented species avoids premature Woodhen detail while keeping the biology
close enough that students can transfer concepts directly into Practical 2. The
species should be intentionally plain: no extended backstory, no extra reading,
and no competing management history. The student should be thinking "what did
this process do to the population?", not "did I remember the case study?".

## Student Flow

The lab should be staged. Each stage should have a clear question, one or two
controls, a visible output, and a short interpretation prompt.

| Stage | Concept | Student action | Visible outputs | Students should understand |
| --- | --- | --- | --- | --- |
| 1 | Deterministic growth | Run the baseline with fixed survival and fecundity. | Median or single trajectory, final abundance, lambda-style matrix cue. | A model can project a population from rates and initial abundance without randomness. |
| 2 | Ceiling carrying capacity | Turn on a simple carrying capacity. | Trajectory flattening, final abundance near a ceiling. | Density limits can stop unlimited growth even when vital rates look favourable. |
| 3 | Demographic stochasticity | Turn on individual-level chance events. | Multiple trajectories, spread among replicates, occasional low paths. | Small populations can diverge because births and deaths are discrete events. |
| 4 | Environmental stochasticity | Increase year-to-year variation. | Wider trajectory fan and uncertainty interval. | Shared bad years can affect many individuals at once and widen long-term uncertainty. |
| 5 | Genetic stochasticity | Turn on inbreeding effects in a small population. | Extinction risk, mean inbreeding coefficient, abundance decline or slower growth. | Genetics can interact with small population size and make recovery harder. |
| 6 | Allee effects | Apply a low-abundance penalty or mate-limitation proxy. | Threshold-like recovery failure below a small-population level. | A population may not recover simply because its mean growth rate is positive. |
| 7 | Extinction vortex synergy | Combine small population size, genetics, and environmental variation. | Rising extinction probability, widening uncertainty, lower median abundance. | Threats can reinforce each other; combined risk is not just a list of separate risks. |
| 8 | Correlated events | Toggle correlated poor survival/reproduction years. | Simultaneous dips across model outputs. | Some bad years are system-wide, not independent individual mishaps. |
| 9 | Catastrophes | Adjust catastrophe frequency or severity within a narrow range. | Step changes in trajectories and extinction probability. | Rare events can dominate risk even when ordinary years look manageable. |
| 10 | Interventions | Add a simple release, removal reduction, or habitat/carrying-capacity improvement. | Before/after comparison table and plot panel. | Management actions should be compared against risk, abundance, and uncertainty. |

The sequence should be linear for first-time students, with a "compare" view
available after each stage. A more open "sandbox" view can be added later, but
the first teaching road test should favour a guided path.

## Core Screens

### 1. Start Screen

Purpose: orient the student without asking for setup decisions.

Minimum content:

- the invented species name and three-stage life cycle,
- one sentence explaining that the app simulates many possible futures,
- a "Start baseline" action,
- a short note that results are illustrative and will prepare them for Woodhen.

### 2. Concept Stage Screen

Purpose: teach one mechanism at a time.

Minimum content:

- stage title,
- one biological question,
- locked baseline settings shown as context,
- one or two allowed controls,
- run button,
- current output panel,
- short interpretation prompt.

Good controls for the first build:

- on/off toggles for mechanisms,
- bounded sliders for `K`, `env_sd`, catastrophe frequency, catastrophe severity,
  release number, and release timing,
- fixed seed option for repeatability,
- replicate count as instructor-controlled rather than student-facing in the
  first road test.

### 3. Compare Screen

Purpose: help students move from one run to evidence comparison.

Minimum content:

- scenario comparison table with extinction probability and final abundance,
- selected plot panel,
- prompt asking what changed and why,
- export buttons for a compact comparison CSV and evidence-notes file.

### 4. Exit Screen

Purpose: prepare students for Practical 2.

Minimum content:

- summary of the mechanisms explored,
- three transfer questions:
  - which output shows extinction risk?
  - which output shows abundance?
  - which output shows uncertainty?
- a note that the next practical uses the real Woodhen case study.

## What The GUI Should Reveal

The interface should reveal:

- scenario names,
- simple biological controls,
- which stochastic processes are active,
- extinction probability,
- final median abundance and uncertainty interval,
- trajectory plots,
- summary plots,
- extinction/inbreeding/sex-ratio plot when relevant,
- concise diagnostic messages from `diagnose_pva_result()`,
- a plain-language record of settings used for each run.
- compact downloads that preserve comparison output, settings, and prompts
  without saving full simulation objects.

The interface should use the real vocabulary students need later: extinction
probability, median abundance, uncertainty interval, demographic stochasticity,
environmental stochasticity, carrying capacity, catastrophe, inbreeding, and
intervention.

## What The GUI Should Hide

The interface should hide or lock:

- YAML files,
- terminal commands,
- package installation,
- internal object structure,
- arbitrary list editing,
- unsupported parameter combinations,
- multi-factor changes during early concept stages,
- seed handling except where repeatability is being taught explicitly,
- long-running replicate counts that make older laptops feel broken.

The GUI should not imply that clicking more mechanisms is better science.
Mechanism combinations should be introduced only after students have seen each
process separately.

## Guardrails

The app should protect students from misleading or hard-to-mark outputs:

- prevent negative or impossible vital rates,
- prevent survival plus stasis from exceeding one,
- keep sliders within teaching-safe ranges,
- warn when extinction probability is based on few replicates,
- label zero observed extinction as "zero in this simulation", not "no risk",
- make one-factor changes the default comparison mode,
- require a short label for a student-chosen intervention or sensitivity run,
- make it clear when trajectory plots require stored trajectories.

## Concept Coverage

### Deterministic Growth

The first run should be simple enough to understand by inspection. Students
should see that a life cycle and starting abundance produce a projected future.
The app can show the projection matrix and a single line, but the teaching
emphasis should be on model structure, not matrix algebra.

### Ceiling Carrying Capacity

The carrying-capacity stage should show that favourable vital rates do not imply
unbounded growth. The app should keep the explanation simple: the habitat can
support only so many territory holders.

### Demographic Stochasticity

Students should see that individual births and deaths produce different paths.
This is especially important because the Woodhen history begins from a very
small population.

### Genetic Stochasticity

The genetics stage should connect inbreeding, small population size, and
extinction risk without becoming a genetics lecture. The key transfer is that
small-population processes can compound demographic vulnerability.

### Allee Effects

The current engine does not expose a named Allee-effect module. For Practical 1,
the app can teach the concept with a thin wrapper or teaching proxy, such as
mate limitation, low-abundance fecundity penalty, or an explicitly labelled
"conceptual Allee threshold" transformation before calling the engine.

### Extinction Vortex Synergy

This should be a compare-and-reflect stage, not a new parameter. Students should
combine demographic stochasticity, environmental stochasticity, genetics, and a
small starting population, then compare against each mechanism alone.

### Environmental Stochasticity And Correlated Events

Environmental stochasticity should be shown with wider trajectory fans and wider
final uncertainty. Correlated events should be treated as a later-stage or
instructor-led concept unless a thin helper can cleanly create correlated bad
years while preserving the engine contract.

### Catastrophes

Catastrophes should use bounded controls: frequency, survival multiplier, and
reproduction multiplier. The app should encourage students to compare rare but
severe events with common but milder events.

### Interventions

Interventions should be introduced as evidence comparison, not optimism. Good
first interventions are:

- increase carrying capacity,
- reduce catastrophe frequency or severity,
- release a small number of individuals,
- improve survival within a narrow range.

The compare view should ask whether the intervention changed extinction risk,
abundance, uncertainty, or all three.

## Practical 2 Transfer

The final Practical 1 output should prepare students to enter Practical 2 with
the following habits:

- compare scenarios rather than describe one run at a time,
- report extinction risk and abundance together,
- interpret uncertainty rather than ignore it,
- treat zero observed extinction as a model result, not proof of safety,
- explain which assumption was changed and why,
- make a recommendation that follows from evidence.

The Practical 1 app should not assess students directly. Its job is to make the
Woodhen practical and later AT1 report fairer by giving everyone a shared
conceptual base.
