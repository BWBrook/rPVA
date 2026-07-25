project_test_result <- function(scenario, abundance_shift = 0, seed = scenario$seed) {
  years <- scenario$spec$years
  reps <- scenario$spec$reps
  replicate_effect <- (seq_len(reps) %% 31L) - 15L
  total <- outer(0:years, replicate_effect, function(year, effect) {
    pmax(0, round(650 + abundance_shift + 2 * year + effect))
  })
  traj <- array(0, dim = c(years + 1L, length(scenario$spec$n0), reps))
  traj[, 1L, ] <- round(total * 0.20)
  traj[, 2L, ] <- total - traj[, 1L, ]
  normalized <- normalize_pva_spec(scenario$spec, stasis = NULL)

  list(
    Nend = total[years + 1L, ],
    traj = traj,
    sr_traj = matrix(0.5, nrow = years + 1L, ncol = reps),
    F_traj = matrix(0, nrow = years + 1L, ncol = reps),
    LE_traj = matrix(0, nrow = years + 1L, ncol = reps),
    ext_prob = rowMeans(total == 0),
    Nend_summary = list(
      median = as.numeric(stats::median(total[years + 1L, ])),
      lo95 = as.numeric(stats::quantile(total[years + 1L, ], 0.025, names = FALSE)),
      hi95 = as.numeric(stats::quantile(total[years + 1L, ], 0.975, names = FALSE))
    ),
    params = c(
      normalized$spec,
      list(years = years, reps = reps, stasis = normalized$stasis, seed = seed)
    ),
    raw = list(
      Nend = total[years + 1L, ], traj = traj,
      sr_traj = matrix(0.5, nrow = years + 1L, ncol = reps),
      F_traj = matrix(0, nrow = years + 1L, ncol = reps),
      LE_traj = matrix(0, nrow = years + 1L, ncol = reps)
    )
  )
}

project_test_run <- function(scenario, abundance_shift = 0) {
  compact_woodhen_run(
    project_test_result(scenario, abundance_shift = abundance_shift),
    scenario,
    sample_trajectories = 3L
  )
}

test_that("new projects have a stable versioned identity without consuming RNG", {
  set.seed(20260721)
  rng_before <- .Random.seed
  now <- as.POSIXct("2026-07-21 02:03:04", tz = "UTC")

  first <- new_woodhen_project("Cyclone options", "Study group", now = now)
  second <- new_woodhen_project("Cyclone options", "Study group", now = now)

  expect_identical(.Random.seed, rng_before)
  expect_false(identical(first$project_id, second$project_id))
  expect_match(first$project_id, "^woodhen_project_[0-9a-f]{16}$")
  expect_named(first, c(
    "project_schema_version", "project_id", "title", "owner_label",
    "created_at", "modified_at", "app_version", "model_version",
    "reference_library_version", "catalog_version", "scenarios",
    "scenario_versions", "runs", "observations", "evidence_ids",
    "provenance", "fingerprint_algorithm", "canonicalization_version",
    "project_fingerprint"
  ))
  expect_equal(first$project_schema_version, "woodhen-project-v1")
  expect_equal(first$app_version, utils::packageDescription("rPVA")$Version)
  expect_equal(first$model_version, woodhen_model_version())
  expect_equal(first$reference_library_version, woodhen_reference_library_version())
  expect_equal(first$catalog_version, woodhen_investigation_catalog_version())
  expect_equal(first$created_at, "2026-07-21T02:03:04Z")
  expect_equal(first$modified_at, first$created_at)
  expect_length(first$scenarios, 0L)
  expect_length(first$scenario_versions, 0L)
  expect_length(first$runs, 0L)
  expect_length(first$observations, 0L)
  expect_length(first$evidence_ids, 0L)
  expect_identical(first$project_fingerprint, woodhen_project_fingerprint(first))
  expect_silent(validate_woodhen_project(first))
})

test_that("compact runs require the current 100-pair warning threshold", {
  scenario <- build_woodhen_sensitivity_family("K", c(500, 150))$scenarios[[1L]]
  run <- project_test_run(scenario)
  run$quasi_extinction_50_pairs$threshold_pairs <- 50L

  expect_error(
    rPVA:::woodhen_project_validate_run(run),
    "100-pair warning threshold"
  )
})

test_that("project mutations are pure, version scenarios, and retain completed evidence", {
  old_family <- build_woodhen_sensitivity_family("K", c(350, 250), seed = 144L)
  new_family <- build_woodhen_sensitivity_family("K", c(300, 250), seed = 144L)
  old_baseline <- old_family$scenarios[[1L]]
  old_scenario <- old_family$scenarios[[2L]]
  new_baseline <- new_family$scenarios[[1L]]
  new_scenario <- new_family$scenarios[[2L]]
  old_run <- project_test_run(old_scenario)
  now <- as.POSIXct("2026-07-21 03:00:00", tz = "UTC")

  empty <- new_woodhen_project(now = now)
  with_old <- add_woodhen_scenario(empty, old_baseline, now = now + 1)
  with_old <- add_woodhen_scenario(with_old, old_scenario, now = now + 2)
  with_run <- add_woodhen_run(with_old, old_run, now = now + 3)
  with_new_parent <- add_woodhen_scenario(with_run, new_baseline, now = now + 4)
  versioned <- add_woodhen_scenario(
    with_new_parent,
    new_scenario,
    now = now + 5,
    supersedes_scenario_id = old_scenario$scenario_id
  )

  expect_length(empty$scenarios, 0L)
  expect_length(with_old$runs, 0L)
  expect_identical(with_run$scenarios, list(old_baseline, old_scenario))
  expect_identical(with_run$runs, list(old_run))
  expect_identical(versioned$scenarios[[2L]], old_scenario)
  expect_identical(versioned$runs[[1L]], old_run)
  expect_identical(versioned$scenarios[[4L]], new_scenario)
  expect_equal(versioned$scenario_versions[[1L]]$scenario_version, 1L)
  expect_equal(versioned$scenario_versions[[4L]]$scenario_version, 2L)
  expect_null(versioned$scenario_versions[[1L]]$supersedes_scenario_id)
  expect_equal(
    versioned$scenario_versions[[4L]]$supersedes_scenario_id,
    old_scenario$scenario_id
  )
  expect_identical(with_run$runs[[1L]]$scenario, old_scenario)
  expect_false(identical(
    with_run$project_fingerprint,
    versioned$project_fingerprint
  ))
  expect_silent(validate_woodhen_project(versioned))
})

