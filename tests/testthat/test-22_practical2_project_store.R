context("Practical 2 browser project store")

browser_snapshot_json <- function(value) {
  rawToChar(woodhen_json_bytes(value))
}

test_that("browser snapshot is deterministic and round-trips without import provenance", {
  project <- new_woodhen_project(
    "Future advice",
    "Study group",
    now = as.POSIXct("2026-07-22 10:00:00", tz = "UTC")
  )

  first <- rPVA:::woodhen_project_browser_snapshot(project)
  second <- rPVA:::woodhen_project_browser_snapshot(project)
  restored <- rPVA:::read_woodhen_project_browser_snapshot(first)

  expect_type(first, "character")
  expect_length(first, 1L)
  expect_identical(first, second)
  expect_identical(restored, project)
  expect_length(restored$provenance$imports, 0L)
  expect_length(restored$provenance$exports, 0L)
})

test_that("browser snapshot rejects non-scalar, invalid JSON, UTF-8, and byte overflow", {
  project <- new_woodhen_project(now = as.POSIXct("2026-07-22 10:00:00", tz = "UTC"))
  snapshot <- rPVA:::woodhen_project_browser_snapshot(project)
  invalid_utf8 <- rawToChar(as.raw(0xff))
  Encoding(invalid_utf8) <- "bytes"

  expect_error(rPVA:::read_woodhen_project_browser_snapshot(NULL), "scalar|character")
  expect_error(rPVA:::read_woodhen_project_browser_snapshot(c(snapshot, snapshot)), "scalar|character")
  expect_error(rPVA:::read_woodhen_project_browser_snapshot(NA_character_), "scalar|character")
  expect_error(rPVA:::read_woodhen_project_browser_snapshot("not json"), "JSON")
  expect_error(rPVA:::read_woodhen_project_browser_snapshot(invalid_utf8), "UTF-8")
  expect_error(
    rPVA:::read_woodhen_project_browser_snapshot(snapshot, max_bytes = nchar(snapshot, type = "bytes") - 1L),
    "size|byte|limit"
  )
  expect_error(rPVA:::read_woodhen_project_browser_snapshot(snapshot, max_bytes = -1), "max_bytes")
})

test_that("browser snapshot enforces exact document and version metadata", {
  project <- new_woodhen_project(now = as.POSIXct("2026-07-22 10:00:00", tz = "UTC"))
  document <- woodhen_json_parse(
    charToRaw(rPVA:::woodhen_project_browser_snapshot(project)),
    "browser snapshot"
  )

  extra <- document
  extra$script <- "alert(1)"
  expect_error(
    rPVA:::read_woodhen_project_browser_snapshot(browser_snapshot_json(extra)),
    "exactly"
  )

  wrong_format <- document
  wrong_format$format_version <- "woodhen-project-json-v999"
  expect_s3_class(
    tryCatch(
      rPVA:::read_woodhen_project_browser_snapshot(browser_snapshot_json(wrong_format)),
      error = identity
    ),
    "woodhen_unsupported_version"
  )

  wrong_schema <- document
  wrong_schema$project_schema_version <- "woodhen-project-v999"
  expect_s3_class(
    tryCatch(
      rPVA:::read_woodhen_project_browser_snapshot(browser_snapshot_json(wrong_schema)),
      error = identity
    ),
    "woodhen_unsupported_version"
  )

  wrong_id <- document
  wrong_id$project_id <- "../../project"
  expect_error(
    rPVA:::read_woodhen_project_browser_snapshot(browser_snapshot_json(wrong_id)),
    "project_id.*malformed"
  )
})

