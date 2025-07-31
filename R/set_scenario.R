#' set_scenario
#' 
#' Combine the global woodhen base spec with an override YAML.
#' @param scen_name Character, e.g. "01_no_mgmt" (no extension).
#' @return A complete `pva_spec` list ready for `run_pva_core()`.
#' @export
set_scenario <- function(scen_name,
                         dir = system.file("extdata", package = "rPVA")) {

  base_path  <- file.path(dir, "_woodhen_base.yaml")
  delta_path <- file.path(dir, paste0(scen_name, ".yaml"))

  if (!file.exists(base_path))
    stop("Base YAML not found: ", base_path)
  if (!file.exists(delta_path))
    stop("Scenario YAML not found: ", delta_path)

  base  <- read_spec(base_path)
  delta <- read_spec(delta_path)   # safe: read_spec() already coerces numerics

  spec  <- modifyList(base, delta)
  if (is.null(spec$name))
    spec$name <- scen_name

  spec
}
