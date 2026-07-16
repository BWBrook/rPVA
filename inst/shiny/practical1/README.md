# Practical 1 Shiny App

This is the browser scaffold for the Practical 1 PVA concept lab. It uses the
public teaching API in `R/teaching_api.R` and base Shiny only.

## Classroom route

The three-hour class uses approximately one hour for PVA teaching and GUI
introduction, followed by approximately two hours of guided, self-paced app
work while the instructor and demonstrators circulate.

Students start on `PVA Basics`, explicitly create baseline run 1 with
`Create baseline run`, and then use the grouped mission rail in Concept Lab.

The five **Core** missions are:

1. Baseline compass;
2. Island ceiling;
3. Individual chance;
4. Shared bad years; and
5. Rescue attempt.

**Compare** is the Core completion destination. It keeps the full successful
session history visible while selecting exactly three evidence runs: baseline,
one eligible risk mechanism, and one intervention or vortex run.

After the Core route, **Explore Further** remains available for genetic
pressure, catastrophes, the extinction vortex, advanced controls, alternative
comparisons, and optional plot downloads. Contextual help, diagnostics, plots,
and every existing deep-dive action remain available.

## Evidence and temporary sessions

The browser session is temporary. Before closing the app, request both the
comparison CSV and the evidence notes Markdown file (the evidence-notes file).
Refreshing, closing the
tab, or allowing the session to expire clears in-app run history, selection,
progress, and interpretation.

The app reports `Download requested` when a download handler receives a
request; it does not claim where the browser saved the file.

The Concept Lab settings record is student-facing. It shows plain-English
parameter labels, the baseline value, the currently selected mission value,
and what changed before the student runs the mission. Optional advanced risk
controls expose preset projection years, simulation futures, and bounded
mortality/fecundity percentage changes after the default path is understood.

Markdown-backed help lives in `content/`:

- `pva-deep-dive.md` for `What is PVA?`;
- `mission-deep-dive.md` for `What you will do`;
- `evidence-deep-dive.md` for `Your evidence pack`;
- `parameter-help.md` for `Control help`;
- `output-reading-help.md` for `Read outputs`;
- `diagnostics-help.md` for `Read diagnostics`; and
- `plot-reading-help.md` for `Read plots`.

The app intentionally excludes persistent student workspaces, authentication,
deployment configuration, and arbitrary YAML editing. Those belong to later,
separate goals.
