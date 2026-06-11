# Practical 1 Go/No-Go Checklist

Use this checklist before presenting Practical 1 to students. It separates
local teaching readiness from hosted student URL release readiness.

## Local/In-Room Teaching Go/No-Go

Local/in-room delivery is `GO` only if all required items are green:

| Check | Required result | Status |
| --- | --- | --- |
| Repo state | Teaching machine is on the intended commit with no unexpected local changes. |  |
| Bootstrap | `source("bootstrap.R")` completes and prints the ready message. |  |
| App launch | Practical 1 Shiny opens on the approved local or class route. |  |
| Start | `Start baseline` creates or restores baseline run 1. |  |
| Concept Lab | Carrying capacity plus at least one stochasticity, one risk-pressure, and one intervention/vortex mission run. |  |
| Compare | Comparison table shows baseline plus later runs and remains readable. |  |
| Exports | Comparison CSV and evidence-notes Markdown download. |  |
| Transfer | Transfer questions are visible and align with the worksheet. |  |
| Worksheet | Students have the mission worksheet and know where to record exported evidence or fallback evidence. |  |
| Report scaffold | DOCX render works if report scaffold use is planned. |  |
| Demonstrator pack | Day-of-class pack, fallback pack, troubleshooting guide, and expected outputs are open. |  |

Local/in-room delivery can be green even if hosted student URL release remains
blocked. In that case, use a local instructor/demo route or the fallback pack,
and do not describe the hosted route as student-ready.

## Hosted URL/TLS/Student-Release Go/No-Go

Hosted student release is `NO-GO` until all required items are green:

| Check | Required result | Status |
| --- | --- | --- |
| Class hostname | Approved class-appropriate hostname is confirmed. |  |
| Browser trust | HTTPS is browser-trusted with no crossed-out HTTPS or warning page. |  |
| Certificate ownership | Issuance, renewal, and rollback owner are documented. |  |
| App path | Students reach the Practical 1 app, not only a gateway or login page. |  |
| Access model | Student access model is approved and tested without exposing secrets. |  |
| Accounts/workspaces | Any class account, token, workspace, quota, and cleanup decisions are approved. |  |
| Capacity | Expected class concurrency is tested or conservatively bounded. |  |
| Recovery | Rollback and fallback instructions are ready for demonstrators. |  |

The current raw-IP or insecure HTTPS route is not a student-ready teaching URL.
Goal 031 does not change DNS, TLS, accounts, services, or remote state.

## Fallback Readiness Go/No-Go

Fallback delivery is `GO` only if:

- `practical-1-fallback-pack.md` is open on the teaching machine;
- `expected-outputs.md` is open for reference values;
- `troubleshooting.md` is open for bootstrap, plotting, and export issues;
- `report-scaffold.qmd` renders to DOCX or a known non-PDF route is available;
- demonstrators can explain that fallback preserves the same evidence target:
  extinction risk, final abundance, uncertainty, and caveat.

## Day-After Cleanup And Notes

After the practical:

- record which path was used: hosted app, local app, instructor demo, or static
  fallback;
- record whether students saved both app evidence files;
- record any common worksheet blank or misconception;
- record any hosted route, TLS, account, or download blocker;
- keep student identifiers and credentials out of repo files and chat.
