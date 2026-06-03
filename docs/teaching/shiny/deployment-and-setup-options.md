# Deployment And Setup Options

## Purpose

The Practical 1 interface must work for a mixed student cohort. The design
target is a student who can open a browser and interact with PVA concepts in
class without installing R, rebuilding packages, editing YAML, or using a
terminal.

This document compares plausible delivery paths for the 2026 road test.

## Evaluation Criteria

The setup path should be judged against:

- reliability in a three-hour practical,
- support burden for demonstrators,
- Windows 11 compatibility,
- macOS compatibility,
- older laptop performance,
- Chromebook or browser-only fallback,
- reproducibility for teaching outputs,
- cost and administrative overhead,
- ability to keep using the package locally after class.

## Option 1: Local Shiny App On Student Machines

Students install R, restore the project environment, and run a Shiny app locally.

### Strengths

- No hosting cost.
- Works offline after installation.
- Students can continue into R workflows later.
- Closest to package development and reproducible local analysis.

### Weaknesses

- Highest classroom setup burden.
- Windows package installation can consume the practical.
- Older laptops may struggle with package restore or repeated simulations.
- Chromebook or locked-down devices are effectively excluded.
- Demonstrators must troubleshoot R, RStudio, permissions, paths, package
  compilation, and browser launch issues.

### Fit

Good as an optional extension path, instructor demo path, or backup for advanced
students. Risky as the primary first-contact pathway for Practical 1.

## Option 2: Hosted Shiny App

Students open a hosted app in a browser. The app runs on a managed server or
hosting service.

### Strengths

- Best first-contact experience for mixed hardware.
- No student package installation.
- Works for Windows, macOS, older laptops, and many Chromebook-like setups.
- Demonstrators can focus on concepts rather than setup.
- Easy to align every student with the same app version.
- Enables pre-class testing from the same URL students will use.

### Weaknesses

- Requires a reliable hosting decision before class.
- Needs capacity testing for class-size concurrency.
- Requires a support plan if the network or hosting service fails.
- Students may not learn how to reproduce the app locally unless a later pathway
  is provided.

### Fit

Best primary path for the 2026 road test if Barry wants Practical 1 to de-risk
concept learning and hardware variability.

## Option 3: Containerized Or Server-Hosted App

The app runs in a controlled server or container environment, potentially on a
university server, Nectar VM, or other managed Linux host.

### Strengths

- Strong reproducibility.
- Avoids student machine setup.
- Can be load-tested and versioned.
- Gives more control than a third-party hosted service.
- Can use Barry's Mac mini as orchestration and a Linux host for deployment
  when appropriate.

### Weaknesses

- Requires infrastructure setup and monitoring.
- Requires a security and access plan.
- Needs deployment documentation and a recovery procedure.
- More operational work than a simple hosted prototype.

### Fit

Good if the road test needs more control, or if institutional constraints make
third-party hosting awkward. For class day, it should still present as a simple
browser URL to students.

## Option 4: Browser-First Static Or Precomputed Fallback

Students use a static web page, prepared outputs, or a lightweight fallback
notebook/report if the live Shiny app is unavailable.

### Strengths

- Lowest runtime risk.
- Works on nearly any browser.
- Good emergency fallback during class.
- Can preserve the teaching sequence even if simulations cannot run live.

### Weaknesses

- Less exploratory.
- Students may see canned output rather than model behaviour.
- Harder to teach the connection between parameter changes and simulation
  output.
- Does not support student-chosen sensitivity work on its own.

### Fit

Essential as a fallback, but not rich enough as the primary Practical 1
experience.

## Hardware And Access Matrix

| Student environment | Local Shiny | Hosted Shiny | Server/container URL | Static fallback |
| --- | --- | --- | --- | --- |
| Windows 11 laptop | Possible but high support | Strong | Strong | Strong |
| macOS laptop | Possible but still support-heavy | Strong | Strong | Strong |
| Older laptop | Risky if local packages or simulations are heavy | Strong if browser works | Strong if server capacity is adequate | Strong |
| Chromebook/browser-only | Poor | Strong | Strong | Strong |
| Locked-down lab machine | Depends on local install rights | Strong | Strong | Strong |
| Offline classroom | Possible after setup | Weak | Weak | Strong if bundled locally |

## Recommended Path For 2026 Road Test

Use hosted or server-hosted Shiny as the primary Practical 1 path, with a static
browser-first fallback and a local instructor/demo path. Students should only
need a browser during the first practical. Local R setup can remain available
for students who want to continue into scripts, but it should not be the entry
ticket for learning PVA concepts.

## Practical Deployment Shape

### Primary

- Hosted Shiny or controlled server-hosted Shiny.
- One stable class URL.
- App version locked for the practical window.
- Pre-class load test using expected class concurrency.
- Demonstrator checklist for browser, URL, refresh, and fallback.

### Fallback

- Static HTML or PDF practical worksheet with prepared screenshots and compact
  output tables.
- Instructor-controlled live demo from the Mac mini or another reliable machine.
- Downloadable evidence bundle for students if the app is unavailable.

### Optional Local Continuation

- Local Shiny or R workflow for students who want to reproduce or extend work.
- Separate setup instructions outside the first-practical critical path.

## Operational Checks Before Class

- Confirm hosting URL and app version.
- Run the complete Practical 1 sequence in Chrome.
- Run the sequence on at least one Windows browser and one macOS browser.
- Test from a lower-spec machine if available.
- Test the fallback static materials without internet beyond file access.
- Confirm export/download behaviour if exports are implemented.
- Confirm expected concurrent users do not exceed server limits.
- Have a short in-class recovery script for demonstrators.

## Unresolved Decisions For Barry

- Is the primary 2026 road-test host a managed Shiny service, university server,
  Nectar-style VM, or another controlled host?
- What class-size concurrency should the first road test assume?
- Does the app need student authentication, or is an unlisted class URL enough?
- Are downloads/exports required in Practical 1, or can they wait until
  Practical 2?
- Should the app collect anonymous usage traces for teaching QA, subject to
  ethics and institutional expectations?
- How much local R setup should remain in the official student instructions?
