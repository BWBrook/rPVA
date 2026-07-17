# Practical 1 Integrated Risk Layer Design

**Date:** 2026-07-17
**Status:** Approved for implementation
**Scope:** Practical 1 Concept Lab only, plus the smallest reusable engine and plotting hooks needed to support it

## Objective

Make the Concept Lab behave as one coherent teaching experiment. A student's latest successful deterministic assumptions must carry into later missions, long stochastic simulations must report honest progress, and the default evidence surface must foreground extinction and quasi-extinction risk as well as population abundance.

This is a classroom-ready iteration for delivery on 2026-07-20. Apply the Pareto principle: implement and verify the high-value behaviour, then return the result for Barry's next beta pass rather than pursuing marginal polish.

## Working Assumptions

Run 1 remains the immutable comparison reference and the baseline pinned in selected evidence. The app also maintains a separate set of session-level working assumptions:

- projection years;
- mortality adjustment; and
- fecundity adjustment.

These values begin with run 1. Each successful deterministic rerun replaces the working assumptions, but does not replace or mutate run 1. Later missions merge the working assumptions with their mission-specific controls. Explicit advanced-control changes override the inherited value for that mission only. Failed and unchanged deterministic reruns do not mutate the working assumptions. Resetting the session restores run 1 values.

The Settings record continues to compare the current mission with run 1. For example, after a successful 50-year deterministic rerun, Core 2 shows a selected mission value of 50 years and reports it as higher than the pinned 25-year reference.

## Progress Reporting

`run_pva_core()` gains an optional callback receiving completed and total replicate counts. The callback is absent by default, preserving current API behaviour. It is invoked at throttled intervals and on the final replicate.

`run_teaching_pva()` passes the callback to the engine. The Shiny server maps engine progress onto a visible sequence:

1. prepare the model;
2. simulate future `i` of `n`;
3. summarise and register the completed run.

Progress is monotonic and based on completed simulated futures, not a claim about exact wall-clock time. The design does not add asynchronous jobs, cancellation, or background workers.

## Risk Evidence

The Concept Lab plot region places **Risk evidence** before **Population projections**. Advanced controls remain optional and do not control risk visibility.

### Extinction through time

For runs containing more than one simulated future, show a compound figure containing:

- cumulative probability of extinction by projection year; and
- a histogram of the first extinction year among futures that became extinct.

Annotate the number of extinct futures out of the total. Show the population-level median extinction time only when cumulative extinction probability reaches at least 0.5. When no futures become extinct, retain the cumulative zero line and replace the histogram with a clear no-observed-extinctions state. Do not include sex-ratio or inbreeding-coefficient lines.

### Quasi-extinction risk

For a finite nominal habitat ceiling `K`, evaluate every integer threshold from zero through `floor(0.5 * K)`. At each threshold `q`, plot the proportion of simulated futures whose total population reaches or falls below `q` at least once during the complete projection, including year zero.

Label the x-axis in animals and state that thresholds are bounded at 50% of nominal `K`. If yearly ceiling variation is active, retain nominal `K` as the reference and say so in the plot subtitle. Where `K` is absent, show an unavailable-state explanation rather than inventing a denominator.

### Deterministic state

A one-future deterministic run does not estimate a probability. Instead of rendering binary probability plots, the risk area explains that the student must run multiple stochastic futures before risk can be estimated.

### Downloads

Retain the existing extinction-risk PNG download identity and add a separate quasi-extinction PNG download. Downloads appear only when their corresponding figure is scientifically available.

## Internal Boundaries

Add internal helpers for total-population trajectories, first-extinction times, extinction-timing plot data, and quasi-extinction plot data. Add internal plotting functions for the two risk figures. Practical 1 consumes these helpers through the package namespace. The existing exported `plot_ext()` function remains unchanged to avoid an unnecessary package-wide behavioural change immediately before teaching delivery.

## Failure Behaviour

- A failed mission does not enter history or change working assumptions.
- A progress callback error must not corrupt the simulation result; Shiny supplies a simple callback that does not throw.
- Missing trajectories, insufficient futures, and missing `K` produce explicit teaching states.
- Existing trajectory and summary figures remain available and retain their download behaviour.

## Verification Boundary

The first-pass acceptance gate is:

1. focused tests prove deterministic assumptions carry into later missions without replacing run 1;
2. engine tests prove progress is monotonic and reaches the final replicate;
3. synthetic trajectories prove extinction timing and quasi-extinction probabilities for zero-risk, sub-50%, and at-least-50% cases;
4. Practical 1 server tests prove deterministic and missing-`K` teaching states;
5. the existing Playwright acceptance flow renders the risk surface without browser errors at its established desktop and responsive viewports; and
6. the localhost remains available for Barry's next beta pass.

No additional refinement cycle is required before returning the first working pass unless these gates expose a classroom-visible failure.
