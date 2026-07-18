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
4. Environmental variability; and
5. Rescue attempt.

**Compare** is the Core completion destination. Students select exactly three
evidence runs: the locked baseline, one eligible risk mechanism, and one
intervention or vortex run. The full successful session history is available
in a collapsed audit panel. Students can change the selected trio, use `Add to
notebook` to preserve multiple observations, and write a final synthesis.

After the Core route, **Explore Further** remains available for genetic
pressure, catastrophes, the extinction vortex, advanced controls, alternative
comparisons, and optional plot downloads. Contextual help, diagnostics, plots,
and every existing deep-dive action remain available.

## Evidence and temporary sessions

The browser session is temporary. Before closing the app, students use
**Transfer** to download both Current files: the comparison CSV and the
evidence notebook Markdown file. Refreshing, closing the tab, or allowing the
session to expire clears in-app run history, selection, notebook observations,
and synthesis. Changing any of that evidence makes an earlier download Stale.

The comparison CSV records the final selected trio. The evidence notebook
collects the final synthesis, all saved observations and their metric
snapshots, the final comparison, and settings provenance.

Practical 1 is unassessed practice in evidence reasoning. Transfer explicitly
bridges those habits to the more independent Practical 2 Woodhen investigation
and its report worth 25% of the unit.

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
- `plot-reading-help.md` for `Read plots`;
- `compare-selection-help.md` for choosing a focused three-run comparison;
- `compare-outcomes-help.md` for reading the outcome matrix;
- `compare-notebook-help.md` for observations and synthesis; and
- `transfer-evidence-help.md` for current and stale evidence downloads.

The app intentionally excludes persistent student workspaces, authentication,
deployment configuration, and arbitrary YAML editing. Those belong to later,
separate goals.
