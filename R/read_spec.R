#' read_spec
#' @param path path to YAML file
#' @return Named list validated against the supported partial spec schema.
#' @export
read_spec <- function(path) {
  raw <- yaml::read_yaml(path)
  out <- normalize_pva_spec_fields(raw)
  class(out) <- c("pva_spec", class(out))
  out
}
