# Plan

1. Read the Goal 013 packet and required Shiny/engine/test sources.
2. Design the smallest teaching adapter around the toy scenario and existing
   helpers.
3. Write focused tests first for catalog, spec-building, validation failures,
   run bundles, settings records, and comparison output.
4. Implement the adapter in one focused R file.
5. Export the public functions through roxygen/NAMESPACE handling consistent
   with the repo.
6. Run focused tests, then full package tests.
7. Run diff hygiene, marker scan, status, and boundary checks.
8. Update `Log.md` during the run and report without committing or pushing.