test_that("run addition is idempotent and rejects identity collisions", {
  scenario <- build_woodhen_sensitivity_family("K", c(350, 250), seed = 208L)$scenarios[[1L]]
  run <- project_test_run(scenario)
  project <- add_woodhen_scenario(new_woodhen_project(), scenario)
  once <- add_woodhen_run(project, run)
  twice <- add_woodhen_run(once, run)

  expect_identical(twice, once)
  collision <- run
  collision$diagnostics$message <- paste(collision$diagnostics$message, "Changed")
  expect_error(add_woodhen_run(once, collision), "collision")
  expect_identical(once$runs[[1L]], run)
})

test_that("compact run validation rejects internally inconsistent evidence", {
  scenario <- build_woodhen_sensitivity_family("K", c(350, 250), seed = 209L)$scenarios[[1L]]
  run <- project_test_run(scenario)
  project <- add_woodhen_scenario(new_woodhen_project(), scenario)

  invalid_probability <- run
  invalid_probability$summary$PE <- 2
  expect_error(add_woodhen_run(project, invalid_probability), "summary")

  invalid_quantile <- run
  invalid_quantile$final_abundance$median <- invalid_quantile$final_abundance$median + 1
  expect_error(add_woodhen_run(project, invalid_quantile), "final_abundance")

  invalid_baseline <- run
  invalid_baseline$baseline_spec_fingerprint <- paste(rep("0", 64L), collapse = "")
  expect_error(add_woodhen_run(project, invalid_baseline), "baseline")

  raw_payload <- run
  raw_payload$raw <- list(traj = array(1, c(2L, 2L, 2L)))
  expect_error(add_woodhen_run(project, raw_payload), "exactly|unexpected")
})

test_that("observations and evidence selections use a strict ordered namespace", {
  scenario <- build_woodhen_sensitivity_family("K", c(350, 250), seed = 92L)$scenarios[[1L]]
  run <- project_test_run(scenario)
  project <- add_woodhen_run(
    add_woodhen_scenario(new_woodhen_project(), scenario),
    run
  )
  set.seed(711)
  rng_before <- .Random.seed
  observed <- add_woodhen_observation(project, list(
    title = "Baseline pattern",
    note = "<script>remains inert plain text</script>",
    run_ids = run$run_id
  ), now = as.POSIXct("2026-07-21 04:00:00", tz = "UTC"))
  observation <- observed$observations[[1L]]

  expect_identical(.Random.seed, rng_before)
  expect_match(observation$observation_id, "^woodhen_observation_[0-9a-f]{16}$")
  expect_named(observation, c(
    "observation_schema_version", "observation_id", "title", "note",
    "run_ids", "created_at", "modified_at"
  ))
  expect_equal(observation$note, "<script>remains inert plain text</script>")
  selected <- select_woodhen_evidence(
    observed,
    c(observation$observation_id, run$run_id)
  )
  expect_identical(
    selected$evidence_ids,
    c(observation$observation_id, run$run_id)
  )
  expect_error(
    select_woodhen_evidence(observed, c(run$run_id, run$run_id)),
    "duplicate"
  )
  expect_error(select_woodhen_evidence(observed, "unknown"), "Unknown evidence")
  expect_error(
    add_woodhen_observation(project, list(
      title = "Missing run", note = "No evidence", run_ids = "woodhen_run_missing"
    )),
    "Unknown run"
  )
})

project_test_nontrivial_project <- function() {
  sensitivity <- build_woodhen_sensitivity_family("K", c(350, 250), seed = 630L)
  prospective <- build_woodhen_prospective_family(list(
    threat_id = "novel_disease",
    components = list(fecundity_effect = list(
      field = "fecund", operator = "multiply", value = 0.80
    ))
  ), seed = 630L)
  project <- new_woodhen_project(
    "Woodhen evidence",
    "Portable group",
    now = as.POSIXct("2026-07-21 05:00:00", tz = "UTC")
  )
  for (scenario in c(sensitivity$scenarios, prospective$scenarios)) {
    project <- add_woodhen_scenario(project, scenario)
  }
  runs <- list(
    project_test_run(sensitivity$scenarios[[1L]]),
    project_test_run(sensitivity$scenarios[[2L]], -80),
    project_test_run(prospective$scenarios[[2L]], -120)
  )
  for (run in runs) {
    project <- add_woodhen_run(project, run)
  }
  project <- add_woodhen_observation(project, list(
    title = "Contrasting futures",
    note = "The disease threat lowered the median; uncertainty remains visible.",
    run_ids = vapply(runs[c(1L, 3L)], `[[`, character(1), "run_id")
  ))
  select_woodhen_evidence(project, c(
    runs[[3L]]$run_id,
    project$observations[[1L]]$observation_id,
    runs[[1L]]$run_id
  ))
}

project_test_extract_members <- function(archive) {
  directory <- tempfile("woodhen-project-test-")
  dir.create(directory)
  zip::unzip(
    archive,
    files = c("manifest.json", "project.json"),
    exdir = directory,
    overwrite = FALSE
  )
  list(
    directory = directory,
    manifest = readBin(file.path(directory, "manifest.json"), "raw", n = 10^7),
    project = readBin(file.path(directory, "project.json"), "raw", n = 10^7)
  )
}

