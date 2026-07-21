project_store_contract_version <- function() {
  "woodhen-project-store-contract-v1"
}

project_store_exact_fields <- function(value, fields, path) {
  if (!is.list(value) || is.null(names(value)) || anyDuplicated(names(value)) ||
      !setequal(names(value), fields)) {
    stop("`", path, "` must contain exactly: ", paste(fields, collapse = ", "), ".", call. = FALSE)
  }
  invisible(value)
}

project_store_scalar_text <- function(value, path, optional = FALSE) {
  if (optional && is.null(value)) {
    return(NULL)
  }
  if (!is.character(value) || length(value) != 1L || is.na(value) || !nzchar(value) ||
      !validUTF8(value)) {
    stop("`", path, "` must be one non-empty UTF-8 character value", if (optional) " or NULL" else "", ".", call. = FALSE)
  }
  enc2utf8(value)
}

project_store_request_id <- function(value, path = "request_id") {
  value <- project_store_scalar_text(value, path)
  if (!grepl("^[a-z]+-[A-Za-z0-9._-]+$", value, perl = TRUE)) {
    stop("`", path, "` is malformed.", call. = FALSE)
  }
  value
}

project_store_key <- function(schema_version, project_id) {
  schema_version <- project_store_scalar_text(schema_version, "schema_version")
  project_id <- project_store_scalar_text(project_id, "project_id")
  if (!identical(schema_version, rPVA:::woodhen_project_schema_version())) {
    stop("The project-store schema version is unsupported.", call. = FALSE)
  }
  rPVA:::woodhen_project_validate_id(
    project_id,
    "^woodhen_project_[0-9a-f]{16}$",
    "project_id"
  )
  paste0(schema_version, "::", project_id)
}

project_store_record_fields <- function(include_snapshot = TRUE) {
  fields <- c(
    "key", "contract_version", "schema_version", "project_id",
    "project_fingerprint", "title", "modified_at", "saved_at",
    "portable_request_fingerprint"
  )
  if (isTRUE(include_snapshot)) c(fields, "snapshot_json") else fields
}

project_store_validate_fingerprint <- function(value, path, optional = FALSE) {
  if (optional && is.null(value)) {
    return(NULL)
  }
  value <- project_store_scalar_text(value, path)
  rPVA:::woodhen_project_validate_id(value, "^[0-9a-f]{64}$", path)
  value
}

project_store_record <- function(project,
                                 snapshot_json,
                                 saved_at,
                                 portable_request_fingerprint = NULL) {
  rPVA::validate_woodhen_project(project)
  decoded <- rPVA:::read_woodhen_project_browser_snapshot(snapshot_json)
  if (!identical(decoded, project)) {
    stop("The browser snapshot does not exactly match the live project.", call. = FALSE)
  }
  saved_at <- rPVA:::woodhen_project_time(saved_at, "saved_at")
  project_store_validate_fingerprint(
    portable_request_fingerprint,
    "portable_request_fingerprint",
    optional = TRUE
  )
  list(
    key = project_store_key(project$project_schema_version, project$project_id),
    contract_version = project_store_contract_version(),
    schema_version = project$project_schema_version,
    project_id = project$project_id,
    project_fingerprint = project$project_fingerprint,
    title = project$title,
    modified_at = project$modified_at,
    saved_at = saved_at,
    portable_request_fingerprint = portable_request_fingerprint,
    snapshot_json = snapshot_json
  )
}

validate_project_store_record <- function(record,
                                          include_snapshot = TRUE,
                                          max_snapshot_bytes = 50 * 1024^2) {
  project_store_exact_fields(
    record,
    project_store_record_fields(include_snapshot),
    "project-store record"
  )
  if (!identical(record$contract_version, project_store_contract_version())) {
    stop("The project-store record contract version is unsupported.", call. = FALSE)
  }
  expected_key <- project_store_key(record$schema_version, record$project_id)
  if (!identical(record$key, expected_key)) {
    stop("The project-store record key does not match its schema and project ID.", call. = FALSE)
  }
  project_store_validate_fingerprint(record$project_fingerprint, "project_fingerprint")
  project_store_scalar_text(record$title, "title", optional = TRUE)
  rPVA:::woodhen_project_time(record$modified_at, "modified_at")
  rPVA:::woodhen_project_time(record$saved_at, "saved_at")
  project_store_validate_fingerprint(
    record$portable_request_fingerprint,
    "portable_request_fingerprint",
    optional = TRUE
  )
  if (!isTRUE(include_snapshot)) {
    return(invisible(record))
  }

  candidate <- rPVA:::read_woodhen_project_browser_snapshot(
    record$snapshot_json,
    max_bytes = max_snapshot_bytes
  )
  for (field in c("project_id", "project_fingerprint")) {
    if (!identical(candidate[[field]], record[[field]])) {
      stop("Project-store record/decoded project mismatch for `", field, "`.", call. = FALSE)
    }
  }
  if (!identical(candidate$project_schema_version, record$schema_version)) {
    stop("Project-store record/decoded project mismatch for `schema_version`.", call. = FALSE)
  }
  candidate
}

