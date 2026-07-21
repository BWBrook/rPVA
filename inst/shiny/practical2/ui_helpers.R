markdown_unavailable_ui <- function(message) {
  div(
    class = "content-unavailable",
    p(strong("Guidance unavailable")),
    p(message)
  )
}

render_markdown_content <- function(path) {
  if (!file.exists(path) || file.access(path, mode = 4) != 0) {
    return(markdown_unavailable_ui(
      "This guidance file could not be read. Please tell your demonstrator."
    ))
  }
  if (!requireNamespace("commonmark", quietly = TRUE)) {
    return(markdown_unavailable_ui(
      "The Markdown renderer is unavailable. Please tell your demonstrator."
    ))
  }

  tryCatch(
    {
      markdown_text <- paste(
        readLines(path, warn = FALSE, encoding = "UTF-8"),
        collapse = "\n"
      )
      HTML(commonmark::markdown_html(markdown_text))
    },
    error = function(...) {
      markdown_unavailable_ui(
        "This guidance file could not be rendered. Please tell your demonstrator."
      )
    }
  )
}

project_help_modal <- function() {
  modalDialog(
    title = "Project recovery and portability",
    div(
      class = "help-modal-content",
      render_markdown_content(file.path(practical2_app_dir, "content", "help-projects.md"))
    ),
    footer = modalButton("Close"),
    easyClose = TRUE,
    size = "m"
  )
}

pending_tab_ui <- function(title, next_step) {
  div(
    class = "page-shell pending-tab-shell",
    tags$section(
      class = "pending-tab-band",
      span(class = "section-eyebrow", "Investigation workspace"),
      h1(title),
      p("This workspace arrives in the next build stage."),
      p(class = "muted", next_step)
    )
  )
}

project_status_ui <- function(label, value, state = "neutral", icon_name = "circle-info") {
  div(
    class = paste("project-status-item", paste0("is-", state)),
    icon(icon_name),
    div(
      span(class = "project-status-label", label),
      span(class = "project-status-value", value)
    )
  )
}
