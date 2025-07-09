# bootstrap.R  ---------------------------------------------------------------
# One-liner for KPZ308 students: source("bootstrap.R")

message("🔧  Setting up the woodhenPVA environment…")

## 1. Install renv if missing -----------------------------------------------
if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv", repos = "https://cloud.r-project.org")
}

## 2. Restore the locked package versions ------------------------------------
renv::activate()          # makes sure renv is initialised
renv::restore(confirm = FALSE)

## 3. Load the package source tree -------------------------------------------
if (!requireNamespace("pkgload", quietly = TRUE)) {
  install.packages("pkgload", repos = "https://cloud.r-project.org")
}

pkgload::load_all(".")  # same as devtools::load_all(), lighter dependencies

message("✅  woodhenPVA is ready!  Open toy_demo.R to get started.")