validate_project_store_inventory <- function(envelope) {
  project_store_exact_fields(
    envelope,
    c("contract_version", "records"),
    "project_store_inventory"
  )
  if (!identical(envelope$contract_version, project_store_contract_version())) {
    stop("The project-store inventory contract version is unsupported.", call. = FALSE)
  }
  if (!is.list(envelope$records) || !is.null(names(envelope$records))) {
    stop("`project_store_inventory$records` must be one unnamed record list.", call. = FALSE)
  }
  lapply(envelope$records, validate_project_store_record, include_snapshot = FALSE)
  keys <- vapply(envelope$records, `[[`, character(1), "key")
  if (anyDuplicated(keys)) {
    stop("The project-store inventory contains duplicate keys.", call. = FALSE)
  }
  envelope$records
}

validate_project_store_restore <- function(envelope,
                                           pending_request,
                                           max_snapshot_bytes = 50 * 1024^2) {
  project_store_exact_fields(
    envelope,
    c("contract_version", "request_id", "key", "record"),
    "project_store_restore"
  )
  if (!identical(envelope$contract_version, project_store_contract_version())) {
    stop("The project-store restore contract version is unsupported.", call. = FALSE)
  }
  request_id <- project_store_request_id(envelope$request_id)
  expected_request_id <- if (is.list(pending_request)) {
    pending_request$request_id
  } else {
    pending_request
  }
  if (!identical(request_id, expected_request_id)) {
    stop("The project-store restore request ID is not pending.", call. = FALSE)
  }
  candidate <- validate_project_store_record(
    envelope$record,
    include_snapshot = TRUE,
    max_snapshot_bytes = max_snapshot_bytes
  )
  if (!identical(envelope$key, envelope$record$key)) {
    stop("The project-store restore envelope key does not match its record.", call. = FALSE)
  }
  if (is.list(pending_request)) {
    for (field in c("key", "project_id", "project_fingerprint")) {
      if (!identical(envelope$record[[field]], pending_request[[field]])) {
        stop("The project-store restore does not match pending `", field, "`.", call. = FALSE)
      }
    }
  }
  candidate
}

validate_project_store_status <- function(envelope, pending_request) {
  project_store_exact_fields(
    envelope,
    c(
      "contract_version", "request_id", "key", "status", "project_id",
      "project_fingerprint", "message"
    ),
    "project_store_status"
  )
  if (!identical(envelope$contract_version, project_store_contract_version())) {
    stop("The project-store status contract version is unsupported.", call. = FALSE)
  }
  if (!is.list(pending_request) ||
      !all(c("request_id", "kind", "record") %in% names(pending_request))) {
    stop("The pending project-store request is malformed.", call. = FALSE)
  }
  request_id <- project_store_request_id(envelope$request_id)
  if (!identical(request_id, pending_request$request_id)) {
    stop("The project-store status request ID is not pending.", call. = FALSE)
  }
  allowed_status <- switch(
    pending_request$kind,
    save = c("saved", "save_error", "superseded"),
    portable = c("portable_marked", "portable_error"),
    stop("The pending project-store request kind is unsupported.", call. = FALSE)
  )
  if (!envelope$status %in% allowed_status) {
    stop(
      "The project-store status is invalid for pending `",
      pending_request$kind,
      "` request kind.",
      call. = FALSE
    )
  }
  expected_key <- project_store_key(rPVA:::woodhen_project_schema_version(), envelope$project_id)
  if (!identical(envelope$key, expected_key)) {
    stop("The project-store status key is inconsistent.", call. = FALSE)
  }
  project_store_validate_fingerprint(envelope$project_fingerprint, "project_fingerprint")
  project_store_scalar_text(envelope$message, "message")
  expected <- pending_request$record
  for (field in c("key", "project_id", "project_fingerprint")) {
    if (!identical(envelope[[field]], expected[[field]])) {
      stop("The project-store status does not match pending `", field, "`.", call. = FALSE)
    }
  }
  envelope
}

replace_live_project <- function(project_state, candidate) {
  rPVA::validate_woodhen_project(candidate)
  project_state(candidate)
  invisible(candidate)
}
