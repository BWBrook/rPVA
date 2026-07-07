# Practical 1 Mission Tutorial

## Purpose

This tutorial turns Practical 1 into an app-led concept lab. Students learn PVA
by changing one ecological assumption at a time, watching the model respond,
comparing runs, and writing down evidence-based observations.

The main teaching path is the Practical 1 Shiny app. The worksheet is light by
design: it nudges students to observe, compare, and explain. It should not
become a heavy reading pack or an answer template.

## Class Shape

Practical 1 is a three-hour class. The central student-led mission arc should
take about two hours, leaving space for Barry to prime the ecological question,
pause the room for short recaps, and wrap the session into the Woodhen
practical.

| Time | Mode | Purpose |
| --- | --- | --- |
| 0:00-0:12 | Barry priming | Frame PVA as a way to compare possible futures under explicit assumptions. |
| 0:12-0:22 | App launch and baseline | Students open the app, run the baseline, and locate extinction risk, abundance, and uncertainty. |
| 0:22-1:18 | Missions 1-3 | Build from fixed growth to carrying capacity and individual-level chance. |
| 1:18-1:28 | Class recap | Compare what changed in the first three missions. |
| 1:28-2:12 | Missions 4-6 | Add shared bad years, genetics, and rare bad events. |
| 2:12-2:28 | Mission 7 | Compare intervention and compounded small-population pressure. |
| 2:28-2:42 | Export and transfer notes | Download comparison evidence and answer the transfer prompts. |
| 2:42-3:00 | Wrap-up | Barry links the evidence habits to the Woodhen management practical. |

If setup takes longer than expected, protect the student-led middle of the
class. Compress mission wording before dropping comparison and transfer.

## App Screen Map

| App screen | Student job |
| --- | --- |
| Start | Run the baseline and identify the three-stage island rail as a simple teaching model. |
| Concept Lab | Choose one mechanism, adjust only its visible controls, run the stage, and inspect metrics and plots. |
| Compare | Compare extinction risk, median final abundance, and uncertainty across runs; download evidence. |
| Transfer | State what each output means and how the same habits carry into the Woodhen practical. |

## Mission Arc

### Mission 1 - Set The Baseline Compass

Learning question: What does the population do when the life cycle is fixed and
nothing is random?

App action:

- On Start, click `Start baseline`.
- Inspect the baseline/current run that the app creates.
- Keep that baseline as run 1 for later comparison.

Expected observation:

- The output is stable because there is no randomness.
- Median final abundance is a reference point for later comparisons.
- The uncertainty interval is a secondary check at this point.

Compare/evidence task:

- Use the existing baseline as run 1 in Compare.
- In the worksheet, record which output you would use to describe abundance.

Checkpoint question:

- If this were the only run you saw, what important ecological process would
  still be missing?

### Mission 2 - Put A Ceiling On The Island

Learning question: Can a population with favourable vital rates grow forever?

App action:

- Select `Ceiling carrying capacity`.
- Change only `Habitat ceiling` or `Yearly ceiling variation`.
- Run the stage and compare it with the baseline.

Expected observation:

- Trajectories flatten near the habitat ceiling.
- Final abundance can be lower even though the life cycle itself has not become
  worse.

Compare/evidence task:

- Compare baseline and carrying capacity.
- Record whether extinction risk, median final abundance, or uncertainty moved
  the most.

Checkpoint question:

- What does carrying capacity represent biologically in a small island bird?

### Mission 3 - Add Individual Chance

Learning question: How much can births and deaths differ just because
individual events are discrete?

App action:

- Select `Demographic stochasticity`.
- Keep one habitat ceiling setting close to Mission 2.
- Run the stage and inspect the trajectory fan.

Expected observation:

- Replicate paths spread out even when the ecological rules are the same.
- Some futures do better than others by chance.

Compare/evidence task:

- Compare Missions 2 and 3.
- Record whether the median changed or whether uncertainty became more visible.

Checkpoint question:

