library(shiny)

source("session_helpers.R", local = TRUE)

catalog <- rPVA::teaching_stage_catalog()
implemented <- catalog[catalog$implemented, , drop = FALSE]
deferred <- catalog[!catalog$implemented, , drop = FALSE]

stage_choices <- stats::setNames(implemented$stage, implemented$label)
stage_questions <- c(
  deterministic_baseline = "What does a fixed life cycle do when nothing is random?",
  carrying_capacity = "How does a habitat ceiling change an otherwise favourable projection?",
  demographic_stochasticity = "How much do individual births and deaths matter in a small population?",
  environmental_stochasticity = "What happens when good and bad years affect the whole population?",
  genetic_stochasticity = "How can inbreeding and small population size compound recovery limits?",
  catastrophe = "Can rare bad years dominate risk even when ordinary years look acceptable?",
  intervention = "Does a bounded habitat improvement change risk, abundance, and uncertainty?",
  extinction_vortex = "What changes when several small-population pressures act together?"
)
stage_prompts <- c(
  deterministic_baseline = "Use this as the reference run. Later runs should be compared against it.",
  carrying_capacity = "Look for flattening trajectories and final abundance near a ceiling.",
  demographic_stochasticity = "Notice whether replicate paths stay together or spread apart.",
  environmental_stochasticity = "Focus on the uncertainty interval as well as the median.",
  genetic_stochasticity = "Check whether risk appears even when the habitat ceiling is unchanged.",
  catastrophe = "Compare extinction risk, final abundance, and uncertainty with the baseline.",
  intervention = "Ask whether abundance improves without ignoring remaining uncertainty.",
  extinction_vortex = "Use this as a warning that mechanisms can reinforce each other."
)
stage_missions <- c(
  deterministic_baseline = "Core 1: Baseline compass",
  carrying_capacity = "Core 2: Island ceiling",
  demographic_stochasticity = "Core 3: Individual chance",
  environmental_stochasticity = "Core 4: Shared bad years",
  intervention = "Core 5: Rescue attempt",
  genetic_stochasticity = "Explore: Small-population pressure",
  catastrophe = "Explore: Rare bad years",
  extinction_vortex = "Explore: Vortex comparison"
)
stage_mission_guidance <- c(
  deterministic_baseline = "Use this stage only as a recovery run after resetting comparison.",
  carrying_capacity = "Change one visible control, then compare with baseline run 1.",
  demographic_stochasticity = "Keep the habitat setting close to Mission 2 so individual chance is the main change.",
  environmental_stochasticity = "Adjust bad-year variation, then compare uncertainty with earlier runs.",
  genetic_stochasticity = "Change one small-population pressure and watch risk as well as abundance.",
  catastrophe = "Change catastrophe chance or severity, not both, before comparing risk.",
  intervention = "Treat intervention as evidence comparison with remaining uncertainty.",
  extinction_vortex = "Use this as the compounded-risk contrast for your final comparison."
)
risk_plot_stages <- c("genetic_stochasticity", "catastrophe", "extinction_vortex")

default_stage <- "deterministic_baseline"

run_stage <- function(stage, controls = list()) {
  rPVA::run_teaching_pva(stage, controls = controls, keep_traj = TRUE, seed = 42)
}

summary_metrics <- function(run) {
  summary <- run$summary
  list(
    "Scenario" = summary$scenario,
    "Years" = summary$years,
    "Extinction risk" = sprintf("%.2f", summary$PE),
    "Median final N" = summary$Nmed,
    "Uncertainty" = paste0(summary$Nlo95, "-", summary$Nhi95)
  )
}

summary_metric_ui <- function(run) {
  metrics <- summary_metrics(run)
  div(
    class = "summary-grid",
    lapply(names(metrics), function(name) {
      div(
        class = "summary-metric",
        span(class = "metric-label", name),
        span(class = "metric-value", metrics[[name]])
      )
    })
  )
}

teaching_parameter_catalog <- function() {
  data.frame(
    field = c(
      "years",
      "reps",
      "n0",
      "K",
      "K_sd",
      "demographic_stochasticity",
      "env_sd",
      "mortality_pct",
      "fecundity_pct",
      "genetics",
      "F_init",
      "cat_freq",
      "cat_surv",
      "cat_repro"
    ),
    Parameter = c(
      "Projection years",
      "Simulation futures",
      "Starting population",
      "Habitat ceiling",
      "Yearly ceiling variation",
      "Individual chance",
      "Bad-year variation",
      "Mortality change",
      "Fecundity change",
      "Genetic pressure",
      "Starting inbreeding",
      "Catastrophe chance each year",
      "Survival in catastrophe years",
      "Breeding in catastrophe years"
    ),
    Meaning = c(
      "How far ahead the model projects.",
      "How many possible futures the model runs.",
      "How many animals are present at the start.",
      "The habitat limit that caps long-term abundance.",
      "How much the habitat ceiling changes among years.",
      "Random births and deaths among individual animals.",
      "Shared good and bad years that move the whole population.",
      "A preset change to survival through mortality.",
      "A preset change to breeding output.",
      "Small-population genetic pressure.",
      "Initial inbreeding pressure at the start.",
      "How often a rare bad year occurs.",
      "How strongly survival drops in catastrophe years.",
      "How strongly breeding changes in catastrophe years."
    ),
    stringsAsFactors = FALSE
  )
}

spec_value <- function(spec, field) {
  value <- spec[[field]]
  if (is.null(value) || !length(value) || all(is.na(value))) {
    return(NA)
  }
  value
}

format_percent <- function(value) {
  paste0(round(100 * as.numeric(value)), "%")
}

format_parameter_value <- function(field, value) {
  if (length(value) == 1 && is.na(value)) {
    return("Inactive")
  }

  if (field == "n0") {
    labels <- c("juveniles", "subadults", "adults")
    values <- as.numeric(value)
    return(paste(paste(values, labels[seq_along(values)]), collapse = ", "))
  }

  if (is.logical(value)) {
    return(if (isTRUE(value)) "On" else "Off")
  }

  if (field %in% c("cat_freq", "cat_surv", "cat_repro", "F_init")) {
    return(format_percent(value))
  }

  if (field %in% c("mortality_pct", "fecundity_pct")) {
    value <- as.numeric(value)
    if (identical(value, 0)) {
      return("No change")
    }
    direction <- if (value < 0) "lower" else "higher"
    return(paste0(abs(value), "% ", direction))
  }

  if (field %in% c("K", "K_sd")) {
    return(paste0(format(round(as.numeric(value), 1), trim = TRUE), " animals"))
  }

  if (field %in% c("years", "reps")) {
    return(format(as.integer(round(as.numeric(value))), trim = TRUE))
  }

  if (is.numeric(value) && length(value) == 1) {
    return(format(round(value, 3), trim = TRUE))
  }

  paste(value, collapse = ", ")
}

