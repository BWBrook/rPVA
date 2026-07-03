# Plan

1. Verify the current repo state and create a Goal 043 branch from
   `origin/main`.
2. Inspect the `stochastic` report branch with read-only Git commands.
3. Adopt only durable lessons:
   - lowercase Docker image namespace;
   - Dockerfile template `listenv` preinstall before `renv::restore()`;
   - dev-first/prod-second immutable-tag promotion policy;
   - canonical dev/prod/staff/capacity validation summary.
4. Reset the `stochastic` inbox to a waiting state and keep raw evidence on the
   report branch.
5. Validate the changed repo-local surfaces with static checks, searches, and
   scans.
6. Leave the result uncommitted for rPVA orchestrator review.
