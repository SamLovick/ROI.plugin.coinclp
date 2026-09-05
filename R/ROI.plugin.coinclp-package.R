#' Solve linear programs in ROI with COIN-OR Clp
#'
#' Registers the COIN-OR Clp solver, through the \pkg{coinclp} package, with
#' the R Optimization Infrastructure.  Loading this package is all the setup
#' there is: linear programs can then be solved with
#' \code{ROI_solve(op, solver = "coinclp")}, and \code{"coinclp"} joins the
#' solvers \code{ROI_solve()} picks from automatically.
#'
#' The plugin accepts a linear objective, linear constraints, continuous
#' variables and variable bounds, minimising or maximising.  Constraints
#' given as a \code{simple_triplet_matrix}, which is how \pkg{ROI} stores
#' them, are passed to Clp in sparse form without being densified.
#'
#' @section Solver controls:
#' Pass these to \code{\link[ROI]{ROI_solve}} as named arguments or in
#' \code{control}:
#' \describe{
#'   \item{\code{log_level}}{How much Clp prints, 0 (silent, the default)
#'     to 4.  Also accepted as \code{amount} or \code{verbosity_level}, the
#'     names the earlier ROI.plugin.clp used.}
#'   \item{\code{max_iterations}}{Iteration limit; also \code{iterations}.}
#'   \item{\code{max_seconds}}{Time limit in seconds; also \code{seconds}.}
#'   \item{\code{algorithm}}{One of \code{"auto"} (the default),
#'     \code{"primal"}, \code{"dual"}, \code{"barrier"} or
#'     \code{"barrier_nocross"}.}
#'   \item{\code{presolve}}{Run Clp's presolve, \code{TRUE} by default.}
#'   \item{\code{primal_tolerance}, \code{dual_tolerance}}{Simplex
#'     tolerances.}
#'   \item{\code{scaling}}{Scaling mode: 0 off, 1 equilibrium, 2 geometric,
#'     3 auto, 4 dynamic.}
#' }
#'
#' @section Solution:
#' Besides the primal solution and the objective value,
#' \code{solution(x, "dual")} gives the dual value of each constraint and
#' \code{solution(x, "aux")} the row activities and reduced costs.
#' \code{solution(x, "msg")} returns the whole \pkg{coinclp} result,
#' including the iteration count.
#'
#' @section Relation to ROI.plugin.clp:
#' This package replaces ROI.plugin.clp, which was archived from CRAN in
#' January 2022 because the \pkg{clpAPI} package it depended on had been
#' archived.  The code here is independent of that plugin; the control names
#' \code{amount}, \code{verbosity_level}, \code{iterations} and
#' \code{seconds} are kept so that scripts written for it still work, but
#' the solver is now named \code{"coinclp"} rather than \code{"clp"}.
#'
#' @keywords internal
#' @importFrom ROI ROI_plugin_solution_dual ROI_plugin_solution_aux
#' @examples
#' library(ROI)
#' op <- OP(objective = c(143, 60),
#'          constraints = L_constraint(rbind(c(120, 210), c(110, 30), c(1, 1)),
#'                                     rep("<=", 3), c(15000, 4000, 75)),
#'          maximum = TRUE)
#' result <- ROI_solve(op, solver = "coinclp", log_level = 0)
#' solution(result)
#' solution(result, "objval")
"_PACKAGE"
