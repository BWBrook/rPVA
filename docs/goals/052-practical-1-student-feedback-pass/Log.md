# Log

## 2026-07-08

- Started from Barry's first local simulated-student feedback pass.
- Preserved the local-first testing lane and avoided remote container updates.
- Added a non-species generated PVA learning hero image.
- Replaced the Start page wording with the requested Practical 1/PVA Basics framing.
- Reworked the Concept Lab settings record into a student-facing table comparing baseline values with selected mission values.
- Set Environmental stochasticity defaults to `K = 15`, `env_sd = 0.35`, `years = 50`, `reps = 100`, producing PE 0.33 with seed 42.
- Added optional advanced risk controls as preset choices for projection years, simulation futures, mortality change, and fecundity change.
- Added a `Previous mission` button to match the existing forward mission control.
- Added Concept Lab plot PNG downloads with automatic filenames for trajectory, summary, and risk-detail plots.
- Replaced the diagnostic wording `not a certainty` and guarded the app/content surface for British English spelling in the student-facing text.
- Browser smoke found reversed Shiny choice values for mortality/fecundity controls; fixed labels so the UI displays English labels while submitting numeric preset values.
- Browser smoke found duplicate Shiny input IDs when advanced controls stayed open across mission changes; fixed advanced projection-year and simulation-future controls to use distinct internal IDs mapped back to API fields.
- Browser smoke initially found a Shiny reactive initialization bug; fixed it and added a static regression guard.
- Focused API/Shiny tests and real-browser smoke passed.
