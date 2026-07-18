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
  environmental_stochasticity = "What happens when environmental conditions vary for the whole population?",
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
  environmental_stochasticity = "Core 4: Environmental variability",
  intervention = "Core 5: Rescue attempt",
  genetic_stochasticity = "Explore: Small-population pressure",
  catastrophe = "Explore: Rare bad years",
  extinction_vortex = "Explore: Vortex comparison"
)
stage_mission_guidance <- c(
  deterministic_baseline = "Rerun only after changing projection years, mortality, or fecundity; otherwise the same deterministic trajectory repeats.",
  carrying_capacity = "Change one visible control, then compare with baseline run 1.",
  demographic_stochasticity = "Keep the habitat setting close to Mission 2 so individual chance is the main change.",
  environmental_stochasticity = "Adjust environmental variation, then compare uncertainty with earlier runs.",
  genetic_stochasticity = "Change one small-population pressure and watch risk as well as abundance.",
  catastrophe = "Change catastrophe chance or severity, not both, before comparing risk.",
  intervention = "Treat intervention as evidence comparison with remaining uncertainty.",
  extinction_vortex = "Use this as the compounded-risk contrast for your final comparison."
)
default_stage <- "deterministic_baseline"

run_stage <- function(stage, controls = list(), progress = NULL) {
  rPVA::run_teaching_pva(
    stage,
    controls = controls,
    keep_traj = TRUE,
    seed = 42,
    progress = progress
  )
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
      "Environmental variation",
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
      "The combined limit for breeding, territory-holding subadults and adults; juveniles are exempt, so total population can exceed it.",
      "How much the habitat ceiling changes among years.",
      "Random births and deaths among individual animals.",
      "Shared environmental variation that produces bonanza and bust years across the whole population.",
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

working_control_value <- function(working_assumptions,
                                  name,
                                  default,
                                  min = -Inf,
                                  max = Inf,
                                  allowed = NULL) {
  value <- working_assumptions[[name]]
  if (is.null(value) || length(value) != 1L || is.na(value) || !is.finite(value)) {
    return(default)
  }
  value <- as.numeric(value)
  if (value < min || value > max || (!is.null(allowed) && !value %in% allowed)) {
    return(default)
  }
  value
}

stage_control_ui <- function(stage,
                             working_assumptions = list(),
                             stage_completed = FALSE,
                             explore_assumptions = list()) {
  intervention_assumptions <- if (isTRUE(stage_completed)) working_assumptions else list()
  switch(
    stage,
    deterministic_baseline = tagList(
      sliderInput(
        "years",
        "Projection years",
        min = 10,
        max = 80,
        value = working_control_value(working_assumptions, "years", 25, 10, 80),
        step = 5
      )
    ),
    carrying_capacity = tagList(
      sliderInput(
        "K",
        "Habitat ceiling",
        min = 20,
        max = 120,
        value = working_control_value(working_assumptions, "K", 35, 20, 120),
        step = 5
      ),
      sliderInput(
        "K_sd",
        "Yearly ceiling variation",
        min = 0,
        max = 20,
        value = working_control_value(working_assumptions, "K_sd", 0, 0, 20),
        step = 1
      )
    ),
    demographic_stochasticity = tagList(
      sliderInput(
        "K",
        "Habitat ceiling",
        min = 20,
        max = 120,
        value = working_control_value(working_assumptions, "K", 35, 20, 120),
        step = 5
      ),
      selectInput(
        "reps",
        "Simulation futures",
        choices = advanced_numeric_labels(advanced_reps_choices),
        selected = as.character(working_control_value(
          working_assumptions,
          "reps",
          100,
          allowed = advanced_reps_choices
        ))
      )
    ),
    environmental_stochasticity = tagList(
      sliderInput(
        "env_sd",
        "Environmental variation",
        min = 0.05,
        max = 0.40,
        value = working_control_value(working_assumptions, "env_sd", 0.35, 0.05, 0.40),
        step = 0.05
      ),
      sliderInput(
        "K",
        "Habitat ceiling",
        min = 10,
        max = 120,
        value = working_control_value(working_assumptions, "K", 15, 10, 120),
        step = 5
      )
    ),
    genetic_stochasticity = tagList(
      sliderInput(
        "F_init",
        "Starting inbreeding",
        min = 0,
        max = 0.40,
        value = working_control_value(explore_assumptions, "F_init", 0.10, 0, 0.40),
        step = 0.05
      )
    ),
    catastrophe = tagList(
      sliderInput(
        "cat_freq",
        "Catastrophe chance each year",
        min = 0,
        max = 0.20,
        value = working_control_value(explore_assumptions, "cat_freq", 0.05, 0, 0.20),
        step = 0.01
      ),
      sliderInput(
        "cat_surv",
        "Survival multiplier in catastrophe years",
        min = 0.20,
        max = 1,
        value = working_control_value(explore_assumptions, "cat_surv", 0.60, 0.20, 1),
        step = 0.05
      )
    ),
    intervention = tagList(
      sliderInput(
        "K",
        "Improved habitat ceiling",
        min = 35,
        max = 160,
        value = working_control_value(intervention_assumptions, "K", 70, 35, 160),
        step = 5
      ),
      sliderInput(
        "K_sd",
        "Yearly ceiling variation",
        min = 0,
        max = 20,
        value = working_control_value(intervention_assumptions, "K_sd", 5, 0, 20),
        step = 1
      )
    ),
    extinction_vortex = tagList(
      sliderInput(
        "cat_freq",
        "Catastrophe chance each year",
        min = 0,
        max = 0.20,
        value = working_control_value(explore_assumptions, "cat_freq", 0.05, 0, 0.20),
        step = 0.01
      )
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

advanced_stage_controls <- function(stage, working_assumptions = NULL) {
  visible_controls <- visible_stage_controls(stage)
  widgets <- list()
  inherited_years <- if (!is.null(working_assumptions$years)) {
    working_assumptions$years
  } else if (identical(stage, "environmental_stochasticity")) {
    50
  } else {
    25
  }
  inherited_mortality <- if (!is.null(working_assumptions$mortality_pct)) {
    working_assumptions$mortality_pct
  } else {
    0
  }
  inherited_fecundity <- if (!is.null(working_assumptions$fecundity_pct)) {
    working_assumptions$fecundity_pct
  } else {
    0
  }
  inherited_reps <- working_control_value(
    working_assumptions,
    "reps",
    100,
    allowed = advanced_reps_choices
  )
  if (!"years" %in% visible_controls) {
    year_choices <- sort(unique(c(advanced_year_choices, inherited_years)))
    widgets <- c(
      widgets,
      list(selectInput(
        "advanced_years",
        "Projection years",
        choices = advanced_numeric_labels(year_choices),
        selected = as.character(inherited_years)
      ))
    )
  }
  if (!"reps" %in% visible_controls && !identical(stage, default_stage)) {
    widgets <- c(
      widgets,
      list(selectInput(
        "advanced_reps",
        "Simulation futures",
        choices = advanced_numeric_labels(advanced_reps_choices),
        selected = as.character(inherited_reps)
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
      selected = as.character(inherited_mortality)
    ),
    selectInput(
      "fecundity_pct",
      "Fecundity change",
      choices = advanced_pct_labels(),
      selected = as.character(inherited_fecundity)
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
    genetic_stochasticity = "F_init",
    catastrophe = c("cat_freq", "cat_surv"),
    intervention = c("K", "K_sd"),
    extinction_vortex = "cat_freq",
    character()
  )

  if (isTRUE(advanced)) {
    advanced_controls <- c(
      if (!"years" %in% base) "advanced_years",
      if (!"reps" %in% base && !identical(stage, default_stage)) "advanced_reps",
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

working_assumptions_from_spec <- function(spec) {
  scalar_or <- function(value, default) {
    if (is.null(value) || !length(value) || is.na(value[[1]])) default else value[[1]]
  }

  list(
    years = as.integer(scalar_or(spec$years, 25)),
    mortality_pct = as.numeric(scalar_or(spec$mortality_pct, 0)),
    fecundity_pct = as.numeric(scalar_or(spec$fecundity_pct, 0))
  )
}

working_assumption_controls <- c(
  "years",
  "mortality_pct",
  "fecundity_pct",
  "K",
  "K_sd",
  "reps",
  "env_sd"
)

update_working_assumptions <- function(current, controls) {
  names_to_update <- working_assumption_controls[working_assumption_controls %in% names(controls)]
  utils::modifyList(current, controls[names_to_update])
}

explore_assumption_controls <- c("F_init", "cat_freq", "cat_surv", "cat_repro")

update_explore_assumptions <- function(current, controls) {
  names_to_update <- explore_assumption_controls[explore_assumption_controls %in% names(controls)]
  utils::modifyList(current, controls[names_to_update])
}

mission_control_values <- function(stage,
                                   input,
                                   advanced = FALSE,
                                   working_assumptions = list(),
                                   explore_assumptions = list()) {
  controls <- stage_control_values(stage, input, advanced = advanced)
  if (identical(stage, default_stage)) {
    return(controls)
  }
  supported <- rPVA:::teaching_control_specs(stage)$control
  inherited_source <- if (stage %in% practical1_stage_groups$extension) {
    utils::modifyList(working_assumptions, explore_assumptions)
  } else {
    working_assumptions
  }
  inherited <- inherited_source[intersect(names(inherited_source), supported)]
  utils::modifyList(inherited, controls)
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
      h2(title),
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

run_stage_action_ui <- function(stage, baseline_started) {
  if (identical(stage, default_stage)) {
    if (!isTRUE(baseline_started)) {
      return(tagAppendAttributes(
        actionButton(
          "run_stage",
          label = tagList(icon("circle-info"), "Create baseline on Start"),
          class = "btn-default"
        ),
        disabled = "disabled",
        `aria-disabled` = "true"
      ))
    }

    return(actionButton(
      "run_stage",
      label = tagList(icon("play"), "Rerun baseline"),
      class = "btn-primary"
    ))
  }

  actionButton(
    "run_stage",
    label = tagList(icon("play"), "Run mission"),
    class = "btn-primary"
  )
}

baseline_assumption_values <- function(spec) {
  unlist(working_assumptions_from_spec(spec), use.names = TRUE)
}

same_baseline_assumptions <- function(candidate_spec, previous_spec) {
  identical(
    baseline_assumption_values(candidate_spec),
    baseline_assumption_values(previous_spec)
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
    quasi_extinction = "practical1-quasi-extinction-",
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
  rPVA:::plot_extinction_timing(run$result)
}

quasi_extinction_plot_for_run <- function(run) {
  rPVA:::plot_quasi_extinction_risk(run$result, K = run$spec$K)
}

risk_plot_availability <- function(run) {
  reps <- run$result$params$reps
  K <- run$spec$K
  list(
    has_trajectories = !is.null(run$result$traj),
    multiple_futures = !is.null(reps) && is.finite(reps) && reps > 1,
    finite_K = !is.null(K) && length(K) == 1L && is.finite(K) && K > 0
  )
}

risk_plot_panel_ui <- function(run) {
  availability <- risk_plot_availability(run)
  if (!availability$has_trajectories) {
    return(div(
      class = "risk-empty-state",
      role = "note",
      h4("Risk evidence is unavailable"),
      p("This run did not retain trajectories, so risk through time cannot be reconstructed.")
    ))
  }

  if (!availability$multiple_futures) {
    return(div(
      class = "risk-empty-state",
      role = "note",
      h4("Risk needs multiple futures"),
      p("One fixed projection cannot estimate probability. Run a stochastic mission with multiple simulated futures to reveal extinction and quasi-extinction risk.")
    ))
  }

  quasi_panel <- if (availability$finite_K) {
    tagList(
      h4("Decline before extinction"),
      plotOutput("quasi_extinction_plot", height = "330px")
    )
  } else {
    div(
      class = "risk-empty-state risk-empty-state-inline",
      role = "note",
      h4("Quasi-extinction risk unavailable"),
      p("Quasi-extinction risk needs a finite habitat ceiling. This mission does not define nominal K.")
    )
  }

  div(
    class = "risk-plot-grid",
    div(
      class = "risk-plot-block",
      h4("Extinction timing"),
      plotOutput("extinction_plot", height = "330px")
    ),
    div(class = "risk-plot-block", quasi_panel)
  )
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
    " | ", run_key_settings_label(run)
  )
}

evidence_key_fields <- list(
  deterministic_baseline = c("years", "mortality_pct", "fecundity_pct"),
  carrying_capacity = c("K", "K_sd", "years"),
  demographic_stochasticity = c("K", "reps", "years"),
  environmental_stochasticity = c("env_sd", "K", "reps"),
  genetic_stochasticity = c("F_init", "K", "reps"),
  catastrophe = c("cat_freq", "cat_surv", "K"),
  intervention = c("K", "K_sd", "env_sd"),
  extinction_vortex = c("cat_freq", "F_init", "K")
)

run_key_settings <- function(run) {
  fields <- evidence_key_fields[[run$stage]]
  if (is.null(fields)) {
    return(character())
  }
  catalog <- teaching_parameter_catalog()
  fields <- fields[fields %in% catalog$field]
  stats::setNames(
    vapply(fields, function(field) {
      format_parameter_value(field, spec_value(run$spec, field))
    }, character(1)),
    catalog$Parameter[match(fields, catalog$field)]
  )
}

run_key_settings_label <- function(run) {
  settings <- run_key_settings(run)
  if (!length(settings)) {
    return("Reference settings")
  }
  paste(paste(names(settings), settings, sep = " "), collapse = "; ")
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

evidence_selection_ui <- function(runs, selected_risk_id, selected_action_id) {
  risk_choices <- eligible_run_choices(runs, practical1_evidence_risk_stages)
  action_choices <- eligible_run_choices(runs, practical1_evidence_action_stages)
  baseline_id <- first_baseline_run_id(runs)
  baseline <- if (is.na(baseline_id)) {
    NULL
  } else {
    select_session_runs(runs, baseline_id)[[1]]
  }
  selected_risk <- if (is.na(selected_risk_id)) {
    NULL
  } else {
    tryCatch(select_session_runs(runs, selected_risk_id)[[1]], error = function(...) NULL)
  }
  selected_action <- if (is.na(selected_action_id)) {
    NULL
  } else {
    tryCatch(select_session_runs(runs, selected_action_id)[[1]], error = function(...) NULL)
  }

  evidence_slot_detail <- function(run, empty_message) {
    if (is.null(run)) {
      return(p(class = "evidence-slot-empty", empty_message))
    }
    tagList(
      p(class = "evidence-slot-mission", stage_missions[[run$stage]]),
      p(class = "evidence-slot-settings", run_key_settings_label(run))
    )
  }

  div(
    class = "evidence-selection-grid",
    div(
      class = "evidence-slot evidence-slot-baseline",
      span(class = "evidence-role", "Baseline reference"),
      if (is.null(baseline)) {
        h4("Not yet available")
      } else {
        h4(paste("Run", baseline_id, "-", baseline$label))
      },
      evidence_slot_detail(baseline, "Create the baseline on Start to establish the reference.")
    ),
    div(
      class = "evidence-slot evidence-slot-risk",
      span(class = "evidence-role", "Risk mechanism"),
      if (length(risk_choices)) {
        selectInput(
          "selected_risk_run_id",
          label = NULL,
          choices = risk_choices,
          selected = if (is.na(selected_risk_id)) NULL else as.character(selected_risk_id)
        )
      } else {
        p(class = "evidence-slot-empty", "Run a risk-mechanism mission to fill this role.")
      },
      evidence_slot_detail(selected_risk, "Choose one risk-mechanism run.")
    ),
    div(
      class = "evidence-slot evidence-slot-action",
      span(class = "evidence-role", "Intervention or vortex"),
      if (length(action_choices)) {
        selectInput(
          "selected_action_run_id",
          label = NULL,
          choices = action_choices,
          selected = if (is.na(selected_action_id)) NULL else as.character(selected_action_id)
        )
      } else {
        p(class = "evidence-slot-empty", "Run Rescue attempt or Vortex comparison to fill this role.")
      },
      evidence_slot_detail(selected_action, "Choose one action or compounded-risk run.")
    )
  )
}

session_history_disclosure_ui <- function(runs) {
  if (!length(runs)) {
    return(div(
      class = "session-history-disclosure",
      p(class = "muted", "No successful session runs yet. Create the baseline run to begin.")
    ))
  }

  pinned_baseline_id <- first_baseline_run_id(runs)
  tags$details(
    class = "session-history-disclosure",
    tags$summary(paste("Review all", length(runs), "session runs")),
    div(
      class = "session-run-list",
      lapply(runs, function(run) {
        div(
          class = "session-run-row",
          span(class = "run-number", paste("Run", session_run_id(run))),
          strong(run$label),
          span(class = "run-category", evidence_stage_category(run$stage)),
          span(class = "run-settings", run_key_settings_label(run)),
          if (identical(session_run_id(run), pinned_baseline_id)) {
            span(class = "run-selection-status", "Baseline reference")
          }
        )
      })
    )
  )
}

comparison_matrix_ui <- function(runs) {
  if (length(runs) != 3L) {
    return(div(
      class = "compare-empty-state",
      h4("Complete the three evidence roles"),
      p("Select a baseline, one risk mechanism, and one intervention or vortex run.")
    ))
  }

  comparison <- rPVA::compare_teaching_runs(runs, include_deltas = TRUE)
  roles <- c("Baseline", "Risk mechanism", "Intervention or vortex")
  values <- lapply(seq_along(runs), function(i) {
    row <- comparison[i, , drop = FALSE]
    c(
      Mission = stage_missions[[runs[[i]]$stage]],
      `Key settings` = run_key_settings_label(runs[[i]]),
      `Extinction probability` = sprintf("%.1f%%", 100 * row$PE),
      `Median final abundance` = format(row$Nmed, trim = TRUE),
      `95% interval` = paste0(row$Nlo95, " to ", row$Nhi95),
      `Change in extinction probability` = if (i == 1L) {
        "Reference"
      } else {
        sprintf("%+.1f percentage points", 100 * row$delta_PE)
      },
      `Change in median abundance` = if (i == 1L) {
        "Reference"
      } else {
        sprintf("%+d", as.integer(row$delta_Nmed))
      },
      `Uncertainty change` = tools::toTitleCase(row$uncertainty_change)
    )
  })
  metric_names <- names(values[[1]])

  desktop <- tags$table(
    class = "evidence-matrix evidence-matrix-desktop",
    tags$thead(tags$tr(
      tags$th(scope = "col", "Measure"),
      lapply(seq_along(runs), function(i) {
        tags$th(
          scope = "col",
          span(class = "evidence-matrix-role", roles[[i]]),
          strong(paste("Run", session_run_id(runs[[i]]))),
          span(runs[[i]]$label)
        )
      })
    )),
    tags$tbody(lapply(metric_names, function(metric) {
      tags$tr(
        tags$th(scope = "row", metric),
        lapply(values, function(run_values) tags$td(run_values[[metric]]))
      )
    }))
  )

  mobile <- div(
    class = "evidence-matrix-mobile",
    lapply(seq_along(runs), function(i) {
      div(
        class = "evidence-matrix-card",
        span(class = "evidence-matrix-role", roles[[i]]),
        h4(paste("Run", session_run_id(runs[[i]]), "-", runs[[i]]$label)),
        tags$dl(lapply(metric_names, function(metric) {
          tagList(tags$dt(metric), tags$dd(values[[i]][[metric]]))
        }))
      )
    })
  )

  tagList(desktop, mobile)
}

observation_notebook_ui <- function(observations) {
  if (!length(observations)) {
    return(div(
      class = "notebook-empty-state",
      h4("No observations saved yet"),
      p("Choose three runs above, write what the comparison shows, then add it to the notebook.")
    ))
  }

  div(
    class = "observation-list",
    lapply(observations, function(observation) {
      comparison <- observation$comparison
      div(
        class = "observation-entry",
        div(
          class = "observation-entry-header",
          div(
            span(class = "observation-number", paste("Observation", observation$id)),
            h4(paste0(
              "Runs ", paste(observation$run_ids, collapse = ", ")
            ))
          ),
          tags$button(
            type = "button",
            class = "btn btn-default btn-sm remove-observation",
            onclick = sprintf(
              "Shiny.setInputValue('remove_observation_id', %d, {priority: 'event'});",
              observation$id
            ),
            icon("trash"),
            "Remove observation",
            `aria-label` = paste("Remove observation", observation$id)
          )
        ),
        p(class = "observation-run-labels", paste(observation$run_labels, collapse = " | ")),
        p(class = "observation-note", observation$note),
        div(
          class = "observation-metrics",
          lapply(seq_len(nrow(comparison)), function(i) {
            row <- comparison[i, , drop = FALSE]
            div(
              class = "observation-metric-row",
              strong(paste("Run", row$run_id)),
              span(paste0("PE ", sprintf("%.1f%%", 100 * row$PE))),
              span(paste0("Nmed ", row$Nmed)),
              span(paste0("95% interval ", row$Nlo95, " to ", row$Nhi95))
            )
          })
        )
      )
    })
  )
}

transfer_evidence_pack_ui <- function(runs,
                                      synthesis,
                                      observation_count,
                                      readiness,
                                      comparison_status,
                                      notes_status) {
  synthesis <- if (is.null(synthesis)) "" else trimws(as.character(synthesis))
  run_summary <- if (length(runs) == 3L) {
    div(
      class = "transfer-run-summary",
      lapply(seq_along(runs), function(i) {
        role <- c("Baseline", "Risk mechanism", "Intervention or vortex")[[i]]
        div(
          class = "transfer-run",
          span(class = "evidence-role", role),
          strong(paste("Run", session_run_id(runs[[i]]), "-", runs[[i]]$label)),
          span(run_key_settings_label(runs[[i]]))
        )
      })
    )
  } else {
    p(class = "muted", "Complete the three evidence roles on Compare.")
  }
  observation_label <- if (identical(as.integer(observation_count), 1L)) {
    "1 notebook observation"
  } else {
    paste(as.integer(observation_count), "notebook observations")
  }
  missing <- if (isTRUE(readiness$ready)) character() else names(readiness$checks)[!readiness$checks]
  downloads_current <- identical(comparison_status, "Current") && identical(notes_status, "Current")

  div(
    class = "transfer-evidence-pack",
    div(
      class = "panel-heading-row",
      h2("Your evidence pack"),
      actionButton(
        "open_transfer_evidence_help",
        label = "Evidence pack help",
        icon = icon("circle-question"),
        class = "btn-default btn-xs contextual-help-button",
        `aria-label` = "Open Practical 1 evidence pack help"
      )
    ),
    run_summary,
    div(
      class = "transfer-pack-summary",
      div(
        span(class = "transfer-summary-label", "Notebook"),
        strong(observation_label)
      ),
      div(
        span(class = "transfer-summary-label", "Final synthesis"),
        p(if (nzchar(synthesis)) synthesis else "Not yet written.")
      )
    ),
    div(
      class = "transfer-download-status",
      div(
        span("Comparison CSV"),
        strong(class = paste("artifact-status", tolower(strsplit(comparison_status, " ")[[1]][[1]])), comparison_status)
      ),
      div(
        span("Evidence notebook"),
        strong(class = paste("artifact-status", tolower(strsplit(notes_status, " ")[[1]][[1]])), notes_status)
      )
    ),
    div(
      class = if (downloads_current) {
        "transfer-completion is-ready"
      } else {
        "transfer-completion is-incomplete"
      },
      strong(if (downloads_current) "Evidence pack complete" else "Evidence pack needs a fresh download"),
      span(if (downloads_current) {
        "Both files match the current selection, notebook, and synthesis."
      } else {
        "Download both current files before closing this tab."
      })
    ),
    if (length(missing)) {
      div(
        class = "transfer-missing",
        strong("Complete on Compare:"),
        tags$ul(lapply(missing, function(name) tags$li(readiness$messages[[name]]))),
        actionButton(
          "return_to_compare",
          label = tagList(icon("arrow-left"), "Return to Compare"),
          class = "btn-default"
        )
      )
    }
  )
}

download_artifact_status <- function(ready, requested, recorded_signature, current_signature) {
  if (!isTRUE(ready)) {
    return("Unavailable")
  }
  if (!isTRUE(requested)) {
    return("Not downloaded")
  }
  if (identical(recorded_signature, current_signature)) {
    return("Current")
  }
  "Stale - download again"
}

evidence_readiness_ui <- function(state) {
  labels <- c(
    baseline = "Baseline",
    risk = "Risk mechanism",
    action = "Intervention or vortex",
    exactly_three = "Exactly three runs",
    observation = "Notebook observation",
    synthesis = "Final synthesis",
    interpretation = "Interpretation",
    interpretation_current = "Current interpretation"
  )

  if (isTRUE(state$ready)) {
    return(div(
      class = "evidence-readiness is-ready",
      strong("Evidence pack ready"),
      span("Your selected runs, notebook, and synthesis are complete.")
    ))
  }

  missing <- names(state$checks)[!state$checks]

  div(
    class = "evidence-readiness is-incomplete",
    strong("Evidence pack in progress"),
    p(class = "muted", paste(length(missing), "requirement(s) still need attention.")),
    tags$ul(
      lapply(missing, function(name) {
        tags$li(
          class = "readiness-check is-missing",
          strong(labels[[name]], ": Missing. "),
          state$messages[[name]]
        )
      })
    )
  )
}

comparison_empty_state_ui <- function() {
  div(
    class = "compare-empty-state",
    h4("No comparison runs yet"),
    p("Create the baseline run to begin comparing runs.")
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
core_explore_help_path <- file.path("content", "core-explore-help.md")
compare_selection_help_path <- file.path("content", "compare-selection-help.md")
compare_outcomes_help_path <- file.path("content", "compare-outcomes-help.md")
compare_notebook_help_path <- file.path("content", "compare-notebook-help.md")
transfer_evidence_help_path <- file.path("content", "transfer-evidence-help.md")

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

core_explore_help_ui <- function() {
  deep_dive_modal_ui("Core and Explore", core_explore_help_path)
}

compare_selection_help_ui <- function() {
  deep_dive_modal_ui("Choosing evidence", compare_selection_help_path)
}

compare_outcomes_help_ui <- function() {
  deep_dive_modal_ui("Reading the outcome matrix", compare_outcomes_help_path)
}

compare_notebook_help_ui <- function() {
  deep_dive_modal_ui("Building the notebook", compare_notebook_help_path)
}

transfer_evidence_help_ui <- function() {
  deep_dive_modal_ui("Securing the evidence pack", transfer_evidence_help_path)
}

session_notice_ui <- function() {
  div(
    class = "session-notice",
    icon("clock"),
    span("This browser session is temporary. Before you finish, use Transfer to download your current evidence pack.")
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
          p(class = "landing-lede", "PVA explores many possible population futures under explicit assumptions about survival, breeding, habitat, and chance. It is not a single forecast."),
          p(class = "landing-task-text", "Create a baseline, change one factor at a time, compare the outcomes, and save a short evidence trail."),
          actionButton("run_baseline", label = tagList(icon("play"), "Create baseline run"), class = "btn-primary"),
          div(
            class = "mission-cue landing-start-cue",
            span(class = "mission-label", "Mission 1: Build your reference"),
            p("Run 1 uses the starting assumptions. Keep it as the reference for every change that follows.")
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
          "PVA explores many possible futures under assumptions, not one prediction.",
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
            h2("Your evidence pack"),
            tags$ul(
              tags$li("a final three-run comparison;"),
              tags$li("saved notebook observations;"),
              tags$li("your final synthesis and provenance.")
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
          actionButton(
            "open_core_explore_help",
            label = tagList(icon("circle-info"), "Core and Explore"),
            class = "btn-default btn-sm",
            `aria-label` = "Open Core and Explore mission help"
          ),
          uiOutput("mission_rail"),
          uiOutput("stage_text"),
          uiOutput("stage_controls"),
          checkboxInput("show_advanced_controls", "Show advanced risk controls", value = FALSE),
          uiOutput("advanced_stage_controls"),
          div(
            class = "mission-actions",
            actionButton("previous_mission", label = tagList(icon("arrow-left"), "Previous mission"), class = "btn-default"),
            uiOutput("run_stage_action", inline = TRUE),
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
          h3("Risk evidence"),
          actionButton(
            "open_plot_help",
            label = "Read plots",
            icon = icon("chart-line"),
            class = "btn-default btn-xs contextual-help-button",
            `aria-label` = "Open Practical 1 plot help"
          )
        ),
        p(class = "muted", "Read risk first: extinction is the endpoint, while quasi-extinction reveals serious decline before zero."),
        uiOutput("risk_plot_panel"),
        uiOutput("risk_plot_downloads"),
        h3("Population projections"),
        fluidRow(
          column(6, plotOutput("trajectory_plot", height = "320px")),
          column(6, plotOutput("summary_plot", height = "320px"))
        ),
        div(
          class = "plot-download-grid",
          downloadButton("download_trajectory_plot", "Trajectory PNG"),
          downloadButton("download_summary_plot", "Summary PNG")
        )
      )
    )
  ),
  tabPanel(
    "Compare",
    div(
      class = "page-shell",
      session_notice_ui(),
      div(
        class = "compare-workspace",
        div(
          class = "compare-workspace-header",
          span(class = "landing-eyebrow", "Evidence workspace"),
          h2("Reason from evidence"),
          p("Choose one reference, one risk mechanism, and one intervention or vortex run. Then read risk, abundance, and uncertainty together.")
        ),
        div(
          class = "evidence-workspace-section",
          div(
            class = "panel-heading-row",
            h3("1. Choose evidence"),
            actionButton(
              "open_compare_selection_help",
              label = "Selection help",
              icon = icon("circle-question"),
              class = "btn-default btn-xs contextual-help-button",
              `aria-label` = "Open Practical 1 evidence selection help"
            )
          ),
          p(class = "muted", "The baseline remains fixed. Change the other two selectors to answer a focused comparison question."),
          uiOutput("evidence_selection")
        ),
        div(
          class = "evidence-workspace-section",
          div(
            class = "panel-heading-row",
            h3("2. Compare outcomes"),
            actionButton(
              "open_compare_outcomes_help",
              label = "Read outcomes",
              icon = icon("circle-question"),
              class = "btn-default btn-xs contextual-help-button",
              `aria-label` = "Open Practical 1 comparison outcome help"
            )
          ),
          p(class = "muted", "Use the baseline-relative rows to separate a change in risk from a change in final abundance or uncertainty."),
          uiOutput("comparison_matrix")
        ),
        div(
          class = "evidence-workspace-section evidence-notebook-section",
          div(
            class = "panel-heading-row",
            h3("3. Build your notebook"),
            actionButton(
              "open_compare_notebook_help",
              label = "Notebook help",
              icon = icon("circle-question"),
              class = "btn-default btn-xs contextual-help-button",
              `aria-label` = "Open Practical 1 evidence notebook help"
            )
          ),
          p(class = "muted", "Save a short observation against the three runs currently selected. Later selections do not rewrite earlier observations."),
          div(
            class = "observation-composer",
            textAreaInput("observation_draft",
              "Evidence observation",
              value = "",
              placeholder = "The risk mechanism changed... The evidence is... A caveat is...",
              rows = 3
            ),
            uiOutput("draft_selection_warning"),
            actionButton(
              "add_observation",
              label = tagList(icon("plus"), "Add to notebook"),
              class = "btn-primary"
            )
          ),
          uiOutput("evidence_notebook")
        ),
        div(
          class = "evidence-workspace-section evidence-synthesis-section",
          h3("4. Write a final synthesis"),
          p(class = "muted", "In two or three sentences, state the pattern across your strongest comparisons and one important limit on the recommendation."),
          textAreaInput(
            "final_synthesis",
            "Final synthesis",
            value = "",
            placeholder = "Across these comparisons... This supports... However...",
            rows = 4
          ),
          uiOutput("evidence_readiness"),
          actionButton(
            "review_evidence_pack",
            label = tagList(icon("arrow-right"), "Review evidence pack"),
            class = "btn-primary"
          )
        ),
        div(
          class = "evidence-workspace-section evidence-history-section",
          h3("Session history"),
          p(class = "muted", "Open this only when you need to audit another attempt or change the selected evidence."),
          uiOutput("session_history"),
          actionButton("clear_runs", label = tagList(icon("trash"), "Reset comparison"), class = "btn-default")
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
        class = "transfer-workspace",
        div(
          class = "transfer-workspace-section",
          uiOutput("transfer_evidence_pack"),
          uiOutput("evidence_downloads")
        ),
        div(
          class = "transfer-workspace-section",
          h2("What you practised"),
          p("You used a guided model to build evidence habits that travel beyond this exercise."),
          tags$ul(
            class = "transfer-practice-list",
            tags$li("Change assumptions deliberately."),
            tags$li("Retain a reference case."),
            tags$li("Compare risk, abundance, and uncertainty together."),
            tags$li("Record evidence promptly."),
            tags$li("Separate results, inference, and caveats.")
          )
        ),
        div(
          class = "transfer-workspace-section transfer-bridge",
          h2("From guided comparison to independent investigation"),
          p("This notebook is unassessed practice. In Practical 2, the same evidence habits will support your individual Woodhen investigation and the report worth 25% of the unit."),
          p("You will frame a question, construct scenarios, test sensitivity to uncertain assumptions, choose comparisons that answer your question, and build your own reproducible argument."),
          tags$ol(
            class = "research-cycle",
            lapply(
              c("Question", "Scenario", "Simulation", "Comparison", "Evidence note", "Synthesis"),
              function(stage) tags$li(stage)
            )
          )
        ),
        div(
          class = "transfer-workspace-section transfer-final-cue",
          strong("Before closing this tab"),
          span("Confirm both evidence files above are Current.")
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
  working_assumptions <- reactiveVal(working_assumptions_from_spec(reference_baseline$spec))
  explore_assumptions <- reactiveVal(list())
  run_history <- reactiveVal(list())
  next_run_id <- reactiveVal(1L)
  baseline_started <- reactiveVal(FALSE)
  selected_stage <- reactiveVal(default_stage)
  selected_risk_run_id <- reactiveVal(NA_integer_)
  selected_action_run_id <- reactiveVal(NA_integer_)
  evidence_notebook <- reactiveVal(list())
  next_observation_id <- reactiveVal(1L)
  draft_selection_signature <- reactiveVal("")
  pending_remove_observation_id <- reactiveVal(NA_integer_)
  run_error <- reactiveVal(NULL)
  last_completed_stage <- reactiveVal(NULL)
  last_completed_run_id <- reactiveVal(NA_integer_)
  download_requested <- reactiveValues(comparison = FALSE, notes = FALSE)
  download_recorded_signatures <- reactiveValues(comparison = "", notes = "")
  execute_with_progress <- function(stage, controls = list(), progress = NULL) {
    execute_formals <- names(formals(execute_stage))
    arguments <- list(stage = stage, controls = controls)
    if ("progress" %in% execute_formals || "..." %in% execute_formals) {
      arguments$progress <- progress
    }
    do.call(execute_stage, arguments)
  }
  run_with_progress <- function(message, stage, controls = list()) {
    withProgress(message = message, value = 0.05, {
      setProgress(0.05, detail = "Preparing model")
      callback <- function(completed, total) {
        setProgress(
          0.05 + 0.88 * completed / total,
          detail = paste("Simulating future", completed, "of", total)
        )
      }
      result <- execute_with_progress(stage, controls, callback)
      setProgress(0.97, detail = "Preparing evidence")
      result
    })
  }
  selected_stage_spec <- reactive({
    stage <- selected_stage()
    rPVA::build_teaching_spec(
      stage,
      controls = mission_control_values(
        stage,
        input,
        advanced = isTRUE(input$show_advanced_controls),
        working_assumptions = working_assumptions(),
        explore_assumptions = explore_assumptions()
      )
    )
  })
  evidence_export <- reactive({
    req(evidence_readiness_state()$ready)
    rPVA:::build_teaching_evidence_export(
      selected_evidence_runs(),
      session_run_count = length(run_history()),
      observations = evidence_notebook(),
      synthesis = input$final_synthesis
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

  current_export_signature <- reactive({
    evidence_pack_signature(
      selected_evidence_ids(),
      evidence_notebook(),
      input$final_synthesis
    )
  })

  evidence_readiness_state <- reactive({
    evidence_readiness(
      run_history(),
      selected_evidence_ids(),
      baseline_started = baseline_started(),
      observations = evidence_notebook(),
      synthesis = input$final_synthesis
    )
  })

  draft_selection_changed <- reactive({
    draft <- input$observation_draft
    if (is.null(draft) || !nzchar(trimws(draft)) || !nzchar(draft_selection_signature())) {
      return(FALSE)
    }
    !identical(
      draft_selection_signature(),
      evidence_selection_signature(selected_evidence_ids())
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

  observeEvent(input$observation_draft, {
    draft <- input$observation_draft
    if (is.null(draft) || !nzchar(trimws(draft))) {
      draft_selection_signature("")
    } else if (!nzchar(draft_selection_signature())) {
      draft_selection_signature(evidence_selection_signature(selected_evidence_ids()))
    }
  }, ignoreInit = TRUE)

  observeEvent(list(selected_evidence_ids(), evidence_notebook(), input$final_synthesis), {
    download_recorded_signatures$comparison <- ""
    download_recorded_signatures$notes <- ""
  }, ignoreInit = TRUE)

  observeEvent(input$add_observation, {
    note <- input$observation_draft
    if (is.null(note) || !nzchar(trimws(note))) {
      showNotification("Write an evidence observation before adding it.", type = "warning")
      return()
    }
    runs <- tryCatch(selected_evidence_runs(), error = function(...) list())
    if (length(runs) != 3L) {
      showNotification("Select all three evidence roles before adding an observation.", type = "warning")
      return()
    }
    observation <- rPVA:::build_teaching_observation(
      runs,
      observation_id = next_observation_id(),
      note = note
    )
    evidence_notebook(c(evidence_notebook(), list(observation)))
    next_observation_id(next_observation_id() + 1L)
    draft_selection_signature("")
    updateTextAreaInput(session, "observation_draft", value = "")
  })

  observeEvent(input$remove_observation_id, {
    observation_id <- suppressWarnings(as.integer(input$remove_observation_id))
    ids <- vapply(evidence_notebook(), `[[`, integer(1), "id")
    if (is.na(observation_id) || !observation_id %in% ids) {
      return()
    }
    pending_remove_observation_id(observation_id)
    showModal(modalDialog(
      title = paste("Remove observation", observation_id, "?"),
      p("This removes the saved note and its metric snapshot. Run history is unchanged."),
      footer = tagList(
        modalButton("Keep observation"),
        actionButton("confirm_remove_observation", "Remove observation", class = "btn-danger")
      ),
      easyClose = TRUE
    ))
  }, ignoreInit = TRUE)

  observeEvent(input$confirm_remove_observation, {
    observation_id <- pending_remove_observation_id()
    req(!is.na(observation_id))
    evidence_notebook(remove_evidence_observation(evidence_notebook(), observation_id))
    pending_remove_observation_id(NA_integer_)
    removeModal()
  })

  observeEvent(input$run_baseline, {
    if (isTRUE(baseline_started())) {
      current_run(baseline_run())
      selected_stage(default_stage)
      run_error(NULL)
      updateNavbarPage(session, "section", selected = "Concept Lab")
      return()
    }

    result <- tryCatch(
      run_with_progress("Running baseline", default_stage),
      error = function(error) error
    )

    if (inherits(result, "error")) {
      run_error("This baseline could not complete. Check the controls and try again.")
      return()
    }

    baseline <- attach_session_run_id(result, 1L)
    baseline_run(baseline)
    current_run(baseline)
    working_assumptions(working_assumptions_from_spec(baseline$spec))
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

  observeEvent(input$open_core_explore_help, {
    showModal(core_explore_help_ui())
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

  observeEvent(input$open_compare_selection_help, {
    showModal(compare_selection_help_ui())
  })

  observeEvent(input$open_compare_outcomes_help, {
    showModal(compare_outcomes_help_ui())
  })

  observeEvent(input$open_compare_notebook_help, {
    showModal(compare_notebook_help_ui())
  })

  observeEvent(input$open_transfer_evidence_help, {
    showModal(transfer_evidence_help_ui())
  })

  observeEvent(input$run_stage, {
    stage <- selected_stage()
    controls <- mission_control_values(
      stage,
      input,
      advanced = isTRUE(input$show_advanced_controls),
      working_assumptions = working_assumptions(),
      explore_assumptions = explore_assumptions()
    )
    if (identical(stage, default_stage)) {
      if (!isTRUE(baseline_started())) {
        run_error("Create the baseline run on Start before running missions.")
        return()
      }

      candidate_spec <- tryCatch(
        rPVA::build_teaching_spec(stage, controls = controls),
        error = function(error) error
      )
      if (inherits(candidate_spec, "error")) {
        run_error("This baseline could not complete. Check the controls and try again.")
        return()
      }

      baseline_runs <- Filter(function(run) identical(run$stage, default_stage), run_history())
      previous_baseline <- baseline_runs[[length(baseline_runs)]]
      if (same_baseline_assumptions(candidate_spec, previous_baseline$spec)) {
        run_error(paste(
          "Nothing changed. A deterministic run repeats the same population trajectory",
          "unless projection years, mortality, or fecundity changes."
        ))
        return()
      }
    }

    run_error(NULL)
    result <- tryCatch(
      run_with_progress("Running mission", stage, controls),
      error = function(error) error
    )

    if (inherits(result, "error")) {
      run_error("This mission could not complete. Check the controls and try again.")
      return()
    }

    run <- attach_session_run_id(result, next_run_id())
    if (stage %in% practical1_stage_groups$core) {
      working_assumptions(update_working_assumptions(working_assumptions(), controls))
    }
    if (stage %in% practical1_stage_groups$extension) {
      explore_assumptions(update_explore_assumptions(explore_assumptions(), controls))
    }
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
      p("Run history, evidence selection, notebook observations, synthesis, and in-session progress will be cleared."),
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
    working_assumptions(working_assumptions_from_spec(reference$spec))
    explore_assumptions(list())
    run_history(list())
    next_run_id(1L)
    baseline_started(FALSE)
    selected_risk_run_id(NA_integer_)
    selected_action_run_id(NA_integer_)
    evidence_notebook(list())
    next_observation_id(1L)
    draft_selection_signature("")
    pending_remove_observation_id(NA_integer_)
    download_requested$comparison <- FALSE
    download_requested$notes <- FALSE
    download_recorded_signatures$comparison <- ""
    download_recorded_signatures$notes <- ""
    selected_stage(default_stage)
    run_error(NULL)
    last_completed_stage(NULL)
    last_completed_run_id(NA_integer_)
    updateTextAreaInput(session, "observation_draft", value = "")
    updateTextAreaInput(session, "final_synthesis", value = "")
    updateNavbarPage(session, "section", selected = "Start")
  })

  observeEvent(input$review_evidence_pack, {
    updateNavbarPage(session, "section", selected = "Transfer")
  })

  observeEvent(input$return_to_compare, {
    updateNavbarPage(session, "section", selected = "Compare")
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

  output$run_stage_action <- renderUI({
    run_stage_action_ui(selected_stage(), baseline_started())
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
    stage <- selected_stage()
    completed <- completed_stage_ids(run_history(), baseline_started())
    stage_control_ui(
      stage,
      working_assumptions(),
      stage %in% completed,
      explore_assumptions()
    )
  })

  output$advanced_stage_controls <- renderUI({
    if (!isTRUE(input$show_advanced_controls)) {
      return(NULL)
    }
    stage <- selected_stage()
    advanced_stage_controls(stage, working_assumptions())
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

  output$risk_plot_panel <- renderUI({
    risk_plot_panel_ui(current_run())
  })

  output$risk_plot_downloads <- renderUI({
    availability <- risk_plot_availability(current_run())
    if (!availability$has_trajectories || !availability$multiple_futures) {
      return(NULL)
    }
    div(
      class = "plot-download-grid risk-download-grid",
      downloadButton("download_extinction_plot", "Extinction risk PNG"),
      if (availability$finite_K) {
        downloadButton("download_quasi_extinction_plot", "Quasi-extinction PNG")
      }
    )
  })

  output$extinction_plot <- renderPlot({
    availability <- risk_plot_availability(current_run())
    req(availability$has_trajectories, availability$multiple_futures)
    extinction_plot_for_run(current_run())
  })

  output$quasi_extinction_plot <- renderPlot({
    availability <- risk_plot_availability(current_run())
    req(
      availability$has_trajectories,
      availability$multiple_futures,
      availability$finite_K
    )
    quasi_extinction_plot_for_run(current_run())
  })

  output$download_extinction_plot <- downloadHandler(
    filename = function() {
      plot_png_filename("risk", current_run())
    },
    content = function(file) {
      availability <- risk_plot_availability(current_run())
      req(availability$has_trajectories, availability$multiple_futures)
      write_plot_png(file, function() extinction_plot_for_run(current_run()))
    }
  )

  output$download_quasi_extinction_plot <- downloadHandler(
    filename = function() {
      plot_png_filename("quasi_extinction", current_run())
    },
    content = function(file) {
      availability <- risk_plot_availability(current_run())
      req(
        availability$has_trajectories,
        availability$multiple_futures,
        availability$finite_K
      )
      write_plot_png(file, function() quasi_extinction_plot_for_run(current_run()))
    }
  )

  output$session_history <- renderUI({
    session_history_disclosure_ui(run_history())
  })

  output$evidence_selection <- renderUI({
    evidence_selection_ui(
      run_history(),
      selected_risk_run_id(),
      selected_action_run_id()
    )
  })

  output$comparison_matrix <- renderUI({
    comparison_matrix_ui(selected_evidence_runs())
  })

  output$draft_selection_warning <- renderUI({
    if (!isTRUE(draft_selection_changed())) {
      return(NULL)
    }
    div(
      class = "draft-selection-warning",
      role = "alert",
      icon("triangle-exclamation"),
      span("Your evidence selection changed. Review this draft before adding it to the notebook.")
    )
  })

  output$evidence_notebook <- renderUI({
    observation_notebook_ui(evidence_notebook())
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
            "Evidence notebook"
          )
        )
      )
    }

    div(
      class = "export-actions evidence-downloads",
      downloadButton("download_comparison", "Comparison CSV"),
      downloadButton("download_evidence_notes", "Evidence notebook")
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
      export <- evidence_export()
      signature <- current_export_signature()
      utils::write.csv(export$comparison, file, row.names = FALSE)
      download_recorded_signatures$comparison <- signature
      download_requested$comparison <- TRUE
    }
  )

  output$download_evidence_notes <- downloadHandler(
    filename = function() {
      paste0("practical1-evidence-notes-", format(Sys.Date(), "%Y%m%d"), ".md")
    },
    content = function(file) {
      export <- evidence_export()
      signature <- current_export_signature()
      writeLines(export$notes, file, useBytes = TRUE)
      download_recorded_signatures$notes <- signature
      download_requested$notes <- TRUE
    }
  )

  transfer_evidence_ui <- reactive({
    signature <- current_export_signature()
    ready <- evidence_readiness_state()$ready
    transfer_evidence_pack_ui(
      runs = selected_evidence_runs(),
      synthesis = input$final_synthesis,
      observation_count = length(evidence_notebook()),
      readiness = evidence_readiness_state(),
      comparison_status = download_artifact_status(
        ready,
        download_requested$comparison,
        download_recorded_signatures$comparison,
        signature
      ),
      notes_status = download_artifact_status(
        ready,
        download_requested$notes,
        download_recorded_signatures$notes,
        signature
      )
    )
  })

  output$transfer_evidence_pack <- renderUI({
    transfer_evidence_ui()
  })

  output$transfer_checklist <- renderUI({
    transfer_evidence_ui()
  })
  }
}

server <- make_practical1_server()
shinyApp(ui, server)