project_test_write_archive <- function(files, archive, modes = NULL) {
  stage <- tempfile("woodhen-hostile-stage-")
  dir.create(stage)
  for (name in names(files)) {
    path <- file.path(stage, name)
    dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
    value <- files[[name]]
    if (is.raw(value)) {
      writeBin(value, path)
    } else {
      writeLines(value, path, useBytes = TRUE)
    }
    if (!is.null(modes) && name %in% names(modes)) {
      Sys.chmod(path, modes[[name]], use_umask = FALSE)
    }
  }
  zip::zip(
    archive,
    files = names(files),
    root = stage,
    mode = "mirror",
    include_directories = FALSE
  )
  invisible(archive)
}

project_test_infozip_archive <- function(files, archive) {
  stage <- tempfile("woodhen-infozip-stage-")
  dir.create(stage)
  for (name in names(files)) {
    value <- files[[name]]
    path <- file.path(stage, name)
    if (is.raw(value)) writeBin(value, path) else writeLines(value, path, useBytes = TRUE)
  }
  old_directory <- setwd(stage)
  on.exit(setwd(old_directory), add = TRUE)
  status <- system2("zip", c("-q", archive, names(files)))
  expect_equal(status, 0L)
  invisible(archive)
}

project_test_rename_zip_member <- function(archive, old_name, new_name) {
  notes <- system2("zipnote", archive, stdout = TRUE)
  position <- match(paste("@", old_name), notes)
  stopifnot(!is.na(position))
  notes <- append(notes, paste0("@=", new_name), after = position)
  note_path <- tempfile("woodhen-zipnote-")
  writeLines(notes, note_path, useBytes = TRUE)
  status <- system(sprintf(
    "zipnote -w %s < %s",
    shQuote(archive),
    shQuote(note_path)
  ))
  expect_equal(status, 0L)
  invisible(archive)
}

project_test_raw_replace <- function(path, old, new) {
  stopifnot(nchar(old, type = "bytes") == nchar(new, type = "bytes"))
  bytes <- readBin(path, "raw", n = file.info(path)$size)
  old_bytes <- charToRaw(old)
  new_bytes <- charToRaw(new)
  starts <- which(bytes == old_bytes[[1L]])
  replaced <- 0L
  for (start in starts) {
    end <- start + length(old_bytes) - 1L
    if (end <= length(bytes) && identical(bytes[start:end], old_bytes)) {
      bytes[start:end] <- new_bytes
      replaced <- replaced + 1L
    }
  }
  stopifnot(replaced >= 2L)
  writeBin(bytes, path)
  invisible(path)
}

project_test_repack <- function(valid_archive,
                                output,
                                mutate_project = identity,
                                mutate_manifest = identity) {
  members <- project_test_extract_members(valid_archive)
  project_bytes <- mutate_project(members$project)
  manifest <- woodhen_json_parse(members$manifest, "manifest.json")
  manifest <- mutate_manifest(manifest)
  manifest$project_json_sha256 <- digest::digest(
    project_bytes,
    algo = "sha256",
    serialize = FALSE
  )
  project_test_write_archive(
    list(
      manifest.json = woodhen_json_bytes(manifest),
      project.json = project_bytes
    ),
    output
  )
}

project_test_mutate_document <- function(bytes, mutate_project) {
  document <- woodhen_json_parse(bytes, "project.json")
  project <- woodhen_typed_decode(document$payload, "project.json$payload")
  project <- mutate_project(project)
  document$project_schema_version <- project$project_schema_version
  document$project_id <- project$project_id
  document$project_fingerprint <- project$project_fingerprint
  document$payload <- woodhen_typed_encode(project)
  woodhen_json_bytes(document)
}

project_test_repack_resigned <- function(valid_archive, output, mutate_project) {
  members <- project_test_extract_members(valid_archive)
  document <- woodhen_json_parse(members$project, "project.json")
  project <- woodhen_typed_decode(document$payload, "project.json$payload")
  project <- mutate_project(project)
  project$project_fingerprint <- woodhen_project_fingerprint(project)
  document$project_schema_version <- project$project_schema_version
  document$project_id <- project$project_id
  document$project_fingerprint <- project$project_fingerprint
  document$payload <- woodhen_typed_encode(project)
  project_bytes <- woodhen_json_bytes(document)
  manifest <- woodhen_json_parse(members$manifest, "manifest.json")
  manifest$project_schema_version <- project$project_schema_version
  manifest$project_id <- project$project_id
  manifest$project_fingerprint <- project$project_fingerprint
  manifest$project_json_sha256 <- digest::digest(
    project_bytes,
    algo = "sha256",
    serialize = FALSE
  )
  project_test_write_archive(
    list(
      manifest.json = woodhen_json_bytes(manifest),
      project.json = project_bytes
    ),
    output
  )
}

test_that("typed JSON preserves non-trivial R semantics deterministically", {
  value <- list(
    integer = c(1L, NA_integer_, 3L),
    double = c(1, NA_real_, 3.25),
    logical = c(TRUE, NA, FALSE),
    character = c("Woodhen", NA_character_, ""),
    matrix = matrix(as.numeric(1:6), nrow = 2L),
    data_frame = data.frame(
      year = 0:2,
      estimate = c(1, NA_real_, 3.5),
      label = c("a", "b", "c"),
      stringsAsFactors = FALSE
    ),
    empty_vector = integer(),
    empty_list = list(),
    missing = NULL
  )
  reordered <- value[rev(names(value))]

  decoded <- woodhen_typed_decode(woodhen_typed_encode(value))
  expect_identical(decoded, value[order(names(value))])
  expect_identical(
    woodhen_json_bytes(woodhen_typed_encode(value)),
    woodhen_json_bytes(woodhen_typed_encode(reordered))
  )
  duplicate <- list(
    type = "object",
    names = list("a", "a"),
    values = list(woodhen_typed_encode(1L), woodhen_typed_encode(2L)),
    classes = NULL
  )
  expect_error(woodhen_typed_decode(duplicate), "duplicate")
  expect_error(woodhen_json_parse(charToRaw('{"a":1,"a":2}')), "duplicate")
  expect_error(woodhen_json_parse(charToRaw("[1,2,3]")), "JSON object")
  expect_error(woodhen_json_parse(as.raw(c(0x7b, 0x22, 0x61, 0x22, 0x3a, 0xff, 0x7d))), "JSON")
})

