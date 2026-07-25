investigate_or <- function(value, default) {
  if (is.null(value) || length(value) == 0L) default else value
}

investigate_catalog_row <- function(catalog, id, label) {
  row <- catalog[catalog$id == id, , drop = FALSE]
  if (nrow(row) != 1L) {
    stop("Choose one valid ", label, ".", call. = FALSE)
  }
  row
}

investigate_control_step <- function(range) {
  if (range[["max"]] > 2) 1 else 0.01
}

investigate_choice_value <- function(choice, custom, row, label) {
  if (!is.character(choice) || length(choice) != 1L || is.na(choice)) {
    stop("Choose one ", label, " setting.", call. = FALSE)
  }
  value <- if (identical(choice, "custom")) custom else choice
  rPVA:::woodhen_resolve_bounded_value(value, row, label = label)
}

investigate_sensitivity_values <- function(factor_id,
                                           first_choice,
                                           second_choice,
                                           first_custom,
                                           second_custom) {
  row <- investigate_catalog_row(
    rPVA::woodhen_sensitivity_catalog(), factor_id, "sensitivity factor"
  )
  values <- c(
    investigate_choice_value(first_choice, first_custom, row, "first altered setting"),
    investigate_choice_value(second_choice, second_custom, row, "second altered setting")
  )
  baseline <- row$locked_baseline[[1L]]
  if (any(values == baseline)) {
    stop(
      "Alternative settings must differ from the current no-change assumption.",
      call. = FALSE
    )
  }
  if (anyDuplicated(values)) {
    stop("Choose two different alternative settings.", call. = FALSE)
  }
  if (values[[1L]] <= baseline) {
    stop(
      "Alternative 1 must be higher than the current no-change assumption.",
      call. = FALSE
    )
  }
  if (values[[2L]] >= baseline) {
    stop(
      "Alternative 2 must be lower than the current no-change assumption.",
      call. = FALSE
    )
  }
  rPVA::build_woodhen_sensitivity_family(factor_id, values, seed = 123L)
  values
}

investigate_sensitivity_factor_choices <- function() {
  catalog <- rPVA::woodhen_sensitivity_catalog()
  stats::setNames(catalog$id, catalog$label)
}

investigate_sensitivity_factor_model <- function(factor_id) {
  row <- investigate_catalog_row(
    rPVA::woodhen_sensitivity_catalog(), factor_id, "sensitivity factor"
  )
  effective_range <- row$custom_range[[1L]]
  if (identical(factor_id, "K_sd")) {
    effective_range[["max"]] <- min(
      effective_range[["max"]],
      floor(rPVA::woodhen_locked_future_spec()$K / 3)
    )
  }
  copy <- switch(
    factor_id,
    K = list(
      question = "How strongly does future Woodhen status depend on breeding habitat?",
      intro = paste(
        "Compare the current breeding-territory ceiling with one higher and one",
        "lower setting, then ask whether the conservation outlook changes."
      ),
      what_changes = "Only the ceiling on territory-holding breeding pairs.",
      input_label = "Breeding territories",
      unit_label = "breeding territories",
      x_label = "Breeding-territory capacity",
      research_placeholder = paste(
        "How does breeding-territory capacity affect projected abundance and",
        "the chance of falling below 100 breeding pairs?"
      ),
      direction_placeholder = paste(
        "Predict how more or less breeding habitat could change abundance or",
        "100-pair warning risk, and explain the ecological link."
      )
    ),
    surv = list(
      question = "Are conclusions robust to uncertainty in survival at every life stage?",
      intro = paste(
        "Apply one common multiplier to survival at every model stage while",
        "holding habitat, reproduction and stochastic settings fixed."
      ),
      what_changes = "Only the common multiplier applied to survival at every stage.",
      input_label = "All-stage survival multiplier",
      unit_label = "proportion of locked survival",
      x_label = "All-stage survival multiplier",
      research_placeholder = paste(
        "How does a broad change in survival across all stages affect abundance",
        "and the chance of falling below 100 breeding pairs?"
      ),
      direction_placeholder = paste(
        "Predict how higher or lower all-stage survival could change abundance",
        "or risk, without assigning the change to a particular stressor."
      )
    ),
    juvenile_surv = list(
      question = "How strongly do early survival assumptions shape the outlook?",
      intro = paste(
        "Change survival for stages 1 and 2 only; survival at later stages",
        "remains at the common-future setting."
      ),
      what_changes = "Only the survival multiplier for model stages 1 and 2.",
      input_label = "Juvenile survival multiplier",
      unit_label = "proportion of locked juvenile survival",
      x_label = "Juvenile survival multiplier",
      research_placeholder = paste(
        "How does juvenile survival at stages 1 and 2 affect projected",
        "abundance and 100-pair warning risk?"
      ),
      direction_placeholder = paste(
        "Predict how higher or lower early-life survival could alter recruitment,",
        "abundance or risk while later survival stays fixed."
      )
    ),
    fecund = list(
      question = "How strongly does breeding output shape long-run recovery confidence?",
      intro = paste(
        "Apply one common multiplier to age-specific breeding output while",
        "holding survival, habitat and stochastic settings fixed."
      ),
      what_changes = "Only the common multiplier applied to breeding output.",
      input_label = "Fecundity multiplier",
      unit_label = "proportion of locked breeding output",
      x_label = "Fecundity multiplier",
      research_placeholder = paste(
        "How does age-specific breeding output affect projected abundance and",
        "the chance of falling below 100 breeding pairs?"
      ),
      direction_placeholder = paste(
        "Predict how higher or lower breeding output could alter recruitment,",
        "abundance or risk across the 75-year future."
      )
    ),
    cat_freq = list(
      question = "How sensitive is the outlook to the frequency of catastrophe years?",
      intro = paste(
        "Change the annual chance of a modelled catastrophe while holding its",
        "survival and breeding-output effects fixed."
      ),
      what_changes = "Only the annual probability that a catastrophe occurs.",
      input_label = "Annual catastrophe probability",
      unit_label = "annual probability",
      x_label = "Annual catastrophe probability",
      research_placeholder = paste(
        "How does the annual chance of catastrophe affect projected abundance",
        "and the chance of falling below 100 breeding pairs?"
      ),
      direction_placeholder = paste(
        "Predict how more or fewer catastrophe years could alter abundance or",
        "risk while event severity stays fixed."
      )
    ),
    cat_surv = list(
      question = "How sensitive is the outlook to survival during catastrophe years?",
      intro = paste(
        "Change the survival multiplier applied in catastrophe years while",
        "holding event frequency and breeding-output effects fixed."
      ),
      what_changes = "Only the all-stage survival multiplier in catastrophe years.",
      input_label = "Catastrophe survival multiplier",
      unit_label = "event-year survival multiplier",
      x_label = "Catastrophe-year survival multiplier",
      research_placeholder = paste(
        "How does catastrophe-year survival affect projected abundance and the",
        "chance of falling below 100 breeding pairs?"
      ),
      direction_placeholder = paste(
        "Predict how more severe event-year survival loss could alter abundance",
        "or risk while catastrophe frequency stays fixed."
      )
    ),
    env_sd = list(
      question = "How sensitive are conclusions to environmental variability?",
      intro = paste(
        "Change the annual variability used for survival and fecundity draws",
        "while their central settings and habitat assumptions remain fixed."
      ),
      what_changes = "Only the scale of annual environmental variability.",
      input_label = "Environmental variability",
      unit_label = "variability scale",
      x_label = "Environmental variability scale",
      research_placeholder = paste(
        "How does environmental variability affect median outcomes, uncertainty",
        "and the chance of falling below 100 breeding pairs?"
      ),
      direction_placeholder = paste(
        "Predict whether greater year-to-year variability changes central",
        "outcomes, the spread of futures, warning risk, or all three."
      )
    ),
    K_sd = list(
      question = "How sensitive are conclusions to year-to-year habitat-capacity variation?",
      intro = paste(
        "Change annual variation around the same mean breeding-territory",
        "capacity while all vital rates remain fixed."
      ),
      what_changes = "Only annual variation around mean breeding-territory capacity.",
      input_label = "Capacity standard deviation",
      unit_label = "territories (standard deviation)",
      x_label = "Habitat-capacity standard deviation",
      research_placeholder = paste(
        "How does annual variation around mean habitat capacity affect abundance,",
        "uncertainty and the chance of falling below 100 breeding pairs?"
      ),
      direction_placeholder = paste(
        "Predict whether wider capacity variation changes central outcomes,",
        "the spread of futures or warning risk."
      )
    )
  )
  list(
    factor_id = factor_id,
    label = row$label[[1L]],
    baseline = row$locked_baseline[[1L]],
    defaults = unname(row$anchors[[1L]][c("higher", "lower")]),
    range = effective_range,
    question = copy$question,
    intro = copy$intro,
    what_changes = copy$what_changes,
    meaning = row$biological_meaning[[1L]],
    boundary = row$limitation[[1L]],
    input_label = copy$input_label,
    unit_label = copy$unit_label,
    x_label = copy$x_label,
    plot_title = paste(row$label[[1L]], "and future outcomes"),
    research_placeholder = copy$research_placeholder,
    direction_placeholder = copy$direction_placeholder
  )
}

investigate_sensitivity_format_value <- function(model, value) {
  vapply(as.numeric(value), function(candidate) {
    switch(
      model$factor_id,
      K = paste0(investigate_format_number(candidate, 0L), " breeding territories"),
      surv = paste0(investigate_format_percent_value(candidate), " of locked survival"),
      juvenile_surv = paste0(
        investigate_format_percent_value(candidate), " of locked juvenile survival"
      ),
      fecund = paste0(
        investigate_format_percent_value(candidate), " of locked breeding output"
      ),
      cat_freq = paste0(
        investigate_format_percent_value(candidate), " annual probability"
      ),
      cat_surv = paste0(
        investigate_format_percent_value(candidate), " event-year survival multiplier"
      ),
      env_sd = paste0(
        investigate_format_number(candidate, 2L), " variability scale"
      ),
      K_sd = paste0(
        investigate_format_number(candidate, 0L), " territories standard deviation"
      )
    )
  }, character(1))
}

investigate_sensitivity_axis_labels <- function(model) {
  if (model$factor_id %in% c(
      "surv", "juvenile_surv", "fecund", "cat_freq", "cat_surv"
    )) {
    return(function(values) investigate_format_percent_value(values))
  }
  digits <- if (identical(model$factor_id, "env_sd")) 2L else 0L
  function(values) investigate_format_number(values, digits)
}

investigate_compatible_interventions <- function(threat_id) {
  investigate_catalog_row(rPVA::woodhen_threat_catalog(), threat_id, "threat")
  if (identical(threat_id, "increased_cyclone_pressure")) {
    return("emergency_response")
  }
  catalog <- rPVA::woodhen_intervention_catalog()
  compatible <- vapply(catalog$id, function(intervention_id) {
    config <- list(list(
      intervention_id = intervention_id,
      intensity = "moderate"
    ))
    names(config) <- "management"
    !inherits(try(
      rPVA::build_woodhen_prospective_family(threat_id, config, seed = 123L),
      silent = TRUE
    ), "try-error")
  }, logical(1))
  catalog$id[compatible]
}

investigate_future_core_catalog <- function() {
  data.frame(
    threat_id = c(
      "predator_reinvasion",
      "habitat_contraction",
      "sea_level_rise_pathway",
      "increased_cyclone_pressure"
    ),
    threat_label = c(
      "Rat return or loss of control",
      "Loss or degradation of breeding habitat",
      "Gradual loss of lowland habitat",
      "More frequent cyclones"
    ),
    intervention_id = c(
      "biosecurity_eradication",
      "habitat_protection_restoration",
      "habitat_protection_restoration",
      "emergency_response"
    ),
    intervention_label = c(
      "Strengthened biosecurity or renewed rodent control",
      "Habitat protection or restoration",
      "Habitat protection or restoration",
      "Emergency response"
    ),
    stringsAsFactors = FALSE
  )
}

investigate_future_catalog_row <- function(threat_id) {
  row <- investigate_future_core_catalog()
  row <- row[row$threat_id == threat_id, , drop = FALSE]
  if (nrow(row) != 1L) {
    stop("Choose one of the guided Woodhen threat comparisons.", call. = FALSE)
  }
  row
}

investigate_future_threat_choices <- function(threat_id) {
  switch(
    threat_id,
    predator_reinvasion = c(
      "Moderate: young-bird survival -15%; breeding output -20%" = "low",
      "Strong: young-bird survival -30%; breeding output -40%" = "moderate",
      "Severe stress test: young-bird survival -50%; breeding output -60%" = "high"
    ),
    habitat_contraction = c(
      "Moderate: capacity falls to 275 breeding territories" = "low",
      "Strong: capacity falls to 225 breeding territories" = "moderate",
      "Severe stress test: capacity falls to 160 breeding territories" = "high"
    ),
    sea_level_rise_pathway = c(
      "Moderate: capacity declines to 275 territories by 2100" = "low",
      "Strong: capacity declines to 225 territories by 2100" = "moderate",
      "Severe stress test: capacity declines to 160 territories by 2100" = "high"
    ),
    increased_cyclone_pressure = c(
      "Moderate: 7% annual probability; survival 45%; breeding output 60%" = "low",
      "Strong: 10% annual probability; survival 40%; breeding output 45%" = "moderate",
      "Severe stress test: 15% annual probability; survival 30%; breeding output 30%" = "high"
    ),
    stop("This threat is not part of the guided 2026 comparison.", call. = FALSE)
  )
}

investigate_future_default_threat_choice <- function(threat_id) {
  if (identical(threat_id, "predator_reinvasion")) "high" else "moderate"
}

investigate_future_response_choices <- function(intervention_id) {
  if (identical(intervention_id, "emergency_response")) {
    return(c(
      "Limited response: recover 25% of both cyclone-year losses" = "low",
      "Substantial response: recover 50% of both cyclone-year losses" = "moderate",
      "Strong response: recover 75% of both cyclone-year losses" = "high"
    ))
  }
  c(
    "Limited response: recover 25% of the modelled loss" = "low",
    "Substantial response: recover 50% of the modelled loss" = "moderate",
    "Full model recovery: recover 100% of the modelled loss" = "high"
  )
}

