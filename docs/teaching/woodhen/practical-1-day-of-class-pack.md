# Practical 1 Day-Of-Class Pack

Use this pack on the day of the Practical 1 road test. It assumes the
mission-mode Practical 1 Shiny app is the main classroom surface and the
worksheet is the student evidence log.

This pack applies only to a route that has passed the current teaching
go/no-go check. The current raw IP address or browser-warning HTTPS page
remains an instructor-only test route.

## Pre-Class Setup

Before students arrive:

- Open this pack, `practical-1-mission-worksheet.md`,
  `practical-1-student-launch-page.md`,
  `practical-1-instructor-beat-sheet.md`, `practical-1-go-no-go-checklist.md`,
  `practical-1-fallback-pack.md`, `troubleshooting.md`, and
  `expected-outputs.md`.
- Confirm which app route is being used:
  - hosted class app URL supplied on the day, only if the hosted go/no-go check
    is green;
  - local instructor machine at `http://127.0.0.1:<port>` for local rehearsal
    or demonstration;
  - static fallback pack if app access or downloads fail reliability checks.
- From the repo root, run:

```r
source("bootstrap.R")
```

- If using local Shiny from the teaching machine, launch:

```r
run_practical1_shiny(host = "127.0.0.1", port = 3898, launch.browser = FALSE)
```

- Render the report scaffold into a temporary folder if students will use it.
  The scaffold now requires explicit student-choice fields; use sample staff
  validation values for a rehearsal render:

```sh
RPVA_DECISION_LENS="classroom validation" \
RPVA_SELECTED_SCENARIO_ID="02_pig_control" \
RPVA_CHOSEN_SENSITIVITY_ID="K_350" \
RPVA_SENSITIVITY_REASON="Habitat recovery may be incomplete." \
RPVA_EXPECTED_DIRECTION="A lower habitat ceiling should reduce final abundance." \
RPVA_ADVICE_CHANGE_CONDITION="Advice would change if lower habitat capacity sharply reduced recovery confidence." \
quarto render docs/teaching/woodhen/report-scaffold.qmd --to docx --output-dir /tmp/rpva-teaching-report

RPVA_DECISION_LENS="classroom validation" \
RPVA_SELECTED_SCENARIO_ID="02_pig_control" \
RPVA_CHOSEN_SENSITIVITY_ID="K_350" \
RPVA_SENSITIVITY_REASON="Habitat recovery may be incomplete." \
RPVA_EXPECTED_DIRECTION="A lower habitat ceiling should reduce final abundance." \
RPVA_ADVICE_CHANGE_CONDITION="Advice would change if lower habitat capacity sharply reduced recovery confidence." \
quarto render docs/teaching/woodhen/report-scaffold.qmd --to pdf --output-dir /tmp/rpva-teaching-report
```

Render DOCX first, then PDF.

## What Students Open

Students need:

- the Practical 1 Shiny app route approved for the class session;
- `practical-1-student-launch-page.md` as the start-here instruction page;
- `practical-1-mission-worksheet.md` as their observation log;
- a local folder where they can save two evidence exports from the Compare
  screen.

If the class is using a hosted URL, give students only the approved class app
URL. Keep the current raw-IP or insecure HTTPS route for instructor-only tests.

## Barry Priming

Use the first 10-12 minutes to frame the activity:

- A model is a way to ask what follows from assumptions.
- Today students are learning how outputs respond when assumptions change.
- For each run, ask: what changed, which output moved, and what caveat remains?
- The Woodhen practical uses the same habits with a real conservation case.

## Mission Timing

| Time | Main action | Instructor focus |
| --- | --- | --- |
| 0:00-0:12 | Prime the room | PVA as comparison of possible futures. |
| 0:12-0:22 | Start baseline | Confirm baseline is run 1 and students can name abundance, risk, and uncertainty outputs. |
| 0:22-0:55 | Missions 1-2 | Fixed baseline and carrying-capacity interpretation. |
| 0:55-1:18 | Mission 3 | Spread among futures alongside median abundance. |
| 1:18-1:28 | Recap | What changed when randomness entered? |
| 1:28-2:12 | Missions 4-6 | Uncertainty, genetics, catastrophe, and risk interpretation. |
| 2:12-2:28 | Mission 7 | Intervention or vortex comparison. |
| 2:28-2:42 | Export and transfer | Save evidence and answer transfer prompts. |
| 2:42-3:00 | Wrap | Bridge to Woodhen scenario comparison and caveated recommendations. |

If time is tight, keep Missions 1, 2, 4, 6, and 7. Preserve Compare and
Transfer.

## Student Evidence Target

Each student or group should leave with:

- at least three compared runs, including baseline run 1;
- one worksheet row explaining an assumption change, output movement, evidence,
  and caveat;
- `practical1-comparison-YYYYMMDD.csv`;
- `practical1-evidence-notes-YYYYMMDD.md`;
- answers to the Transfer questions.

If downloads fail after one retry, students should copy the visible comparison
table into their worksheet and record that they used fallback evidence capture.

## Recap Beats

After Mission 3:

- Ask which output moved when carrying capacity was added.
- Ask whether demographic stochasticity changed the median, the spread, or
  both.
- Reinforce that one-factor comparisons are easier to interpret.

After Mission 6:

- Ask students to separate median abundance from extinction risk.
- Ask whether a rare event can matter when ordinary years look acceptable.
- Reinforce that zero observed extinction is a simulation outcome to interpret
  with horizon, replicate count, and assumptions.

Final wrap:

- Ask for one example where abundance and risk did not tell the same story.
- Ask which caveat they would carry into a management recommendation.
- Preview Practical 2 as the same reasoning pattern applied to Woodhen
  scenarios.

## Fallback Switch Rule

Switch to `practical-1-fallback-pack.md` if any of these would cost more than a
few minutes of class time:

- students fail to reach the approved app route;
- the app is visibly slow for several students;
- Compare-screen downloads fail after one retry;
- the hosted service remains unavailable before class;
- the demonstrator needs to continue with an instructor-led local session.

When switching, say:

> We are switching to the static fallback so we can keep the ecological question
> moving. The same outputs matter: extinction risk, final abundance, and
> uncertainty.

## Post-Class Notes To Capture

After class, record:

- route used: hosted app, local instructor app, or fallback;
- whether students could start baseline and keep it as run 1;
- whether students changed one visible control at a time;
- whether downloads worked;
- whether DOCX and PDF report renders worked;
- any repeated misconception worth turning into a future wording fix;
- whether hosted URL/TLS/student access blockers remain.