test_that("portable packages round trip exact scientific and selected evidence", {
  project <- project_test_nontrivial_project()
  first_path <- tempfile(fileext = ".zip")
  deterministic_path <- tempfile(fileext = ".zip")
  second_path <- tempfile(fileext = ".zip")
  export_time <- as.POSIXct("2026-07-21 06:00:00", tz = "UTC")

  write_woodhen_project_package(project, first_path, now = export_time)
  write_woodhen_project_package(project, deterministic_path, now = export_time)
  first_members <- project_test_extract_members(first_path)
  deterministic_members <- project_test_extract_members(deterministic_path)
  expect_identical(first_members$project, deterministic_members$project)
  expect_identical(first_members$manifest, deterministic_members$manifest)

  manifest <- woodhen_json_parse(first_members$manifest, "manifest.json")
  expect_named(manifest, c(
    "package_format_version", "project_schema_version", "project_id",
    "project_fingerprint", "exported_at", "app_version", "model_version",
    "reference_library_version", "catalog_version", "members",
    "project_json_sha256", "digest_algorithm"
  ))
  expect_identical(manifest$members, as.list(c("manifest.json", "project.json")))
  expect_identical(
    manifest$project_json_sha256,
    digest::digest(first_members$project, algo = "sha256", serialize = FALSE)
  )

  imported <- read_woodhen_project_package(first_path)
  expect_equal(imported$project_id, project$project_id)
  expect_equal(imported$project_fingerprint, project$project_fingerprint)
  expect_equal(imported$evidence_ids, project$evidence_ids)
  expect_equal(imported$observations, project$observations)
  expect_equal(
    vapply(imported$runs, `[[`, character(1), "run_id"),
    vapply(project$runs, `[[`, character(1), "run_id")
  )
  expect_equal(
    vapply(imported$scenarios, `[[`, character(1), "spec_fingerprint"),
    vapply(project$scenarios, `[[`, character(1), "spec_fingerprint")
  )
  expect_identical(
    imported$scenarios[[5L]]$spec$annual_profiles$surv,
    project$scenarios[[5L]]$spec$annual_profiles$surv
  )
  expect_identical(imported$runs[[1L]]$summary, project$runs[[1L]]$summary)
  expect_identical(
    imported$runs[[1L]]$extinction_evidence$first_extinction_year,
    project$runs[[1L]]$extinction_evidence$first_extinction_year
  )
  expect_length(imported$provenance$exports, 1L)
  expect_length(imported$provenance$imports, 1L)

  write_woodhen_project_package(imported, second_path, now = export_time + 60)
  reimported <- read_woodhen_project_package(second_path)
  expect_equal(reimported$project_fingerprint, project$project_fingerprint)
  expect_equal(reimported$evidence_ids, project$evidence_ids)
  expect_equal(reimported$observations, project$observations)
  expect_identical(reimported$runs, imported$runs)
  expect_identical(reimported$scenarios, imported$scenarios)
  expect_gt(file.info(first_path)$size, 0)
  expect_lt(file.info(first_path)$size, 25 * 1024^2)
})

test_that("fingerprints include stable content and exclude volatile provenance", {
  project <- project_test_nontrivial_project()
  reordered <- project[rev(names(project))]
  class(reordered) <- class(project)
  provenance_only <- project
  provenance_only$provenance$imports[[1L]] <- list(
    event_schema_version = "woodhen-import-event-v1",
    imported_at = "2026-07-21T07:00:00Z",
    package_format_version = "woodhen-project-package-v1",
    source_project_id = project$project_id,
    source_project_fingerprint = project$project_fingerprint
  )
  changed_note <- project
  changed_note$observations[[1L]]$note <- "A different student observation."

  expect_identical(woodhen_project_fingerprint(reordered), project$project_fingerprint)
  expect_identical(woodhen_project_fingerprint(provenance_only), project$project_fingerprint)
  expect_false(identical(woodhen_project_fingerprint(changed_note), project$project_fingerprint))
})

test_that("unsupported schema versions preserve the discovered value", {
  project <- new_woodhen_project()
  project$project_schema_version <- "woodhen-project-v999"
  condition <- expect_error(validate_woodhen_project(project), class = "woodhen_unsupported_version")
  expect_equal(condition$discovered_version, "woodhen-project-v999")
  expect_equal(condition$version_field, "project_schema_version")
  expect_equal(condition$supported_version, "woodhen-project-v1")
})