investigate_rat_breeding_output_multiplier <- function(threat_choice) {
  values <- c(low = 0.80, moderate = 0.60, high = 0.40)
  if (!threat_choice %in% names(values)) {
    stop("Choose one of the guided rat-pressure settings.", call. = FALSE)
  }
  unname(values[[threat_choice]])
}

investigate_cyclone_presets <- function() {
  data.frame(
    choice = c("low", "moderate", "high"),
    cat_freq = c(0.07, 0.10, 0.15),
    cat_surv = c(0.45, 0.40, 0.30),
    cat_repro = c(0.60, 0.45, 0.30),
    stringsAsFactors = FALSE
  )
}

investigate_cyclone_preset <- function(choice) {
  presets <- investigate_cyclone_presets()
  preset <- presets[presets$choice == choice, , drop = FALSE]
  if (nrow(preset) != 1L) {
    stop(
      "The guided cyclone comparison uses named settings for frequency, survival and breeding output.",
      call. = FALSE
    )
  }
  preset
}

investigate_future_scenario_names <- function(threat_id) {
  switch(
    threat_id,
    predator_reinvasion = c(
      "Common future",
      "Rat-return future",
      "Rat return with renewed control"
    ),
    habitat_contraction = c(
      "Common future",
      "Habitat-contraction future",
      "Habitat contraction with restoration"
    ),
    sea_level_rise_pathway = c(
      "Common future",
      "Lowland-habitat-loss future",
      "Lowland habitat loss with restoration"
    ),
    increased_cyclone_pressure = c(
      "Common future",
      "Higher-cyclone future",
      "Higher cyclone pressure with emergency response"
    ),
    c("Common future", "Threatened future", "Threat with management")
  )
}

investigate_build_future_family <- function(threat_id,
                                            threat_choice,
                                            threat_custom,
                                            intervention_id,
                                            intervention_choice,
                                            intervention_custom) {
  core <- investigate_future_catalog_row(threat_id)
  threat_row <- investigate_catalog_row(
    rPVA::woodhen_threat_catalog(), threat_id, "threat"
  )
  if (!is.character(intervention_id) || length(intervention_id) != 1L ||
      is.na(intervention_id) || !nzchar(intervention_id)) {
    stop("Choose one compatible intervention; no-intervention is not a core route.", call. = FALSE)
  }
  compatible <- investigate_compatible_interventions(threat_id)
  if (!intervention_id %in% compatible) {
    stop("The selected intervention is not compatible with this threat.", call. = FALSE)
  }
  if (!identical(intervention_id, core$intervention_id[[1L]])) {
    stop(
      "Choose the guided management response paired with this threat.",
      call. = FALSE
    )
  }
  intervention_row <- investigate_catalog_row(
    rPVA::woodhen_intervention_catalog(), intervention_id, "intervention"
  )
  cyclone <- identical(threat_id, "increased_cyclone_pressure")
  if (cyclone &&
      (identical(threat_choice, "custom") ||
        identical(intervention_choice, "custom"))) {
    stop(
      "The guided cyclone comparison uses named settings so all three cyclone effects remain explicit.",
      call. = FALSE
    )
  }
  threat_value <- investigate_choice_value(
    threat_choice, threat_custom, threat_row, "threat intensity"
  )
  intervention_value <- investigate_choice_value(
    intervention_choice, intervention_custom, intervention_row,
    "intervention intensity"
  )
  sea_level <- identical(threat_id, "sea_level_rise_pathway")
  scenario_names <- investigate_future_scenario_names(threat_id)
  threat <- list(
    threat_id = threat_id,
    intensity = threat_value,
    label = scenario_names[[2L]],
    temporal_shape = if (sea_level) "linear" else "step",
    onset_year = 1L,
    end_year = if (sea_level) 75L else 1L
  )
  if (identical(threat_id, "predator_reinvasion")) {
    if (identical(threat_choice, "custom")) {
      stop(
        "The guided rat-return comparison uses named settings so both recruitment effects remain explicit.",
        call. = FALSE
      )
    }
    threat$components <- list(
      breeding_output = list(
        field = "fecund",
        operator = "multiply",
        value = investigate_rat_breeding_output_multiplier(threat_choice),
        stages = 2:7
      )
    )
  }
  if (cyclone) {
    preset <- investigate_cyclone_preset(threat_choice)
    threat$components <- list(
      cyclone_survival = list(
        field = "cat_surv",
        operator = "absolute",
        value = preset$cat_surv[[1L]]
      ),
      cyclone_reproduction = list(
        field = "cat_repro",
        operator = "absolute",
        value = preset$cat_repro[[1L]]
      )
    )
  }
  intervention <- list(management = list(
    intervention_id = intervention_id,
    intensity = intervention_value,
    label = scenario_names[[3L]]
  ))
  rPVA::build_woodhen_prospective_family(
    threat = threat,
    interventions = intervention,
    seed = 123L
  )
}

investigate_begin_batch <- function(busy) {
  if (isTRUE(busy())) return(FALSE)
  busy(TRUE)
  TRUE
}

investigate_family_key <- function(family_id, family_type) {
  catalog_ids <- if (identical(family_type, "sensitivity")) {
    rPVA::woodhen_sensitivity_catalog()$id
  } else {
    rPVA::woodhen_threat_catalog()$id
  }
  prefix <- paste0(family_type, "_", catalog_ids, "_")
  suffix <- substring(family_id, nchar(prefix) + 1L)
  match_index <- which(
    startsWith(family_id, prefix) &
      nchar(suffix) == 12L & grepl("^[0-9a-f]{12}$", suffix)
  )
  if (length(match_index) == 1L) catalog_ids[[match_index]] else NA_character_
}

investigate_sensitivity_factor_id <- function(comparison) {
  sensitivity_runs <- comparison$runs[vapply(comparison$runs, function(run) {
    identical(run$scenario_type, "sensitivity")
  }, logical(1))]
  component_ids <- unique(unlist(lapply(sensitivity_runs, function(run) {
    names(run$scenario$components)
  }), use.names = FALSE))
  catalog <- rPVA::woodhen_sensitivity_catalog()
  catalog_components <- vapply(
    catalog$mapping,
    function(mapping) names(mapping)[[1L]],
    character(1)
  )
  matches <- match(component_ids, catalog_components)
  if (length(component_ids) != 1L || anyNA(matches)) {
    stop("A restored sensitivity family has no exact catalogue component.", call. = FALSE)
  }
  catalog$id[[matches[[1L]]]]
}

investigate_completed_family_ids <- function(project, family_type) {
  if (is.null(project) || !is.list(project$runs) || length(project$runs) == 0L) {
    return(character())
  }
  ids <- unique(vapply(project$runs, `[[`, character(1), "family_id"))
  ids[vapply(ids, function(family_id) {
    runs <- project$runs[vapply(project$runs, function(run) {
      identical(run$family_id, family_id)
    }, logical(1))]
    types <- vapply(runs, `[[`, character(1), "scenario_type")
    if (identical(family_type, "sensitivity")) {
      identical(types, c("locked_baseline", "sensitivity", "sensitivity"))
    } else {
      length(types) >= 3L && identical(types[1:3], c(
        "locked_baseline", "threat", "intervention"
      ))
    }
  }, logical(1))]
}

investigate_latest_family_id <- function(project, family_type) {
  ids <- investigate_completed_family_ids(project, family_type)
  if (length(ids) == 0L) NULL else tail(ids, 1L)
}

investigate_project_comparison <- function(project, family_id) {
  if (is.null(project) || is.null(family_id)) return(NULL)
  runs <- project$runs[vapply(project$runs, function(run) {
    identical(run$family_id, family_id)
  }, logical(1))]
  if (length(runs) < 3L) return(NULL)
  rPVA::compare_woodhen_run_family(runs, family_id)
}

investigate_restored_controls <- function(project) {
  sensitivity_id <- investigate_latest_family_id(project, "sensitivity")
  prospective_id <- investigate_latest_family_id(project, "prospective")
  sensitivity <- investigate_project_comparison(project, sensitivity_id)
  prospective <- investigate_project_comparison(project, prospective_id)

  sensitivity_state <- NULL
  if (!is.null(sensitivity)) {
    factor_id <- investigate_sensitivity_factor_id(sensitivity)
    row <- investigate_catalog_row(
      rPVA::woodhen_sensitivity_catalog(), factor_id, "sensitivity factor"
    )
    values <- unname(sensitivity$table$setting_value[-1L])
    sensitivity_state <- list(
      family_id = sensitivity_id,
      factor_id = factor_id,
      values = values,
      choices = unname(vapply(
        values, investigate_named_choice, character(1),
        anchors = row$anchors[[1L]]
      ))
    )
  }

  future_state <- NULL
  if (!is.null(prospective)) {
    threat_id <- investigate_family_key(prospective_id, "prospective")
    threat_run <- prospective$runs[[which(
      prospective$table$scenario_type == "threat"
    )[[1L]]]]
    intervention_run <- prospective$runs[[which(
      prospective$table$scenario_type == "intervention"
    )[[1L]]]]
    threat_row <- investigate_catalog_row(
      rPVA::woodhen_threat_catalog(), threat_id, "threat"
    )
    primary_component <- names(threat_row$mapping[[1L]])[[1L]]
    if (!primary_component %in% names(threat_run$scenario$components)) {
      stop(
        "A restored threat family is missing its primary threat component.",
        call. = FALSE
      )
    }
    threat_value <- as.numeric(
      threat_run$scenario$components[[primary_component]]$value
    )
    direct_names <- names(intervention_run$scenario$components)
    direct_names <- direct_names[!startsWith(direct_names, "threat__")]
    if (length(direct_names) == 0L) {
      stop("A restored intervention family has no direct intervention component.", call. = FALSE)
    }
    intervention_id <- intervention_run$scenario$intervention_id
    intervention_value <- as.numeric(
      intervention_run$scenario$components[[direct_names[[1L]]]]$value
    )
    intervention_row <- investigate_catalog_row(
      rPVA::woodhen_intervention_catalog(), intervention_id, "intervention"
    )
    future_state <- list(
      family_id = prospective_id,
      threat_id = threat_id,
      threat_value = threat_value,
      threat_choice = investigate_named_choice(
        threat_value, threat_row$anchors[[1L]]
      ),
      intervention_id = intervention_id,
      intervention_value = intervention_value,
      intervention_choice = investigate_named_choice(
        intervention_value, intervention_row$anchors[[1L]]
      )
    )
  }
  list(sensitivity = sensitivity_state, future = future_state)
}

investigate_named_choice <- function(value, anchors) {
  matches <- names(anchors)[anchors == value]
  if (length(matches)) matches[[1L]] else "custom"
}

investigate_format_number <- function(value, digits = 3L) {
  format(round(value, digits), trim = TRUE, big.mark = ",", scientific = FALSE)
}

investigate_format_probability <- function(value) {
  sprintf("%.1f%%", 100 * value)
}

investigate_format_timing <- function(value, overall = FALSE) {
  if (is.na(value)) {
    if (overall) "Overall median not reached" else "Threshold not crossed"
  } else {
    paste0(investigate_format_number(value, 1L), " years")
  }
}

investigate_format_percent_value <- function(value, digits = 0L) {
  paste0(
    format(
      round(100 * value, digits),
      trim = TRUE,
      scientific = FALSE,
      nsmall = digits
    ),
    "%"
  )
}

investigate_format_percent_precise <- function(value) {
  vapply(as.numeric(value), function(candidate) {
    percent <- 100 * candidate
    digits <- if (abs(percent - round(percent)) < 1e-10) {
      0L
    } else if (abs(10 * percent - round(10 * percent)) < 1e-10) {
      1L
    } else {
      2L
    }
    investigate_format_percent_value(candidate, digits)
  }, character(1))
}

