#' make_projection_matrix
#' Construct a stage-structured projection matrix (Leslie or Lefkovitch form)
#'
#' @param surv_prog numeric, length n-1. Probability of progressing from stage *i* to *i+1* (0–1).
#' @param fecund    numeric, length n. Per-capita fecundity for each stage (>= 0).
#' @param stasis    numeric, length n (optional). Probability of remaining in stage *i* (defaults to 0).
#'                  Classic Leslie: all 0. Classic Lefkovitch: stasis[n] = adult survival, earlier stasis usually 0.
#' @param tol       numeric, numerical tolerance for sum-to-one checks (default 1e-9).
#' @return n × n matrix with row/col names `stage1`, ..., `stagen`.
#' @examples
#' # 3-stage Leslie (no stasis)
#' make_projection_matrix(surv_prog = c(0.35, 0.75),
#'                        fecund    = c(0, 2.2, 2.2))
#'
#' # Lefkovitch with 15% adult stasis
#' make_projection_matrix(surv_prog = c(0.35, 0.60),
#'                        fecund    = c(0, 2.2, 2.2),
#'                        stasis    = c(0, 0, 0.15))
#' @export
make_projection_matrix <- function(surv_prog, fecund, stasis = NULL, tol = 1e-9) {
  n <- length(fecund)

  # --- Input validation ---
  if (!is.numeric(surv_prog) || length(surv_prog) != max(0, n - 1))
    stop("surv_prog must be numeric of length n-1.")
  if (!is.numeric(fecund) || length(fecund) != n)
    stop("fecund must be numeric of length n.")
  if (any(fecund < 0, na.rm = TRUE))
    stop("All fecundities must be non-negative.")

  if (is.null(stasis)) stasis <- numeric(n)
  if (!is.numeric(stasis) || length(stasis) != n)
    stop("stasis must be numeric of length n.")
  if (any(stasis < 0 | stasis > 1, na.rm = TRUE))
    stop("All stasis entries must be in [0, 1].")
  if (any(surv_prog < 0 | surv_prog > 1, na.rm = TRUE))
    stop("All surv_prog entries must be in [0, 1].")

  # -- Check progression + stasis sums --
  sum_check <- surv_prog + stasis[-n]
  over_one <- which(sum_check > 1 + tol)
  almost_one <- which(abs(sum_check - 1) <= tol & sum_check <= 1 + tol)

  if (length(over_one) > 0)
    stop(sprintf("For stages %s, surv_prog + stasis exceeds 1.",
                 paste(over_one, collapse = ", ")))
  if (length(almost_one) > 0)
    warning(sprintf("For stages %s, surv_prog + stasis is numerically very close to 1. Double-check biological meaning or rounding.",
                    paste(almost_one, collapse = ", ")))

  # -- Optional: sum-to-one check for last stage (adult stasis) --
  if (stasis[n] > 1 + tol)
    stop("stasis[n] (last stage) cannot exceed 1.")
  if (abs(stasis[n] - 1) <= tol & stasis[n] <= 1 + tol)
    warning("stasis[n] is numerically very close to 1. If adults have no mortality or other fate, confirm this is intentional.")

  # --- Matrix construction ---
  A <- matrix(0, n, n,
              dimnames = list(stage = paste0("stage", seq_len(n)),
                              stage = paste0("stage", seq_len(n))))

  A[1, ] <- fecund                         # Fecundity row
  if (n > 1) {
    for (i in seq_len(n - 1)) {
      A[i + 1, i] <- surv_prog[i]          # Progression (sub-diagonal)
    }
  }
  diag(A) <- diag(A) + stasis              # Add stasis to diagonal

  # -- Optionally: invisible return, but print for pedagogical clarity --
  return(A)
}
