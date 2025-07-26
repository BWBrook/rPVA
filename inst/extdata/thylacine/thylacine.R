# woodhen.R
pkgload::load_all(".")

# These are the scenarios you can run individually:
scen_list <- c("10_thy_historical_no_action",            # 1
               "11_thy_habitat_restoration",        # 2
               "12_thy_legal_protection",        # 3
               "13a_thy_captive_breeding", # 4
               "13b_thy_captive_plus_protection",    # 5
               "14_thy_sensitivity_template")  # 6

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