investigate_future_mechanism_model <- function(threat_id,
                                               threat_choice =
                                                 investigate_future_default_threat_choice(
                                                   threat_id
                                                 ),
                                               intervention_choice = "moderate") {
  core <- investigate_future_catalog_row(threat_id)
  threat_row <- investigate_catalog_row(
    rPVA::woodhen_threat_catalog(), threat_id, "threat"
  )
  intervention_row <- investigate_catalog_row(
    rPVA::woodhen_intervention_catalog(),
    core$intervention_id[[1L]],
    "intervention"
  )
  threat_value <- rPVA:::woodhen_resolve_bounded_value(
    threat_choice, threat_row, "threat intensity"
  )
  response_value <- rPVA:::woodhen_resolve_bounded_value(
    intervention_choice, intervention_row, "intervention intensity"
  )
  locked <- rPVA:::woodhen_locked_future_spec()
  names <- investigate_future_scenario_names(threat_id)

  if (identical(threat_id, "predator_reinvasion")) {
    baseline_survival <- locked$surv[[1L]]
    threat_survival <- baseline_survival * threat_value
    threat_output <- investigate_rat_breeding_output_multiplier(threat_choice)
    managed_survival <- threat_survival +
      response_value * (baseline_survival - threat_survival)
    managed_output <- threat_output + response_value * (1 - threat_output)
    return(list(
      threat_id = threat_id,
      intervention_id = core$intervention_id[[1L]],
      names = names,
      common_setting = paste0(
        "First-year survival: ",
        investigate_format_percent_value(baseline_survival),
        "; breeding output: 100% of the common-future setting"
      ),
      threat_setting = paste0(
        "First-year survival: ",
        investigate_format_percent_value(threat_survival, 1L),
        "; breeding output: ",
        investigate_format_percent_value(threat_output),
        " of the common-future setting"
      ),
      managed_setting = paste0(
        "First-year survival: ",
        investigate_format_percent_value(managed_survival, 1L),
        "; breeding output: ",
        investigate_format_percent_value(managed_output),
        " of the common-future setting"
      ),
      threat_mechanism = paste(
        "Rat return is represented as lower breeding output from egg or chick",
        "losses and lower survival of young birds after fledging. Established",
        "territory-holder survival is unchanged."
      ),
      response_mechanism = paste0(
        core$intervention_label[[1L]],
        " recovers ",
        investigate_format_percent_value(response_value),
        " of both modelled recruitment losses toward the common future."
      ),
      threat_timing = "The recruitment pressure begins in 2025 and persists.",
      response_timing = "The management response begins with the threatened future and persists.",
      held_constant = paste(
        "Survival after the first-year stage, breeding-territory capacity,",
        "environmental and cyclone settings, genetics, the 2025 starting",
        "population, the 75-year horizon, and 1,000 simulated futures."
      ),
      boundary = paste(
        "The paired recruitment changes are bounded teaching assumptions, not",
        "estimates of rat impacts. Their joint result cannot separate egg or",
        "chick loss from post-fledging mortality."
      )
    ))
  }

  if (threat_id %in% c("habitat_contraction", "sea_level_rise_pathway")) {
    baseline_capacity <- locked$K
    managed_capacity <- threat_value +
      response_value * (baseline_capacity - threat_value)
    gradual <- identical(threat_id, "sea_level_rise_pathway")
    return(list(
      threat_id = threat_id,
      intervention_id = core$intervention_id[[1L]],
      names = names,
      common_setting = paste0(
        "Breeding-territory capacity: ",
        investigate_format_number(baseline_capacity, 0L)
      ),
      threat_setting = paste0(
        "Breeding-territory capacity: ",
        if (gradual) "declines to " else "",
        investigate_format_number(threat_value, 0L)
      ),
      managed_setting = paste0(
        "Breeding-territory capacity: ",
        if (gradual) "declines to " else "",
        investigate_format_number(managed_capacity, 0L)
      ),
      threat_mechanism = if (gradual) {
        paste(
          "Inundation and saline intrusion are represented as a gradual loss of",
          "lowland breeding-territory capacity. This is a habitat pathway, not a",
          "spatial sea-level model."
        )
      } else {
        paste(
          "Illustrative routes include climate-driven moisture and",
          "invertebrate-food changes, and habitat degradation by invasive plants.",
          "The model only lowers suitable breeding-territory capacity; it does",
          "not simulate any route separately."
        )
      },
      response_mechanism = paste0(
        "Habitat protection or restoration recovers ",
        investigate_format_percent_value(response_value),
        " of the modelled capacity loss toward the common future."
      ),
      threat_timing = if (gradual) {
        "Capacity declines gradually from 2025 to the selected value in 2100."
      } else {
        "The lower capacity begins in 2025 and persists."
      },
      response_timing = "The management response acts on the threatened habitat pathway.",
      held_constant = paste(
        "Vital rates, environmental and cyclone settings, genetics, the 2025",
        "starting population, the 75-year horizon, and 1,000 simulated futures."
      ),
      boundary = paste(
        if (gradual) {
          "Capacity settings are bounded teaching assumptions. They do not estimate"
        } else {
          paste(
            "These ecological routes are illustrative routes, not predictions.",
            "Capacity settings do not estimate"
          )
        },
        "the area restored, feasibility, cost, or the exact effects of habitat change."
      )
    ))
  }

  preset <- investigate_cyclone_preset(threat_choice)
  baseline_frequency <- locked$cat_freq
  baseline_cyclone_survival <- locked$cat_surv
  baseline_cyclone_reproduction <- locked$cat_repro
  threat_cyclone_survival <- preset$cat_surv[[1L]]
  threat_cyclone_reproduction <- preset$cat_repro[[1L]]
  managed_cyclone_survival <- threat_cyclone_survival +
    response_value * (baseline_cyclone_survival - threat_cyclone_survival)
  managed_cyclone_reproduction <- threat_cyclone_reproduction +
    response_value * (
      baseline_cyclone_reproduction - threat_cyclone_reproduction
    )
  list(
    threat_id = threat_id,
    intervention_id = core$intervention_id[[1L]],
    names = names,
    common_setting = paste0(
      "Annual cyclone probability: ",
      investigate_format_percent_value(baseline_frequency),
      "; cyclone-year survival multiplier: ",
      investigate_format_percent_value(baseline_cyclone_survival),
      "; cyclone-year breeding output: ",
      investigate_format_percent_value(baseline_cyclone_reproduction)
    ),
    threat_setting = paste0(
      "Annual cyclone probability: ",
      investigate_format_percent_value(preset$cat_freq[[1L]]),
      "; cyclone-year survival multiplier: ",
      investigate_format_percent_value(threat_cyclone_survival),
      "; cyclone-year breeding output: ",
      investigate_format_percent_value(threat_cyclone_reproduction)
    ),
    managed_setting = paste0(
      "Annual cyclone probability: ",
      investigate_format_percent_value(preset$cat_freq[[1L]]),
      "; cyclone-year survival multiplier: ",
      investigate_format_percent_precise(managed_cyclone_survival),
      "; cyclone-year breeding output: ",
      investigate_format_percent_precise(managed_cyclone_reproduction)
    ),
    threat_mechanism = paste(
      "Cyclone pressure combines a higher annual chance of a cyclone with an",
      "event-year survival multiplier that affects all model stages. A separate",
      "breeding-output multiplier represents acute recruitment loss."
    ),
    response_mechanism = paste0(
      "Emergency response recovers ",
      investigate_format_percent_value(response_value),
      " of both modelled cyclone-year losses toward the common values; the",
      " annual cyclone probability remains ",
      investigate_format_percent_value(preset$cat_freq[[1L]]),
      "."
    ),
    threat_timing = "The higher annual cyclone probability begins in 2025 and persists.",
    response_timing = "Emergency capacity is assumed to be available in every cyclone year.",
    held_constant = paste(
      "Normal-year vital rates, breeding-territory capacity, environmental",
      "variation, genetics, the 2025 starting population, the 75-year horizon,",
      "and 1,000 simulated futures."
    ),
    boundary = paste(
      "The catastrophe survival multiplier applies to all model stages, while",
      "the breeding-output multiplier represents acute recruitment loss; this",
      "structure cannot uniquely model juvenile mortality. These are bounded",
      "teaching assumptions, not cyclone forecasts or evidence that emergency",
      "action is feasible."
    )
  )
}

investigate_future_mechanism_ui <- function(model) {
  tagList(
    div(
      class = "future-mechanism-briefing",
      span(class = "workspace-label", "Mechanism briefing"),
      h3("What changes, when it changes, and what stays fixed"),
      div(
        class = "future-mechanism-grid",
        div(
          h4(icon("triangle-exclamation"), "Threat mechanism"),
          p(model$threat_mechanism),
          p(class = "future-stage-note", model$threat_timing)
        ),
        div(
          h4(icon("shield-halved"), "Management mechanism"),
          p(model$response_mechanism),
          p(class = "future-stage-note", model$response_timing)
        )
      ),
      div(
        class = "future-held-constant",
        icon("lock"),
        div(
          strong("Held constant across all three scenarios"),
          span(model$held_constant)
        )
      ),
      p(
        class = "future-boundary-note",
        strong("Interpretation boundary: "),
        model$boundary
      )
    ),
    div(
      class = "future-scenario-lineage",
      `aria-label` = paste(
        "Common future compared with a threatened future and the same threat",
        "with management"
      ),
      div(
        class = "future-scenario-card is-common",
        span(class = "setting-kicker", "Common assumptions"),
        h3(model$names[[1L]]),
        strong(model$common_setting),
        p("The 2025 starting population is projected for 75 years.")
      ),
      div(
        class = "future-lineage-arrow",
        icon("arrow-right"),
        span("add threat")
      ),
      div(
        class = "future-scenario-card is-threat",
        span(class = "setting-kicker", "Add the threat"),
        h3(model$names[[2L]]),
        strong(model$threat_setting),
        p(model$threat_timing)
      ),
      div(
        class = "future-lineage-arrow",
        icon("arrow-right"),
        span("add management")
      ),
      div(
        class = "future-scenario-card is-managed",
        span(class = "setting-kicker", "Add management to the same threat"),
        h3(model$names[[3L]]),
        strong(model$managed_setting),
        p(model$response_timing)
      )
    )
  )
}

investigate_sensitivity_display_data <- function(comparison = NULL,
                                                 factor_id = NULL) {
  if (is.null(comparison)) return(NULL)
  comparison_factor_id <- investigate_sensitivity_factor_id(comparison)
  if (!is.null(factor_id) && !identical(factor_id, comparison_factor_id)) {
    stop(
      "Sensitivity evidence does not match the selected ecological assumption.",
      call. = FALSE
    )
  }
  model <- investigate_sensitivity_factor_model(comparison_factor_id)
  table <- comparison$table
  values <- as.numeric(table$setting_value)
  data.frame(
    factor_id = rep(comparison_factor_id, length(values)),
    setting_value = values,
    setting_label = ifelse(
      table$scenario_type == "locked_baseline",
      paste0(
        "No-change: ",
        investigate_sensitivity_format_value(model, values)
      ),
      investigate_sensitivity_format_value(model, values)
    ),
    final_median_abundance = table$final_median_abundance,
    final_q025 = table$final_q025,
    final_q975 = table$final_q975,
    extinction_probability = table$extinction_probability,
    quasi_extinction_probability = table$quasi_extinction_probability,
    quasi_extinction_conditional_median_year =
      table$quasi_extinction_conditional_median_year,
    reps = table$reps,
    stringsAsFactors = FALSE
  )
}

investigate_sensitivity_probe_plot <- function(data) {
  if (is.null(data) || nrow(data) == 0L) {
    stop("Sensitivity evidence is required before plotting.", call. = FALSE)
  }
  factor_ids <- unique(data$factor_id)
  if (length(factor_ids) != 1L) {
    stop("Sensitivity plot data must describe one ecological assumption.", call. = FALSE)
  }
  model <- investigate_sensitivity_factor_model(factor_ids[[1L]])
  data <- data[order(data$setting_value), , drop = FALSE]
  setting_breaks <- sort(unique(data$setting_value))
  setting_span <- diff(range(setting_breaks))
  errorbar_width <- if (setting_span > 0) setting_span * 0.035 else 0
  abundance_limit <- max(data$final_q975) * 1.08
  percent_labels <- function(values) paste0(round(100 * values), "%")
  risk_upper <- min(
    1,
    max(0.1, ceiling((max(data$quasi_extinction_probability) + 0.05) * 10) / 10)
  )

  abundance <- ggplot2::ggplot(
    data,
    ggplot2::aes(x = setting_value, y = final_median_abundance)
  ) +
    ggplot2::geom_errorbar(
      ggplot2::aes(ymin = final_q025, ymax = final_q975),
      width = errorbar_width,
      linewidth = 0.8,
      colour = "#4a7779"
    ) +
    ggplot2::geom_line(linewidth = 0.9, colour = "#006d77") +
    ggplot2::geom_point(size = 3.1, colour = "#006d77") +
    ggplot2::scale_x_continuous(
      breaks = setting_breaks,
      labels = investigate_sensitivity_axis_labels(model)
    ) +
    ggplot2::scale_y_continuous(
      limits = c(0, abundance_limit),
      labels = function(values) format(round(values), big.mark = ",", scientific = FALSE)
    ) +
    ggplot2::labs(
      title = "Final abundance in 2100",
      subtitle = "Median and 95% simulation interval",
      x = model$x_label,
      y = "Number of birds"
    ) +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(face = "bold")
    )

  risk <- ggplot2::ggplot(
    data,
    ggplot2::aes(x = setting_value, y = quasi_extinction_probability)
  ) +
    ggplot2::geom_line(linewidth = 0.9, colour = "#b23a48") +
    ggplot2::geom_point(size = 3.1, colour = "#b23a48") +
    ggplot2::geom_text(
      ggplot2::aes(
        label = sprintf("%.1f%%", 100 * quasi_extinction_probability),
        vjust = ifelse(quasi_extinction_probability > 0.9, 1.5, -0.8)
      ),
      size = 3.8,
      colour = "#7d2631"
    ) +
    ggplot2::scale_x_continuous(
      breaks = setting_breaks,
      labels = investigate_sensitivity_axis_labels(model)
    ) +
    ggplot2::scale_y_continuous(
      limits = c(0, risk_upper),
      breaks = pretty(c(0, risk_upper), n = 5),
      labels = percent_labels,
      expand = ggplot2::expansion(mult = c(0, 0.03))
    ) +
    ggplot2::labs(
      title = "Risk of falling below 100 pairs",
      subtitle = "Probability at any time from 2025 to 2100",
      x = model$x_label,
      y = "Probability"
    ) +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(face = "bold")
    )

  patchwork::wrap_plots(abundance, risk, widths = c(1.12, 1)) +
    patchwork::plot_annotation(
      title = model$plot_title,
      caption = paste(
        model$what_changes,
        "Each setting uses 1,000 simulated futures."
      ),
      theme = ggplot2::theme(
        plot.title = ggplot2::element_text(size = 15, face = "bold"),
        plot.caption = ggplot2::element_text(colour = "#4f5d5d")
      )
    )
}

investigate_sensitivity_probe_table <- function(data) {
  crossing_text <- vapply(seq_len(nrow(data)), function(index) {
    year <- data$quasi_extinction_conditional_median_year[[index]]
    count <- round(data$quasi_extinction_probability[[index]] * data$reps[[index]])
    if (is.na(year) || count == 0L) return("Not observed in these futures")
    paste0(
      "Around ", 2025 + round(year), " among the ", count,
      " futures that crossed"
    )
  }, character(1))
  data.frame(
    Setting = data$setting_label,
    `Final birds in 2100 (95% interval)` = paste0(
      investigate_format_number(data$final_median_abundance, 0L), " (",
      investigate_format_number(data$final_q025, 0L), " - ",
      investigate_format_number(data$final_q975, 0L), ")"
    ),
    `Extinction by 2100` = investigate_format_probability(
      data$extinction_probability
    ),
    `Below 100 pairs by 2100` = investigate_format_probability(
      data$quasi_extinction_probability
    ),
    `When the 100-pair threshold was crossed` = crossing_text,
    check.names = FALSE
  )
}

