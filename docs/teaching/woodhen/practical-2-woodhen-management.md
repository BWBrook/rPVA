# Practical 2: Woodhen Management and Bounded Sensitivity

## Aim

Use the real case-study scaffold (woodhen) to compare management options and test
how sensitive long-term viability is to one changed ecological parameter.

## Learning outcomes

- run all Woodhen core scenarios and compare summaries,
- interpret why scenario ranking does (or does not) match intuition,
- run bounded sensitivity experiments with one factor changed at a time,
- convert outputs into report-ready statements with uncertainty and caveats.

## Time allocation (3 hours)

1. Core scenario run and compare (80 min)
2. Management scenario interpretation (45 min)
3. Bounded sensitivity exercise (50 min)
4. Report draft (45 min)

## Setup

```r
source("bootstrap.R")
```

## Part A — run and compare the Woodhen baseline package

```r
woodhen_tbl <- run_scenarios(
  "woodhen",
  csv_out = NULL,
  rds_out = NULL,
  keep_traj = FALSE,
  parallel = FALSE
)
print(woodhen_tbl)
```

Expected baseline comparison values:

- `woodhen_no_intervention`: PE=0.666, Nmed=16
- `woodhen_pig_control`: PE=0.566, Nmed=57
- `woodhen_captive_pig`: PE=0.082, Nmed=119
- `woodhen_rat_eradication`: PE=0.000, Nmed=832
- `woodhen_future_baseline`: PE=0.000, Nmed=1510

Checkpoint 1:

- Which scenario is the strongest practical intervention across the scenario
  horizons used in this teaching setup (40-year intervention cases, a 5-year rat-
  eradication check, and the 75-year future baseline)?
- Is the best Nmed scenario always the best for extinction risk?

## Part B — scenario-by-scenario visual checks

Run and plot one scenario at a time using its YAML key.

```r
spec <- set_scenario("02_pig_control", "woodhen")
sim  <- run_pva_core(spec, keep_traj = TRUE, seed = 123, verbose = FALSE)

summarize_pva_result(sim)
diagnose_pva_result(sim)

plot_pva_panel(
  plot_pva_traj(sim, sample = 150),
  plot_pva_summary(sim),
  plot_ext(sim)
)
```

Try the same pattern for:

- `"01_no_mgmt"`
- `"03_captive_pig"`
- `"04_rodent_eradication"`

Checklist:

- Is the extinction curve still near zero or rising?
- Does suppression/recovery timing match the narrative (e.g., later restoration)?
- Do management effects appear in the trajectory medians or tails first?

## Part C — bounded sensitivity analysis (one-factor-at-a-time)

Use the built-in `sensitivity_analysis` case. Keep all other inputs fixed and test
exactly one parameter change per run.

```r
base <- set_scenario("sensitivity_analysis", "woodhen")

s1 <- run_pva_core(base, keep_traj = FALSE, seed = 123)
s2 <- run_pva_core(modifyList(base, list(surv = base$surv * 0.90)),
                  keep_traj = FALSE, seed = 123)
s3 <- run_pva_core(modifyList(base, list(K = 250)),
                  keep_traj = FALSE, seed = 123)
s4 <- run_pva_core(modifyList(base, list(cat_freq = 0.10)),
                  keep_traj = FALSE, seed = 123)

sensitivity_tbl <- compare_pva_results(
  list(s1, s2, s3, s4),
  scenarios = c("baseline", "survival_minus_10pct", "K_250", "cat_freq_0.10")
)
print(sensitivity_tbl)

diagnose_pva_result(s2, scenario = "survival_minus_10pct")
```

Important guardrails:

- do not change `years`, `n0`, or `reps`,
- do not alter both `surv` and `K` together in the same run,
- keep all edits interpretable for managers.

Checkpoint 2:

- Which assumption changes output the most?
- Does one-factor change produce a larger impact than a comparable management
  intervention?

## Part D — written management conclusion

Write a 250–300 word interpretation using:

1) extinction risk pattern,
2) median abundance trend,
3) uncertainty interval width,
4) likely biological interpretation,
5) one management recommendation and one caveat.

Your recommendation must include one non-implementation caveat (e.g. data quality,
model assumptions, or unmodelled processes).
