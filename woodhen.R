# woodhen.R
pkgload::load_all(".")

# First run all scenarios and compare results
run_scenarios(csv_out = NULL)

# These are the scenarios you can run individually:
scen_list <- c("01_no_mgmt",            # 1
               "02_pig_control",        # 2
               "03_captive_pig",        # 3
               "04_rodent_eradication", # 4
               "05_future_baseline",    # 5
               "sensitivity_analysis")  # 6

# Choose which scenario number you wish to run:
select_scen_number <- 1

spec <- set_scenario(scen_list[select_scen_number])
plot_pva_matrix(spec) # returns composite plot and a list
sim  <- run_pva_core(spec, seed = 123)

# Create a composite plot of the PVA results
plot_pva_panel(plot_pva_traj(sim, sample = 100),
               plot_pva_summary(sim), 
               plot_ext(sim))
sim[c(1:3,5:6)] # show core results as numbers
sum(sim$traj_mean[spec$years+1,])*2 # final population of females and males
