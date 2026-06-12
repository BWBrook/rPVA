# Practical 1 Barry Roleplay Session Brief

Use this brief for the next human roleplay session. It is written for the
orchestrator/operator and Barry. It is not a student handout and it does not
approve student release.

## Purpose

Barry will roleplay a Practical 1 student on the current mission-mode app and
teaching materials. The session should find classroom friction, not debug app
or infrastructure internals.

Expected duration:

- Stage A local route: 25-35 minutes.
- Stage B hosted warning route: 25-40 minutes, only if route and access details
  are supplied out of band.
- Return notes and evidence: 5-10 minutes.

## Materials

Barry should open these files before acting as a student:

- `practical-1-student-launch-page.md`
- `practical-1-mission-worksheet.md`
- `practical-1-barry-roleplay-script.md`
- `practical-1-roleplay-notes-template.md`
- `practical-1-roleplay-feedback-return-template.md`

Create a local evidence folder named `practical-1-evidence`. Save app downloads
there. Screenshots are optional unless a blocker is hard to describe.

## Operator Setup

The operator should start and later stop the local app route. Barry should not
need to run R commands during the student-mode roleplay.

For Stage A, the operator should start Practical 1 from the repo root on the
controlled local route:

```r
source("bootstrap.R")
run_practical1_shiny(host = "127.0.0.1", port = 3902, launch.browser = FALSE)
```

Then give Barry this Stage A route:

```text
http://127.0.0.1:3902/
```

After Stage A, the operator should stop the app and confirm the port is closed.

## Stage A: Local Student-Mode Pass

Barry should act as a student who has been given the launch page, worksheet,
and app route.

Do:

1. Open the supplied local app route.
2. Click `Start baseline`.
3. Inspect baseline run 1 and keep it as the comparison reference.
4. Run `Carrying capacity`.
5. Run one stochasticity mission, preferably `Environmental stochasticity`.
6. Run one risk-pressure mission, preferably `Catastrophe`.
7. Run one final comparison, preferably `Simple intervention`.
8. Open Compare and check that baseline run 1 plus later runs are visible.
9. Download the comparison CSV.
10. Download the evidence-notes Markdown file.
11. Record the filenames in the worksheet or notes template.
12. Open Transfer and answer the prompts briefly.

Pause for one-sentence notes after opening the materials, after `Start
baseline`, after the first changed mission run, after both downloads, and after
Transfer.

## Stage B: Hosted Warning-Route Pass

Stage B is instructor-only. It is not a student release and must not be placed
in Moodle or sent to students.

Run Stage B only if the orchestrator supplies all of this out of band:

- exact hosted route;
- browser/device context;
- allowed non-student access details;
- permission for Barry to accept the browser warning for this instructor-only
  pass.

Barry should use his Windows 11 machine for Stage B. If the browser warning or
login blocks the path, record the blocker and stop. Do not debug DNS, TLS,
accounts, ShinyProxy, nginx, or app internals during the roleplay.

## Stop Rules

Stop and record the blocker if:

- the app route is missing or does not open after one retry;
- login or access friction prevents acting like a student;
- `Start baseline` does not leave baseline as run 1;
- Compare does not show baseline plus later runs;
- either evidence download fails after one retry;
- a mission instruction is unclear enough that a student would need help;
- continuing would require instructor, developer, service, credential, or
  infrastructure knowledge.

## Return Packet

Return these items for Checkpoint B triage:

- completed `practical-1-roleplay-notes-template.md`;
- completed `practical-1-roleplay-feedback-return-template.md`;
- evidence folder path;
- comparison CSV filename for Stage A and, if run, Stage B;
- evidence-notes Markdown filename for Stage A and, if run, Stage B;
- any screenshots that show a blocker;
- one overall recommendation: `GO`, `REVISE`, or `STOP`;
- one sentence on whether the hosted route remains student-release no-go.

The notes can be brief. The key evidence is where the student path slowed down
or stopped.

## Current Release Boundary

Local Stage A may be used for the controlled Barry roleplay when the operator
has just proven the route is green. Hosted Stage B may be used only as an
instructor warning-accepted test with out-of-band access details.

Student release remains no-go until a separate infrastructure gate approves the
class hostname, browser-trusted HTTPS, student access model, capacity, recovery,
and support path.
