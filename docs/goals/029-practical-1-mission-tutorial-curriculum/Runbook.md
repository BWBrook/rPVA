# Runbook

Goal 029 is a docs-only pedagogy package. Do not implement app code, change
models, change services, or broaden into deployment.

## Local Guard

```sh
pwd
git branch --show-current
git rev-parse HEAD
git rev-parse origin/main
git status --short --branch
```

Expected:

```text
branch: codex/rpva-goal029-practical1-mission-tutorial
HEAD/origin-main base: 7fb56fb Add campus IT TLS request pack
```

The only expected starting dirty state is the untracked Goal 029 packet
directory created by the orchestrator.

## Source Facts To Use

Use accepted repo-local records and live repo files:

- `docs/teaching/shiny/practical-1-design-brief.md`
- `docs/teaching/shiny/implementation-roadmap.md`
- `docs/teaching/shiny/student-workspace-and-export-design.md`
- `docs/teaching/woodhen/practical-1-pva-foundations.md`
- `docs/teaching/woodhen/practical-1-fallback-pack.md`
- `docs/teaching/woodhen/practical-2-woodhen-management.md`
- `docs/teaching/woodhen/classroom-dry-run-checklist.md`
- `docs/teaching/woodhen/instructor-guide.md`
- `docs/goals/024-practical-1-classroom-dry-run-fallback/dry-run-report.md`
- `inst/shiny/practical1/app.R`
- `R/teaching_api.R`

Use Barry's supplied direction:

```text
The experience should be app-led with a lightweight mission worksheet.
Students should be doing, testing, and playing rather than just reading and
memorising. The worksheet should gently get them to record observations and
think critically.
```

Do not read Chief of Staff, Goal Composer, sibling project folders, KPZ314
materials, or archive material.

## Draft Structure

`docs/teaching/shiny/practical-1-mission-tutorial.md` should include:

1. purpose and class shape;
2. the 2-hour mission arc inside the 3-hour practical;
3. mission-by-mission sequence;
4. app-screen mapping;
5. expected observations and compare tasks;
6. extension or compression options;
7. transfer to the Woodhen practical.

`docs/teaching/woodhen/practical-1-mission-worksheet.md` should include:

1. short student orientation;
2. one compact table or section per mission;
3. prompts for assumption changed, output observed, evidence used, and caveat;
4. export checklist;
5. final transfer questions.

`docs/teaching/woodhen/practical-1-instructor-beat-sheet.md` should include:

1. pre-class stance;
2. suggested timing;
3. Barry priming points;
4. recap beats;
5. roam prompts;
6. common misconceptions;
7. wrap-up prompts;
8. triage if time runs short.

`pedagogy-review.md` should include:

1. what was synthesized;
2. why the chosen sequence works;
3. how the worksheet supports scientific observation;
4. known gaps for later app/UI-support work;
5. what was deliberately left out.

## Tone Rules

- Student text should be active, concise, and exploratory.
- Avoid a lecture-note voice in the worksheet.
- Keep the game/tutorial feel in structure and momentum, not gimmicky language.
- Use the real vocabulary students need later: extinction probability, median
  abundance, uncertainty, carrying capacity, demographic stochasticity,
  environmental stochasticity, genetic stochasticity, catastrophe, intervention,
  scenario comparison, and caveat.
- Do not imply that app exports are final answers.
- Do not imply that raw IP/insecure HTTPS is student-ready.

## Validation

```sh
git status --short --branch
git diff --check
Rscript -e 'renv::status(sources = FALSE)'
```

Marker scan:

```sh
files=$( { git diff --name-only --diff-filter=ACMRTUXB; git ls-files --others --exclude-standard; } | sort -u )
pattern="$(printf '%s|%s|%s|%s|%s|%s' 'TO''DO' 'T''BD' 'FIX''ME' 'PLACE''HOLDER' 'X''XX' 'CHANGE''ME')"
test -z "$files" || printf "%s\n" "$files" | xargs rg -n --pcre2 "(?i)($pattern)" || true
```

Secret/private-key scan:

```sh
files=$( { git diff --name-only --diff-filter=ACMRTUXB; git ls-files --others --exclude-standard; } | sort -u )
test -z "$files" || printf "%s\n" "$files" | xargs rg -n --pcre2 "(?i)(api[_-]?key|secret|token|password|credential|passwd|private[ _-]?key|BEGIN (RSA|OPENSSH|EC|PRIVATE) KEY)" || true
```

Manual review:

- no credential values;
- no private keys;
- no student identifiers;
- no sensitive service payloads;
- no app-code, science/YAML, deployment, or assessment-redesign changes.