test_that("ZIP preflight rejects size, membership, type, path, and mode hostility", {
  project <- new_woodhen_project()
  valid <- tempfile(fileext = ".zip")
  write_woodhen_project_package(project, valid)
  members <- project_test_extract_members(valid)
  file_size <- file.info(valid)$size
  expanded <- sum(zip::zip_list(valid)$uncompressed_size)

  expect_error(
    read_woodhen_project_package(valid, max_compressed_bytes = file_size - 1),
    "compressed-size limit"
  )
  expect_error(
    read_woodhen_project_package(valid, max_expanded_bytes = expanded - 1),
    "expanded-size limit"
  )

  missing <- tempfile(fileext = ".zip")
  project_test_write_archive(list(project.json = members$project), missing)
  expect_error(read_woodhen_project_package(missing), "exactly|members")

  unknown <- tempfile(fileext = ".zip")
  project_test_write_archive(list(
    manifest.json = members$manifest,
    project.json = members$project,
    script.R = "stop('not executed')"
  ), unknown)
  expect_error(read_woodhen_project_package(unknown), "exactly|members")

  executable <- tempfile(fileext = ".zip")
  project_test_write_archive(
    list(manifest.json = members$manifest, project.json = members$project),
    executable,
    modes = c(manifest.json = "0755", project.json = "0644")
  )
  expect_error(read_woodhen_project_package(executable), "executable")

  symlink_stage <- tempfile("woodhen-symlink-")
  dir.create(symlink_stage)
  writeBin(members$manifest, file.path(symlink_stage, "manifest.json"))
  writeBin(members$project, file.path(symlink_stage, "target.json"))
  expect_true(file.symlink("target.json", file.path(symlink_stage, "project.json")))
  symlink_archive <- tempfile(fileext = ".zip")
  old_directory <- setwd(symlink_stage)
  symlink_status <- system2(
    "zip",
    c("-q", "-y", symlink_archive, "manifest.json", "project.json")
  )
  setwd(old_directory)
  expect_equal(symlink_status, 0L)
  expect_equal(zip::zip_list(symlink_archive)$type, c("file", "symlink"))
  expect_error(read_woodhen_project_package(symlink_archive), "regular files|type")

  directory_stage <- tempfile("woodhen-directory-")
  dir.create(directory_stage)
  writeBin(members$manifest, file.path(directory_stage, "manifest.json"))
  dir.create(file.path(directory_stage, "project.json"))
  directory_archive <- tempfile(fileext = ".zip")
  zip::zip(
    directory_archive,
    c("manifest.json", "project.json"),
    root = directory_stage,
    mode = "mirror",
    include_directories = TRUE
  )
  expect_error(read_woodhen_project_package(directory_archive), "members|regular files|type")

  path_names <- c(
    "../project.json", "/project.json", "folder/project.json", "PROJECT.JSON",
    "./project.json", "pro\u0458ect.json"
  )
  for (hostile_name in path_names) {
    hostile <- tempfile(fileext = ".zip")
    project_test_infozip_archive(
      list(manifest.json = members$manifest, project.json = members$project),
      hostile
    )
    project_test_rename_zip_member(hostile, "project.json", hostile_name)
    expect_error(read_woodhen_project_package(hostile), "members", info = hostile_name)
  }

  backslash <- tempfile(fileext = ".zip")
  project_test_infozip_archive(
    list(manifest.json = members$manifest, project.json = members$project),
    backslash
  )
  project_test_rename_zip_member(backslash, "project.json", "folder/project.json")
  project_test_raw_replace(backslash, "folder/project.json", "folder\\project.json")
  expect_error(read_woodhen_project_package(backslash), "members")

  duplicate <- tempfile(fileext = ".zip")
  project_test_infozip_archive(
    list(project.json = members$project, duplicate.json = members$project),
    duplicate
  )
  project_test_rename_zip_member(duplicate, "duplicate.json", "project.json")
  expect_error(read_woodhen_project_package(duplicate), "duplicate|members")

  malformed <- tempfile(fileext = ".zip")
  writeBin(charToRaw("not a zip archive"), malformed)
  expect_error(read_woodhen_project_package(malformed), "ZIP|archive")

  truncated <- tempfile(fileext = ".zip")
  valid_raw <- readBin(valid, "raw", n = file.info(valid)$size)
  writeBin(valid_raw[seq_len(length(valid_raw) - 20L)], truncated)
  expect_error(read_woodhen_project_package(truncated), "ZIP|archive")

  encrypted_stage <- tempfile("woodhen-encrypted-")
  dir.create(encrypted_stage)
  writeBin(members$manifest, file.path(encrypted_stage, "manifest.json"))
  writeBin(members$project, file.path(encrypted_stage, "project.json"))
  encrypted <- tempfile(fileext = ".zip")
  old_directory <- setwd(encrypted_stage)
  encrypted_status <- system2(
    "zip",
    c("-q", "-P", "woodhen-test-password", encrypted, "manifest.json", "project.json")
  )
  setwd(old_directory)
  expect_equal(encrypted_status, 0L)
  expect_error(read_woodhen_project_package(encrypted), "extract|encrypt|ZIP")

  corrupt_stage <- tempfile("woodhen-corrupt-")
  dir.create(corrupt_stage)
  writeBin(members$manifest, file.path(corrupt_stage, "manifest.json"))
  writeBin(members$project, file.path(corrupt_stage, "project.json"))
  corrupt <- tempfile(fileext = ".zip")
  old_directory <- setwd(corrupt_stage)
  corrupt_status <- system2(
    "zip",
    c("-q", "-0", corrupt, "manifest.json", "project.json")
  )
  setwd(old_directory)
  expect_equal(corrupt_status, 0L)
  corrupt_bytes <- readBin(corrupt, "raw", n = file.info(corrupt)$size)
  marker <- members$project[seq_len(min(128L, length(members$project)))]
  starts <- which(corrupt_bytes == marker[[1L]])
  member_start <- starts[vapply(starts, function(start) {
    end <- start + length(marker) - 1L
    end <= length(corrupt_bytes) && identical(corrupt_bytes[start:end], marker)
  }, logical(1))][[1L]]
  corrupt_bytes[[member_start + 64L]] <- as.raw(bitwXor(
    as.integer(corrupt_bytes[[member_start + 64L]]),
    1L
  ))
  writeBin(corrupt_bytes, corrupt)
  expect_error(read_woodhen_project_package(corrupt), "extract|CRC|ZIP")

  symlink_path <- tempfile("woodhen-package-link-")
  expect_true(file.symlink(valid, symlink_path))
  expect_error(read_woodhen_project_package(symlink_path), "symlink")
})

