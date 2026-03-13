# thylacine.R
pkgload::load_all(".")

# These are the scenarios you can run individually:
scen_list <- c("01_historical_no_action", # 1
               "02_habitat_restoration",  # 2
               "03_legal_protection",     # 3
               "04_captive_breeding",     # 4
               "05_combined_action",      # 5
               "06_sensitivity_template") # 6

# Choose which scenario number you wish to run:
select_scen_number <- 5
demo <- run_case_study_demo("thylacine", scen_list, select_scen_number)
spec <- demo$spec
sim <- demo$sim
sim[c(1:3,5:6)] # show core results as numbers
sum(sim$traj_mean[spec$years+1,])*2 # final population of females and males

# Repeat the above for each of the 5 core scenarios, and the sens anal.

# Finally, you can run all scenarios and compare results
scen <- demo$scenario_table; scen