investigate_future_probe_data <- function() {
  scenarios <- c(
    "Common future",
    "Predator-reinvasion threat",
    "Threat plus biosecurity response"
  )
  years <- seq.int(0L, 75L, 5L)
  summary <- data.frame(
    scenario = scenarios,
    early_survival_1 = c(0.6, 0.3, 0.375),
    early_survival_2 = c(0.75, 0.375, 0.46875),
    final_median_abundance = c(2163, 1722, 2100),
    final_q025 = c(1580, 174, 1120),
    final_q975 = c(2884, 2682, 2898),
    extinction_probability = c(0, 0.004, 0),
    warning_probability = c(0, 0.269, 0.014),
    crossed_reps = c(0L, 269L, 14L),
    conditional_median_crossing_year = c(NA, 40, 51),
    reps = rep(1000L, 3L),
    horizon = rep(75L, 3L),
    stringsAsFactors = FALSE
  )
  abundance <- data.frame(
    scenario = rep(scenarios, each = length(years)),
    projection_year = rep(years, times = length(scenarios)),
    calendar_year = rep(2025L + years, times = length(scenarios)),
    q025 = c(
      1654, 1657.85, 1708, 1583.95, 1619.9, 1619.85, 1685.8, 1647.85,
      1643.95, 1611.8, 1598, 1633.95, 1627.95, 1581.85, 1597.9, 1579.9,
      1654, 861.9, 733.75, 603.9, 473.8, 486, 417.9, 403.8, 359.9,
      317.95, 287.7, 271.75, 263.8, 275.45, 225.9, 173.85,
      1654, 1367.85, 1311.95, 1265.55, 1327.95, 1329.5, 1227.8, 1247.85,
      1245.9, 1167.9, 1237.65, 1204.9, 1209.8, 1187.75, 1150, 1119.8
    ),
    median = c(
      1654, 2226, 2214, 2243, 2218, 2214, 2222, 2206, 2187, 2197, 2186,
      2200, 2216, 2178, 2166, 2163,
      1654, 1969, 1913, 1807, 1801, 1808, 1737, 1740, 1761, 1731, 1757,
      1780, 1745, 1704, 1749, 1722,
      1654, 2160, 2128, 2127, 2126, 2130, 2136, 2112, 2121, 2111, 2130,
      2095, 2072, 2082, 2093, 2100
    ),
    q975 = c(
      1654, 2992.05, 2920.25, 2946.2, 2904, 2930.1, 2938.1, 2914.3,
      2950, 2958.1, 2900.05, 2962.2, 2988.1, 2925, 2892, 2884,
      1654, 2680.15, 2728, 2654.35, 2650.05, 2730.15, 2690.5, 2598.15,
      2684.15, 2636.05, 2700.25, 2624.1, 2674.25, 2698.05, 2630.2,
      2682.05,
      1654, 2888, 2873.45, 2898.25, 2892.15, 2860, 2882.2, 2818.35,
      2890.05, 2860, 2808, 2874, 2838.1, 2884.1, 2808, 2898.05
    ),
    stringsAsFactors = FALSE
  )
  risk <- data.frame(
    scenario = rep(scenarios, each = 2L * length(years)),
    projection_year = rep(rep(years, times = 2L), times = length(scenarios)),
    calendar_year = rep(rep(2025L + years, times = 2L), times = length(scenarios)),
    metric = rep(
      rep(c("Extinction", "Fewer than 100 pairs"), each = length(years)),
      times = length(scenarios)
    ),
    probability = c(
      rep(0, 32L),
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.001, 0.001, 0.002, 0.003, 0.004,
      0, 0.003, 0.013, 0.032, 0.05, 0.065, 0.087, 0.107, 0.136, 0.159,
      0.181, 0.203, 0.223, 0.239, 0.252, 0.269,
      rep(0, 16L),
      0, 0, 0.001, 0.002, 0.003, 0.004, 0.004, 0.004, 0.004, 0.004,
      0.007, 0.008, 0.008, 0.01, 0.012, 0.014
    ),
    stringsAsFactors = FALSE
  )
  passage_starts <- seq.int(1L, 71L, 5L)
  first_passage <- data.frame(
    scenario = rep(scenarios, each = length(passage_starts)),
    projection_start = rep(passage_starts, times = length(scenarios)),
    projection_end = rep(passage_starts + 4L, times = length(scenarios)),
    calendar_start = rep(2025L + passage_starts, times = length(scenarios)),
    calendar_end = rep(2029L + passage_starts, times = length(scenarios)),
    count = c(
      rep(0L, 15L),
      3L, 10L, 19L, 18L, 15L, 22L, 20L, 29L, 23L, 22L, 22L, 20L,
      16L, 13L, 17L,
      0L, 1L, 1L, 1L, 1L, 0L, 0L, 0L, 0L, 3L, 1L, 0L, 2L, 2L, 2L
    ),
    stringsAsFactors = FALSE
  )
  list(
    summary = summary,
    abundance = abundance,
    risk = risk,
    first_passage = first_passage,
    differences = list(
      comparison = "Intervention versus threat",
      final_median_birds = 378,
      extinction_percentage_points = -0.4,
      warning_percentage_points = -25.5
    )
  )
}

investigate_future_display_data <- function(comparison) {
  if (is.null(comparison)) return(NULL)
  runs <- comparison$runs
  table <- comparison$table
  labels <- vapply(seq_along(runs), function(index) {
    if (identical(runs[[index]]$scenario_type, "locked_baseline")) {
      "Common future"
    } else {
      runs[[index]]$student_label
    }
  }, character(1))

  summary <- data.frame(
    scenario = labels,
    final_median_abundance = table$final_median_abundance,
    final_q025 = table$final_q025,
    final_q975 = table$final_q975,
    extinction_probability = table$extinction_probability,
    warning_probability = table$quasi_extinction_probability,
    crossed_reps = vapply(
      runs,
      function(run) run$quasi_extinction_50_pairs$crossed_reps,
      integer(1)
    ),
    conditional_median_crossing_year =
      table$quasi_extinction_conditional_median_year,
    reps = table$reps,
    horizon = table$horizon,
    stringsAsFactors = FALSE
  )

  abundance <- do.call(rbind, lapply(seq_along(runs), function(index) {
    values <- runs[[index]]$annual_quantiles
    data.frame(
      scenario = labels[[index]],
      projection_year = values$year,
      calendar_year = 2025L + values$year,
      q025 = values$q025,
      median = values$median,
      q975 = values$q975,
      stringsAsFactors = FALSE
    )
  }))
  rownames(abundance) <- NULL

  risk <- do.call(rbind, lapply(seq_along(runs), function(index) {
    warning <- runs[[index]]$quasi_extinction_50_pairs$cumulative
    data.frame(
      scenario = labels[[index]],
      projection_year = warning$year,
      calendar_year = 2025L + warning$year,
      metric = "Fewer than 100 pairs",
      probability = warning$probability,
      stringsAsFactors = FALSE
    )
  }))
  rownames(risk) <- NULL

  starts <- seq.int(1L, 71L, 5L)
  first_passage <- do.call(rbind, lapply(seq_along(runs), function(index) {
    years <- runs[[index]]$quasi_extinction_50_pairs$first_crossing_year
    years <- years[!is.na(years)]
    counts <- vapply(starts, function(start) {
      sum(years >= start & years <= start + 4L)
    }, integer(1))
    data.frame(
      scenario = labels[[index]],
      projection_start = starts,
      projection_end = starts + 4L,
      calendar_start = 2025L + starts,
      calendar_end = 2029L + starts,
      count = counts,
      probability = counts / runs[[index]]$reps,
      stringsAsFactors = FALSE
    )
  }))
  rownames(first_passage) <- NULL

  threat_index <- which(table$scenario_type == "threat")[[1L]]
  intervention_index <- which(table$scenario_type == "intervention")[[1L]]
  list(
    summary = summary,
    abundance = abundance,
    risk = risk,
    first_passage = first_passage,
    differences = list(
      comparison = "Management versus the same threat without management",
      final_median_birds = table$final_median_abundance[[intervention_index]] -
        table$final_median_abundance[[threat_index]],
      extinction_percentage_points = 100 * (
        table$extinction_probability[[intervention_index]] -
          table$extinction_probability[[threat_index]]
      ),
      warning_percentage_points = 100 * (
        table$quasi_extinction_probability[[intervention_index]] -
          table$quasi_extinction_probability[[threat_index]]
      )
    )
  )
}

investigate_future_palette <- function(evidence = NULL) {
  labels <- if (is.null(evidence)) {
    c(
      "Common future",
      "Predator-reinvasion threat",
      "Threat plus biosecurity response"
    )
  } else {
    evidence$summary$scenario
  }
  stats::setNames(c("#236b70", "#a23b4a", "#4f7a3d"), labels)
}

investigate_future_plot_theme <- function() {
  ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      legend.position = "bottom",
      legend.title = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(face = "bold")
    )
}

investigate_future_abundance_plot <- function(evidence) {
  data <- evidence$abundance
  data$scenario <- factor(data$scenario, levels = evidence$summary$scenario)
  ggplot2::ggplot(
    data,
    ggplot2::aes(
      x = calendar_year, y = median, colour = scenario, fill = scenario
    )
  ) +
    ggplot2::geom_ribbon(
      ggplot2::aes(ymin = q025, ymax = q975),
      alpha = 0.18,
      colour = NA
    ) +
    ggplot2::geom_line(linewidth = 0.9) +
    ggplot2::facet_wrap(~scenario, ncol = 3L) +
    ggplot2::scale_colour_manual(values = investigate_future_palette(evidence)) +
    ggplot2::scale_fill_manual(values = investigate_future_palette(evidence)) +
    ggplot2::scale_x_continuous(
      breaks = seq.int(2025L, 2100L, 15L),
      limits = c(2025, 2100)
    ) +
    ggplot2::scale_y_continuous(
      labels = function(values) {
        format(round(values), big.mark = ",", scientific = FALSE)
      },
      expand = ggplot2::expansion(mult = c(0.02, 0.05))
    ) +
    ggplot2::labs(
      title = "Abundance through time",
      subtitle = "Each panel shows the median and 95% simulation interval across 1,000 futures",
      x = "Calendar year",
      y = "Number of birds"
    ) +
    investigate_future_plot_theme() +
    ggplot2::theme(legend.position = "none")
}

investigate_future_risk_plot <- function(evidence) {
  data <- evidence$risk
  data$scenario <- factor(data$scenario, levels = evidence$summary$scenario)
  risk_upper <- min(
    1,
    max(0.1, ceiling((max(data$probability) + 0.02) * 10) / 10)
  )
  ggplot2::ggplot(
    data,
    ggplot2::aes(x = calendar_year, y = probability, colour = scenario)
  ) +
    ggplot2::geom_line(linewidth = 0.9) +
    ggplot2::scale_colour_manual(values = investigate_future_palette(evidence)) +
    ggplot2::scale_x_continuous(
      breaks = seq.int(2025L, 2100L, 25L),
      limits = c(2025, 2100)
    ) +
    ggplot2::scale_y_continuous(
      limits = c(0, risk_upper),
      breaks = pretty(c(0, risk_upper), n = 5),
      labels = function(values) paste0(round(100 * values), "%"),
      expand = ggplot2::expansion(mult = c(0, 0.02))
    ) +
    ggplot2::labs(
      title = "Cumulative 100-pair warning risk through time",
      subtitle = "Probability of having fallen below 100 territory-holding pairs",
      x = "Calendar year",
      y = "Cumulative probability"
    ) +
    investigate_future_plot_theme()
}

investigate_future_passage_plot <- function(evidence) {
  data <- evidence$first_passage
  if (!"probability" %in% names(data)) {
    data$probability <- data$count / evidence$summary$reps[
      match(data$scenario, evidence$summary$scenario)
    ]
  }
  data <- data[data$scenario != "Common future", , drop = FALSE]
  data$scenario <- factor(data$scenario, levels = evidence$summary$scenario[-1L])
  data$calendar_midpoint <- (data$calendar_start + data$calendar_end) / 2
  ggplot2::ggplot(
    data,
    ggplot2::aes(x = calendar_midpoint, y = probability, fill = scenario)
  ) +
    ggplot2::geom_col(
      position = ggplot2::position_dodge(width = 4),
      width = 3.6
    ) +
    ggplot2::scale_fill_manual(values = investigate_future_palette(evidence)) +
    ggplot2::scale_x_continuous(
      breaks = seq.int(2030L, 2100L, 10L),
      limits = c(2025, 2101)
    ) +
    ggplot2::scale_y_continuous(
      labels = function(values) paste0(round(100 * values, 1), "%"),
      expand = ggplot2::expansion(mult = c(0, 0.08))
    ) +
    ggplot2::labs(
      title = "First passage below 100 pairs",
      subtitle = paste(
        "Percentage of all 1,000 futures first crossing in each five-year period;",
        "bars sum to the risk by 2100"
      ),
      x = "Calendar-year bin",
      y = "Percentage of all futures"
    ) +
    investigate_future_plot_theme()
}

investigate_future_probe_table <- function(evidence) {
  data <- evidence$summary
  crossing <- ifelse(
    data$crossed_reps == 0L,
    "Not observed",
    paste0(
      "Year ", investigate_format_number(
        data$conditional_median_crossing_year, 0L
      ),
      " / ",
      sprintf("%.0f", 2025 + data$conditional_median_crossing_year)
    )
  )
  data.frame(
    Scenario = data$scenario,
    `Final birds in 2100 (95% interval)` = paste0(
      investigate_format_number(data$final_median_abundance, 0L), " (",
      investigate_format_number(data$final_q025, 0L), " - ",
      investigate_format_number(data$final_q975, 0L), ")"
    ),
    `Extinction by 2100` = investigate_format_probability(
      data$extinction_probability
    ),
    `Below 100 pairs` = investigate_format_probability(data$warning_probability),
    `Futures below 100 pairs by 2100` = paste0(
      investigate_format_number(data$crossed_reps, 0L), " / ",
      investigate_format_number(data$reps, 0L)
    ),
    `Conditional median crossing` = crossing,
    check.names = FALSE
  )
}