test_that("manifest and project hostility is rejected before return", {
  valid_project <- new_woodhen_project()
  scenario <- build_woodhen_sensitivity_family("K", c(350, 250))$scenarios[[1L]]
  valid_project <- add_woodhen_scenario(valid_project, scenario)
  valid <- tempfile(fileext = ".zip")
  write_woodhen_project_package(valid_project, valid)
  members <- project_test_extract_members(valid)

  invalid_manifest <- tempfile(fileext = ".zip")
  project_test_write_archive(list(
    manifest.json = "{not-json",
    project.json = members$project
  ), invalid_manifest)
  expect_error(read_woodhen_project_package(invalid_manifest), "JSON")

  invalid_project <- tempfile(fileext = ".zip")
  project_test_write_archive(list(
    manifest.json = members$manifest,
    project.json = "{not-json"
  ), invalid_project)
  expect_error(read_woodhen_project_package(invalid_project), "digest|JSON")

  unknown_document_field <- tempfile(fileext = ".zip")
  project_test_repack(valid, unknown_document_field, mutate_project = function(bytes) {
    document <- woodhen_json_parse(bytes)
    document$script <- "source('payload.R')"
    woodhen_json_bytes(document)
  })
  expect_error(read_woodhen_project_package(unknown_document_field), "exactly|unexpected")

  unknown_scenario_field <- tempfile(fileext = ".zip")
  project_test_repack(valid, unknown_scenario_field, mutate_project = function(bytes) {
    project_test_mutate_document(bytes, function(project) {
      project$scenarios[[1L]]$script <- "system('not executed')"
      project
    })
  })
  expect_error(read_woodhen_project_package(unknown_scenario_field), "unexpected.*field")

  invalid_bound <- tempfile(fileext = ".zip")
  project_test_repack(
    valid,
    invalid_bound,
    mutate_project = function(bytes) {
      project_test_mutate_document(bytes, function(project) {
        project$scenarios[[1L]]$spec$K <- 149
        project$scenarios[[1L]]$spec_fingerprint <-
          woodhen_spec_fingerprint(project$scenarios[[1L]]$spec)
        project$scenarios[[1L]]$scientific_identity_fingerprint <-
          woodhen_record_scientific_fingerprint(project$scenarios[[1L]])
        project$project_fingerprint <- woodhen_project_fingerprint(project)
        project
      })
    },
    mutate_manifest = function(manifest) {
      document <- woodhen_json_parse(project_test_mutate_document(
        members$project,
        function(project) {
          project$scenarios[[1L]]$spec$K <- 149
          project$scenarios[[1L]]$spec_fingerprint <-
            woodhen_spec_fingerprint(project$scenarios[[1L]]$spec)
          project$scenarios[[1L]]$scientific_identity_fingerprint <-
            woodhen_record_scientific_fingerprint(project$scenarios[[1L]])
          project$project_fingerprint <- woodhen_project_fingerprint(project)
          project
        }
      ))
      manifest$project_fingerprint <- document$project_fingerprint
      manifest
    }
  )
  expect_error(read_woodhen_project_package(invalid_bound), "K >= 150")

  fingerprint_mismatch <- tempfile(fileext = ".zip")
  mismatch <- paste(rep("0", 64L), collapse = "")
  project_test_repack(
    valid,
    fingerprint_mismatch,
    mutate_project = function(bytes) {
      document <- woodhen_json_parse(bytes)
      document$project_fingerprint <- mismatch
      woodhen_json_bytes(document)
    },
    mutate_manifest = function(manifest) {
      manifest$project_fingerprint <- mismatch
      manifest
    }
  )
  expect_error(read_woodhen_project_package(fingerprint_mismatch), "fingerprint")

  digest_mismatch <- tempfile(fileext = ".zip")
  project_test_write_archive(list(
    manifest.json = members$manifest,
    project.json = c(members$project, as.raw(0x20))
  ), digest_mismatch)
  expect_error(read_woodhen_project_package(digest_mismatch), "digest")

  id_mismatch <- tempfile(fileext = ".zip")
  project_test_repack(valid, id_mismatch, mutate_manifest = function(manifest) {
    manifest$project_id <- "woodhen_project_0000000000000000"
    manifest
  })
  expect_error(read_woodhen_project_package(id_mismatch), "mismatch")

  invalid_numeric_type <- tempfile(fileext = ".zip")
  project_test_repack(valid, invalid_numeric_type, mutate_manifest = function(manifest) {
    manifest$app_version <- Inf
    manifest
  })
  expect_error(read_woodhen_project_package(invalid_numeric_type), "app_version")
})

test_that("unsupported package versions raise structured conditions", {
  project <- new_woodhen_project()
  valid <- tempfile(fileext = ".zip")
  hostile <- tempfile(fileext = ".zip")
  write_woodhen_project_package(project, valid)
  project_test_repack(valid, hostile, mutate_manifest = function(manifest) {
    manifest$package_format_version <- "woodhen-project-package-v999"
    manifest
  })

  condition <- expect_error(
    read_woodhen_project_package(hostile),
    class = "woodhen_unsupported_version"
  )
  expect_equal(condition$discovered_version, "woodhen-project-package-v999")
  expect_equal(condition$version_field, "package_format_version")

  manifest_schema <- tempfile(fileext = ".zip")
  project_test_repack(valid, manifest_schema, mutate_manifest = function(manifest) {
    manifest$project_schema_version <- "woodhen-project-v999"
    manifest
  })
  condition <- expect_error(
    read_woodhen_project_package(manifest_schema),
    class = "woodhen_unsupported_version"
  )
  expect_equal(condition$discovered_version, "woodhen-project-v999")
  expect_equal(condition$version_field, "project_schema_version")

  for (field in c("format_version", "project_schema_version")) {
    document_version <- tempfile(fileext = ".zip")
    discovered <- if (identical(field, "format_version")) {
      "woodhen-project-json-v999"
    } else {
      "woodhen-project-v999"
    }
    project_test_repack(valid, document_version, mutate_project = function(bytes) {
      document <- woodhen_json_parse(bytes)
      document[[field]] <- discovered
      woodhen_json_bytes(document)
    })
    condition <- expect_error(
      read_woodhen_project_package(document_version),
      class = "woodhen_unsupported_version",
      info = field
    )
    expect_equal(condition$discovered_version, discovered, info = field)
    expect_equal(condition$version_field, field, info = field)
  }
})

