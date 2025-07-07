# woodhen.R

#find_yaml <- function(filename = NULL) {
#  if (is.null(filename)) file.choose() else filename
#}
#spec <- read_spec(find_yaml())

devtools::load_all()
devtools::test(filter = "02") # filter example
devtools::test()  # full suite

devtools::load_all()
spec <- read_spec(system.file("extdata", "woodhen_test.yaml", package="woodhenPVA"))
sim  <- run_pva_core(spec, keep_traj = TRUE, verbose = TRUE)
plot_pva_traj(sim)
sim[1:4]
plot_pva_summary(sim)

p <- plot_pva_matrix(spec) # returns patchwork composite or a list

summary(as.vector(sim$traj))
df <- traj_to_long(sim$traj)
str(df)
table(df$Year, df$Rep)
head(df)
plot_pva_traj(sim)



spec_ext <- read_spec(system.file("extdata","woodhen_test.yaml",package="woodhenPVA"))
spec_ext$env_sd  <- 0
spec_ext$demo_sd <- FALSE
spec_ext$years   <- 1
spec_ext$reps    <- 1

# Force extinction scenario
spec_ext$surv[]   <- 0
spec_ext$fecund[] <- 0
spec_ext$n0[]     <- 1

out <- run_pva_core(spec_ext, keep_traj = TRUE)

print(out$traj)   # show the full stage vector at t=0 and t=1
print(out$Nend)   # should be zero

