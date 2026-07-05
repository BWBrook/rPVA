# Practical 1 PVA Deep-Dive Card Report

## Summary

Goal 045 adds one optional deep-dive interaction to the Practical 1 landing
screen. The existing `What is PVA?` card stays short, but now includes a visible
`Explore PVA` button that opens a contained Shiny modal with a richer
student-facing explanation.

This is deliberately a one-card prototype. The `What you will do` and `Your
evidence pack` cards remain static so Barry can test whether the deep-dive
pattern is useful before expanding it.

## Source Synthesis

The modal text primarily rewrites material from:

- the Practical 1 PVA foundations emphasis on extinction risk, abundance, and
  uncertainty;
- the Practical 1 Shiny design brief's student-flow and many-possible-futures
  framing.

The legacy intake overview informed only the general assessment-facing habits:
state assumptions, interpret outputs, and acknowledge limitations. It does not
surface thylacine case-study content to students.

The app avoids Woodhen case-study detail, thylacine content, YAML, R internals,
package functions, file paths, and engine order. It frames PVA as transferable
scenario comparison and interpretation rather than a single forecast.

## Student-Facing Deep-Dive Text

The modal currently says:

> Population viability analysis, or PVA, explores many possible futures under
> assumptions about survival, breeding, habitat limits, and chance events.
> Instead of giving one forecast, it asks: if the biology behaves like this,
> what range of outcomes could happen?
>
> In this practical, each model run is one scenario. The baseline is your
> reference future, then later runs change one factor so you can see what moved.
> A good comparison is not about finding the biggest number; it is about
> explaining which assumption changed and how the population responded.
>
> Extinction risk shows how often simulated futures reach zero. Abundance shows
> where the population tends to finish. Uncertainty shows how spread out the
> possible futures are. Evidence for interpretation means the outputs support
> your reasoning; they are not final answers by themselves.
>
> Use the outputs as evidence for interpretation: compare scenarios, name
> uncertainty, and be honest about the assumptions behind the model.

## Changed Files

- `inst/shiny/practical1/app.R`
- `inst/shiny/practical1/www/styles.css`
- `inst/shiny/practical1/README.md`
- `tests/testthat/test-13_practical1_shiny.R`
- `docs/goals/045-pva-deep-dive-card/`

## Validation

Passed:

- `git diff --check`
- `Rscript -e 'source("bootstrap.R")'`
- `Rscript -e 'renv::status(sources = FALSE)'`
- `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'`
- `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'`
- Local browser smoke on `http://127.0.0.1:3911`
- Marker scan over changed/untracked text: no hits.
- Strict secret/private-key/token/student-identifier scan over changed/untracked
  text: no hits. A broader exploratory scan hit only the existing `risk-note`
  CSS/app class name because it contains the string `sk-`; no secret value or
  student identifier was present.
- Modal-specific case/internal-term scan: no thylacine, Woodhen case-study,
  Gitea, stochastic-worker, or ITS wording in the deep-dive modal.

The focused teaching API test was run conservatively because the goal required
preserving export shape. No teaching API code changed.

## Browser Evidence

Browser smoke used Google Chrome through Playwright against the local Shiny
app. It proved:

- landing screen visible;
- `Explore PVA` opens and closes the deep-dive;
- modal content is readable and contains the intended PVA concepts;
- modal does not leak case-study or internal/deployment wording;
- `Start baseline` reaches Concept Lab with the deterministic baseline visible;
- the `Introduction` button returns to the Start tab;
- after one non-baseline Concept Lab run, Compare and both export buttons still
  work;
- comparison CSV preserves baseline as run 1 and retains the accepted export
  shape.

Evidence paths:

- `/tmp/rpva-goal045-pva-deep-dive/landing-screen.png`
- `/tmp/rpva-goal045-pva-deep-dive/pva-deep-dive-open.png`
- `/tmp/rpva-goal045-pva-deep-dive/post-start-baseline.png`
- `/tmp/rpva-goal045-pva-deep-dive/practical1-comparison.csv`
- `/tmp/rpva-goal045-pva-deep-dive/practical1-evidence-notes.md`
- `/tmp/rpva-goal045-pva-deep-dive/smoke-summary.txt`

Screenshot dimensions:

- `landing-screen.png`: 1440 x 1050
- `pva-deep-dive-open.png`: 1440 x 1050
- `post-start-baseline.png`: 1440 x 1200

Checksums:

```text
c283a187e5e6f211cf0c276db5534e0ae5b0be2f4bdd94d9b8f87685a0a51229  landing-screen.png
23a62c2a41c43cf276fbdd39031110ba0e0905f94a45eac52a1b3f409a57d8a9  pva-deep-dive-open.png
e6b0ce0e690c8a7da62c1e22b55d51f1b55cebbaa110037c78162ff2a4174c24  post-start-baseline.png
7895f193406701cb1353552bf6b8321bc3f35359234ac92b4d0ee44174e22422  practical1-comparison.csv
448e0315df31d1ef90856dccb5248b4179e16b9460cde5cc18cb83eb5a5832ce  practical1-evidence-notes.md
f5607e3813ec122740bca9030d638f5cc469c4d4a4a7bf9af9b0e30b869a3bf5  smoke-summary.txt
```

The browser console recorded one harmless 404 for a missing browser-requested
resource. It did not affect app flow, modal interaction, baseline state, or
exports.

## Assets

No new image assets were generated or added. The prototype reuses the Goal 044
landing images and changes only interaction/content/styling.

## Recommendation

This is ready for Barry to test the single-card deep-dive pattern as a small
opening-experience experiment. The most useful next judgement is whether the
modal feels like a helpful optional door, rather than a distracting manual page.