test_that("portable project API is exported from the source namespace", {
  required <- c(
    "new_woodhen_project", "validate_woodhen_project", "add_woodhen_scenario",
    "add_woodhen_run", "add_woodhen_observation", "select_woodhen_evidence",
    "woodhen_project_fingerprint", "write_woodhen_project_package",
    "read_woodhen_project_package"
  )
  expect_setequal(intersect(getNamespaceExports("rPVA"), required), required)
})

test_that("resigned portable packages reject inconsistent compact evidence", {
  project <- project_test_nontrivial_project()
  valid <- tempfile(fileext = ".zip")
  write_woodhen_project_package(project, valid)

  attacks <- list(
    extinction_count = function(project) {
      run <- project$runs[[1L]]
      run$extinction_evidence$extinct_reps <- 1L
      run$summary$extinct_reps <- 1L
      run$summary$surviving_reps <- run$reps - 1L
      project$runs[[1L]] <- run
      project
    },
    extinction_probability = function(project) {
      project$runs[[1L]]$extinction_evidence$probability_by_horizon <- 0.1
      project$runs[[1L]]$extinction_evidence$cumulative$probability[] <- 0.1
      project$runs[[1L]]$summary$PE <- 0.1
      project
    },
    extinction_cumulative = function(project) {
      run <- project$runs[[1L]]
      midpoint <- as.integer(run$horizon %/% 2L)
      run$extinction_evidence$cumulative$probability[
        run$extinction_evidence$cumulative$year >= midpoint
      ] <- 0.1
      run$extinction_evidence$probability_by_horizon <- 0.1
      run$summary$PE <- 0.1
      project$runs[[1L]] <- run
      project
    },
    extinction_conditional_median = function(project) {
      project$runs[[1L]]$extinction_evidence$conditional_median_year <- 0
      project
    },
    extinction_overall_median = function(project) {
      project$runs[[1L]]$extinction_evidence$overall_median_year <- 0
      project
    },
    extinction_first_event = function(project) {
      project$runs[[1L]]$extinction_evidence$first_extinction_year[[1L]] <- 1L
      project
    },
    summary_quantile = function(project) {
      project$runs[[1L]]$summary$Nmed <- project$runs[[1L]]$summary$Nmed + 1
      project
    },
    annual_quantile_order = function(project) {
      run <- project$runs[[1L]]
      run$annual_quantiles$q025[[1L]] <- run$annual_quantiles$q975[[1L]] + 1
      project$runs[[1L]] <- run
      project
    },
    annual_final_quantile = function(project) {
      run <- project$runs[[1L]]
      final_row <- nrow(run$annual_quantiles)
      run$annual_quantiles$q025[[final_row]] <-
        run$annual_quantiles$q025[[final_row]] + 0.25
      project$runs[[1L]] <- run
      project
    },
    trajectory_cartesian_product = function(project) {
      run <- project$runs[[1L]]
      first <- run$sampled_replicate_indices[[1L]]
      second <- run$sampled_replicate_indices[[2L]]
      row <- which(
        run$trajectory_sample$year == 0L &
          run$trajectory_sample$replicate_index == first
      )[[1L]]
      run$trajectory_sample$replicate_index[[row]] <- second
      project$runs[[1L]] <- run
      project
    },
    trajectory_horizon_abundance = function(project) {
      run <- project$runs[[1L]]
      sampled <- run$sampled_replicate_indices[[1L]]
      row <- which(
        run$trajectory_sample$year == run$horizon &
          run$trajectory_sample$replicate_index == sampled
      )[[1L]]
      run$trajectory_sample$abundance[[row]] <-
        run$trajectory_sample$abundance[[row]] + 1
      project$runs[[1L]] <- run
      project
    },
    quasi_count = function(project) {
      project$runs[[1L]]$quasi_extinction_50_pairs$crossed_reps <- 1L
      project
    },
    quasi_probability = function(project) {
      project$runs[[1L]]$quasi_extinction_50_pairs$probability_by_horizon <- 0.1
      project$runs[[1L]]$quasi_extinction_50_pairs$cumulative$probability[] <- 0.1
      project
    },
    quasi_cumulative = function(project) {
      run <- project$runs[[1L]]
      midpoint <- as.integer(run$horizon %/% 2L)
      run$quasi_extinction_50_pairs$cumulative$probability[
        run$quasi_extinction_50_pairs$cumulative$year >= midpoint
      ] <- 0.1
      run$quasi_extinction_50_pairs$probability_by_horizon <- 0.1
      project$runs[[1L]] <- run
      project
    },
    quasi_conditional_median = function(project) {
      project$runs[[1L]]$quasi_extinction_50_pairs$conditional_median_year <- 0
      project
    },
    quasi_overall_median = function(project) {
      project$runs[[1L]]$quasi_extinction_50_pairs$overall_median_year <- 0
      project
    },
    quasi_first_event = function(project) {
      project$runs[[1L]]$quasi_extinction_50_pairs$first_crossing_year[[1L]] <- 1L
      project
    },
    quasi_minimum = function(project) {
      project$runs[[1L]]$quasi_extinction_50_pairs$minimum_breeding_pairs[[1L]] <- 0
      project
    },
    parentless_status = function(project) {
      project$runs[[1L]]$difference_from_parent$status <- "pending_comparison"
      project
    },
    pending_outcomes = function(project) {
      project$runs[[2L]]$difference_from_parent$outcomes <- list(
        extinction_probability = 0,
        quasi_extinction_probability = 0,
        final_median_abundance = 0
      )
      project
    },
    computed_parent_delta = function(project) {
      project$runs[[2L]]$difference_from_parent$status <- "computed"
      project$runs[[2L]]$difference_from_parent$outcomes <- list(
        extinction_probability = 0,
        quasi_extinction_probability = 0,
        final_median_abundance = 0
      )
      project
    }
  )

  for (name in names(attacks)) {
    hostile <- tempfile(pattern = paste0("woodhen-", name, "-"), fileext = ".zip")
    project_test_repack_resigned(valid, hostile, attacks[[name]])
    expect_error(
      read_woodhen_project_package(hostile),
      "evidence|summary|quantile|trajectory|quasi|difference|parent",
      info = name
    )
  }
})

