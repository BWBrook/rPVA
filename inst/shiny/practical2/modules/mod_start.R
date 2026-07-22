start_ui <- function(id) {
  ns <- NS(id)

  div(
    class = "page-shell start-shell",
    tags$section(
      class = "start-hero",
      tags$img(
        src = "img/lord-howe-island-nasa.webp",
        class = "start-island-image",
        alt = "NASA astronaut photograph of Lord Howe Island and its lagoon"
      ),
      div(
        class = "start-hero-copy",
        span(class = "section-eyebrow", "Practical 2: Woodhen investigation"),
        h1("Advise from evidence"),
        p("Reconstruct the conservation record, test future pressures, and develop transparent management advice."),
        p(
          class = "start-image-credit",
          tags$a(
            href = "https://commons.wikimedia.org/wiki/File:Lord_Howe_ISS006-E-5731.png",
            target = "_blank",
            rel = "noopener noreferrer",
            "View original island photograph"
          )
        )
      )
    ),
    tags$section(
      class = "start-narrative",
      div(
        class = "start-narrative-heading",
        actionButton(
          ns("open_woodhen_background"),
          "Woodhen background",
          icon = icon("feather"),
          class = "btn-default btn-sm"
        )
      ),
      div(
        class = "start-narrative-grid",
        div(
          class = "start-narrative-copy",
          render_markdown_content(file.path(practical2_app_dir, "content", "start.md"))
        ),
        tags$figure(
          class = "start-woodhen-figure",
          tags$img(
            src = "img/lord-howe-woodhen-family.jpg",
            alt = "Lord Howe Island woodhen with two chicks"
          ),
          tags$figcaption(
            tags$a(
              href = "https://www.lordhoweislandsignal.com.au/back-from-the-brink-lord-howe-woodhen-population-surges/",
              target = "_blank",
              rel = "noopener noreferrer",
              "Woodhen with chicks - NPWS / Liam Murphy"
            )
          )
        )
      )
    ),
    tags$section(
      class = "project-band",
      div(
        class = "section-heading-row",
        div(
          span(class = "section-eyebrow", "Investigation project"),
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
            "Import a project copy",
            accept = c(".zip", "application/zip"),
            buttonLabel = "Choose project",
            placeholder = "No project chosen"
          ),
          downloadButton(
            ns("download_project"),
            "Download project copy",
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
        `aria-label` = "Project copy"
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
          candidate = rPVA::new_woodhen_project(
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
            return(list(ok = FALSE, message = "Choose one downloaded project ZIP file."))
      }
      tryCatch(
        list(ok = TRUE, candidate = rPVA::read_woodhen_project_package(upload$datapath)),
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
        rPVA::write_woodhen_project_package(candidate, file)
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

    observeEvent(input$open_woodhen_background, {
      showModal(woodhen_background_modal())
    })

    output$project_browser_status <- renderUI({
      status <- browser_status()
      project_status_ui("Autosave in this browser", status$value, status$state, status$icon)
    })
    output$project_portable_status <- renderUI({
      status <- portable_status()
      project_status_ui("Project copy", status$value, status$state, status$icon)
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
