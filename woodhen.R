# woodhen.R

#find_yaml <- function(filename = NULL) {
#  if (is.null(filename)) file.choose() else filename
#}
#spec <- read_spec(find_yaml())

devtools::load_all()
spec_path <- system.file("extdata", "woodhen_no_mgmt.yaml", package = "woodhenPVA")
spec <- read_spec(spec_path)

devtools::test()

sim  <- run_pva_core(spec, keep_traj = TRUE, verbose = TRUE)
plot_pva_traj(sim)
plot_pva_summary(sim)
p <- plot_pva_matrix(spec); p  # returns patchwork composite or a list

summary(as.vector(sim$traj))
df <- traj_to_long(sim$traj)
str(df)
table(df$Year, df$Rep)
head(df)
plot_pva_traj(sim)