test_that("browser snapshot rejects outer, decoded, and stable fingerprint mismatch", {
  project <- new_woodhen_project(now = as.POSIXct("2026-07-22 10:00:00", tz = "UTC"))
  document <- woodhen_json_parse(
    charToRaw(rPVA:::woodhen_project_browser_snapshot(project)),
    "browser snapshot"
  )
  other_id <- sub(".$", if (substr(project$project_id, nchar(project$project_id), nchar(project$project_id)) == "0") "1" else "0", project$project_id)
  other_fingerprint <- paste(rep("0", 64), collapse = "")

  outer_id <- document
  outer_id$project_id <- other_id
  expect_error(
    rPVA:::read_woodhen_project_browser_snapshot(browser_snapshot_json(outer_id)),
    "metadata mismatch|project_id"
  )

  outer_fingerprint <- document
  outer_fingerprint$project_fingerprint <- other_fingerprint
  expect_error(
    rPVA:::read_woodhen_project_browser_snapshot(browser_snapshot_json(outer_fingerprint)),
    "fingerprint"
  )

  decoded <- woodhen_typed_decode(document$payload, "project")
  decoded$title <- "Tampered"
  document$payload <- woodhen_typed_encode(decoded, "project")
  expect_error(
    rPVA:::read_woodhen_project_browser_snapshot(browser_snapshot_json(document)),
    "fingerprint"
  )
})

test_that("project store key and save record have exact scoped fields", {
  app_dir <- rPVA:::practical2_shiny_app_dir()
  env <- new.env(parent = globalenv())
  sys.source(file.path(app_dir, "project_helpers.R"), envir = env)
  project <- new_woodhen_project("Advice", now = as.POSIXct("2026-07-22 10:00:00", tz = "UTC"))
  snapshot <- rPVA:::woodhen_project_browser_snapshot(project)
  saved_at <- "2026-07-22T10:01:00Z"
  record <- env$project_store_record(project, snapshot, saved_at, portable_request_fingerprint = NULL)

  expect_identical(
    env$project_store_key(project$project_schema_version, project$project_id),
    paste0(project$project_schema_version, "::", project$project_id)
  )
  expect_named(record, c(
    "key", "contract_version", "schema_version", "project_id",
    "project_fingerprint", "title", "modified_at", "saved_at",
    "portable_request_fingerprint", "snapshot_json"
  ), ignore.order = FALSE)
  expect_identical(record$key, paste0(project$project_schema_version, "::", project$project_id))
  expect_identical(record$contract_version, "woodhen-project-store-contract-v1")
  expect_identical(record$snapshot_json, snapshot)
})

test_that("restore envelope requires the pending request and validates outer and decoded identity", {
  app_dir <- rPVA:::practical2_shiny_app_dir()
  env <- new.env(parent = globalenv())
  sys.source(file.path(app_dir, "project_helpers.R"), envir = env)
  project <- new_woodhen_project("Advice", now = as.POSIXct("2026-07-22 10:00:00", tz = "UTC"))
  snapshot <- rPVA:::woodhen_project_browser_snapshot(project)
  record <- env$project_store_record(project, snapshot, "2026-07-22T10:01:00Z", NULL)
  envelope <- list(
    contract_version = "woodhen-project-store-contract-v1",
    request_id = "restore-7",
    key = record$key,
    record = record
  )

  expect_identical(env$validate_project_store_restore(envelope, "restore-7"), project)
  expect_error(env$validate_project_store_restore(envelope, "restore-8"), "request")

  wrong_key <- envelope
  wrong_key$key <- paste0(record$key, "-wrong")
  expect_error(env$validate_project_store_restore(wrong_key, "restore-7"), "key")

  wrong_outer <- envelope
  wrong_outer$record$project_fingerprint <- paste(rep("0", 64), collapse = "")
  expect_error(env$validate_project_store_restore(wrong_outer, "restore-7"), "fingerprint")

  wrong_contract <- envelope
  wrong_contract$contract_version <- "woodhen-project-store-contract-v2"
  expect_error(env$validate_project_store_restore(wrong_contract, "restore-7"), "contract")

  extra <- envelope
  extra$html <- "<script>bad()</script>"
  expect_error(env$validate_project_store_restore(extra, "restore-7"), "exactly")
})