test_that("valid parent comparison states remain portable", {
  family <- build_woodhen_sensitivity_family("K", c(350, 250), seed = 913L)
  baseline <- project_test_run(family$scenarios[[1L]])
  child <- project_test_run(family$scenarios[[2L]], abundance_shift = -80)
  compared <- compare_woodhen_run_family(list(baseline, child), family$family_id)$runs

  baseline_zero <- compared[[1L]]
  expect_silent(woodhen_project_validate_run(baseline_zero))

  child_only <- add_woodhen_scenario(new_woodhen_project(), family$scenarios[[1L]])
  child_only <- add_woodhen_scenario(child_only, family$scenarios[[2L]])
  expect_silent(add_woodhen_run(child_only, compared[[2L]]))

  project <- new_woodhen_project("Computed comparison")
  project <- add_woodhen_scenario(project, family$scenarios[[1L]])
  project <- add_woodhen_scenario(project, family$scenarios[[2L]])
  project <- add_woodhen_run(project, compared[[1L]])
  project <- add_woodhen_run(project, compared[[2L]])
  fingerprint <- project$project_fingerprint
  path <- tempfile(fileext = ".zip")
  write_woodhen_project_package(project, path)
  imported <- read_woodhen_project_package(path)

  expect_identical(imported$runs, project$runs)
  expect_identical(
    imported$runs[[2L]]$difference_from_parent$outcomes,
    compared[[2L]]$difference_from_parent$outcomes
  )
  expect_identical(imported$project_fingerprint, fingerprint)
})

test_that("nested portable versions raise structured conditions", {
  project <- project_test_nontrivial_project()
  first <- tempfile(fileext = ".zip")
  write_woodhen_project_package(project, first)
  imported <- read_woodhen_project_package(first)
  valid <- tempfile(fileext = ".zip")
  write_woodhen_project_package(imported, valid)

  cases <- list(
    scenario_record = list(
      field = "record_schema_version", supported = "woodhen-scenario-record-v1",
      mutate = function(project) {
        project$scenarios[[1L]]$record_schema_version <- "woodhen-scenario-record-v999"
        project
      }
    ),
    scenario_version = list(
      field = "scenario_version_schema", supported = "woodhen-project-scenario-version-v1",
      mutate = function(project) {
        project$scenario_versions[[1L]]$scenario_version_schema <-
          "woodhen-project-scenario-version-v999"
        project
      }
    ),
    compact_run = list(
      field = "run_schema_version", supported = "woodhen-compact-run-v1",
      mutate = function(project) {
        project$runs[[1L]]$run_schema_version <- "woodhen-compact-run-v999"
        project
      }
    ),
    embedded_scenario = list(
      field = "record_schema_version", supported = "woodhen-scenario-record-v1",
      mutate = function(project) {
        project$runs[[1L]]$scenario$record_schema_version <-
          "woodhen-scenario-record-v999"
        project
      }
    ),
    observation = list(
      field = "observation_schema_version", supported = "woodhen-observation-v1",
      mutate = function(project) {
        project$observations[[1L]]$observation_schema_version <- "woodhen-observation-v999"
        project
      }
    ),
    import_event = list(
      field = "event_schema_version", supported = "woodhen-import-event-v1",
      mutate = function(project) {
        project$provenance$imports[[1L]]$event_schema_version <-
          "woodhen-import-event-v999"
        project
      }
    ),
    import_package = list(
      field = "package_format_version", supported = "woodhen-project-package-v1",
      mutate = function(project) {
        project$provenance$imports[[1L]]$package_format_version <-
          "woodhen-project-package-v999"
        project
      }
    ),
    export_event = list(
      field = "event_schema_version", supported = "woodhen-export-event-v1",
      mutate = function(project) {
        project$provenance$exports[[1L]]$event_schema_version <-
          "woodhen-export-event-v999"
        project
      }
    ),
    export_package = list(
      field = "package_format_version", supported = "woodhen-project-package-v1",
      mutate = function(project) {
        project$provenance$exports[[1L]]$package_format_version <-
          "woodhen-project-package-v999"
        project
      }
    )
  )

  for (name in names(cases)) {
    case <- cases[[name]]
    hostile <- tempfile(pattern = paste0("woodhen-version-", name, "-"), fileext = ".zip")
    project_test_repack_resigned(valid, hostile, case$mutate)
    condition <- expect_error(
      read_woodhen_project_package(hostile),
      class = "woodhen_unsupported_version",
      info = name
    )
    expect_equal(condition$version_field, case$field, info = name)
    expect_equal(condition$supported_version, case$supported, info = name)
    expect_match(condition$discovered_version, "v999$", info = name)
  }
})
