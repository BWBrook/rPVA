start_ui <- function(id) {
  ns <- NS(id)

  div(
    class = "page-shell start-shell",
    tags$section(
      class = "start-hero",
      tags$img(
        src = "img/landing-woodhen-population.png",
        alt = "Lord Howe Island woodhen standing among green island vegetation"
      ),
      div(
        class = "start-hero-copy",
        span(class = "section-eyebrow", "Practical 2: Woodhen investigation"),
        h1("Advise from evidence"),
        p("Reconstruct the conservation record, test future pressures, and develop transparent management advice.")
      )
    ),
    tags$section(
      class = "start-narrative",
      render_markdown_content(file.path(practical2_app_dir, "content", "start.md"))
    ),
    tags$section(
      class = "project-band",
      div(
        class = "section-heading-row",
        div(
          span(class = "section-eyebrow", "Local-first project"),
          h2("Begin or recover your investigation")
        ),
        actionButton(
          ns("open_project_help"),
          label = "Project help",
          icon = icon("circle-info"),
          class = "btn-default btn-sm",
          `aria-label` = "Open project recovery and portability help"
        )
      ),
      div(
        class = "project-action-grid",
        div(
          class = "project-action",
          h3("Create"),
          textInput(ns("project_title"), "Project title (optional)"),
          textInput(ns("owner_label"), "Owner label (optional)"),
          actionButton(
            ns("create_project"),
            "Create project",
            icon = icon("plus"),
            class = "btn-primary"
          )
        ),
        div(
          class = "project-action",
          h3("Resume"),
          selectInput(
            ns("resume_key"),
            "Autosaved project",
            choices = c("No browser project found" = "")
          ),
          actionButton(
            ns("resume_project"),
            "Resume selected project",
            icon = icon("rotate-right")
          )
        ),
        div(
          class = "project-action",
          h3("Move a project"),
          fileInput(
            ns("import_project"),
            "Import portable project",
            accept = c(".zip", "application/zip"),
            buttonLabel = "Choose project",
            placeholder = "No project chosen"
          ),
          downloadButton(
            ns("download_project"),
            "Download portable project",
            icon = icon("download")
          )
        )
      )
    ),
    tags$section(
      class = "project-status-band",
      `aria-live` = "polite",
      `aria-atomic` = "true",
      uiOutput(
        ns("project_browser_status"),
        `aria-live` = "polite",
        `aria-label` = "Autosave in this browser"
      ),
      uiOutput(
        ns("project_portable_status"),
        `aria-live` = "polite",
        `aria-label` = "Portable project"
      ),
      uiOutput(
        ns("project_dirty_status"),
        `aria-live` = "polite",
        `aria-label` = "Unsaved changes"
      )
    )
  )
}

start_server <- function(id,
                         project,
                         inventory,
                         browser_status,
                         portable_status,
                         dirty_status) {
  moduleServer(id, function(input, output, session) {
    create_event <- eventReactive(input$create_project, {
      title <- trimws(input$project_title %||% "")
      owner <- trimws(input$owner_label %||% "")
      tryCatch(
        list(
          ok = TRUE,
          candidate = new_woodhen_project(
            title = if (nzchar(title)) title else NULL,
            owner_label = if (nzchar(owner)) owner else NULL
          )
        ),
        error = function(error) list(ok = FALSE, message = conditionMessage(error))
      )
    })

    resume_event <- eventReactive(input$resume_project, {
      selected <- input$resume_key %||% ""
      records <- inventory()
      match_index <- match(selected, vapply(records, `[[`, character(1), "key"))
      if (!nzchar(selected) || is.na(match_index)) {
        return(list(ok = FALSE, message = "Choose an available browser project first."))
      }
      list(ok = TRUE, record = records[[match_index]])
    })

    import_event <- eventReactive(input$import_project, {
      upload <- input$import_project
      if (is.null(upload) || !is.character(upload$datapath) ||
          length(upload$datapath) != 1L) {
        return(list(ok = FALSE, message = "Choose one portable project package."))
      }
      tryCatch(
        list(ok = TRUE, candidate = read_woodhen_project_package(upload$datapath)),
        error = function(error) list(ok = FALSE, message = conditionMessage(error))
      )
    })

    download_requested <- reactiveVal(NULL)
    download_counter <- reactiveVal(0L)

    output$download_project <- downloadHandler(
      filename = function() {
        candidate <- req(project())
        paste0(candidate$project_id, ".zip")
      },
      content = function(file) {
        candidate <- req(project())
        write_woodhen_project_package(candidate, file)
        next_count <- download_counter() + 1L
        download_counter(next_count)
        download_requested(list(
          count = next_count,
          project_id = candidate$project_id,
          project_fingerprint = candidate$project_fingerprint
        ))
      },
      contentType = "application/zip"
    )

    observeEvent(inventory(), {
      records <- inventory()
      choices <- if (!length(records)) {
        c("No browser project found" = "")
      } else {
        stats::setNames(
          vapply(records, `[[`, character(1), "key"),
          vapply(records, function(record) {
            title <- if (is.null(record$title)) "Untitled project" else record$title
            paste0(title, " - ", record$saved_at)
          }, character(1))
        )
      }
      updateSelectInput(session, "resume_key", choices = choices)
    }, ignoreInit = FALSE)

    observeEvent(input$open_project_help, {
      showModal(project_help_modal())
    })

    output$project_browser_status <- renderUI({
      status <- browser_status()
      project_status_ui("Autosave in this browser", status$value, status$state, status$icon)
    })
    output$project_portable_status <- renderUI({
      status <- portable_status()
      project_status_ui("Portable project", status$value, status$state, status$icon)
    })
    output$project_dirty_status <- renderUI({
      status <- dirty_status()
      project_status_ui("Unsaved changes", status$value, status$state, status$icon)
    })

    list(
      create = create_event,
      resume = resume_event,
      import = import_event,
      download_requested = reactive(download_requested())
    )
  })
}
