# Practical 1 Barry Roleplay Go/No-Go

Use this checklist before spending Barry's time on the human roleplay. It does
not approve student release or hosted infrastructure.

For the two-route roleplay path, use
`practical-1-dual-route-roleplay-runbook.md` and
`practical-1-dual-route-go-no-go.md` alongside this checklist. The hosted
warning route is for Barry/instructor testing only and remains separate from
student release.

## Roleplay Pack Readiness

Barry roleplay execution is `GO` only if each item is green:

| Check | Required result | Status |
| --- | --- | --- |
| Script | `practical-1-barry-roleplay-script.md` is short and student-role focused. |  |
| Notes template | `practical-1-roleplay-notes-template.md` supports quick notes and severity. |  |
| Launch page | `practical-1-student-launch-page.md` is the start-here surface. |  |
| Worksheet | `practical-1-mission-worksheet.md` is available for observation notes. |  |
| Evidence folder | Barry knows where to save CSV and Markdown exports. |  |
| Stop rule | Barry is told to record blockers rather than debug as instructor/developer. |  |
| Local rehearsal | Goal 034 local rehearsal evidence exists and is reviewed. |  |
| Artefacts | Goal 033 Moodle-ready artefacts regenerate under `/tmp`. |  |

## Local Or Class Route Readiness

Roleplay route readiness is `GO` only if:

| Check | Required result | Status |
| --- | --- | --- |
| Approved route | The roleplay session has an approved local or class app route. |  |
| App start | The Practical 1 app opens at the supplied route. |  |
| Start baseline | `Start baseline` restores baseline run 1. |  |
| Mission run | Carrying capacity plus stochasticity, risk-pressure, and intervention/vortex runs work. |  |
| Compare | Compare shows baseline and later runs. |  |
| Exports | CSV and evidence-notes Markdown downloads work. |  |
| Transfer | Transfer prompts are reachable. |  |

If the route is missing or access friction appears, do not run the human
roleplay. Record the blocker and either supply a green local route or schedule
the roleplay after the route issue is resolved.

## Hosted Student URL Release Readiness

Hosted student URL release is still `NO-GO` unless a separate infrastructure
gate confirms:

| Check | Required result | Status |
| --- | --- | --- |
| Class hostname | Approved class-appropriate hostname exists. |  |
| Browser trust | HTTPS is browser-trusted with no warning page. |  |
| Access model | Student access is approved and tested without exposing sensitive values. |  |
| Capacity | Expected class concurrency is tested or conservatively bounded. |  |
| Recovery | Rollback and fallback instructions are ready. |  |

Do not use the current raw-IP or insecure HTTPS route as a student-ready link.
Goal 034 does not change DNS, TLS, accounts, services, Moodle, or student
release state.

## Decision

| Decision | When to choose it |
| --- | --- |
| GO | Roleplay pack and local/class route readiness are green. |
| REVISE | Materials are usable but one wording or packaging issue should be fixed first. |
| STOP | App route, access, exports, or role clarity blocks the student path. |