investigate_signed_number <- function(value, digits = 0L, suffix = "") {
  paste0(
    if (value > 0) "+" else if (value < 0) "\u2212" else "",
    investigate_format_number(abs(value), digits),
    suffix
  )
}

investigate_future_difference_ui <- function(evidence) {
  summary <- evidence$summary
  threat <- summary[nrow(summary) - 1L, , drop = FALSE]
  managed <- summary[nrow(summary), , drop = FALSE]
  differences <- evidence$differences
  div(
    class = "future-difference-summary",
    div(
      span("Management versus the same threat"),
      strong(investigate_signed_number(
        differences$final_median_birds, 0L
      )),
      tags$small("final median birds")
    ),
    div(
      span("Below-100-pairs risk change"),
      strong(investigate_signed_number(
        differences$warning_percentage_points, 1L,
        " percentage points"
      )),
      tags$small(paste0(
        investigate_format_probability(threat$warning_probability),
        " to ",
        investigate_format_probability(managed$warning_probability),
        " by 2100"
      ))
    )
  )
}

investigate_future_probe_progress <- function() {
  list(
    scenario_labels = c(
      "Common future",
      "Predator-reinvasion threat",
      "Threat plus biosecurity response"
    ),
    per_scenario = 1000L,
    total = 3000L
  )
}

investigate_future_design_probe_active <- function() {
  FALSE
}

investigate_mapping_text <- function(row) {
  mapping <- row$mapping[[1L]][[1L]]
  stages <- mapping$affected_stages
  stage_text <- if (is.numeric(stages)) {
    paste(stages, collapse = ", ")
  } else {
    paste(stages, collapse = ", ")
  }
  paste0(
    paste(mapping$affected_fields, collapse = ", "),
    " | stages: ", stage_text,
    " | operation: ", mapping$operator
  )
}

investigate_help_modal <- function() {
  modalDialog(
    title = "How to use sensitivity analysis",
    div(
      class = "help-modal-content",
      render_markdown_content(file.path(
        practical2_app_dir, "content", "help-sensitivity.md"
      ))
    ),
    footer = modalButton("Close"),
    easyClose = TRUE,
    size = "m"
  )
}

investigate_future_help_modal <- function() {
  modalDialog(
    title = "How to compare a threat and management response",
    div(
      class = "help-modal-content",
      render_markdown_content(file.path(
        practical2_app_dir, "content", "help-threat-intervention.md"
      ))
    ),
    footer = modalButton("Close"),
    easyClose = TRUE,
    size = "m"
  )
}

investigate_prompt_inputs <- function(ns, prefix, model = NULL) {
  if (identical(prefix, "sensitivity")) {
    if (is.null(model)) {
      model <- investigate_sensitivity_factor_model("K")
    }
    return(tagList(
      textAreaInput(
        ns("sensitivity_research_question"),
        "What are you testing? (optional)",
        rows = 2,
        placeholder = model$research_placeholder
      ),
      textAreaInput(
        ns("sensitivity_expected_direction"),
        "Your prediction and reasoning (optional)",
        rows = 2,
        placeholder = model$direction_placeholder
      )
    ))
  }
  tagList(
    textAreaInput(
      ns(paste0(prefix, "_research_question")),
      "Optional research question",
      rows = 2
    ),
    textAreaInput(
      ns(paste0(prefix, "_biological_reason")),
      "Optional biological reason",
      rows = 2
    ),
    textAreaInput(
      ns(paste0(prefix, "_expected_direction")),
      "Optional expected direction",
      rows = 2
    )
  )
}

investigate_sensitivity_purpose_ui <- function(ns, model) {
  tagList(
    h2(id = ns("sensitivity_question_heading"), model$question),
    p(model$intro),
    div(
      class = "sensitivity-fair-comparison",
      div(
        class = "sensitivity-comparison-item is-changed",
        icon("sliders"),
        div(strong("What changes"), span(model$what_changes))
      ),
      div(
        class = "sensitivity-comparison-item",
        icon("lock"),
        div(
          strong("What stays the same"),
          span(paste(
            "The 2025 starting population, all other model settings, 75 years,",
            "and 1,000 simulated futures."
          ))
        )
      )
    ),
    p(
      class = "sensitivity-territory-note",
      strong("Biological meaning: "),
      model$meaning,
      " ",
      strong("Interpretation boundary: "),
      model$boundary
    )
  )
}

investigate_sensitivity_workspace_intro_ui <- function(ns, model) {
  tagList(
    h2(
      id = ns("sensitivity_heading"),
      paste("Compare three", tolower(model$label), "settings")
    ),
    p(
      "The current no-change assumption is retained as a reference.",
      "Alternative 1 is higher and Alternative 2 is lower, so the current",
      "assumption is bracketed before you run."
    )
  )
}

investigate_sensitivity_setting_grid <- function(ns, model, values = NULL) {
  values <- investigate_or(values, model$defaults)
  div(
    class = "sensitivity-setting-grid",
    div(
      class = "sensitivity-setting is-baseline",
      span(class = "setting-kicker", "Current no-change assumption"),
      strong(investigate_sensitivity_format_value(model, model$baseline)),
      tags$small("Kept as the common reference")
    ),
    div(
      class = "sensitivity-setting",
      span(class = "setting-kicker", "Alternative 1: higher setting"),
      numericInput(
        ns("sensitivity_first_custom"),
        model$input_label,
        value = values[[1L]],
        min = model$range[["min"]],
        max = model$range[["max"]],
        step = investigate_control_step(model$range)
      ),
      tags$small(paste("Units:", model$unit_label))
    ),
    div(
      class = "sensitivity-setting",
      span(class = "setting-kicker", "Alternative 2: lower setting"),
      numericInput(
        ns("sensitivity_second_custom"),
        model$input_label,
        value = values[[2L]],
        min = model$range[["min"]],
        max = model$range[["max"]],
        step = investigate_control_step(model$range)
      ),
      tags$small(paste("Units:", model$unit_label))
    )
  )
}

investigate_sensitivity_plot_region_ui <- function(ns, model) {
  div(
    class = "investigate-plot sensitivity-response-plot",
    role = "img",
    `aria-label` = paste(
      "Final abundance and probability of falling below 100 breeding pairs",
      "across three settings for", model$label
    ),
    plotOutput(ns("sensitivity_plot"), height = "450px")
  )
}

investigate_future_prediction_prompts <- function(ns) {
  div(
    class = "future-prompt-grid",
    textAreaInput(
      ns("future_expected_outcome"),
      "Which outcome do you expect to change? (optional)",
      rows = 2,
      placeholder = paste(
        "Compare expected abundance, extinction risk and the chance of falling",
        "below 100 pairs."
      )
    ),
    textAreaInput(
      ns("future_mechanism_prediction"),
      "How could the threat mechanisms produce that outcome? (optional)",
      rows = 2,
      placeholder = paste(
        "Link the changed ecological processes to recruitment, abundance,",
        "uncertainty or the chance of falling below 100 pairs."
      )
    ),
    textAreaInput(
      ns("future_partial_recovery"),
      "Do you expect full or partial recovery? Why? (optional)",
      rows = 2,
      placeholder = paste(
        "Consider how much of the modelled loss the response restores, and",
        "which threat assumptions remain."
      )
    )
  )
}

investigate_future_observation_prompts <- function(ns) {
  save_button <- actionButton(
    ns("save_future_notes"),
    "Save observation to project",
    icon = icon("note-sticky"),
    class = "btn-default btn-sm"
  )
  div(
    class = "future-observation-grid",
    textAreaInput(
      ns("future_threat_observation"),
      "What changed under the threat? (optional)",
      rows = 2,
      placeholder = paste(
        "Compare the threatened future with the common future, including",
        "uncertainty and warning-threshold risk."
      )
    ),
    textAreaInput(
      ns("future_response_observation"),
      "What did the response recover, and what remained different? (optional)",
      rows = 2,
      placeholder = paste(
        "Compare the threat with management against the same threat without",
        "management, then against the common future."
      )
    ),
    textAreaInput(
      ns("future_caveat"),
      "Name one limiting uncertainty or omitted process (optional)",
      rows = 2,
      placeholder = paste(
        "For example: uncertain effect size, implementation feasibility,",
        "observation uncertainty or an omitted ecological process."
      )
    ),
    save_button
  )
}

investigate_result_prompts <- function(ns,
                                       prefix,
                                       design_probe = FALSE,
                                       model = NULL) {
  save_button <- actionButton(
    ns(paste0("save_", prefix, "_notes")),
    if (identical(prefix, "sensitivity")) {
      "Save observation to project"
    } else {
      "Save result observations"
    },
    icon = icon("note-sticky"),
    class = "btn-default btn-sm"
  )
  if (design_probe) {
    save_button <- tagAppendAttributes(
      save_button,
      disabled = "disabled",
      `aria-disabled` = "true"
    )
  }
  div(
    class = "investigate-result-prompts",
    textAreaInput(
      ns(paste0(prefix, "_interpretation")),
      if (identical(prefix, "sensitivity")) {
        "What did the simulations show, and why? (optional)"
      } else {
        "Optional interpretation"
      },
      rows = 2,
      placeholder = if (identical(prefix, "sensitivity")) {
        if (is.null(model)) {
          model <- investigate_sensitivity_factor_model("K")
        }
        paste(
          "Describe the pattern across the three",
          tolower(model$label),
          "settings, including",
          "uncertainty and 100-pair warning risk. Then explain which conclusion appears",
          "sensitive and which appears robust."
        )
      } else {
        NULL
      }
    ),
    textAreaInput(
      ns(paste0(prefix, "_caveat")),
      if (identical(prefix, "sensitivity")) {
        "What limits this conclusion? (optional)"
      } else {
        "Optional caveat"
      },
      rows = 2,
      placeholder = if (identical(prefix, "sensitivity")) {
        paste(
          model$boundary,
          "Name any additional uncertainty or omitted process that limits how",
          "confidently this result could guide management."
        )
      } else {
        NULL
      }
    ),
    save_button
  )
}

investigate_disable_run_actions_js <- function(ns) {
  ids <- paste0('"', c(ns("run_sensitivity"), ns("run_future")), '"')
  paste0(
    "[", paste(ids, collapse = ","), "].forEach(function(id){",
    "var button=document.getElementById(id);",
    "if(button){button.disabled=true;",
    "button.setAttribute('aria-disabled','true');}});"
  )
}

investigate_run_action <- function(ns, route, busy, design_probe = FALSE) {
  is_sensitivity <- identical(route, "sensitivity")
  button <- actionButton(
    ns(if (is_sensitivity) "run_sensitivity" else "run_future"),
    if (is_sensitivity) {
      "Run sensitivity comparison"
    } else {
      "Run three comparable futures"
    },
    icon = icon("play"),
    class = "btn-primary investigate-run-action",
    onclick = investigate_disable_run_actions_js(ns),
    `aria-disabled` = if (busy || design_probe) "true" else "false"
  )
  if (busy || design_probe) {
    tagAppendAttributes(button, disabled = "disabled")
  } else {
    button
  }
}

