# Practical 1 Fallback Pack

Use this pack if the Practical 1 Shiny concept lab is unavailable, slow, or
download evidence fails during class. It preserves the teaching objective:
students should still compare PVA mechanisms, interpret uncertainty, and leave
ready for the Woodhen practical.

This is a demonstrator-facing index for live-route failure or unreliable
downloads. Keep `practical-1-pva-foundations.md`, `expected-outputs.md`, and
`troubleshooting.md` open alongside it.

## When To Switch To Fallback

Switch to this path when any of these would cost more than a few minutes of
class time:

- students fail to reach the app URL;
- the app is visibly slow for several students;
- browser downloads fail and a quick retry fails too;
- the hosted service remains unavailable before class;
- a demonstrator needs to continue with an instructor-led local session.

## Minimum Teaching Path

1. Start from the repository root.
2. Run the bootstrap:

```r
source("bootstrap.R")
```

3. Run the Practical 1 toy model:

```r
toy <- run_toy_demo(
  keep_traj = TRUE,
  plot_matrix = FALSE,
  verbose = FALSE
)
toy$summary
```

4. Compare the output with `expected-outputs.md`.
5. Show or ask students to generate:
   - one trajectory plot;
   - one summary plot;
   - one extinction plot.
6. Ask the same interpretation questions used in the Shiny Transfer screen:
   - Which output shows extinction risk?
   - Which output shows abundance?
   - Which output shows uncertainty?

## Expected Output Anchor

The Practical 1 reference table is in `expected-outputs.md`. The classroom
anchor values are:

| scenario | PE | N_med |
| --- | ---: | ---: |
| det | 0.000 | 264 |
| ceiling | 0.000 | 85 |
| demographic_stochasticity | 0.000 | 82 |
| env_sd | 0.000 | 70 |
| genetics | 0.070 | 60 |

Small differences are acceptable if students change seeds or settings, but the
demonstrator should first check whether the command was run as written.

## Plot Commands

Use these if the app is unavailable but R is working:

```r
plot_pva_traj(toy$results$demographic_stochasticity, sample = 20)
plot_pva_summary(toy$results$env_sd)
plot_ext(toy$results$genetics)
```

If plots are blank, rerun the simulation with `keep_traj = TRUE`.

## Shiny Evidence Shape

When the Shiny app is available, students should save both files from the
Compare screen:

- `practical1-comparison-YYYYMMDD.csv`
- `practical1-evidence-notes-YYYYMMDD.md`

The CSV is the compact comparison table. The Markdown file records settings,
provenance, fixed-seed wording, and interpretation prompts. These files are
evidence for interpretation. Students still need to explain what changed and why.

## Static Evidence From The 2026-06-11 Dry Run

Goal 024 generated local evidence under `/tmp` on the Mac mini:

- `/tmp/rpva-goal024-browser/start-screen.png`
- `/tmp/rpva-goal024-browser/concept-environmental-stage.png`
- `/tmp/rpva-goal024-browser/concept-genetics-risk-stage.png`
- `/tmp/rpva-goal024-browser/compare-after-dry-run.png`
- `/tmp/rpva-goal024-browser/transfer-after-dry-run.png`
- `/tmp/rpva-goal024-browser/practical1-comparison-chrome.csv`
- `/tmp/rpva-goal024-browser/practical1-evidence-notes-chrome.md`
- `/tmp/rpva-goal024-nonshiny/practical1-toy-plots.pdf`

These paths are run evidence for validation. If a class handout
needs screenshots, copy only small, reviewed images into a future teaching
materials goal.

## Report Scaffold

The report scaffold can still be rendered without Shiny:

```sh
quarto render docs/teaching/woodhen/report-scaffold.qmd --to docx --output-dir /tmp/rpva-teaching-report
quarto render docs/teaching/woodhen/report-scaffold.qmd --to pdf --output-dir /tmp/rpva-teaching-report
```

If PDF rendering fails but DOCX succeeds, continue with DOCX and record the PDF
toolchain issue for later setup work.

## Demonstrator Recovery Script

Use this plain-language sequence in class:

1. "We are switching to the static fallback so we can keep the ecological
   question moving."
2. "The same outputs matter: extinction risk, final abundance, and uncertainty."
3. "Run the toy model commands, compare your table with the reference values,
   and save one plot or table as evidence."
4. "Your evidence supports your interpretation; your judgement completes the explanation."

## After Class

Record:

- which path was used: Shiny, local instructor demo, or static fallback;
- whether downloads succeeded;
- whether DOCX and PDF report renders worked;
- any student misunderstanding that should become a wording fix.
