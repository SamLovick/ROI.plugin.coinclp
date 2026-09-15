## The solver method ROI calls for a linear program.

## ROI hands the objective over as a simple triplet matrix with one row; a
## plain vector or a matrix turns up when a problem is built by hand.
objective_vector <- function(x, ncols) {
    obj <- stats::terms(ROI::objective(x))[["L"]]
    if (is.null(obj)) return(rep(0, ncols))
    if (slam::is.simple_triplet_matrix(obj)) obj <- as.matrix(obj)
    obj <- as.numeric(obj)
    if (length(obj) != ncols)
        stop("the objective has ", length(obj), " coefficients but the problem ",
             "has ", ncols, " variables", call. = FALSE)
    obj
}

## Constraints reach the plugin as an L_constraint, whose L is a simple
## triplet matrix; coinclp takes that representation directly, so only the
## non-zero entries travel and the matrix is never expanded to dense.
constraint_parts <- function(x) {
    con <- ROI::constraints(x)
    if (is.null(con) || length(con) == 0L)
        return(list(mat = NULL, dir = character(0), rhs = numeric(0)))
    mat <- con$L
    if (is.null(mat) || NROW(mat) == 0L)
        return(list(mat = NULL, dir = character(0), rhs = numeric(0)))
    list(mat = mat, dir = as.character(con$dir), rhs = as.numeric(con$rhs))
}

## V_bound stores only the entries that differ from the default [0, Inf).
variable_bounds <- function(x, ncols) {
    lower <- rep(0, ncols)
    upper <- rep(Inf, ncols)
    b <- ROI::bounds(x)
    if (!is.null(b)) {
        if (length(b$lower$ind)) lower[b$lower$ind] <- b$lower$val
        if (length(b$upper$ind)) upper[b$upper$ind] <- b$upper$val
    }
    list(lower = lower, upper = upper)
}

## Control names from the 2018 plugin are kept alongside the coinclp ones.
control_to_clp <- function(control) {
    pick <- function(...) {
        for (nm in c(...)) if (!is.null(control[[nm]])) return(control[[nm]])
        NULL
    }
    log_level <- pick("log_level", "amount", "verbosity_level")
    algorithm <- pick("algorithm")
    presolve <- pick("presolve")
    args <- list(
        log_level = if (is.null(log_level)) 0L else as.integer(log_level),
        algorithm = if (is.null(algorithm)) "auto" else as.character(algorithm),
        presolve = if (is.null(presolve)) TRUE else isTRUE(presolve),
        max_iterations = pick("max_iterations", "iterations"),
        max_seconds = pick("max_seconds", "seconds"),
        primal_tolerance = pick("primal_tolerance"),
        dual_tolerance = pick("dual_tolerance"),
        scaling = pick("scaling"))
    if (!args$log_level %in% 0:4)
        stop("the log level must be between 0 and 4", call. = FALSE)
    do.call(coinclp::clp_control, args)
}

#' Solve a linear program with Clp
#'
#' The method \pkg{ROI} dispatches to when a linear program is solved with
#' \code{solver = "coinclp"}.  It is not called directly; use
#' \code{\link[ROI]{ROI_solve}}.
#'
#' @param x An object of class \code{"OP"} holding a linear program.
#' @param control A named list of solver controls, see
#'   \code{\link{ROI.plugin.coinclp}} for the ones recognised.
#' @return An object of class \code{"coinclp_solution"}, which
#'   \code{\link[ROI]{solution}} unpacks.
#' @export
#' @examples
#' library(ROI)
#' op <- OP(objective = c(143, 60),
#'          constraints = L_constraint(rbind(c(120, 210), c(110, 30), c(1, 1)),
#'                                     rep("<=", 3), c(15000, 4000, 75)),
#'          maximum = TRUE)
#' result <- ROI_solve(op, solver = "coinclp")
#' solution(result)
#' solution(result, "dual")
solve_OP <- function(x, control = list()) {
    solver <- ROI::ROI_plugin_get_solver_name(methods::getPackageName())

    if (!is.null(x$types) && any(x$types != "C"))
        stop("the Clp solver handles continuous variables only; ",
             "use a mixed integer solver for types ",
             paste(unique(setdiff(x$types, "C")), collapse = ", "),
             call. = FALSE)

    ncols <- length(ROI::objective(x))
    obj <- objective_vector(x, ncols)
    con <- constraint_parts(x)
    vb <- variable_bounds(x, ncols)

    fit <- coinclp::clp_solve(objective = obj,
                              constraints = con$mat,
                              dir = if (length(con$dir)) con$dir else "<=",
                              rhs = if (length(con$rhs)) con$rhs else NULL,
                              lower = vb$lower, upper = vb$upper,
                              max = isTRUE(x$maximum),
                              control = control_to_clp(control))

    ROI::ROI_plugin_canonicalize_solution(solution = fit$solution,
                                          optimum = fit$objval,
                                          status = fit$status,
                                          solver = solver,
                                          message = fit)
}

#' Dual values and auxiliary quantities
#'
#' \code{solution(x, "dual")} returns the dual value of each constraint, the
#' shadow price of its right hand side.  \code{solution(x, "aux")} returns a
#' list with the row activities as \code{primal} and the reduced costs of the
#' variables as \code{dual}.
#'
#' Signs follow Clp's own convention for the direction that was solved, so a
#' maximisation and the equivalent minimisation of the negated objective
#' report duals of opposite sign.
#'
#' @param x A solution returned by \code{\link[ROI]{ROI_solve}} with
#'   \code{solver = "coinclp"}.
#' @return A numeric vector of dual values, or a list of auxiliary vectors.
#' @rdname coinclp_solution
#' @export
#' @examples
#' library(ROI)
#' op <- OP(objective = c(143, 60),
#'          constraints = L_constraint(rbind(c(120, 210), c(110, 30), c(1, 1)),
#'                                     rep("<=", 3), c(15000, 4000, 75)),
#'          maximum = TRUE)
#' result <- ROI_solve(op, solver = "coinclp")
#' solution(result, "dual")
#' solution(result, "aux")
ROI_plugin_solution_dual.coinclp_solution <- function(x) {
    duals <- x$message$duals
    if (is.null(duals)) NA else duals
}

#' @rdname coinclp_solution
#' @export
ROI_plugin_solution_aux.coinclp_solution <- function(x) {
    list(primal = x$message$row_activity,
         dual = x$message$reduced_costs)
}