same_parameter_value <- function(baseline, selected) {
  format_raw <- function(value) {
    if (length(value) == 1 && is.na(value)) {
      return("<inactive>")
    }
    paste(as.character(value), collapse = "|")
  }

  identical(format_raw(baseline), format_raw(selected))
}

parameter_change_label <- function(field, baseline, selected) {
  baseline_inactive <- length(baseline) == 1 && is.na(baseline)
  selected_inactive <- length(selected) == 1 && is.na(selected)

  if (baseline_inactive && selected_inactive) {
    return("Same as baseline")
  }

  if (baseline_inactive && !selected_inactive) {
    return("Added in this mission")
  }

  if (!baseline_inactive && selected_inactive) {
    return("Removed in this mission")
  }

  if (same_parameter_value(baseline, selected)) {
    return("Same as baseline")
  }

  if (is.logical(baseline) && is.logical(selected) && length(baseline) == 1 && length(selected) == 1) {
    return(if (isTRUE(selected)) "Turned on" else "Turned off")
  }

  if (is.numeric(baseline) && is.numeric(selected) && length(baseline) == 1 && length(selected) == 1) {
    return(if (selected > baseline) "Higher than baseline" else "Lower than baseline")
  }

  "Changed from baseline"
}

settings_for_display <- function(selected_spec, baseline_spec) {
  catalog <- teaching_parameter_catalog()

  values <- lapply(catalog$field, function(field) {
    baseline_value <- spec_value(baseline_spec, field)
    selected_value <- spec_value(selected_spec, field)
    list(
      baseline = format_parameter_value(field, baseline_value),
      selected = format_parameter_value(field, selected_value),
      change = parameter_change_label(field, baseline_value, selected_value)
    )
  })

  data.frame(
    Parameter = catalog$Parameter,
    `Baseline value` = vapply(values, `[[`, character(1), "baseline"),
    `Selected mission value` = vapply(values, `[[`, character(1), "selected"),
    `What changed` = vapply(values, `[[`, character(1), "change"),
    Meaning = catalog$Meaning,
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
}

diagnostics_ui <- function(run) {
  diagnostics <- run$diagnostics
  if (!nrow(diagnostics)) {
    return(tags$p(class = "muted", "No major diagnostic warnings for this run. Keep comparing assumptions."))
  }
  tags$ul(
    class = "diagnostic-list",
    lapply(seq_len(nrow(diagnostics)), function(i) {
      tags$li(
        class = if (identical(diagnostics$severity[[i]], "warning")) "risk-note" else NULL,
        diagnostics$message[[i]]
      )
    })
  )
}

stage_control_ui <- function(stage) {
  switch(
    stage,
    deterministic_baseline = tagList(
      sliderInput("years", "Projection years", min = 10, max = 80, value = 25, step = 5)
    ),
    carrying_capacity = tagList(
      sliderInput("K", "Habitat ceiling", min = 20, max = 120, value = 35, step = 5),
      sliderInput("K_sd", "Yearly ceiling variation", min = 0, max = 20, value = 0, step = 1)
    ),
    demographic_stochasticity = tagList(
      sliderInput("K", "Habitat ceiling", min = 20, max = 120, value = 35, step = 5),
      sliderInput("reps", "Simulation futures", min = 20, max = 200, value = 100, step = 20)
    ),
    environmental_stochasticity = tagList(
      sliderInput("env_sd", "Bad-year variation", min = 0.05, max = 0.35, value = 0.35, step = 0.05),
      sliderInput("K", "Habitat ceiling", min = 10, max = 120, value = 15, step = 5)
    ),
    genetic_stochasticity = tagList(
      sliderInput("F_init", "Starting inbreeding", min = 0, max = 0.40, value = 0.10, step = 0.05),
      sliderInput("env_sd", "Bad-year variation", min = 0.05, max = 0.35, value = 0.25, step = 0.05)
    ),
    catastrophe = tagList(
      sliderInput("cat_freq", "Catastrophe chance each year", min = 0, max = 0.20, value = 0.05, step = 0.01),
      sliderInput("cat_surv", "Survival multiplier in catastrophe years", min = 0.20, max = 1, value = 0.60, step = 0.05)
    ),
    intervention = tagList(
      sliderInput("K", "Improved habitat ceiling", min = 35, max = 160, value = 70, step = 5),
      sliderInput("K_sd", "Yearly ceiling variation", min = 0, max = 20, value = 5, step = 1)
    ),
    extinction_vortex = tagList(
      sliderInput("K", "Restricted habitat ceiling", min = 12, max = 60, value = 25, step = 2),
      sliderInput("cat_freq", "Catastrophe chance each year", min = 0, max = 0.15, value = 0.05, step = 0.01)
    )
  )
}

advanced_year_choices <- c(10, 25, 50, 100, 1000)
advanced_reps_choices <- c(10, 100, 500, 1000)
advanced_pct_choices <- c(-20, -10, -5, 0, 5, 10, 20)

advanced_pct_labels <- function() {
  c(
    "20% lower" = "-20",
    "10% lower" = "-10",
    "5% lower" = "-5",
    "No change" = "0",
    "5% higher" = "5",
    "10% higher" = "10",
    "20% higher" = "20"
  )
}

advanced_numeric_labels <- function(values) {
  stats::setNames(as.character(values), as.character(values))
}

advanced_control_aliases <- c(
  advanced_years = "years",
  advanced_reps = "reps"
)

advanced_stage_controls <- function(stage) {
  visible_controls <- visible_stage_controls(stage)
  widgets <- list()
  if (!"years" %in% visible_controls) {
    widgets <- c(
      widgets,
      list(selectInput(
        "advanced_years",
        "Projection years",
        choices = advanced_numeric_labels(advanced_year_choices),
        selected = as.character(if (identical(stage, "environmental_stochasticity")) 50 else 25)
      ))
    )
  }
  if (!"reps" %in% visible_controls) {
    widgets <- c(
      widgets,
      list(selectInput(
        "advanced_reps",
        "Simulation futures",
        choices = advanced_numeric_labels(advanced_reps_choices),
        selected = "100"
      ))
    )
  }

  div(
    class = "advanced-controls",
    h4("Advanced risk controls"),
    p(class = "muted", "Choose preset values for the time horizon, number of futures, or vital-rate sensitivity."),
    widgets,
    selectInput(
      "mortality_pct",
      "Mortality change",
      choices = advanced_pct_labels(),
      selected = "0"
    ),
    selectInput(
      "fecundity_pct",
      "Fecundity change",
      choices = advanced_pct_labels(),
      selected = "0"
    )
  )
}

visible_stage_controls <- function(stage, advanced = FALSE) {
  base <- switch(
    stage,
    deterministic_baseline = "years",
    carrying_capacity = c("K", "K_sd"),
    demographic_stochasticity = c("K", "reps"),
    environmental_stochasticity = c("env_sd", "K"),
    genetic_stochasticity = c("F_init", "env_sd"),
    catastrophe = c("cat_freq", "cat_surv"),
    intervention = c("K", "K_sd"),
    extinction_vortex = c("K", "cat_freq"),
    character()
  )

  if (isTRUE(advanced)) {
    advanced_controls <- c(
      if (!"years" %in% base) "advanced_years",
      if (!"reps" %in% base) "advanced_reps",
      "mortality_pct",
      "fecundity_pct"
    )
    return(unique(c(base, advanced_controls)))
  }

  base
}

coerce_stage_control_value <- function(value) {
  if (is.character(value) && length(value) == 1 && grepl("^-?[0-9]+(\\.[0-9]+)?$", value)) {
    return(as.numeric(value))
  }
  value
}

stage_control_values <- function(stage, input, advanced = FALSE) {
  allowed <- visible_stage_controls(stage, advanced = advanced)
  values <- list()
  for (name in allowed) {
    if (!is.null(input[[name]])) {
      if (name %in% names(advanced_control_aliases)) {
        control_name <- unname(advanced_control_aliases[[name]])
      } else {
        control_name <- name
      }
      values[[control_name]] <- coerce_stage_control_value(input[[name]])
    }
  }
  values
}

landing_card_ui <- function(image, alt, eyebrow, title, body, action = NULL, extra_class = NULL) {
  card_class <- paste(c("landing-card", extra_class), collapse = " ")

  div(
    class = card_class,
    div(
      class = "landing-visual",
      tags$img(src = image, alt = alt)
    ),
    div(
      class = "landing-card-copy",
      span(class = "landing-eyebrow", eyebrow),
      h3(title),
      p(body),
      action
    )
  )
}

mission_rail_ui <- function(current_stage, completed_stages = character()) {
  group_ui <- function(title, stages, group_class) {
    group_title <- if (identical(title, "Core")) {
      span(class = "mission-group-title", "Core")
    } else {
      span(class = "mission-group-title", "Explore Further")
    }
    div(
      class = paste("mission-group", group_class),
      group_title,
      lapply(seq_along(stages), function(index) {
        stage <- stages[[index]]
        complete <- stage %in% completed_stages
        step_class <- paste(c(
          "mission-step",
          if (identical(stage, current_stage)) "is-current",
          if (complete) "is-complete"
        ), collapse = " ")
        status <- if (complete) "Complete" else if (identical(stage, current_stage)) "Current" else "Available"

        actionLink(paste0("mission_", stage),
          label = tagList(
            span(class = "mission-step-index", if (group_class == "is-core") index else "+"),
            span(class = "mission-step-label", stage_missions[[stage]]),
            span(class = "mission-step-status", status)
          ),
          class = step_class,
          `aria-current` = if (identical(stage, current_stage)) "step" else NULL
        )
      })
    )
  }

  div(
    class = "mission-rail",
    group_ui("Core", practical1_stage_groups$core, "is-core"),
    group_ui("Explore Further", practical1_stage_groups$extension, "is-extension")
  )
}

adjacent_mission_stage <- function(stage, offset) {
  current <- match(stage, practical1_mission_order)
  if (is.na(current)) {
    return(default_stage)
  }
  practical1_mission_order[[max(1L, min(length(practical1_mission_order), current + offset))]]
}

next_mission_stage <- function(stage) adjacent_mission_stage(stage, 1L)
previous_mission_stage <- function(stage) adjacent_mission_stage(stage, -1L)

slug_text <- function(value) {
  slug <- gsub("[^a-z0-9]+", "-", tolower(value))
  slug <- gsub("(^-+|-+$)", "", slug)
  if (!nzchar(slug)) {
    return("plot")
  }
  slug
}

plot_png_filename <- function(kind, run) {
  prefix <- switch(
    kind,
    trajectory = "practical1-trajectory-",
    summary = "practical1-summary-",
    risk = "practical1-risk-",
    paste0("practical1-", slug_text(kind), "-")
  )
  paste0(prefix, slug_text(run$stage), "-", format(Sys.Date(), "%Y%m%d"), ".png")
}

write_plot_png <- function(file, plot) {
  grDevices::png(file, width = 1200, height = 800, res = 144)
  on.exit(grDevices::dev.off(), add = TRUE)
  plot()
}

trajectory_plot_for_run <- function(run) {
  rPVA::plot_pva_traj(run$result, alpha = 0.28, sample = 40, raster = FALSE)
}

summary_plot_for_run <- function(run) {
  rPVA::plot_pva_summary(run$result)
}

extinction_plot_for_run <- function(run) {
  rPVA::plot_ext(run$result)
}

run_changed_settings_label <- function(run) {
  controls <- run$settings[grepl("^control_", run$settings$setting), , drop = FALSE]
  if (!nrow(controls)) {
    return("Reference settings")
  }

  labels <- paste0(sub("^control_", "", controls$setting), " = ", controls$value)
  paste(labels, collapse = "; ")
}

evidence_choice_label <- function(run) {
  paste0(
    "Run ", session_run_id(run), " - ", run$label,
    " (", run_changed_settings_label(run), ")"
  )
}

eligible_run_choices <- function(runs, eligible_stages) {
  eligible <- Filter(function(run) run$stage %in% eligible_stages, runs)
  stats::setNames(
    vapply(eligible, session_run_id, integer(1)),
    vapply(eligible, evidence_choice_label, character(1))
  )
}

evidence_stage_category <- function(stage) {
  if (identical(stage, "deterministic_baseline")) return("Baseline")
  if (stage %in% practical1_evidence_risk_stages) return("Risk mechanism")
  if (stage %in% practical1_evidence_action_stages) return("Intervention or vortex")
  "Other"
}

session_history_ui <- function(runs, selected_risk_id, selected_action_id) {
  history_rows <- if (length(runs)) {
    lapply(runs, function(run) {
      div(
        class = "session-run-row",
        span(class = "run-number", paste("Run", session_run_id(run))),
        strong(run$label),
        span(class = "run-category", evidence_stage_category(run$stage)),
        span(class = "run-settings", run_changed_settings_label(run)),
        if (identical(run$stage, "deterministic_baseline")) {
          span(class = "run-selection-status", "Pinned in selected evidence")
        }
      )
    })
  } else {
    p(class = "muted", "No successful session runs yet. Start baseline to create run 1.")
  }

  risk_choices <- eligible_run_choices(runs, practical1_evidence_risk_stages)
  action_choices <- eligible_run_choices(runs, practical1_evidence_action_stages)
  baseline_id <- first_baseline_run_id(runs)

  div(
    class = "session-history compare-history-panel",
    h4("Full session history"),
    div(class = "session-run-list", history_rows),
    div(
      class = "evidence-selection",
      h4("Selected evidence"),
      p(
        class = "pinned-baseline",
        if (is.na(baseline_id)) {
          "Baseline missing - use Start baseline."
        } else {
          paste("Run", baseline_id, "- Baseline pinned in selected evidence")
        }
      ),
      if (length(risk_choices)) {
        radioButtons(
          "selected_risk_run_id",
          "Choose one risk mechanism",
          choices = risk_choices,
          selected = if (is.na(selected_risk_id)) NULL else as.character(selected_risk_id)
        )
      } else {
        p(class = "muted", "Run one risk-mechanism mission to make a selection.")
      },
      if (length(action_choices)) {
        radioButtons(
          "selected_action_run_id",
          "Choose one intervention or vortex run",
          choices = action_choices,
          selected = if (is.na(selected_action_id)) NULL else as.character(selected_action_id)
        )
      } else {
        p(class = "muted", "Run Rescue attempt or Vortex comparison to make a selection.")
      }
    )
  )
}

evidence_readiness_ui <- function(state) {
  labels <- c(
    baseline = "Baseline",
    risk = "Risk mechanism",
    action = "Intervention or vortex",
    exactly_three = "Exactly three runs",
    interpretation = "Interpretation",
    interpretation_current = "Current interpretation"
  )

  div(
    class = "evidence-readiness",
    h4("Evidence readiness"),
    tags$ul(
      lapply(names(state$checks), function(name) {
        ready <- isTRUE(state$checks[[name]])
        tags$li(
          class = if (ready) "readiness-check is-ready" else "readiness-check is-missing",
          strong(labels[[name]], ": "),
          if (ready) "Ready. " else "Missing. ",
          state$messages[[name]]
        )
      })
    ),
    if (isTRUE(state$checks[["interpretation"]]) &&
        !isTRUE(state$checks[["interpretation_current"]])) {
      p(class = "review-required", strong("Review required"), ": edit or reconfirm this interpretation for the selected evidence.")
    }
  )
}

comparison_empty_state_ui <- function() {
  div(
    class = "compare-empty-state",
    h4("No comparison runs yet"),
    p("Start baseline to begin comparing runs.")
  )
}

run_cards_ui <- function(runs) {
  if (!length(runs)) {
    return(comparison_empty_state_ui())
  }

  comparison <- rPVA::compare_teaching_runs(runs, include_deltas = TRUE)

  div(
    class = "run-card-grid",
    lapply(seq_along(runs), function(i) {
      row <- comparison[i, , drop = FALSE]
      div(
        class = "run-card",
        span(class = "run-card-kicker", paste("Run", session_run_id(runs[[i]]))),
        h4(runs[[i]]$label),
        p(class = "muted", run_changed_settings_label(runs[[i]])),
        div(
          class = "run-card-metrics",
          span(strong("PE"), ": ", sprintf("%.3f", row$PE)),
          span(strong("Nmed"), ": ", row$Nmed),
          span(strong("Delta PE"), ": ", sprintf("%+.3f", row$delta_PE)),
          span(strong("Delta Nmed"), ": ", sprintf("%+d", row$delta_Nmed)),
          span(strong("Uncertainty"), ": ", row$uncertainty_change)
        )
      )
    })
  )
}

pva_deep_dive_path <- file.path("content", "pva-deep-dive.md")
mission_deep_dive_path <- file.path("content", "mission-deep-dive.md")
evidence_deep_dive_path <- file.path("content", "evidence-deep-dive.md")
parameter_help_path <- file.path("content", "parameter-help.md")
output_help_path <- file.path("content", "output-reading-help.md")
diagnostic_help_path <- file.path("content", "diagnostics-help.md")
plot_help_path <- file.path("content", "plot-reading-help.md")

markdown_unavailable_ui <- function(message) {
  div(
    class = "deep-dive-modal-warning",
    p(strong("Deep-dive note unavailable")),
    p(message)
  )
}

render_markdown_content <- function(path) {
  if (!file.exists(path)) {
    return(markdown_unavailable_ui("The deep-dive note could not be found. Please tell your demonstrator."))
  }

  if (file.access(path, mode = 4) != 0) {
    return(markdown_unavailable_ui("The deep-dive note could not be read. Please tell your demonstrator."))
  }

  if (!requireNamespace("commonmark", quietly = TRUE)) {
    return(markdown_unavailable_ui("The Markdown renderer is unavailable. Please tell your demonstrator."))
  }

  tryCatch(
    {
      markdown_text <- paste(readLines(path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
      HTML(commonmark::markdown_html(markdown_text))
    },
    error = function(...) {
      markdown_unavailable_ui("The deep-dive note could not be rendered. Please tell your demonstrator.")
    }
  )
}

deep_dive_modal_ui <- function(title, path) {
  modalDialog(
    title = title,
    div(
      class = "deep-dive-modal",
      render_markdown_content(path)
    ),
    footer = modalButton("Close"),
    easyClose = TRUE,
    size = "m"
  )
}

pva_deep_dive_ui <- function() {
  deep_dive_modal_ui("What is PVA?", pva_deep_dive_path)
}

mission_deep_dive_ui <- function() {
  deep_dive_modal_ui("What you will do", mission_deep_dive_path)
}

evidence_deep_dive_ui <- function() {
  deep_dive_modal_ui("Your evidence pack", evidence_deep_dive_path)
}

parameter_help_ui <- function() {
  deep_dive_modal_ui("Control help", parameter_help_path)
}

output_help_ui <- function() {
  deep_dive_modal_ui("Read outputs", output_help_path)
}

diagnostic_help_ui <- function() {
  deep_dive_modal_ui("Read diagnostics", diagnostic_help_path)
}

plot_help_ui <- function() {
  deep_dive_modal_ui("Read plots", plot_help_path)
}

session_notice_ui <- function() {
  div(
    class = "session-notice",
    icon("clock"),
    span("This session is temporary. Download your comparison CSV and evidence notes before closing the app.")
  )
}

ui <- navbarPage(
  title = "Practical 1 PVA",
  id = "section",
  header = tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
    tags$script(src = "practical1.js")
  ),
  tabPanel(
    "Start",
    div(
      class = "page-shell",
      session_notice_ui(),
      div(
        class = "landing-hero",
        div(
          class = "landing-copy",
          span(class = "landing-eyebrow", "Practical 1: Learning PVA"),
          h1("PVA Basics"),
          p(class = "landing-lede", "PVA is a way to test how a population might change when survival, breeding, habitat, and chance interact."),
          p(class = "landing-task-text", "You will build a short chain of model runs, compare what changed, and save evidence for discussion."),
          actionButton("run_baseline", label = tagList(icon("play"), "Start baseline"), class = "btn-primary"),
          div(
            class = "mission-cue landing-start-cue",
            span(class = "mission-label", "Mission 1: Baseline compass"),
            p("Start baseline creates or restores baseline as run 1."),
            p(class = "muted", "Keep run 1 as your reference before changing controls.")
          )
        ),
        div(
          class = "landing-hero-visual",
          tags$img(
            src = "img/landing-pva-learning-futures.png",
            alt = "Population trajectories, uncertainty bands, and evidence notes arranged on an island planning desk"
          )
        )
      ),
      div(
        class = "landing-card-grid",
        landing_card_ui(
          "img/landing-trajectory-evidence.png",
          "population trajectory lines and evidence marks on a field notebook page",
          "Background",
          "What is PVA?",
          "A population viability analysis explores a set of possible futures.",
          action = actionButton(
            "open_pva_deep_dive",
            label = "Explore PVA",
            icon = icon("circle-info"),
            class = "btn-default landing-card-action",
            `aria-label` = "Explore population viability analysis"
          ),
          extra_class = "is-interactive"
        ),
        landing_card_ui(
          "img/landing-conservation-decision.png",
          "conservation decision scene with island habitat map and field notes",
          "Your mission",
          "What you will do",
          "Run the baseline, change one factor at a time, compare results, and explain the trade-offs.",
          action = actionButton(
            "open_mission_deep_dive",
            label = "Explore mission",
            icon = icon("route"),
            class = "btn-default landing-card-action",
            `aria-label` = "Explore the Practical 1 mission"
          ),
          extra_class = "is-interactive"
        ),
        div(
          class = "landing-card evidence-card is-interactive",
          div(
            class = "landing-card-copy",
            span(class = "landing-eyebrow", "Evidence to save"),
            h3("Your evidence pack"),
            tags$ul(
              tags$li("a comparison CSV from Compare;"),
              tags$li("evidence notes Markdown;"),
              tags$li("one sentence about what changed and why it matters.")
            ),
            actionButton(
              "open_evidence_deep_dive",
              label = "Explore evidence",
              icon = icon("download"),
              class = "btn-default landing-card-action",
              `aria-label` = "Explore the Practical 1 evidence pack"
            )
          )
        )
      )
    )
  ),
  tabPanel(
    "Concept Lab",
    div(
      class = "page-shell",
      div(
        class = "lab-grid",
        div(
          class = "panel-block",
          div(
            class = "panel-heading-row",
            h3("Choose one mechanism"),
            actionButton(
              "open_parameter_help",
              label = "Control help",
              icon = icon("sliders"),
              class = "btn-default btn-xs contextual-help-button",
              `aria-label` = "Open Practical 1 parameter help"
            )
          ),
          p(class = "mission-path", "Work through the mission path by changing one visible control at a time, then compare."),
          actionButton("show_intro", label = tagList(icon("circle-info"), "Introduction"), class = "btn-default btn-sm"),
          uiOutput("mission_rail"),
          uiOutput("stage_text"),
          uiOutput("stage_controls"),
          checkboxInput("show_advanced_controls", "Show advanced risk controls", value = FALSE),
          uiOutput("advanced_stage_controls"),
          div(
            class = "mission-actions",
            actionButton("previous_mission", label = tagList(icon("arrow-left"), "Previous mission"), class = "btn-default"),
            actionButton("run_stage", label = tagList(icon("play"), "Run mission"), class = "btn-primary"),
            actionButton("next_mission", label = tagList(icon("arrow-right"), "Next mission"), class = "btn-default")
          ),
          uiOutput("run_status"),
          div(class = "prompt", textOutput("stage_prompt"))
        ),
        div(
          class = "panel-block output-region",
          div(
            class = "panel-heading-row",
            h3("Current run"),
            actionButton(
              "open_output_help",
              label = "Read outputs",
              icon = icon("table"),
              class = "btn-default btn-xs contextual-help-button",
              `aria-label` = "Open Practical 1 output help"
            )
          ),
          uiOutput("summary_table"),
          div(class = "concept-help-strip", "Choose one changed input, one moved output, and one caveat."),
          div(
            class = "panel-heading-row",
            h4("Diagnostics"),
            actionButton(
              "open_diagnostic_help",
              label = "Read diagnostics",
              icon = icon("triangle-exclamation"),
              class = "btn-default btn-xs contextual-help-button",
              `aria-label` = "Open Practical 1 diagnostic help"
            )
          ),
          uiOutput("diagnostics"),
          h4("Settings record"),
          div(class = "settings-table", tableOutput("settings_table"))
        )
      ),
      div(
        class = "panel-block plot-region",
        div(
          class = "panel-heading-row",
          h3("Plots"),
          actionButton(
            "open_plot_help",
            label = "Read plots",
            icon = icon("chart-line"),
            class = "btn-default btn-xs contextual-help-button",
            `aria-label` = "Open Practical 1 plot help"
          )
        ),
        fluidRow(
          column(6, plotOutput("trajectory_plot", height = "320px")),
          column(6, plotOutput("summary_plot", height = "320px"))
        ),
        div(
          class = "plot-download-grid",
          downloadButton("download_trajectory_plot", "Trajectory PNG"),
          downloadButton("download_summary_plot", "Summary PNG"),
          uiOutput("extinction_plot_download")
        ),
        uiOutput("extinction_plot_panel")
      )
    )
  ),
  tabPanel(
    "Compare",
    div(
      class = "page-shell",
      session_notice_ui(),
      div(
        class = "compare-grid",
        div(
          class = "panel-block compare-history-panel",
          h3("Session history"),
          div(
            class = "mission-cue compare-guidance",
            span(class = "mission-label", "Compare mission evidence"),
            p("Choose a clean comparison: baseline run 1, one risk mechanism, and one intervention or vortex run."),
            p(class = "muted", "Repeated clicks are less useful than a targeted one-factor change.")
          ),
          uiOutput("session_history"),
          actionButton("clear_runs", label = tagList(icon("trash"), "Reset comparison")),
          div(class = "prompt", "The full history stays available so you can distinguish repeated attempts from selected evidence.")
        ),
        div(
          class = "panel-block compare-evidence-panel",
          h3("Selected evidence"),
          uiOutput("run_cards"),
          div(class = "compare-table", tableOutput("comparison_table")),
          uiOutput("evidence_readiness"),
          div(
            class = "interpretation-capture",
            textAreaInput("interpretation_note",
              "One-sentence interpretation",
              value = "",
              placeholder = "I changed... The output that moved was... My caveat is...",
              rows = 3
            ),
            actionButton("confirm_interpretation", "Use this interpretation", class = "btn-default")
          ),
          h4("Save evidence"),
          p(class = "muted", "Download a compact comparison table and notes for your own report. These files are evidence for your interpretation."),
          uiOutput("evidence_downloads"),
          div(class = "prompt", "What changed between runs, and which output supports your explanation?"),
          h3("Comparison habits"),
          tags$ul(
            tags$li("Compare extinction risk and abundance together."),
            tags$li("Interpret zero observed extinction with the horizon, sample size, and assumptions in view."),
            tags$li("Use uncertainty intervals when judging management actions.")
          )
        )
      )
    )
  ),
  tabPanel(
    "Transfer",
    div(
      class = "page-shell",
      session_notice_ui(),
      div(
        class = "panel-block",
        uiOutput("transfer_checklist"),
        h2("Transfer to the Woodhen practical"),
        p("You have explored deterministic growth, carrying capacity, stochasticity, catastrophes, genetics, intervention, and combined small-population risk."),
        tags$ol(
          tags$li("Which output shows extinction risk?"),
          tags$li("Which output shows abundance?"),
          tags$li("Which output shows uncertainty?")
        ),
        p("In Practical 2 you will use the same evidence habits with the Woodhen case study: compare scenarios, explain uncertainty, and make a recommendation from the model results."),
        h3("Future concepts"),
        tags$ul(
          class = "future-list",
          lapply(seq_len(nrow(deferred)), function(i) {
            tags$li(strong(deferred$label[[i]]), ": ", deferred$concept[[i]])
          })
        )
      )
    )
  )
)

make_practical1_server <- function(execute_stage = run_stage) {
  function(input, output, session) {
  session_run_id <- get("session_run_id", envir = parent.env(environment()))
  completed_stage_ids <- get("completed_stage_ids", envir = parent.env(environment()))
  reference_baseline <- run_stage(default_stage)
  baseline_run <- reactiveVal(reference_baseline)
  current_run <- reactiveVal(reference_baseline)
  run_history <- reactiveVal(list())
  next_run_id <- reactiveVal(1L)
  baseline_started <- reactiveVal(FALSE)
  selected_stage <- reactiveVal(default_stage)
  selected_risk_run_id <- reactiveVal(NA_integer_)
  selected_action_run_id <- reactiveVal(NA_integer_)
  interpretation_signature <- reactiveVal("")
  run_error <- reactiveVal(NULL)
  last_completed_stage <- reactiveVal(NULL)
  last_completed_run_id <- reactiveVal(NA_integer_)
  download_requested <- reactiveValues(comparison = FALSE, notes = FALSE)
  selected_stage_spec <- reactive({
    stage <- selected_stage()
    rPVA::build_teaching_spec(
      stage,
      controls = stage_control_values(stage, input, advanced = isTRUE(input$show_advanced_controls))
    )
  })
  evidence_export <- reactive({
    req(evidence_readiness_state()$ready)
    rPVA:::build_teaching_evidence_export(
      selected_evidence_runs(),
      interpretation = input$interpretation_note,
      session_run_count = length(run_history())
    )
  })

  selected_evidence_ids <- reactive({
    ids <- c(
      first_baseline_run_id(run_history()),
      selected_risk_run_id(),
      selected_action_run_id()
    )
    as.integer(ids[!is.na(ids)])
  })

  selected_evidence_runs <- reactive({
    select_session_runs(run_history(), selected_evidence_ids())
  })

  evidence_readiness_state <- reactive({
    evidence_readiness(
      run_history(),
      selected_evidence_ids(),
      input$interpretation_note,
      interpretation_signature(),
      baseline_started()
    )
  })

  observeEvent(run_history(), {
    risk_ids <- unname(eligible_run_choices(run_history(), practical1_evidence_risk_stages))
    action_ids <- unname(eligible_run_choices(run_history(), practical1_evidence_action_stages))
    selected_risk_run_id(if (length(risk_ids)) tail(risk_ids, 1) else NA_integer_)
    selected_action_run_id(if (length(action_ids)) tail(action_ids, 1) else NA_integer_)
  }, ignoreInit = FALSE)

  observeEvent(input$selected_risk_run_id, {
    if (!is.null(input$selected_risk_run_id) && nzchar(input$selected_risk_run_id)) {
      selected_risk_run_id(as.integer(input$selected_risk_run_id))
    }
  }, ignoreInit = TRUE)

  observeEvent(input$selected_action_run_id, {
    if (!is.null(input$selected_action_run_id) && nzchar(input$selected_action_run_id)) {
      selected_action_run_id(as.integer(input$selected_action_run_id))
    }
  }, ignoreInit = TRUE)

  observeEvent(input$interpretation_note, {
    if (nzchar(trimws(input$interpretation_note))) {
      interpretation_signature(evidence_selection_signature(selected_evidence_ids()))
    }
  }, ignoreInit = TRUE)

  observeEvent(input$confirm_interpretation, {
    req(nzchar(trimws(input$interpretation_note)))
    interpretation_signature(evidence_selection_signature(selected_evidence_ids()))
  })

  observeEvent(input$run_baseline, {
    result <- tryCatch(
      withProgress(message = "Running baseline", value = 0.5, {
        execute_stage(default_stage)
      }),
      error = function(error) error
    )

    if (inherits(result, "error")) {
      run_error("This baseline could not complete. Check the controls and try again.")
      return()
    }

    baseline <- attach_session_run_id(result, 1L)
    baseline_run(baseline)
    current_run(baseline)
    run_history(list(baseline))
    next_run_id(2L)
    baseline_started(TRUE)
    selected_risk_run_id(NA_integer_)
    selected_action_run_id(NA_integer_)
    selected_stage(default_stage)
    run_error(NULL)
    last_completed_stage(NULL)
    last_completed_run_id(NA_integer_)
    updateNavbarPage(session, "section", selected = "Concept Lab")
  })

  lapply(practical1_mission_order, function(stage) {
    local({
      stage_id <- stage
      observeEvent(input[[paste0("mission_", stage_id)]], {
        selected_stage(stage_id)
      }, ignoreInit = TRUE)
    })
  })

  observeEvent(input$show_intro, {
    updateNavbarPage(session, "section", selected = "Start")
  })

  observeEvent(input$open_pva_deep_dive, {
    showModal(pva_deep_dive_ui())
  })

  observeEvent(input$open_mission_deep_dive, {
    showModal(mission_deep_dive_ui())
  })

  observeEvent(input$open_evidence_deep_dive, {
    showModal(evidence_deep_dive_ui())
  })

  observeEvent(input$open_parameter_help, {
    showModal(parameter_help_ui())
  })

  observeEvent(input$open_output_help, {
    showModal(output_help_ui())
  })

  observeEvent(input$open_diagnostic_help, {
    showModal(diagnostic_help_ui())
  })

  observeEvent(input$open_plot_help, {
    showModal(plot_help_ui())
  })

  observeEvent(input$run_stage, {
    stage <- selected_stage()
    if (identical(stage, default_stage)) {
      updateNavbarPage(session, "section", selected = "Start")
      run_error("Use Start baseline to create baseline run 1.")
      return()
    }

    run_error(NULL)
    result <- tryCatch(
      withProgress(message = "Running mission", value = 0.5, {
        execute_stage(
          stage,
          stage_control_values(stage, input, advanced = isTRUE(input$show_advanced_controls))
        )
      }),
      error = function(error) error
    )

    if (inherits(result, "error")) {
      run_error("This mission could not complete. Check the controls and try again.")
      return()
    }

    run <- attach_session_run_id(result, next_run_id())
    next_run_id(next_run_id() + 1L)
    current_run(run)
    run_history(c(run_history(), list(run)))
    last_completed_stage(stage)
    last_completed_run_id(session_run_id(run))
  })

  observeEvent(input$next_mission, {
    selected_stage(next_mission_stage(selected_stage()))
  })

  observeEvent(input$previous_mission, {
    selected_stage(previous_mission_stage(selected_stage()))
  })

  observeEvent(input$clear_runs, {
    showModal(modalDialog(
      title = "Reset this session?",
      p("Run history, evidence selection, interpretation, and in-session progress will be cleared."),
      footer = tagList(
        modalButton("Keep my work"),
        actionButton("confirm_clear_runs", "Reset session", class = "btn-danger")
      ),
      easyClose = TRUE
    ))
  })

  observeEvent(input$confirm_clear_runs, {
    removeModal()
    reference <- run_stage(default_stage)
    baseline_run(reference)
    current_run(reference)
    run_history(list())
    next_run_id(1L)
    baseline_started(FALSE)
    selected_risk_run_id(NA_integer_)
    selected_action_run_id(NA_integer_)
    interpretation_signature("")
    download_requested$comparison <- FALSE
    download_requested$notes <- FALSE
    selected_stage(default_stage)
    run_error(NULL)
    last_completed_stage(NULL)
    last_completed_run_id(NA_integer_)
    updateTextAreaInput(session, "interpretation_note", value = "")
    updateNavbarPage(session, "section", selected = "Start")
  })

  output$run_status <- renderUI({
    error <- run_error()
    if (!is.null(error)) {
      return(div(class = "run-error", role = "alert", error))
    }

    stage <- last_completed_stage()
    if (is.null(stage)) {
      return(NULL)
    }

    next_core <- next_incomplete_core_stage(completed_stage_ids(run_history(), baseline_started()))
    next_core_message <- if (is.na(next_core)) {
      "Core route complete. Continue to Compare, or explore another mission."
    } else {
      paste("Next Core action:", stage_missions[[next_core]])
    }
    div(
      class = "mission-complete",
      `data-run-id` = last_completed_run_id(),
      strong("Mission complete: "),
      stage_missions[[stage]],
      p(class = "muted", next_core_message)
    )
  })

  output$stage_text <- renderUI({
    stage <- selected_stage()
    info <- implemented[implemented$stage == stage, , drop = FALSE]
    next_core <- next_incomplete_core_stage(completed_stage_ids(run_history(), baseline_started()))
    next_core_text <- if (is.na(next_core)) {
      "Core route complete. Continue to Compare, or explore another mission."
    } else {
      paste("Next Core action:", stage_missions[[next_core]])
    }
    tagList(
      div(class = "stage-badge", info$label[[1]]),
      div(
        class = "mission-cue",
        span(class = "mission-label", stage_missions[[stage]]),
        p(strong(stage_questions[[stage]])),
        p(class = "mission-guidance", stage_mission_guidance[[stage]])
      ),
      p(class = "mission-next-action", next_core_text),
      p(class = "muted", info$concept[[1]])
    )
  })

  output$stage_controls <- renderUI({
    stage_control_ui(selected_stage())
  })

  output$advanced_stage_controls <- renderUI({
    if (!isTRUE(input$show_advanced_controls)) {
      return(NULL)
    }
    stage <- selected_stage()
    advanced_stage_controls(stage)
  })

  output$mission_rail <- renderUI({
    stage <- selected_stage()
    completed <- completed_stage_ids(run_history(), baseline_started())
    mission_rail_ui(stage, completed)
  })

  output$stage_prompt <- renderText({
    stage_prompts[[selected_stage()]]
  })

  output$start_summary <- renderUI({
    summary_metric_ui(current_run())
  })

  output$summary_table <- renderUI({
    summary_metric_ui(current_run())
  })

  output$settings_table <- renderTable({
    settings_for_display(selected_stage_spec(), baseline_run()$spec)
  }, striped = TRUE, bordered = TRUE, spacing = "s")

  output$diagnostics <- renderUI({
    diagnostics_ui(current_run())
  })

  output$trajectory_plot <- renderPlot({
    trajectory_plot_for_run(current_run())
  })

  output$summary_plot <- renderPlot({
    summary_plot_for_run(current_run())
  })

  output$download_trajectory_plot <- downloadHandler(
    filename = function() {
      plot_png_filename("trajectory", current_run())
    },
    content = function(file) {
      write_plot_png(file, function() trajectory_plot_for_run(current_run()))
    }
  )

  output$download_summary_plot <- downloadHandler(
    filename = function() {
      plot_png_filename("summary", current_run())
    },
    content = function(file) {
      write_plot_png(file, function() summary_plot_for_run(current_run()))
    }
  )

  output$extinction_plot_download <- renderUI({
    if (!current_run()$stage %in% risk_plot_stages) {
      return(NULL)
    }
    downloadButton("download_extinction_plot", "Risk PNG")
  })

  output$extinction_plot_panel <- renderUI({
    if (!current_run()$stage %in% risk_plot_stages) {
      return(NULL)
    }
    tagList(
      h4("Risk detail"),
      plotOutput("extinction_plot", height = "300px")
    )
  })

  output$extinction_plot <- renderPlot({
    req(current_run()$stage %in% risk_plot_stages)
    extinction_plot_for_run(current_run())
  })

  output$download_extinction_plot <- downloadHandler(
    filename = function() {
      plot_png_filename("risk", current_run())
    },
    content = function(file) {
      req(current_run()$stage %in% risk_plot_stages)
      write_plot_png(file, function() extinction_plot_for_run(current_run()))
    }
  )

  output$session_history <- renderUI({
    session_history_ui(
      run_history(),
      selected_risk_run_id(),
      selected_action_run_id()
    )
  })

  output$evidence_readiness <- renderUI({
    evidence_readiness_ui(evidence_readiness_state())
  })

  output$evidence_downloads <- renderUI({
    if (!isTRUE(evidence_readiness_state()$ready)) {
      return(
        div(
          class = "export-actions evidence-downloads",
          tags$button(
            id = "download_comparison",
            type = "button",
            class = "btn btn-default",
            disabled = "disabled",
            `aria-disabled` = "true",
            "Comparison CSV"
          ),
          tags$button(
            id = "download_evidence_notes",
            type = "button",
            class = "btn btn-default",
            disabled = "disabled",
            `aria-disabled` = "true",
            "Evidence notes"
          )
        )
      )
    }

    div(
      class = "export-actions evidence-downloads",
      downloadButton("download_comparison", "Comparison CSV"),
      downloadButton("download_evidence_notes", "Evidence notes")
    )
  })

  output$comparison_table <- renderTable({
    runs <- selected_evidence_runs()
    if (!length(runs)) {
      return(NULL)
    }
    rPVA::compare_teaching_runs(runs, include_deltas = TRUE)
  }, striped = TRUE, bordered = TRUE, spacing = "s")

  output$run_cards <- renderUI({
    run_cards_ui(selected_evidence_runs())
  })

  output$download_comparison <- downloadHandler(
    filename = function() {
      paste0("practical1-comparison-", format(Sys.Date(), "%Y%m%d"), ".csv")
    },
    content = function(file) {
      utils::write.csv(evidence_export()$comparison, file, row.names = FALSE)
      download_requested$comparison <- TRUE
    }
  )

  output$download_evidence_notes <- downloadHandler(
    filename = function() {
      paste0("practical1-evidence-notes-", format(Sys.Date(), "%Y%m%d"), ".md")
    },
    content = function(file) {
      writeLines(evidence_export()$notes, file, useBytes = TRUE)
      download_requested$notes <- TRUE
    }
  )

  output$transfer_checklist <- renderUI({
    comparison_requested <- isTRUE(download_requested$comparison)
    notes_requested <- isTRUE(download_requested$notes)
    complete <- comparison_requested && notes_requested
    comparison_status <- if (comparison_requested) {
      "Comparison CSV: Download requested"
    } else {
      "Comparison CSV: Not requested yet"
    }
    notes_status <- if (notes_requested) {
      "Evidence notes: Download requested"
    } else {
      "Evidence notes: Not requested yet"
    }

    div(
      class = "transfer-checklist",
      h3("Transfer checklist"),
      tags$ul(
        tags$li(
          class = if (comparison_requested) "is-ready" else "is-missing",
          comparison_status
        ),
        tags$li(
          class = if (notes_requested) "is-ready" else "is-missing",
          notes_status
        )
      ),
      p(
        class = "muted",
        if (complete) {
          "Both evidence requests are complete. You can continue to Practical 2."
        } else {
          "Request both evidence downloads before closing this temporary session."
        }
      )
    )
  })
  }
}

server <- make_practical1_server()
shinyApp(ui, server)
