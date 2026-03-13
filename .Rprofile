## .Rprofile (project root)
## Prefer pak everywhere, but only force binary installs on platforms where
## CRAN/RSPM binaries are routinely available.
Sys.setenv(RENV_CONFIG_PAK_ENABLED = "TRUE")

if (!identical(Sys.info()[["sysname"]], "Linux")) {
  Sys.setenv(RENV_CONFIG_INSTALL_TYPE = "binary")
  options(pkgType = "binary")
}

source("renv/activate.R")