investigate_ui <- function(id) {
  ns <- NS(id)

  div(
    class = "page-shell investigate-shell",
    tags$header(
      class = "investigate-header",
      div(
        span(class = "section-eyebrow", "Phase 2: Advise from the present"),
        h1("Test an uncertain ecological assumption"),
        p(
          "Sensitivity analysis asks whether your conclusion changes when one",
          "plausible assumption changes and the rest of the future stays the same."
        )
      ),
      actionButton(
        ns("open_investigate_help"),
        "Sensitivity guide",
        icon = icon("circle-info"),
        class = "btn-default btn-sm"
      )
    ),
    div(
      class = "investigate-anchor-band",
      uiOutput(ns("anchor_status"), `aria-live` = "polite", `aria-atomic` = "true"),
      conditionalPanel(
        condition = sprintf("output['%s'] !== true", ns("anchor_ready")),
        actionButton(
          ns("go_calibrate"),
          "Go to Calibrate",
          icon = icon("arrow-left"),
          class = "btn-primary"
        )
      )
    ),
    tags$nav(
      class = "investigate-route-rail",
      `aria-label` = "Investigate activities",
      tags$a(
        id = ns("route_sensitivity"),
        href = paste0("#", ns("sensitivity-route")),
        icon("chart-line"),
        span("Sensitivity analysis")
      ),
      tags$a(
        id = ns("route_future"),
        href = paste0("#", ns("future-route")),
        icon("arrow-right-arrow-left"),
        span("Threat + management response")
      )
    ),
    tags$section(
      id = ns("sensitivity-route"),
      class = "sensitivity-purpose-band",
      `aria-labelledby` = ns("sensitivity_question_heading"),
      span(class = "workspace-label", "Sensitivity question"),
      uiOutput(ns("sensitivity_purpose"))
    ),
    tags$section(
      class = "sensitivity-workspace",
      `aria-labelledby` = ns("sensitivity_heading"),
      div(
        class = "sensitivity-workspace-heading",
        div(
          span(class = "workspace-label", "Set up the comparison"),
          uiOutput(ns("sensitivity_workspace_intro"))
        ),
        selectInput(
          ns("factor_id"), "Ecological assumption to test",
          choices = investigate_sensitivity_factor_choices(),
          selected = "K"
        )
      ),
      uiOutput(ns("sensitivity_setting_grid")),
      uiOutput(ns("sensitivity_preview")),
      div(
        class = "sensitivity-prediction-band",
        h3("Pause before running: what do you expect?"),
        p(
          "A prediction makes the comparison a test of reasoning, not just a",
          "button press. These notes are optional and can be revised later."
        ),
        div(
          class = "investigate-prompts",
          uiOutput(ns("sensitivity_prediction_prompts"))
        )
      ),
      div(
        class = "sensitivity-run-band",
        div(
          uiOutput(ns("sensitivity_run_control")),
          p(
            "The comparison runs 1,000 futures for each setting and may take",
            "about a minute. Progress remains visible throughout."
          )
        ),
        uiOutput(ns("sensitivity_progress")),
        uiOutput(
          ns("sensitivity_status"),
          `aria-live` = "polite",
          `aria-atomic` = "true"
        ),
        uiOutput(ns("sensitivity_completion"))
      )
    ),
    tags$section(
      class = "sensitivity-results",
      `aria-labelledby` = ns("sensitivity_results_heading"),
      div(
        class = "sensitivity-results-heading",
        div(
          span(class = "workspace-label", "Read the response"),
          h2(
            id = ns("sensitivity_results_heading"),
            "Look for conclusions that change across the three settings"
          )
        ),
        uiOutput(ns("sensitivity_result_context"))
      ),
      p(
        "The left panel shows how the final population responds. The right",
        "panel asks whether the same change also alters the chance of crossing",
        "the working 100-pair warning threshold."
      ),
      div(
        class = "investigate-threshold-note",
        h3("What does \"below 100 pairs\" mean?"),
        p(
          "In each simulated future, the app records whether the population ever",
          "falls below 100 territory-holding breeding pairs between 2025 and 2100.",
          "In PVA, this is a quasi-extinction threshold: it flags a serious decline",
          "before complete extinction."
        ),
        p(
          "The same working warning level is used across scenarios so their risks",
          "can be compared consistently. It is not a universal minimum viable",
          "population or a proven biological tipping point."
        )
      ),
      uiOutput(ns("sensitivity_plot_region")),
      div(
        class = "sensitivity-table-region",
        h3("Comparison record"),
        p(
          "The timing column describes only those simulated futures that",
          "actually crossed the threshold. It is not a prediction that every",
          "future will cross at that time."
        ),
        div(class = "investigate-table-scroll", tableOutput(ns("sensitivity_table")))
      ),
      div(
        class = "sensitivity-observation-band",
        h3("Record what the comparison means"),
        p(
          "Separate the pattern you observed from a limitation or uncertainty.",
          "That distinction will matter when you turn model output into advice."
        ),
        uiOutput(ns("sensitivity_result_prompts"))
      )
    ),
    tags$section(
      id = ns("future-route"),
      class = "future-probe",
      `aria-labelledby` = ns("future_heading"),
      div(
        class = "future-purpose-band",
        div(
          span(class = "workspace-label", "Threat + management response"),
          h2(
            id = ns("future_heading"),
            "Test a future threat and a management response"
          ),
          p(
            "Choose one plausible pressure on the common 2025-2100 future, then",
            "compare that threat with and without a compatible management",
            "response. All three scenarios retain the same starting population,",
            "horizon and simulation effort."
          )
        ),
        actionButton(
          ns("open_future_help"),
          "Threat and response guide",
          icon = icon("circle-info"),
          class = "btn-default btn-sm"
        )
      ),
      uiOutput(ns("future_mechanism_and_scenarios")),
      div(
        class = "future-setup-band",
        span(class = "workspace-label", "Bounded setup"),
        h3("Choose one threat and its compatible response"),
        p(
          "The guided settings are broad enough to test a management question",
          "but remain anchored to processes represented by the Woodhen model."
        ),
        tags$fieldset(
          class = "future-control-fieldset",
          tags$legend("Threat and compatible response"),
          div(
            class = "future-control-grid",
            selectInput(
              ns("threat_id"),
              "Future threat",
              choices = stats::setNames(
                investigate_future_core_catalog()$threat_id,
                investigate_future_core_catalog()$threat_label
              ),
              selected = "predator_reinvasion"
            ),
            selectInput(
              ns("threat_choice"),
              "Threat setting",
              choices = investigate_future_threat_choices("predator_reinvasion"),
              selected = investigate_future_default_threat_choice(
                "predator_reinvasion"
              )
            ),
            selectInput(
              ns("intervention_id"),
              "Compatible management response",
              choices = c(
                "Strengthened biosecurity or renewed rodent control" =
                  "biosecurity_eradication"
              ),
              selected = "biosecurity_eradication"
            ),
            selectInput(
              ns("intervention_choice"),
              "Management setting",
              choices = investigate_future_response_choices(
                "biosecurity_eradication"
              ),
              selected = "moderate"
            )
          )
        )
      ),
      div(
        class = "future-prediction-band",
        span(class = "workspace-label", "Predict before comparing"),
        h3("What pattern do you expect, and why?"),
        p(
          "These optional prompts are non-blocking. State your expectation",
          "without treating the chosen settings as known real-world effects."
        ),
        investigate_future_prediction_prompts(ns)
      ),
      div(
        class = "future-run-band",
        div(
          uiOutput(ns("future_run_control")),
          p(
            "The proposed run compares three scenarios with 1,000 simulated",
            "futures each: 3,000 futures overall."
          )
        ),
        uiOutput(ns("future_progress")),
        uiOutput(
          ns("future_status"),
          `aria-live` = "polite",
          `aria-atomic` = "true"
        )
      ),
      div(
        class = "future-results-band",
        div(
          class = "future-results-heading",
          div(
            span(class = "workspace-label", "Comparison results"),
            h3("Read the connected comparisons in sequence")
          ),
          uiOutput(ns("future_result_context"))
        ),
        p(
          class = "future-reading-order",
          strong("Reading order: "),
          "common future to threat; threat to intervention; then intervention",
          "back to the common future."
        ),
        div(
          class = "future-result-grid",
          div(
            class = "future-plot-region is-wide",
            role = "img",
            `aria-label` = paste(
              "Abundance from 2025 to 2100 for the common future, threatened",
              "future and managed threatened future"
            ),
            plotOutput(ns("future_abundance_plot"), height = "460px")
          ),
          div(
            class = "future-plot-region is-wide",
            role = "img",
            `aria-label` = paste(
              "Cumulative probability of falling below 100 territory-holding",
              "breeding pairs from 2025 to 2100"
            ),
            plotOutput(ns("future_risk_plot"), height = "420px")
          ),
          div(
            class = "future-plot-region is-wide",
            role = "img",
            `aria-label` = paste(
              "First-passage timing among futures that crossed the working",
              "100-pair threshold"
            ),
            plotOutput(ns("future_passage_plot"), height = "390px")
          )
        ),
        uiOutput(ns("future_difference_summary")),
        div(
          class = "future-inference-note",
          h4("Keep improvement separate from recovery and effectiveness"),
          p(
            "Simulated improvement is not automatically full recovery, and it",
            "is not evidence that the action will work, is feasible, affordable,",
            "or sufficient in the real system."
          ),
          p(
            "The 1,000 futures represent process stochasticity under the chosen",
            "settings. They do not represent parameter, model-form, observation,",
            "or implementation-feasibility uncertainty."
          )
        ),
        div(
          class = "future-table-region",
          h4("Comparison record"),
          p(
            "Conditional timing describes only futures that crossed the shared",
            "working warning threshold. Fewer than 100 pairs is not a universal",
            "minimum viable population."
          ),
          div(
            class = "investigate-table-scroll future-table-scroll",
            tableOutput(ns("future_table"))
          )
        )
      ),
      div(
        class = "future-observation-band",
        span(class = "workspace-label", "Observe and qualify"),
        h3("Record what changed, what was recovered, and what remains uncertain"),
        p(
          "Your notes do not affect the simulations. Save a concise observation",
          "when the comparison gives you evidence worth carrying into Compare."
        ),
        investigate_future_observation_prompts(ns)
      )
    )
  )
}

investigate_progress_heading <- function(
    route,
    scenario,
    scenarios,
    overall_completed,
    overall_total,
    is_busy,
    has_comparison,
    sensitivity_label = NULL) {
  if (scenario < 1L) {
    if (identical(route, "sensitivity")) {
      return(paste(
        "Ready to simulate three",
        tolower(sensitivity_label),
        "settings"
      ))
    }
    return("Ready to simulate three comparable futures")
  }
  if (overall_completed >= overall_total) {
    if (isTRUE(is_busy)) return("Summarising and plotting results")
    if (!isTRUE(has_comparison)) return("Comparison not completed")
    if (identical(route, "sensitivity")) {
      return(paste(sensitivity_label, "comparison complete"))
    }
    return("Threat and management comparison complete")
  }
  if (identical(route, "sensitivity")) {
    return(paste0("Simulating setting ", scenario, " of ", scenarios))
  }
  paste0("Simulating scenario ", scenario, " of ", scenarios)
}