test_that("storage status validator correlates kind and exact request identity", {
  app_dir <- rPVA:::practical2_shiny_app_dir()
  env <- new.env(parent = globalenv())
  sys.source(file.path(app_dir, "project_helpers.R"), envir = env)
  project <- rPVA::new_woodhen_project("Status advice")
  snapshot <- rPVA:::woodhen_project_browser_snapshot(project)
  record <- env$project_store_record(project, snapshot, "2026-07-22T10:01:00Z", NULL)
  status <- list(
    contract_version = "woodhen-project-store-contract-v1",
    request_id = "save-7",
    key = record$key,
    status = "saved",
    project_id = record$project_id,
    project_fingerprint = record$project_fingerprint,
    message = "Autosaved in this browser."
  )
  save_request <- list(
    request_id = "save-7",
    kind = "save",
    record = record
  )

  expect_identical(env$validate_project_store_status(status, save_request), status)

  wrong_kind <- status
  wrong_kind$status <- "portable_marked"
  expect_error(
    env$validate_project_store_status(wrong_kind, save_request),
    "kind|save"
  )

  other <- rPVA::new_woodhen_project("Other status advice")
  wrong_identity <- status
  wrong_identity$key <- env$project_store_key(other$project_schema_version, other$project_id)
  wrong_identity$project_id <- other$project_id
  wrong_identity$project_fingerprint <- other$project_fingerprint
  expect_error(
    env$validate_project_store_status(wrong_identity, save_request),
    "match|key|project"
  )

  portable_request <- list(
    request_id = "portable-8",
    kind = "portable",
    record = list(
      key = record$key,
      project_id = record$project_id,
      project_fingerprint = record$project_fingerprint
    )
  )
  portable_status <- status
  portable_status$request_id <- "portable-8"
  portable_status$status <- "portable_error"
  expect_identical(
    env$validate_project_store_status(portable_status, portable_request),
    portable_status
  )

  save_as_portable <- portable_status
  save_as_portable$status <- "saved"
  expect_error(
    env$validate_project_store_status(save_as_portable, portable_request),
    "kind|portable"
  )
})

test_that("JavaScript implements inventory-first, one restore input, keyed debounce, and error paths", {
  app_dir <- rPVA:::practical2_shiny_app_dir()
  js_path <- file.path(app_dir, "www", "project-store.js")
  js <- paste(readLines(js_path, warn = FALSE), collapse = "\n")

  expect_identical(attr(system2("node", c("--check", shQuote(js_path))), "status"), NULL)
  expect_match(js, 'DATABASE_NAME = "rPVA-practical2-projects"', fixed = TRUE)
  expect_match(js, 'STORE_NAME = "project_snapshots"', fixed = TRUE)
  expect_match(js, 'CONTRACT_VERSION = "woodhen-project-store-contract-v1"', fixed = TRUE)
  expect_match(js, 'schema_version + "::" + project_id', fixed = TRUE)
  expect_equal(length(gregexpr('Shiny.setInputValue("project_store_restore"', js, fixed = TRUE)[[1L]]), 1L)
  expect_lt(
    regexpr('Shiny.setInputValue("project_store_inventory"', js, fixed = TRUE)[[1L]],
    regexpr('Shiny.setInputValue("project_store_restore"', js, fixed = TRUE)[[1L]]
  )
  expect_match(js, 'Shiny.addCustomMessageHandler("woodhen-project-store-restore"', fixed = TRUE)
  expect_match(js, 'Shiny.addCustomMessageHandler("woodhen-project-store-save"', fixed = TRUE)
  expect_match(js, 'Shiny.addCustomMessageHandler("woodhen-project-store-mark-portable"', fixed = TRUE)
  expect_match(js, "pendingSaves = new Map", fixed = TRUE)
  expect_match(js, "pending.portableRequests.push(message)", fixed = TRUE)
  expect_match(js, "window.setTimeout", fixed = TRUE)
  expect_match(js, "store.put", fixed = TRUE)
  expect_match(js, "request.onerror", fixed = TRUE)
  expect_match(js, "transaction.onerror", fixed = TRUE)
  expect_match(js, "request_id")
  expect_false(grepl("localStorage", js, fixed = TRUE))
  expect_false(grepl("eval\\(|innerHTML|document.write", js))
})

test_that("static store tests do not claim real IndexedDB persistence", {
  app_dir <- rPVA:::practical2_shiny_app_dir()
  production_text <- paste(readLines(file.path(app_dir, "README.md"), warn = FALSE), collapse = "\n")
  overclaim <- paste("autosave survives", "refresh")

  expect_false(grepl(overclaim, production_text, fixed = TRUE))
})
