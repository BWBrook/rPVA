# Expected Outputs (Reference Values)

Use this file to keep class outputs aligned and explain that minor variation is
acceptable if a fixed seed is not used in every call.

## Toy model reference output

Command:

```r
source("bootstrap.R")
toy <- run_toy_demo(keep_traj = FALSE, plot_matrix = FALSE, verbose = FALSE)
print(toy$summary)
```

Reference table:

| scenario                  | PE   | N_med |
|--------------------------|-----:|------:|
| det                      | 0.000 | 264 |
| ceiling                  | 0.000 | 85 |
| demographic_stochasticity | 0.000 | 82 |
| env_sd                   | 0.000 | 70 |
| genetics                 | 0.070 | 60 |

## Woodhen core scenario table (reference)

Command:

```r
source("bootstrap.R")
tbl <- run_scenarios("woodhen", csv_out = NULL, rds_out = NULL, keep_traj = FALSE, parallel = FALSE)
print(tbl)
```

Reference table:

| scenario                 | years | reps | PE   | Nmed | Nlo95 | Nhi95 |
|-------------------------|------:|-----:|-----:|-----:|------:|------:|
| woodhen_no_intervention  | 40 | 1000 | 0.666 | 16 | 1 | 31 |
| woodhen_pig_control      | 40 | 1000 | 0.566 | 57 | 2 | 184 |
| woodhen_captive_pig     | 40 | 1000 | 0.082 | 119 | 4 | 199 |
| woodhen_rat_eradication  | 5 | 1000 | 0.000 | 832 | 340 | 1386 |
| woodhen_future_baseline  | 75 | 1000 | 0.000 | 1510 | 1109 | 1957 |

## Sensitivity check reference (bounded, seeded example)

Command:

```r
source("bootstrap.R")
base <- set_scenario("sensitivity_analysis", "woodhen")
s1 <- run_pva_core(base, keep_traj = FALSE, seed = 123)
s2 <- run_pva_core(modifyList(base, list(surv = base$surv * 0.90)), keep_traj = FALSE, seed = 123)
s3 <- run_pva_core(modifyList(base, list(K = 250)), keep_traj = FALSE, seed = 123)
s4 <- run_pva_core(modifyList(base, list(cat_freq = 0.10)), keep_traj = FALSE, seed = 123)

summarise <- function(label, out, years) {
  pe <- if (!is.null(out$ext_prob)) out$ext_prob[years + 1] else mean(out$Nend == 0)
  data.frame(label = label, PE = round(pe, 3), Nmed = out$Nend_summary$median, Nlo95 = out$Nend_summary$lo95, Nhi95 = out$Nend_summary$hi95)
}
print(dplyr::bind_rows(
  summarise("sensitivity_default", s1, base$years),
  summarise("survival_minus_10pct", s2, base$years),
  summarise("K_250", s3, base$years),
  summarise("cat_freq_0.10", s4, base$years)
))
```

Reference table:

| label                  | PE   | Nmed | Nlo95 | Nhi95 |
|-----------------------|-----:|-----:|------:|------:|
| sensitivity_default   | 0.000 | 1510 | 1109 | 1957 |
| survival_minus_10pct  | 0.000 | 1484 | 1091 | 1968 |
| K_250                | 0.000 | 745 | 466 | 1070 |
| cat_freq_0.10        | 0.000 | 1483 | 1052 | 1975 |

## Interpretation note

`run_scenarios()` and `run_toy_demo()` are stochastic methods; only commands run with
an explicit `seed` are directly reproducible across machines.