investigate_server <- function(
    id,
    project,
    scenario_runner = rPVA::run_woodhen_investigation_scenario) {
  moduleServer(id, function(input, output, session) {
    busy <- reactiveVal(FALSE)
    processing_notice_active <- reactiveVal(FALSE)
    processing_notice_id <- session$ns("processing-results")
    project_update_state <- reactiveVal(NULL)
    observation_update_state <- reactiveVal(NULL)
    navigation_state <- reactiveVal(NULL)
    event_counter <- reactiveVal(0L)
    status_state <- reactiveVal(c(
      sensitivity = "Choose two alternative settings, then run the comparison.",
      future = paste(
        "Choose a threat and management setting, make a prediction, then run",
        "three comparable futures."
      )
    ))
    progress_state <- reactiveVal(list(
      sensitivity = c(scenario = 0L, scenarios = 3L, completed = 0L, total = 1000L),
      future = c(scenario = 0L, scenarios = 3L, completed = 0L, total = 1000L)
    ))
    progress_history_state <- reactiveVal(list(sensitivity = list(), future = list()))
    sensitivity_selector_initialized <- reactiveVal(FALSE)
    sensitivity_selector_state <- reactiveVal(NULL)

    publish <- function(target, value) {
      next_event <- shiny::isolate(event_counter()) + 1L
      event_counter(next_event)
      value$event_id <- next_event
      target(value)
      invisible(value)
    }

    set_status <- function(route, value) {
      status <- shiny::isolate(status_state())
      status[[route]] <- value
      status_state(status)
    }

    show_processing_notice <- function() {
      if (isTRUE(shiny::isolate(processing_notice_active()))) {
        return(invisible(processing_notice_id))
      }
      processing_notice_active(TRUE)
      showNotification(
        paste(
          "Simulations complete. Summarising and plotting results.",
          "Please wait for the results to appear."
        ),
        duration = NULL,
        closeButton = FALSE,
        id = processing_notice_id,
        type = "message",
        session = session
      )
      invisible(processing_notice_id)
    }

    clear_processing_notice <- function() {
      if (isTRUE(shiny::isolate(processing_notice_active()))) {
        removeNotification(processing_notice_id, session = session)
        processing_notice_active(FALSE)
      }
      invisible(NULL)
    }

    release_batch_after_flush <- function() {
      session$onFlushed(function() {
        clear_processing_notice()
        if (isTRUE(shiny::isolate(busy()))) busy(FALSE)
      }, once = TRUE)
      invisible(NULL)
    }

    set_progress <- function(route, scenario, scenarios, completed, total) {
      progress <- shiny::isolate(progress_state())
      progress[[route]] <- c(
        scenario = as.integer(scenario), scenarios = as.integer(scenarios),
        completed = as.integer(completed), total = as.integer(total)
      )
      progress_state(progress)
      history <- shiny::isolate(progress_history_state())
      history[[route]][[length(history[[route]]) + 1L]] <- progress[[route]]
      progress_history_state(history)
      set_status(route, paste0(
        "Scenario ", scenario, "/", scenarios, ": ",
        format(completed, big.mark = ","), "/", format(total, big.mark = ","),
        " futures completed."
      ))
    }

    project_fingerprint <- reactive({
      candidate <- project()
      if (is.null(candidate)) "no-active-project" else candidate$project_fingerprint
    })

    observeEvent(project_fingerprint(), {
      candidate <- project()
      sensitivity_selector_initialized(FALSE)
      progress_history_state(list(sensitivity = list(), future = list()))
      restored <- investigate_restored_controls(candidate)
      if (!is.null(restored$sensitivity)) {
        state <- restored$sensitivity
        sensitivity_selector_state(list(
          family_id = state$family_id,
          factor_id = state$factor_id,
          values = state$values
        ))
        updateSelectInput(session, "factor_id", selected = state$factor_id)
        updateSelectInput(session, "sensitivity_first_choice", selected = state$choices[[1L]])
        updateSelectInput(session, "sensitivity_second_choice", selected = state$choices[[2L]])
        updateNumericInput(session, "sensitivity_first_custom", value = state$values[[1L]])
        updateNumericInput(session, "sensitivity_second_custom", value = state$values[[2L]])
      } else {
        sensitivity_selector_state(NULL)
      }
      if (!is.null(restored$future) &&
          restored$future$threat_id %in% investigate_future_core_catalog()$threat_id) {
        state <- restored$future
        core <- investigate_future_catalog_row(state$threat_id)
        updateSelectInput(session, "threat_id", selected = state$threat_id)
        updateSelectInput(
          session,
          "threat_choice",
          choices = investigate_future_threat_choices(state$threat_id),
          selected = state$threat_choice
        )
        updateSelectInput(
          session,
          "intervention_id",
          choices = stats::setNames(
            core$intervention_id, core$intervention_label
          ),
          selected = core$intervention_id
        )
        updateSelectInput(
          session,
          "intervention_choice",
          choices = investigate_future_response_choices(core$intervention_id),
          selected = state$intervention_choice
        )
      }
      session$onFlushed(function() {
        sensitivity_selector_initialized(TRUE)
      }, once = TRUE)
    }, ignoreInit = FALSE)

    observeEvent(input$open_investigate_help, {
      showModal(investigate_help_modal())
    })

    observeEvent(input$open_future_help, {
      showModal(investigate_future_help_modal())
    })

    observeEvent(input$go_calibrate, {
      publish(navigation_state, list(section = "calibrate"))
    })

    observeEvent(input$factor_id, {
      sensitivity_selector_initialized(FALSE)
      selector_state <- shiny::isolate(sensitivity_selector_state())
      if (!is.null(selector_state) &&
          !identical(selector_state$factor_id, input$factor_id)) {
        sensitivity_selector_state(NULL)
      }
      row <- investigate_catalog_row(
        rPVA::woodhen_sensitivity_catalog(), input$factor_id, "sensitivity factor"
      )
      range <- investigate_sensitivity_factor_model(input$factor_id)$range
      restored <- investigate_restored_controls(project())$sensitivity
      restored_values <- if (!is.null(restored) &&
          identical(restored$factor_id, input$factor_id)) restored$values else NULL
      updateNumericInput(
        session, "sensitivity_first_custom",
        value = investigate_or(restored_values[[1L]], row$anchors[[1L]][["higher"]]),
        min = range[["min"]], max = range[["max"]],
        step = investigate_control_step(range)
      )
      updateNumericInput(
        session, "sensitivity_second_custom",
        value = investigate_or(restored_values[[2L]], row$anchors[[1L]][["lower"]]),
        min = range[["min"]], max = range[["max"]],
        step = investigate_control_step(range)
      )
      session$onFlushed(function() {
        sensitivity_selector_initialized(TRUE)
      }, once = TRUE)
    }, ignoreInit = FALSE)

    selected_sensitivity_family_id <- reactive({
      if (!isTRUE(sensitivity_selector_initialized())) return(NULL)
      initialized_state <- sensitivity_selector_state()
      required <- list(
        input$factor_id,
        input$sensitivity_first_custom,
        input$sensitivity_second_custom
      )
      if (any(vapply(required, function(value) {
        is.null(value) || length(value) != 1L || is.na(value)
      }, logical(1)))) {
        if (is.null(initialized_state)) return(NULL)
        return(initialized_state$family_id)
      }
      values <- tryCatch(
        investigate_sensitivity_values(
          input$factor_id,
          "custom",
          "custom",
          input$sensitivity_first_custom,
          input$sensitivity_second_custom
        ),
        error = function(error) NULL
      )
      if (is.null(values)) return(NULL)
      family <- tryCatch(
        rPVA::build_woodhen_sensitivity_family(
          input$factor_id, values, seed = 123L
        ),
        error = function(error) NULL
      )
      if (is.null(family)) NULL else family$family_id
    })

    observeEvent(selected_sensitivity_family_id(), {
      selected_id <- selected_sensitivity_family_id()
      completed_ids <- investigate_completed_family_ids(project(), "sensitivity")
      if (!is.null(selected_id) && !selected_id %in% completed_ids) {
        progress <- shiny::isolate(progress_state())
        progress$sensitivity <- c(
          scenario = 0L, scenarios = 3L, completed = 0L, total = 1000L
        )
        progress_state(progress)
        set_status(
          "sensitivity",
          "Settings changed. Run these three comparable settings to create evidence."
        )
      }
    }, ignoreInit = TRUE)

    observeEvent(input$threat_id, {
      core <- investigate_future_catalog_row(input$threat_id)
      restored <- investigate_restored_controls(project())$future
      threat_choices <- investigate_future_threat_choices(input$threat_id)
      threat_selected <- if (!is.null(restored) &&
          identical(restored$threat_id, input$threat_id) &&
          restored$threat_choice %in% unname(threat_choices)) {
        restored$threat_choice
      } else {
        investigate_future_default_threat_choice(input$threat_id)
      }
      updateSelectInput(
        session,
        "threat_choice",
        choices = threat_choices,
        selected = threat_selected
      )
      updateSelectInput(
        session,
        "intervention_id",
        choices = stats::setNames(
          core$intervention_id, core$intervention_label
        ),
        selected = core$intervention_id
      )
      response_choices <- investigate_future_response_choices(
        core$intervention_id
      )
      response_selected <- if (!is.null(restored) &&
          identical(restored$threat_id, input$threat_id) &&
          identical(restored$intervention_id, core$intervention_id[[1L]]) &&
          restored$intervention_choice %in% unname(response_choices)) {
        restored$intervention_choice
      } else {
        "moderate"
      }
      updateSelectInput(
        session,
        "intervention_choice",
        choices = response_choices,
        selected = response_selected
      )
    }, ignoreInit = FALSE)

    selected_future_family_id <- reactive({
      required <- list(
        input$threat_id,
        input$threat_choice,
        input$intervention_id,
        input$intervention_choice
      )
      if (any(vapply(required, function(value) {
        is.null(value) || length(value) == 0L
      }, logical(1)))) {
        return(NULL)
      }
      family <- tryCatch(
        investigate_build_future_family(
          input$threat_id,
          input$threat_choice,
          input$threat_custom,
          input$intervention_id,
          input$intervention_choice,
          input$intervention_custom
        ),
        error = function(error) NULL
      )
      if (is.null(family)) NULL else family$family_id
    })

    observeEvent(selected_future_family_id(), {
      selected_id <- selected_future_family_id()
      completed_ids <- investigate_completed_family_ids(project(), "prospective")
      if (!is.null(selected_id) && !selected_id %in% completed_ids) {
        progress <- shiny::isolate(progress_state())
        progress$future <- c(
          scenario = 0L, scenarios = 3L, completed = 0L, total = 1000L
        )
        progress_state(progress)
        set_status(
          "future",
          "Settings changed. Run these three comparable futures to create evidence."
        )
      }
    }, ignoreInit = TRUE)

    output$anchor_ready <- reactive({
      identical(rPVA:::woodhen_locked_anchor_status(project())$status, "ready")
    })
    outputOptions(output, "anchor_ready", suspendWhenHidden = FALSE)

    output$anchor_status <- renderUI({
      anchor <- rPVA:::woodhen_locked_anchor_status(project())
      div(
        class = paste0("anchor-status is-", anchor$status),
        strong(switch(anchor$status,
          ready = "Common future comparison ready",
          stale = "Common future comparison needs to be rerun",
          "Common future comparison not yet run"
        )),
        span(anchor$action)
      )
    })

    sensitivity_model <- reactive({
      selector_state <- sensitivity_selector_state()
      factor_id <- if (!is.null(input$factor_id) &&
          length(input$factor_id) == 1L && nzchar(input$factor_id)) {
        input$factor_id
      } else if (!is.null(selector_state)) {
        selector_state$factor_id
      } else {
        "K"
      }
      investigate_sensitivity_factor_model(
        factor_id
      )
    })

    output$sensitivity_purpose <- renderUI({
      investigate_sensitivity_purpose_ui(session$ns, sensitivity_model())
    })

    output$sensitivity_workspace_intro <- renderUI({
      investigate_sensitivity_workspace_intro_ui(
        session$ns, sensitivity_model()
      )
    })

    output$sensitivity_setting_grid <- renderUI({
      model <- sensitivity_model()
      restored <- investigate_restored_controls(project())$sensitivity
      values <- if (!is.null(restored) &&
          identical(restored$factor_id, model$factor_id)) {
        restored$values
      } else {
        model$defaults
      }
      investigate_sensitivity_setting_grid(session$ns, model, values)
    })

    output$sensitivity_prediction_prompts <- renderUI({
      investigate_prompt_inputs(
        session$ns, "sensitivity", sensitivity_model()
      )
    })

    output$sensitivity_result_prompts <- renderUI({
      investigate_result_prompts(
        session$ns, "sensitivity", model = sensitivity_model()
      )
    })

    output$sensitivity_plot_region <- renderUI({
      investigate_sensitivity_plot_region_ui(
        session$ns, sensitivity_model()
      )
    })

    output$sensitivity_preview <- renderUI({
      req(input$factor_id)
      model <- sensitivity_model()
      row <- investigate_catalog_row(
        rPVA::woodhen_sensitivity_catalog(), model$factor_id,
        "sensitivity factor"
      )
      values <- tryCatch(investigate_sensitivity_values(
        input$factor_id,
        "custom",
        "custom",
        investigate_or(input$sensitivity_first_custom, row$anchors[[1L]][["higher"]]),
        investigate_or(input$sensitivity_second_custom, row$anchors[[1L]][["lower"]])
      ), error = function(error) error)
      if (inherits(values, "error")) {
        return(div(
          class = "investigate-preview is-invalid",
          icon("triangle-exclamation"),
          strong("Adjust the comparison: "),
          conditionMessage(values)
        ))
      }
      div(
        class = "investigate-preview",
        icon("circle-check"),
        div(
          strong("Fair comparison ready"),
          span(paste(
            paste(
              investigate_sensitivity_format_value(
                model, c(model$baseline, values)
              ),
              collapse = ", "
            ),
            "; every other model assumption is unchanged."
          ))
        )
      )
    })

    output$future_mechanism_and_scenarios <- renderUI({
      req(input$threat_id)
      threat_choices <- investigate_future_threat_choices(input$threat_id)
      threat_choice <- investigate_or(
        input$threat_choice,
        investigate_future_default_threat_choice(input$threat_id)
      )
      if (!threat_choice %in% unname(threat_choices)) {
        threat_choice <- investigate_future_default_threat_choice(input$threat_id)
      }
      response_choice <- investigate_or(input$intervention_choice, "moderate")
      model <- tryCatch(
        investigate_future_mechanism_model(
          input$threat_id,
          threat_choice,
          response_choice
        ),
        error = function(error) error
      )
      if (inherits(model, "error")) {
        return(div(
          class = "investigate-preview is-invalid",
          icon("triangle-exclamation"),
          strong("Adjust the comparison: "),
          conditionMessage(model)
        ))
      }
      investigate_future_mechanism_ui(model)
    })

    output$sensitivity_run_control <- renderUI({
      investigate_run_action(session$ns, "sensitivity", busy())
    })
    output$future_run_control <- renderUI({
      investigate_run_action(session$ns, "future", busy())
    })

    run_route <- function(route, family, prompt, batch_started = FALSE) {
      prompt <- force(prompt)
      if (!batch_started && !investigate_begin_batch(busy)) {
        set_status(route, "A family is already running; the repeated submission was ignored.")
        return(NULL)
      }
      if (batch_started && !isTRUE(shiny::isolate(busy()))) {
        stop("An accepted investigation batch must retain the shared busy guard.", call. = FALSE)
      }
      candidate <- project()
      base_project_fingerprint <- candidate$project_fingerprint
      anchor <- rPVA:::woodhen_locked_anchor_status(candidate)
      if (!identical(anchor$status, "ready")) {
        set_status(route, paste("Run blocked.", anchor$action))
        publish(project_update_state, list(
          ok = FALSE,
          message = paste("Run blocked.", anchor$action),
          base_project_fingerprint = base_project_fingerprint
        ))
        release_batch_after_flush()
        return(NULL)
      }
      progress <- progress_state()
      progress[[route]] <- c(scenario = 0L, scenarios = length(family$scenarios), completed = 0L, total = 1000L)
      progress_state(progress)
      history <- progress_history_state()
      history[[route]] <- list()
      progress_history_state(history)
      set_status(route, "Preparing three comparable scenarios.")
      session$onFlushed(function() {
        on.exit(release_batch_after_flush(), add = TRUE)
        live_project <- shiny::isolate(project())
        live_project_fingerprint <- if (is.null(live_project)) {
          NULL
        } else {
          live_project$project_fingerprint
        }
        if (!identical(live_project_fingerprint, base_project_fingerprint)) {
          message <- paste(
            "The run was cancelled because the active project changed.",
            "Start it again from the current project."
          )
          set_status(route, message)
          publish(project_update_state, list(
            ok = FALSE,
            message = message,
            base_project_fingerprint = base_project_fingerprint
          ))
          return(NULL)
        }
        action <- withProgress(
          message = if (identical(route, "sensitivity")) {
            "Running sensitivity comparison"
          } else {
            "Running threat-intervention comparison"
          },
          value = 0.01,
          {
            setProgress(
              0.01,
              detail = paste("Preparing", length(family$scenarios), "comparable settings")
            )
            tryCatch(
              rPVA:::woodhen_run_investigation_family_project(
                candidate,
                family,
                prompt = prompt,
                progress = function(scenario, scenarios, completed, total) {
                  set_progress(route, scenario, scenarios, completed, total)
                  overall <- ((scenario - 1L) * total + completed) /
                    (scenarios * total)
                  final_simulation <- scenario == scenarios &&
                    completed >= total
                  if (final_simulation) {
                    set_status(
                      route,
                      "Simulations complete. Summarising and plotting results."
                    )
                    show_processing_notice()
                  }
                  setProgress(
                    0.02 + 0.96 * overall,
                    detail = if (final_simulation) {
                      "Summarising and plotting results"
                    } else {
                      paste0(
                        "Setting ", scenario, " of ", scenarios, ": ",
                        format(completed, big.mark = ","), " of ",
                        format(total, big.mark = ","), " futures"
                      )
                    }
                  )
                },
                runner = scenario_runner
              ),
              error = function(error) error
            )
          }
        )
        if (inherits(action, "error")) {
          message <- paste(
            "The comparison did not finish, so no partial results were saved:",
            conditionMessage(action)
          )
          set_status(route, message)
          publish(project_update_state, list(
            ok = FALSE,
            message = message,
            base_project_fingerprint = base_project_fingerprint
          ))
          return(NULL)
        }
        message <- if (action$reused) {
          "These exact settings were already complete; the saved results are shown."
        } else {
          "Comparison complete. Results are ready to save in this project."
        }
        if (action$prompt_saved) {
          message <- paste(message, "Your pre-run notes were saved with the comparison.")
        }
        set_status(route, message)
        publish(project_update_state, list(
          ok = TRUE,
          candidate = action$project,
          family_id = action$family$family_id,
          route = route,
          reused = action$reused,
          message = message,
          base_project_fingerprint = base_project_fingerprint
        ))
        action
      }, once = TRUE)
      invisible(TRUE)
    }

    observeEvent(input$run_sensitivity, {
      if (!investigate_begin_batch(busy)) {
        set_status("sensitivity", "A family is already running; the repeated submission was ignored.")
        return()
      }
      values <- tryCatch(investigate_sensitivity_values(
        input$factor_id,
        "custom",
        "custom",
        input$sensitivity_first_custom,
        input$sensitivity_second_custom
      ), error = function(error) error)
      if (inherits(values, "error")) {
        set_status("sensitivity", conditionMessage(values))
        release_batch_after_flush()
        return()
      }
      family <- tryCatch(
        rPVA::build_woodhen_sensitivity_family(
          input$factor_id, values, seed = 123L
        ),
        error = function(error) error
      )
      if (inherits(family, "error")) {
        set_status("sensitivity", conditionMessage(family))
        release_batch_after_flush()
        return()
      }
      run_route("sensitivity", family, list(
        research_question = investigate_or(input$sensitivity_research_question, ""),
        biological_reason = "",
        expected_direction = investigate_or(input$sensitivity_expected_direction, "")
      ), batch_started = TRUE)
    })

    observeEvent(input$run_future, {
      if (isTRUE(shiny::isolate(busy()))) {
        set_status(
          "future",
          "A family is already running; the repeated submission was ignored."
        )
        return()
      }
      if (!investigate_begin_batch(busy)) {
        set_status("future", "A family is already running; the repeated submission was ignored.")
        return()
      }
      family <- tryCatch(investigate_build_future_family(
        input$threat_id,
        input$threat_choice,
        input$threat_custom,
        input$intervention_id,
        input$intervention_choice,
        input$intervention_custom
      ), error = function(error) error)
      if (inherits(family, "error")) {
        set_status("future", conditionMessage(family))
        release_batch_after_flush()
        return()
      }
      run_route("future", family, list(
        research_question = investigate_or(input$future_expected_outcome, ""),
        biological_reason = investigate_or(input$future_mechanism_prediction, ""),
        expected_direction = investigate_or(input$future_partial_recovery, "")
      ), batch_started = TRUE)
    })

    sensitivity_comparison <- reactive({
      investigate_project_comparison(
        project(), selected_sensitivity_family_id()
      )
    })
    future_comparison <- reactive({
      investigate_project_comparison(project(), selected_future_family_id())
    })

    completion_state <- reactive({
      list(
        sensitivity = if (is.null(sensitivity_comparison())) FALSE else {
          paste(sensitivity_model()$label, "comparison complete")
        },
        future = if (is.null(future_comparison())) FALSE else {
          "Threat and management comparison complete"
        }
      )
    })

    output$sensitivity_progress <- renderUI({
      state <- progress_state()$sensitivity
      scenario <- as.integer(state[["scenario"]])
      scenarios <- as.integer(state[["scenarios"]])
      per_scenario <- as.integer(state[["total"]])
      completed <- as.integer(state[["completed"]])
      overall_completed <- if (scenario < 1L) {
        0L
      } else {
        (scenario - 1L) * per_scenario + completed
      }
      overall_total <- scenarios * per_scenario
      percent <- round(100 * overall_completed / overall_total)
      model <- sensitivity_model()
      first_value <- investigate_or(
        input$sensitivity_first_custom, model$defaults[[1L]]
      )
      second_value <- investigate_or(
        input$sensitivity_second_custom, model$defaults[[2L]]
      )
      labels <- c(
        paste0(
          "No-change: ",
          investigate_sensitivity_format_value(model, model$baseline)
        ),
        investigate_sensitivity_format_value(model, first_value),
        investigate_sensitivity_format_value(model, second_value)
      )
      step_class <- vapply(seq_len(scenarios), function(index) {
        if (scenario > index || (scenario == index && completed >= per_scenario)) {
          "is-complete"
        } else if (scenario == index && completed < per_scenario) {
          "is-active"
        } else {
          "is-pending"
        }
      }, character(1))
      div(
        class = "investigate-progress",
        div(
          class = "investigate-progress-heading",
          strong(investigate_progress_heading(
            route = "sensitivity",
            scenario = scenario,
            scenarios = scenarios,
            overall_completed = overall_completed,
            overall_total = overall_total,
            is_busy = busy(),
            has_comparison = !identical(
              completion_state()$sensitivity,
              FALSE
            ),
            sensitivity_label = model$label
          )),
          span(paste0(format(overall_completed, big.mark = ","), " of ",
            format(overall_total, big.mark = ","), " futures"))
        ),
        div(
          class = "investigate-progress-track",
          role = "progressbar",
          `aria-valuemin` = "0",
          `aria-valuemax` = as.character(overall_total),
          `aria-valuenow` = as.character(overall_completed),
          `aria-label` = paste(model$label, "sensitivity simulation progress"),
          div(
            class = "investigate-progress-fill",
            style = paste0("width: ", percent, "%")
          )
        ),
        div(
          class = "investigate-progress-steps",
          lapply(seq_along(labels), function(index) {
            span(
              class = paste("investigate-progress-step", step_class[[index]]),
              icon(if (identical(step_class[[index]], "is-complete")) {
                "circle-check"
              } else {
                "circle"
              }),
              labels[[index]]
            )
          })
        )
      )
    })
    output$future_progress <- renderUI({
      state <- progress_state()$future
      scenario <- as.integer(state[["scenario"]])
      scenarios <- as.integer(state[["scenarios"]])
      per_scenario <- as.integer(state[["total"]])
      completed <- as.integer(state[["completed"]])
      overall_completed <- if (scenario < 1L) {
        0L
      } else {
        (scenario - 1L) * per_scenario + completed
      }
      overall_total <- scenarios * per_scenario
      percent <- round(100 * overall_completed / overall_total)
      threat_choices <- investigate_future_threat_choices(
        investigate_or(input$threat_id, "predator_reinvasion")
      )
      threat_choice <- investigate_or(
        input$threat_choice,
        investigate_future_default_threat_choice(
          investigate_or(input$threat_id, "predator_reinvasion")
        )
      )
      if (!threat_choice %in% unname(threat_choices)) {
        threat_choice <- investigate_future_default_threat_choice(
          investigate_or(input$threat_id, "predator_reinvasion")
        )
      }
      model <- investigate_future_mechanism_model(
        investigate_or(input$threat_id, "predator_reinvasion"),
        threat_choice,
        investigate_or(input$intervention_choice, "moderate")
      )
      labels <- model$names
      step_class <- vapply(seq_len(scenarios), function(index) {
        if (scenario > index || (scenario == index && completed >= per_scenario)) {
          "is-complete"
        } else if (scenario == index && completed < per_scenario) {
          "is-active"
        } else {
          "is-pending"
        }
      }, character(1))
      div(
        class = "investigate-progress",
        div(
          class = "investigate-progress-heading",
          strong(investigate_progress_heading(
            route = "future",
            scenario = scenario,
            scenarios = scenarios,
            overall_completed = overall_completed,
            overall_total = overall_total,
            is_busy = busy(),
            has_comparison = !identical(completion_state()$future, FALSE)
          )),
          span(paste0(format(overall_completed, big.mark = ","), " of ",
            format(overall_total, big.mark = ","), " futures"))
        ),
        div(
          class = "investigate-progress-track",
          role = "progressbar",
          `aria-valuemin` = "0",
          `aria-valuemax` = as.character(overall_total),
          `aria-valuenow` = as.character(overall_completed),
          `aria-label` = "Threat and management response simulation progress",
          div(
            class = "investigate-progress-fill",
            style = paste0("width: ", percent, "%")
          )
        ),
        div(
          class = "investigate-progress-steps",
          lapply(seq_along(labels), function(index) {
            span(
              class = paste("investigate-progress-step", step_class[[index]]),
              icon(if (identical(step_class[[index]], "is-complete")) {
                "circle-check"
              } else {
                "circle"
              }),
              labels[[index]]
            )
          })
        )
      )
    })
    output$sensitivity_status <- renderUI({
      div(class = "investigate-state", status_state()[["sensitivity"]])
    })
    output$future_status <- renderUI({
      div(class = "investigate-state", status_state()[["future"]])
    })
    output$sensitivity_completion <- renderUI({
      state <- completion_state()$sensitivity
      if (identical(state, FALSE)) return(NULL)
      div(class = "investigate-completion", icon("circle-check"), state)
    })
    output$future_completion <- renderUI({
      state <- completion_state()$future
      if (identical(state, FALSE)) return(NULL)
      div(class = "investigate-completion", icon("circle-check"), state)
    })

    output$sensitivity_result_context <- renderUI({
      if (is.null(sensitivity_comparison())) {
        div(
          class = "sensitivity-result-context is-example",
          icon("circle-info"),
          span("Run the selected settings to create project evidence")
        )
      } else {
        div(
          class = "sensitivity-result-context is-current",
          icon("circle-check"),
          span("Results from your current project")
        )
      }
    })

    output$future_result_context <- renderUI({
      if (is.null(future_comparison())) {
        div(
          class = "sensitivity-result-context is-example",
          icon("circle-info"),
          span("Run the selected comparison to create project evidence")
        )
      } else {
        div(
          class = "sensitivity-result-context is-current",
          icon("circle-check"),
          span("Results from your current project")
        )
      }
    })

    output$sensitivity_plot <- renderPlot({
      comparison <- sensitivity_comparison()
      evidence <- investigate_sensitivity_display_data(
        comparison, sensitivity_model()$factor_id
      )
      validate(need(
        !is.null(evidence),
        "Run the three selected settings to see sensitivity evidence."
      ))
      investigate_sensitivity_probe_plot(evidence)
    }, res = 96)
    output$future_abundance_plot <- renderPlot({
      evidence <- investigate_future_display_data(future_comparison())
      validate(need(!is.null(evidence), "Run the three comparable futures to see abundance evidence."))
      investigate_future_abundance_plot(evidence)
    }, res = 96)
    output$future_risk_plot <- renderPlot({
      evidence <- investigate_future_display_data(future_comparison())
      validate(need(!is.null(evidence), "Run the comparison to see 100-pair warning risk."))
      investigate_future_risk_plot(evidence)
    }, res = 96)
    output$future_passage_plot <- renderPlot({
      evidence <- investigate_future_display_data(future_comparison())
      validate(need(!is.null(evidence), "Run the comparison to see when futures first cross below 100 pairs."))
      investigate_future_passage_plot(evidence)
    }, res = 96)
    output$future_difference_summary <- renderUI({
      evidence <- investigate_future_display_data(future_comparison())
      if (is.null(evidence)) return(NULL)
      investigate_future_difference_ui(evidence)
    })

    result_table <- function(comparison) {
      if (is.null(comparison)) return(NULL)
      table <- comparison$table
      data.frame(
        Scenario = table$student_label,
        `Final median (95% interval)` = paste0(
          investigate_format_number(table$final_median_abundance), " (",
          investigate_format_number(table$final_q025), "-",
          investigate_format_number(table$final_q975), ")"
        ),
        `Extinction by year 75` = investigate_format_probability(table$extinction_probability),
        `Extinction timing (conditional)` = vapply(
          table$extinction_conditional_median_year,
          investigate_format_timing, character(1)
        ),
        `Fewer than 100 pairs` = investigate_format_probability(table$quasi_extinction_probability),
        `100-pair timing (conditional)` = vapply(
          table$quasi_extinction_conditional_median_year,
          investigate_format_timing, character(1)
        ),
        `100-pair timing (overall)` = vapply(
          table$quasi_extinction_overall_median_year,
          investigate_format_timing, character(1), overall = TRUE
        ),
        `Change from preceding scenario: final median` = investigate_format_number(
          table$delta_final_median_abundance
        ),
        check.names = FALSE
      )
    }

    output$sensitivity_table <- renderTable({
      evidence <- investigate_sensitivity_display_data(
        sensitivity_comparison(), sensitivity_model()$factor_id
      )
      if (is.null(evidence)) return(NULL)
      investigate_sensitivity_probe_table(evidence)
    }, striped = TRUE, bordered = FALSE, spacing = "s", rownames = FALSE)
    output$future_table <- renderTable({
      evidence <- investigate_future_display_data(future_comparison())
      if (is.null(evidence)) return(NULL)
      investigate_future_probe_table(evidence)
    }, striped = TRUE, bordered = FALSE, spacing = "s", rownames = FALSE)

    save_result_notes <- function(route, comparison, interpretation, caveat) {
      notes <- c(Interpretation = trimws(investigate_or(interpretation, "")),
        Caveat = trimws(investigate_or(caveat, "")))
      notes <- notes[nzchar(notes)]
      if (length(notes) == 0L) {
        set_status(route, "No result observation was saved because both fields are empty.")
        return()
      }
      if (is.null(comparison)) {
        set_status(
          route,
          "Run all three comparable scenarios before saving result observations."
        )
        return()
      }
      observation <- list(
        title = if (identical(route, "sensitivity")) {
          "Sensitivity result observation"
        } else {
          "Future advice result observation"
        },
        note = paste(paste0(names(notes), ": ", notes), collapse = "\n"),
        run_ids = comparison$table$run_id
      )
      saved <- tryCatch(
        rPVA:::woodhen_add_prompt_once(project(), observation, Sys.time()),
        error = function(error) error
      )
      if (inherits(saved, "error")) {
        set_status(route, paste("Observation was not saved:", conditionMessage(saved)))
        return()
      }
      if (!saved$saved) {
        set_status(route, "The identical result observation was already recorded.")
        return()
      }
      set_status(route, "Observation ready to save in this project.")
      publish(observation_update_state, list(
        ok = TRUE,
        candidate = saved$project,
        family_id = comparison$family_id,
        route = route,
        message = "Result observation saved.",
        base_project_fingerprint = project()$project_fingerprint
      ))
    }

    observeEvent(input$save_sensitivity_notes, {
      save_result_notes(
        "sensitivity", sensitivity_comparison(),
        input$sensitivity_interpretation, input$sensitivity_caveat
      )
    })
    observeEvent(input$save_future_notes, {
      interpretation <- c(
        Threat = trimws(investigate_or(input$future_threat_observation, "")),
        Management = trimws(investigate_or(input$future_response_observation, ""))
      )
      interpretation <- interpretation[nzchar(interpretation)]
      save_result_notes(
        "future", future_comparison(),
        paste(
          paste0(names(interpretation), ": ", interpretation),
          collapse = "\n"
        ),
        input$future_caveat
      )
    })

    list(
      project_update = reactive(project_update_state()),
      observation_update = reactive(observation_update_state()),
      navigate = reactive(navigation_state()),
      progress_state = reactive(progress_state()),
      progress_history = reactive(progress_history_state()),
      busy_state = reactive(busy()),
      status_state = reactive(status_state()),
      selected_sensitivity_family_id = selected_sensitivity_family_id,
      sensitivity_comparison = sensitivity_comparison,
      future_comparison = future_comparison,
      completion_state = completion_state
    )
  })
}
