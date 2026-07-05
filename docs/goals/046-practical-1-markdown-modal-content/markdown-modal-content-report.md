# Markdown Modal Content Report

## Summary

Goal 046 refactors the accepted `What is PVA?` landing deep-dive so Barry can
edit the student-facing body text without touching Shiny code.

The modal title, `Explore PVA` trigger, close action, and one-card-only
prototype scope are unchanged. The body now comes from:

`inst/shiny/practical1/content/pva-deep-dive.md`

## Renderer Approach

`app.R` keeps the modal mechanics and uses a small local
`render_markdown_content()` helper. The helper:

- checks that the Markdown file exists and is readable;
- uses `commonmark::markdown_html()` to render static app-local Markdown;
- returns a polite in-modal fallback if the file, renderer, or rendering step
  fails.

This avoids adding dependencies. `commonmark` is already available through the
existing Shiny dependency stack in `renv.lock`.

## Wording Change

No substantive teaching-text rewrite was made. The existing Goal 045 wording
was moved into Markdown with minor formatting:

- bold emphasis around `many possible futures under assumptions`;
- bullet labels expressed as Markdown bold text.

## Changed Files

- `inst/shiny/practical1/app.R`
- `inst/shiny/practical1/www/styles.css`
- `inst/shiny/practical1/README.md`
- `inst/shiny/practical1/content/pva-deep-dive.md`
- `tests/testthat/test-13_practical1_shiny.R`
- `docs/goals/046-practical-1-markdown-modal-content/`

## Validation

Passed:

- `git diff --check`
- `Rscript -e 'source("bootstrap.R")'`
- `Rscript -e 'renv::status(sources = FALSE)'`
- `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-13_practical1_shiny.R", reporter = "summary")'`
- `Rscript -e 'source("bootstrap.R"); testthat::test_file("tests/testthat/test-12_teaching_api.R", reporter = "summary")'`
- Local browser smoke on `http://127.0.0.1:3914`

The teaching API test was run conservatively even though no teaching API or
export code changed, because the browser smoke also verifies that Compare
exports retain the accepted CSV and evidence-notes shapes.

## Browser Evidence

Browser smoke proved:

- landing screen visible;
- `Explore PVA` opens the Markdown-backed modal;
- modal key concepts are present;
- modal close action works;
- modal text does not leak thylacine, Woodhen case-study, or
  internal/deployment wording;
- `Start baseline` reaches Concept Lab;
- `Introduction` returns to Start;
- Compare/export works after one non-baseline run;
- comparison CSV preserves baseline as run 1.

Evidence paths:

- `/tmp/rpva-goal046-markdown-modal-content/landing-screen.png`
- `/tmp/rpva-goal046-markdown-modal-content/markdown-modal-open.png`
- `/tmp/rpva-goal046-markdown-modal-content/markdown-modal-panel.png`
- `/tmp/rpva-goal046-markdown-modal-content/post-start-baseline.png`
- `/tmp/rpva-goal046-markdown-modal-content/practical1-comparison.csv`
- `/tmp/rpva-goal046-markdown-modal-content/practical1-evidence-notes.md`
- `/tmp/rpva-goal046-markdown-modal-content/smoke-summary.txt`

Screenshot dimensions:

- `landing-screen.png`: 1440 x 1050
- `markdown-modal-open.png`: 1440 x 1050
- `markdown-modal-panel.png`: 600 x 566
- `post-start-baseline.png`: 1440 x 1085

Checksums:

```text
dfb9089168f3d26be640c4364a82e39c5a1f18f4e3bb19da11208f2614a5c033  landing-screen.png
56a893179d9c1a3c119e913eba9540a769ef705d7555d95f155cdc884231c5ca  markdown-modal-open.png
61c55032ae2a47b5903f1b0e9f50d0056a46156ae562743c5547329b030e660a  markdown-modal-panel.png
155d73bdb9086ce003f07ec84816f9f0b297eb26e4a93afb26e42e4c72788280  post-start-baseline.png
7895f193406701cb1353552bf6b8321bc3f35359234ac92b4d0ee44174e22422  practical1-comparison.csv
5d3674f066a9104c1e1a05ea15fbe3f59acaaade8d54cacff1c730880568085b  practical1-evidence-notes.md
6a68d214a86c11f406a7b8bc8b21f4bf1bde9937889dbe474b899b7b4af988ad  smoke-summary.txt
```

The browser console recorded one harmless 404 for a browser-requested resource.
It did not affect modal interaction, baseline flow, Compare, or exports.

## Scans

Final scans over changed/untracked text:

- marker scan: no hits;
- strict secret/private-key/token/student-identifier scan: no hits;
- student-facing Markdown content scan: no thylacine, Woodhen case-study,
  internal, or deployment wording.

## Recommendation

This is ready for Barry to edit the Markdown text and retest the opening flow
locally. The main tradeoff is that Markdown is rendered through `commonmark`,
which is already present through Shiny; if that renderer were unavailable, the
modal shows a clear in-app fallback rather than crashing the app.
