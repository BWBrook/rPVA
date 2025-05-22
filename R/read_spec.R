#' read_spec
#' @param path path to YAML file
#' @return named list with numeric vectors
#' @export
read_spec <- function(path) {
  raw <- yaml::read_yaml(path)
  out <- raw
  for (nm in names(raw)) {
    val <- raw[[nm]]
    # Numeric coercion: only if it's a scalar or vector/list of numbers
    if (is.list(val) || is.atomic(val)) {
      # Try coercion only if *all* elements look like numbers
      if (all(grepl("^[-+]?[0-9]*\\.?[0-9]+([eE][-+]?[0-9]+)?$", as.character(unlist(val))))) {
        out[[nm]] <- as.numeric(unlist(val))
      }
    }
    # Otherwise, leave as is (character, logical, etc.)
  }
  class(out) <- c("pva_spec", class(out))
  out
}

