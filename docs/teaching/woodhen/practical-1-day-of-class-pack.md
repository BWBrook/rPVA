# Practical 1 Day-Of-Class Pack

Use this pack for the three-hour Practical 1 class. The Shiny app is the main
classroom surface and the worksheet is the student evidence log.

The three-hour class uses approximately one hour for PVA teaching and a guided
GUI introduction, followed by approximately two hours of self-paced Practical
1 work while the instructor and demonstrators circulate.

## Your route through Practical 1

Start with the five **Core** model missions: Baseline compass, Island ceiling,
Individual chance, Environmental variability, and Rescue attempt. Then go to **Compare**
and build a three-run evidence set containing baseline, one risk mechanism, and
one intervention or vortex run.

When the Core route is complete, **Explore Further** remains available for
genetic pressure, catastrophes, the extinction vortex, advanced controls,
alternative comparisons, and optional plot downloads.

This browser session is temporary. Before closing the tab, request both your
comparison CSV and your evidence-notes Markdown file. Refreshing, closing the
tab, or allowing the session to expire clears the in-app run history,
selection, progress, and interpretation.

## Pre-class setup

Before students arrive:

- confirm the approved Practical 1 app URL or local rehearsal route;
- open the student launch page and mission worksheet;
- prepare a static fallback if app access or downloads are unreliable; and
- create a temporary local evidence folder for rehearsal downloads.

If using local Shiny from the teaching machine, launch from the repository root:

```r
source("bootstrap.R")
run_practical1_shiny(host = "127.0.0.1", port = 3898, launch.browser = FALSE)
```

## Class sequence

1. Use the first hour for the PVA teaching and GUI introduction. Students
   locate extinction risk, abundance, uncertainty, and the Start baseline
   action.
2. During the two-hour self-paced app period, students complete the five Core
   missions in order while staff circulate and answer questions.
3. Students go to Compare, select exactly baseline plus one risk plus one
   intervention or vortex, write an interpretation, and request both downloads.
4. Students may use Explore Further for genetics, catastrophes, vortex,
   advanced controls, alternative comparisons, and optional plot downloads.

## Student evidence target

Each student or group should leave with:

- exactly three selected evidence runs: baseline, one risk mechanism, and one
  intervention or vortex run;
- a short interpretation and caveat;
- the comparison CSV; and
- the evidence notes Markdown file.

The app says `Download requested` when each handler receives a request. It does
not guarantee the browser save location. If downloads fail, students should
copy the visible selected comparison into the worksheet and label it fallback
evidence.

## Prompts while circulating

- What changed, exactly?
- Which output moved: risk, abundance, uncertainty, or a mixture?
- What evidence supports that observation?
- What caveat remains?

Keep the Core route accessible to every student. Explore Further is optional;
Compare is the Core completion destination.

## Fallback switch rule

Switch to the fallback pack if the app route is unavailable, visibly slow for
several students, or either evidence download still fails after one retry.
Say:

> We are switching to the static fallback so we can keep the ecological question
> moving. The same outputs matter: extinction risk, final abundance, and
> uncertainty.

The fallback must preserve the same three-run evidence target and temporary
session reminder: save the comparison CSV equivalent and evidence notes before
closing the work session.

## End-of-class check

Confirm that students know that refreshing, closing the tab, or session expiry
clears in-app history, selection, progress, and interpretation. Their local
comparison CSV, evidence notes, and worksheet are the durable record.
