#' Launch the Practical 1 Shiny concept lab
#'
#' Opens the browser-based Practical 1 teaching scaffold from the package's
#' installed Shiny app directory.
#'
#' @param host Host interface passed to [shiny::runApp()]. Defaults to
#'   `"127.0.0.1"` for local teaching use.
#' @param port Port passed to [shiny::runApp()]. Defaults to option
#'   `shiny.port`, falling back to `3851`.
#' @param launch.browser Logical or function passed to [shiny::runApp()].
#' @param ... Additional arguments passed to [shiny::runApp()].
#' @return The value returned by [shiny::runApp()].
#' @export
run_practical1_shiny <- function(host = "127.0.0.1",
                                 port = getOption("shiny.port", 3851),
                                 launch.browser = interactive(),
                                 ...) {
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop(
      "The Practical 1 Shiny app requires the `shiny` package. ",
      "Install it with `renv::install(\"shiny\")` or `install.packages(\"shiny\")`.",
      call. = FALSE
    )
  }

  shiny::runApp(
    appDir = practical1_shiny_app_dir(),
    host = host,
    port = port,
    launch.browser = launch.browser,
    ...
  )
}

practical1_shiny_app_dir <- function() {
  app_dir <- system.file("shiny", "practical1", package = "rPVA", mustWork = FALSE)
  if (!nzchar(app_dir) || !dir.exists(app_dir)) {
    stop("Could not locate the Practical 1 Shiny app directory in the rPVA package.", call. = FALSE)
  }
  app_dir
}
