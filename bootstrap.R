# bootstrap.R  ---------------------------------------------------------------
# One-liner for installation: source("bootstrap.R")

message("🔧  Setting up the r-pva environment…")

## 1. Install renv if missing -----------------------------------------------
if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv", repos = "https://cloud.r-project.org")
}

## 2. Restore the locked package versions ------------------------------------
project <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
active_project <- tryCatch(renv::project(), error = function(e) NULL)
active_project <- if (length(active_project)) {
  normalizePath(active_project, winslash = "/", mustWork = FALSE)
} else {
  NA_character_
}

if (!identical(active_project, project)) {
  renv::activate(project = project)
}

status <- renv::status(sources = FALSE)
if (!isTRUE(status$synchronized)) {
  renv::restore(confirm = FALSE, exclude = "renv")
}

## 3. Load the package source tree -------------------------------------------
if (!requireNamespace("pkgload", quietly = TRUE)) {
  install.packages("pkgload", repos = "https://cloud.r-project.org")
}

pkgload::load_all(".")  # same as devtools::load_all(), lighter dependencies

message("✅  r-pva is ready!  Open README.md to get started.")