- Why is individual-level chance more worrying for small populations than for
  large populations?

### Mission 4 - Make Some Years Bad For Everyone

Learning question: What happens when good and bad years affect the whole
population?

App action:

- Select `Environmental stochasticity`.
- Adjust `Bad-year variation` within the visible range.
- Run the stage and inspect the uncertainty interval.

Expected observation:

- The fan of futures widens.
- The median and the tails can tell different stories.

Compare/evidence task:

- Compare demographic and environmental stochasticity.
- Record which evidence best shows shared good/bad-year uncertainty.

Checkpoint question:

- What would you lose if you only reported one average trajectory?

### Mission 5 - Let Small-Population Pressure Build

Learning question: How can genetics and small population size compound recovery
limits?

App action:

- Select `Genetic stochasticity`.
- Change `Starting inbreeding` or leave the default if time is tight.
- Run the stage and inspect the risk detail if it appears.

Expected observation:

- Extinction risk may appear or rise even when habitat settings look similar.
- Inbreeding is a small-population process that interacts with abundance and stochasticity.

Compare/evidence task:

- Compare genetics against environmental stochasticity.
- Record the evidence that links small population size, uncertainty, and risk.

Checkpoint question:

- Why should "no extinction in one run" never be reported as "safe"?

### Mission 6 - Test Rare Bad Years

Learning question: Can rare bad events dominate risk even when ordinary years
look acceptable?

App action:

- Select `Catastrophe`.
- Change either `Catastrophe chance each year` or `Survival multiplier in
  catastrophe years`, not both.
- Run the stage.

Expected observation:

- Extinction risk may move more strongly than median abundance.
- A rare process can matter because the downside is large.

Compare/evidence task:

- Compare catastrophe against baseline and environmental stochasticity.
- Record whether your evidence supports a risk story, an abundance story, or
  both.

Checkpoint question:

- Which is more persuasive for a manager here: the median final abundance or
  the extinction-risk change?

### Mission 7 - Rescue Attempt Or Vortex?

Learning question: How do management improvements compare with compounded
small-population pressure?

App action:

- Select `Simple intervention` and run it.
- Then select `Extinction vortex comparison` and run it.
- Open Compare and inspect the full set of runs.

Expected observation:

- Intervention can improve some outputs without removing all uncertainty.
- The extinction-vortex comparison shows that mechanisms can reinforce each
  other.

Compare/evidence task:

- Choose three runs for your final explanation: one baseline, one risk
  mechanism, and one intervention or vortex run.
- Download the comparison CSV and evidence-notes file if downloads are
  available.

Checkpoint question:

- What would you tell someone who looked only for the "best" median abundance?

## Transfer To The Woodhen Practical

By the end of Practical 1, students should be able to enter Practical 2 ready
to:

- compare scenarios and explain differences across runs;
- report extinction probability, median abundance, and uncertainty together;
- explain which assumption changed and why it mattered;
- interpret zero observed extinction with the simulation horizon, replicate
  count, and assumptions in view;
- recognise that stochasticity and small-population processes can compound;
- use app exports as evidence that supports interpretation;
- write a caveat before making a conservation recommendation.

## Compression And Extension

If the room is slow:

- keep Missions 1, 2, 4, 6, and 7;
- use demographic stochasticity as an instructor-led recap and keep the student
  worksheet focused on the main mission path;
- leave genetic stochasticity as a guided demonstration if needed;
- still require one Compare-screen evidence check and the Transfer questions.

If the room is fast:

- ask students to rerun one mission with a single slider changed;
- ask them to explain why a duplicate run is less useful than a targeted
  comparison;
- ask them to choose whether intervention changed risk, abundance, uncertainty,
  or all three.

## Fallback Boundary

The fallback pack remains the contingency route if the app is unavailable,
slow, or unable to download evidence. It should preserve the same teaching
target: compare mechanisms, interpret uncertainty, and prepare for Woodhen.

Do not let fallback material become the centre of this class when the app path
is available.
