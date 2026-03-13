#' set_scenario
#'
#' Combine a species-specific “base” YAML with a scenario override YAML.
#'
#' @param scen_name   Character, e.g. "01_no_mgmt" (no extension)
#' @param subdir      Sub-folder under inst/extdata/ that holds the YAMLs
#'                    (default "woodhen").
#' @return            A complete `pva_spec` list ready for `run_pva_core()`.
#' @export
set_scenario <- function(scen_name,
                         subdir = "woodhen",
                         pkg    = utils::packageName()) {

  root <- system.file("extdata", subdir, package = pkg)

  if (root == "" || !dir.exists(root))
    stop("Cannot locate inst/extdata/", subdir, " in package ", pkg, call. = FALSE)

  base_path  <- file.path(root, paste0("_", subdir, "_base.yaml"))
  delta_path <- file.path(root, paste0(scen_name,  ".yaml"))

  if (!file.exists(base_path))
    stop("Base YAML not found: ", base_path,  call. = FALSE)
  if (!file.exists(delta_path))
    stop("Scenario YAML not found: ", delta_path, call. = FALSE)

  base  <- read_spec(base_path)
  delta <- read_spec(delta_path)

  spec  <- validate_full_pva_spec(modifyList(base, delta))
  if (is.null(spec$name)) spec$name <- scen_name
  class(spec) <- c("pva_spec", class(spec))
  spec
}
