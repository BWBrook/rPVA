# Practical 1 Dual-Route Roleplay Runbook

Use this runbook before Barry spends time roleplaying a Practical 1 student.
It separates the controlled local route from the hosted warning route and keeps
student release outside the roleplay.

## Purpose

The roleplay has two stages:

| Stage | Route | Purpose | Release status |
| --- | --- | --- | --- |
| A | Local Mac route | Test the student mission path on a route we control. | Roleplay only. |
| B | Hosted deep-server route | Test instructor-only access and warning friction from Barry's Windows 11 machine. | Instructor-only test. |
| Student release | Approved class route | Use only after hostname, browser trust, access, capacity, and recovery are green. | No-go for now. |

Run Stage A first. Run Stage B only if the orchestrator supplies the exact
route and access details out of band for the roleplay session.

## Materials To Open

Open these before Stage A:

- `practical-1-student-launch-page.md`
- `practical-1-mission-worksheet.md`
- `practical-1-barry-roleplay-script.md`
- `practical-1-roleplay-notes-template.md`
- `practical-1-roleplay-feedback-return-template.md`
- this runbook

Create a local folder called `practical-1-evidence` for app downloads and
fallback notes.

## Stage A: Local Mac Route

Start a local app route from the repo root:

```r
source("bootstrap.R")
run_practical1_shiny(host = "127.0.0.1", port = 3901, launch.browser = FALSE)
```

Use this route for the local roleplay:

```text
http://127.0.0.1:3901/
```

Barry should act as a student, not as instructor or developer:

1. Open the local app route.
2. Click `Start baseline`.
3. Inspect baseline run 1 and keep it as the comparison reference.
4. Run `Carrying capacity`.
5. Run one stochasticity mission.
6. Run one risk-pressure mission.
7. Run one intervention or vortex comparison.
8. Open Compare and confirm baseline plus later runs are visible.
9. Save the comparison CSV.
10. Save the evidence-notes Markdown file.
11. Record filenames in the worksheet or notes template.
12. Open Transfer and answer the prompts briefly.

Stop Stage A and report if the app does not open, baseline is not run 1,
Compare does not show the expected rows, either evidence download fails after
one retry, or the instructions require instructor/developer knowledge.

After Stage A, stop the local app route and confirm the local port is closed.

## Stage B: Hosted Deep-Server Route

Stage B is optional for the later human roleplay and is instructor-only. It is
not a student release.

Use Stage B only when the orchestrator supplies:

- the exact hosted route to test;
- the allowed browser and device context;
- the out-of-band non-student access details;
- permission for Barry to accept the browser warning for this test only.

Current expected posture:

- the raw campus route is expected to show crossed-out HTTPS or a browser
  warning while campus IT/TLS work remains pending;
- Barry may accept that warning only for this instructor-controlled roleplay;
- the same route must not be placed in Moodle or given to students.

Barry should test from the Windows 11 machine:

1. Open the supplied hosted route.
2. Record whether the browser warning appears and how disruptive it is.
3. Continue only if the session instructions explicitly allow warning
   acceptance for this instructor-only pass.
4. Sign in using the out-of-band non-student access details.
5. Open Practical 1.
6. Repeat the same student path used in Stage A.
7. Save the comparison CSV and evidence-notes Markdown if downloads work.
8. Record any route, login, warning, speed, export, or clarity issue in the
   feedback-return template.

Stop Stage B and report if login is unreachable, access details are missing,
Practical 1 does not open, warning acceptance is unclear, either evidence
download fails after one retry, or any step would require Barry to debug
infrastructure.

## Student Release Boundary

Do not release the hosted route to students until a separate infrastructure gate
confirms:

- approved class hostname;
- browser-trusted HTTPS with no warning page;
- approved student access model;
- class account or workspace decision;
- expected concurrency and recovery plan;
- fallback pack and cleanup path.

Until then, student-facing materials should keep saying "the approved Practical
1 app link supplied for the class session" rather than naming the hosted route.

## What To Return

After either stage, return:

- the completed notes template;
- the completed feedback-return template;
- the evidence folder path;
- the comparison CSV and evidence-notes filenames;
- one recommendation: `GO`, `REVISE`, or `STOP`.

One or two sentences per checkpoint is enough. The aim is to find classroom
friction, not to debug the service during the roleplay.
