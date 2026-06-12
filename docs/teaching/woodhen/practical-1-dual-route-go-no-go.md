# Practical 1 Dual-Route Roleplay Go/No-Go

Use this checklist before scheduling Barry's two-stage roleplay. It does not
approve student release.

## Stage A: Local Mac Route

Stage A is `GO` only if every required item is green:

| Check | Required result | Status |
| --- | --- | --- |
| Repo state | Teaching machine is on the intended commit with no unexpected changes. |  |
| Bootstrap | `source("bootstrap.R")` completes. |  |
| Local app route | Practical 1 opens at the supplied local route. |  |
| Start baseline | `Start baseline` restores baseline as run 1. |  |
| Mission path | Carrying capacity plus stochasticity, risk-pressure, and intervention/vortex runs work. |  |
| Compare | Baseline plus later runs are visible and readable. |  |
| Exports | Comparison CSV and evidence-notes Markdown download. |  |
| Transfer | Transfer prompts are reachable. |  |
| Notes | Barry has the roleplay notes and feedback-return templates. |  |

If Stage A is not green, do not spend Barry's time on Stage B. Fix or report
the local blocker first.

## Stage B: Hosted Deep-Server Route

Stage B is instructor-only and warning-accepted. It is `GO` for Barry roleplay
only if every required item is green:

| Check | Required result | Status |
| --- | --- | --- |
| Purpose | Barry understands this is an instructor-only test, not a student link. |  |
| Route | The orchestrator supplies the exact hosted route out of band. |  |
| Access | The orchestrator supplies allowed non-student access details out of band. |  |
| Browser warning | Barry is told the warning is expected and accepted only for this test. |  |
| Login | Barry can reach login and sign in without asking students or IT for help. |  |
| App path | Barry reaches Practical 1, not just a gateway or login page. |  |
| Mission path | The same student path used in Stage A works. |  |
| Exports | CSV and evidence-notes Markdown downloads work or the blocker is recorded. |  |
| Stop rule | Barry records blockers rather than debugging infrastructure. |  |

If Stage B reaches a route or access blocker, keep the blocker as evidence for
the trusted-route or access gate. Do not turn the session into infrastructure
debugging.

## Student Release Gate

Student release is `NO-GO` until a separate infrastructure gate confirms:

| Check | Required result | Status |
| --- | --- | --- |
| Hostname | Approved class-appropriate hostname exists. |  |
| Browser trust | HTTPS is browser-trusted with no warning page. |  |
| Access model | Student access model is approved and tested. |  |
| Accounts/workspaces | Class account, workspace, quota, and cleanup decisions are approved. |  |
| Capacity | Expected class concurrency is tested or conservatively bounded. |  |
| Recovery | Fallback, rollback, and support path are ready. |  |

The raw-IP or warning-producing hosted route is not student-ready.

## Decision

| Decision | When to choose it |
| --- | --- |
| GO | Stage A is green, and Stage B has an explicit instructor-only route/access setup. |
| REVISE | The materials are clear enough to test, but one wording or packaging issue should be fixed first. |
| STOP | App route, access, browser warning, exports, or role clarity blocks the student path. |
