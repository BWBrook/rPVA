assessment_ilos <- function() {
  c(
    "Discuss the requirements for success in effective species conservation by integrating theory and case studies.",
    "Diagnose and solve biodiversity problems by applying fundamental principles from population and community ecology, genetics and ecosystem science.",
    "Evaluate the causes of uncertainty and controversy in the development of strategies for species conservation.",
    "Communicate a conservation problem to scientific peers and relevant stakeholders."
  )
}

assessment_criteria <- function() {
  data.frame(
    criterion = paste0("C", 1:4),
    marks = c(5L, 6L, 8L, 6L),
    assessment_criteria = c(
      "Describe the uses and limitations of simulation modelling in conservation decision-making.",
      "Model stochastic processes and causes of threat.",
      "Undertake scenario testing to compare the relative effectiveness of alternative management options.",
      "Translate simulation results and communicate them as conservation recommendations."
    ),
    stringsAsFactors = FALSE
  )
}

assessment_family_counts <- function(runs) {
  counts <- c(sensitivity = 0L, future = 0L)
  if (!is.list(runs) || length(runs) == 0L) return(counts)
  valid <- vapply(runs, function(run) {
    is.list(run) &&
      is.character(run$family_id) && length(run$family_id) == 1L &&
      is.character(run$scenario_type) && length(run$scenario_type) == 1L
  }, logical(1))
  if (!all(valid)) stop("Run identity is unavailable.", call. = FALSE)

  families <- split(runs, vapply(runs, `[[`, character(1), "family_id"))
  for (family in families) {
    types <- vapply(family, `[[`, character(1), "scenario_type")
    type_counts <- table(types)
    count_type <- function(type) {
      if (type %in% names(type_counts)) {
        as.integer(type_counts[[type]])
      } else {
        0L
      }
    }
    sensitivity <- all(types %in% c("locked_baseline", "sensitivity")) &&
      identical(count_type("locked_baseline"), 1L) &&
      count_type("sensitivity") >= 2L
    future <- all(types %in% c(
      "locked_baseline", "threat", "intervention"
    )) &&
      identical(count_type("locked_baseline"), 1L) &&
      identical(count_type("threat"), 1L) &&
      count_type("intervention") >= 1L
    if (isTRUE(sensitivity)) {
      counts[["sensitivity"]] <- counts[["sensitivity"]] + 1L
    } else if (isTRUE(future)) {
      counts[["future"]] <- counts[["future"]] + 1L
    }
  }
  counts
}

assessment_project_summary <- function(project) {
  required <- c(
    "title", "owner_label", "runs", "observations", "evidence_items"
  )
  if (!is.list(project) || !all(required %in% names(project))) {
    stop("Project summary fields are unavailable.", call. = FALSE)
  }
  counts <- assessment_family_counts(project$runs)
  historical <- vapply(project$runs, function(run) {
    identical(run$scenario_type, "reference") &&
      run$scenario_id %in% c(
        "01_no_mgmt", "02_pig_control", "03_captive_pig",
        "04_rodent_eradication"
      )
  }, logical(1))
  list(
    status = "available",
    title = project$title,
    owner_label = project$owner_label,
    historical_count = as.integer(sum(historical)),
    sensitivity_count = unname(counts[["sensitivity"]]),
    future_count = unname(counts[["future"]]),
    observation_count = as.integer(length(project$observations)),
    portfolio_count = as.integer(length(project$evidence_items))
  )
}

assessment_safe_project_summary <- function(project) {
  if (is.null(project)) {
    return(list(
      status = "empty", title = NULL, owner_label = NULL,
      historical_count = 0L, sensitivity_count = 0L, future_count = 0L,
      observation_count = 0L, portfolio_count = 0L
    ))
  }
  tryCatch(
    assessment_project_summary(project),
    error = function(...) list(
      status = "unavailable", title = NULL, owner_label = NULL,
      historical_count = 0L, sensitivity_count = 0L, future_count = 0L,
      observation_count = 0L, portfolio_count = 0L
    )
  )
}
