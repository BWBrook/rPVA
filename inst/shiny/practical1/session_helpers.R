practical1_stage_groups <- list(
  core = c(
    "deterministic_baseline",
    "carrying_capacity",
    "demographic_stochasticity",
    "environmental_stochasticity",
    "intervention"
  ),
  extension = c(
    "genetic_stochasticity",
    "catastrophe",
    "extinction_vortex"
  )
)

practical1_mission_order <- unname(unlist(practical1_stage_groups, use.names = FALSE))

practical1_evidence_risk_stages <- c(
  "carrying_capacity",
  "demographic_stochasticity",
  "environmental_stochasticity",
  "genetic_stochasticity",
  "catastrophe"
)

practical1_evidence_action_stages <- c("intervention", "extinction_vortex")

attach_session_run_id <- function(run, run_id) {
  stopifnot(is.list(run), length(run_id) == 1L, !is.na(run_id), run_id >= 1)
  run$session_run_id <- as.integer(run_id)
  run
}

session_run_id <- function(run) {
  id <- run$session_run_id
  if (length(id) != 1L || is.na(id)) {
    stop("A session run must have one non-missing session_run_id.", call. = FALSE)
  }
  as.integer(id)
}

completed_stage_ids <- function(runs, baseline_started) {
  if (!length(runs)) {
    return(character())
  }
  stages <- unique(vapply(runs, `[[`, character(1), "stage"))
  if (!isTRUE(baseline_started)) {
    stages <- setdiff(stages, "deterministic_baseline")
  }
  practical1_mission_order[practical1_mission_order %in% stages]
}

next_incomplete_core_stage <- function(completed_stages) {
  remaining <- setdiff(practical1_stage_groups$core, completed_stages)
  if (length(remaining)) remaining[[1]] else NA_character_
}

first_baseline_run_id <- function(runs) {
  if (!length(runs)) {
    return(NA_integer_)
  }
  stages <- vapply(runs, `[[`, character(1), "stage")
  index <- which(stages == "deterministic_baseline")
  if (!length(index)) NA_integer_ else session_run_id(runs[[index[[1]]]])
}

latest_stage_group_run_id <- function(runs, eligible_stages) {
  if (!length(runs)) {
    return(NA_integer_)
  }
  stages <- vapply(runs, `[[`, character(1), "stage")
  index <- which(stages %in% eligible_stages)
  if (!length(index)) NA_integer_ else session_run_id(runs[[index[[length(index)]]]])
}

default_evidence_run_ids <- function(runs, baseline_started) {
  ids <- c(
    if (isTRUE(baseline_started)) first_baseline_run_id(runs) else NA_integer_,
    latest_stage_group_run_id(runs, practical1_evidence_risk_stages),
    latest_stage_group_run_id(runs, practical1_evidence_action_stages)
  )
  as.integer(ids[!is.na(ids)])
}

select_session_runs <- function(runs, selected_ids) {
  selected_ids <- as.integer(selected_ids)
  if (!length(selected_ids)) {
    return(list())
  }
  run_ids <- vapply(runs, session_run_id, integer(1))
  index <- match(selected_ids, run_ids)
  if (anyNA(index)) {
    stop("Every selected evidence ID must identify a successful session run.", call. = FALSE)
  }
  runs[index]
}

evidence_selection_signature <- function(selected_ids) {
  paste(as.integer(selected_ids), collapse = ":")
}

evidence_pack_signature <- function(selected_ids, observations, synthesis) {
  synthesis <- if (is.null(synthesis)) "" else trimws(as.character(synthesis))
  state <- list(
    selected_ids = as.integer(selected_ids),
    observations = observations,
    synthesis = synthesis
  )
  paste(as.integer(serialize(state, NULL, version = 2)), collapse = "-")
}

valid_evidence_observation <- function(observation) {
  is.list(observation) &&
    all(c("id", "run_ids", "note") %in% names(observation)) &&
    length(observation$id) == 1L &&
    !is.na(observation$id) &&
    observation$id >= 1L &&
    length(observation$run_ids) == 3L &&
    length(unique(as.integer(observation$run_ids))) == 3L &&
    length(observation$note) == 1L &&
    !is.na(observation$note) &&
    nzchar(trimws(as.character(observation$note)))
}

remove_evidence_observation <- function(observations, observation_id) {
  valid_id <-
    is.numeric(observation_id) &&
    length(observation_id) == 1L &&
    is.finite(observation_id) &&
    observation_id >= 1 &&
    observation_id == floor(observation_id)
  if (!valid_id) {
    stop("observation_id must be one positive integer.", call. = FALSE)
  }
  observation_id <- as.integer(observation_id)
  ids <- vapply(observations, `[[`, integer(1), "id")
  if (!observation_id %in% ids) {
    stop("The requested evidence observation does not exist.", call. = FALSE)
  }
  observations[ids != observation_id]
}

evidence_readiness <- function(runs,
                               selected_ids,
                               interpretation = NULL,
                               interpretation_signature = "",
                               baseline_started,
                               observations = NULL,
                               synthesis = NULL) {
  selected_ids <- as.integer(selected_ids)
  selected <- tryCatch(
    select_session_runs(runs, selected_ids),
    error = function(error) list()
  )
  stages <- if (length(selected)) {
    vapply(selected, `[[`, character(1), "stage")
  } else {
    character()
  }

  if (!is.null(observations)) {
    observation_present <- length(observations) > 0L && all(vapply(
      observations,
      valid_evidence_observation,
      logical(1)
    ))
    synthesis_present <-
      length(synthesis) == 1L &&
      !is.na(synthesis) &&
      nzchar(trimws(as.character(synthesis)))

    checks <- c(
      baseline = isTRUE(baseline_started) && sum(stages == "deterministic_baseline") == 1L,
      risk = sum(stages %in% practical1_evidence_risk_stages) == 1L,
      action = sum(stages %in% practical1_evidence_action_stages) == 1L,
      exactly_three = length(selected_ids) == 3L && length(unique(selected_ids)) == 3L && length(selected) == 3L,
      observation = observation_present,
      synthesis = synthesis_present
    )

    return(list(
      ready = all(checks),
      checks = checks,
      messages = c(
        baseline = "Baseline run 1 is included.",
        risk = "One risk-mechanism run is selected.",
        action = "One intervention or vortex run is selected.",
        exactly_three = "The evidence set contains exactly three different runs.",
        observation = "At least one evidence observation is saved.",
        synthesis = "A final synthesis is present."
      )
    ))
  }

  interpretation_present <- length(interpretation) == 1L && nzchar(trimws(interpretation))
  current_signature <- evidence_selection_signature(selected_ids)

  checks <- c(
    baseline = isTRUE(baseline_started) && sum(stages == "deterministic_baseline") == 1L,
    risk = sum(stages %in% practical1_evidence_risk_stages) == 1L,
    action = sum(stages %in% practical1_evidence_action_stages) == 1L,
    exactly_three = length(selected_ids) == 3L && length(unique(selected_ids)) == 3L && length(selected) == 3L,
    interpretation = interpretation_present,
    interpretation_current = interpretation_present && identical(interpretation_signature, current_signature)
  )

  list(
    ready = all(checks),
    checks = checks,
    messages = c(
      baseline = "Baseline run 1 is included.",
      risk = "One risk-mechanism run is selected.",
      action = "One intervention or vortex run is selected.",
      exactly_three = "The evidence set contains exactly three different runs.",
      interpretation = "A one-sentence interpretation is present.",
      interpretation_current = "The interpretation matches the current selection."
    )
  )
}
