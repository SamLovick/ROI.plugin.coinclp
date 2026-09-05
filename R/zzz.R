## Registration with ROI: the signature of problems this solver accepts, the
## status code table, and the controls it understands.

make_LP_signature <- function() {
    ROI::ROI_plugin_make_signature(objective = "L",
                                   constraints = c("X", "L"),
                                   types = "C",
                                   bounds = c("X", "V"),
                                   cones = "X",
                                   maximum = c(TRUE, FALSE))
}

## Clp's problem status, mapped onto ROI's canonical 0 = solved.
add_status_codes <- function() {
    solver <- ROI::ROI_plugin_get_solver_name(methods::getPackageName())
    add <- function(code, message, roi_code = 1L)
        ROI::ROI_plugin_add_status_code_to_db(solver, code, message, message,
                                              roi_code)
    add(0L, "solution is optimal", 0L)
    add(1L, "problem is primal infeasible")
    add(2L, "problem is dual infeasible, the objective is unbounded")
    add(3L, "stopped on the iteration or time limit")
    add(4L, "stopped because of numerical errors")
    add(5L, "stopped by an event handler")
    add(-1L, "the problem was not solved")
    invisible(TRUE)
}

add_controls <- function() {
    solver <- ROI::ROI_plugin_get_solver_name(methods::getPackageName())
    ROI::ROI_plugin_register_solver_control(solver, "log_level", "verbose")
    ROI::ROI_plugin_register_solver_control(solver, "max_iterations", "max_iter")
    ROI::ROI_plugin_register_solver_control(solver, "max_seconds", "max_time")
    for (nm in c("amount", "verbosity_level", "iterations", "seconds",
                 "algorithm", "presolve", "primal_tolerance",
                 "dual_tolerance", "scaling"))
        ROI::ROI_plugin_register_solver_control(solver, nm, "X")
    invisible(TRUE)
}

.onLoad <- function(libname, pkgname) {
    if (!pkgname %in% ROI::ROI_registered_solvers()) {
        solver <- ROI::ROI_plugin_get_solver_name(pkgname)
        ROI::ROI_plugin_register_solver_method(
            signatures = make_LP_signature(),
            solver = solver,
            method = methods::getFunction("solve_OP", where = getNamespace(pkgname)))
        add_status_codes()
        add_controls()
    }
    invisible(NULL)
}
