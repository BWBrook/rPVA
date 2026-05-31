run_case_study_demo <- function(subdir, scen_list, select_scen_number = 1, seed = 123, sample = 100) {
  scenario_id <- scen_list[[select_scen_number]]
  spec <- set_scenario(scenario_id, subdir = subdir)

  plot_pva_matrix(spec)
  sim <- run_pva_core(spec, seed = seed, keep_traj = TRUE, verbose = FALSE)
  plot_pva_panel(
    plot_pva_traj(sim, sample = sample),
    plot_pva_summary(sim),
    plot_ext(sim)
  )

  list(
    spec = spec,
    sim = sim,
    scenario_table = run_scenarios(
      subdir,
      csv_out = NULL,
      rds_out = NULL,
      keep_traj = FALSE
    )
  )
}
