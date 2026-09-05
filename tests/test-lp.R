## The plugin as ROI sees it.

library(ROI)
library(ROI.plugin.coinclp)

near <- function(x, y, tol = 1e-6) all(abs(x - y) < tol)

## Registration: ROI keys its solver tables by solver name and stores the
## package name as the value.
stopifnot("coinclp" %in% names(ROI_registered_solvers()),
          "coinclp" %in% names(ROI_installed_solvers()),
          identical(unname(ROI_registered_solvers()["coinclp"]),
                    "ROI.plugin.coinclp"))

## The product mix problem, with a known optimum.
##   max 143x + 60y  s.t. 120x + 210y <= 15000
##                        110x +  30y <=  4000
##                          x +    y  <=    75
op <- OP(objective = c(143, 60),
         constraints = L_constraint(rbind(c(120, 210), c(110, 30), c(1, 1)),
                                    rep("<=", 3), c(15000, 4000, 75)),
         maximum = TRUE)

res <- ROI_solve(op, solver = "coinclp")
stopifnot(inherits(res, "coinclp_solution"),
          solution(res, "status_code") == 0L,
          near(solution(res, "objval"), 6315.625),
          near(solution(res), c(21.875, 53.125)))

## Duals, reduced costs and row activities come back too.
duals <- solution(res, "dual")
aux <- solution(res, "aux")
stopifnot(length(duals) == 3L, near(duals[1], 0),
          length(aux$primal) == 3L, length(aux$dual) == 2L,
          near(aux$primal, c(13781.25, 4000, 75)))
stopifnot(is.list(solution(res, "msg")),
          solution(res, "msg")$iterations >= 0L)

## Minimisation of the negated objective gives the same point.
opmin <- OP(objective = c(-143, -60),
            constraints = constraints(op), maximum = FALSE)
resmin <- ROI_solve(opmin, solver = "coinclp")
stopifnot(near(solution(resmin), solution(res)),
          near(solution(resmin, "objval"), -6315.625))

## Equality rows, ranged variable bounds and free variables.
opeq <- OP(objective = c(1, 2),
           constraints = L_constraint(rbind(c(1, 1)), "==", 4))
stopifnot(near(solution(ROI_solve(opeq, solver = "coinclp"), "objval"), 4))

opb <- OP(objective = c(-1, 1),
          constraints = L_constraint(rbind(c(1, 1)), "<=", 10),
          bounds = V_bound(li = 1:2, ui = 1:2,
                           lb = c(0, -2), ub = c(3, 5), nobj = 2))
resb <- ROI_solve(opb, solver = "coinclp")
stopifnot(near(solution(resb), c(3, -2)), near(solution(resb, "objval"), -5))

opfree <- OP(objective = c(1, 1),
             constraints = L_constraint(rbind(c(1, 1)), ">=", 2),
             bounds = V_bound(li = 1:2, lb = rep(-Inf, 2), nobj = 2))
stopifnot(near(solution(ROI_solve(opfree, solver = "coinclp"), "objval"), 2))

## A problem with no constraints at all, which the old plugin could not do.
opnc <- OP(objective = c(-1, 1),
           bounds = V_bound(ui = 1:2, ub = c(4, 4), nobj = 2))
stopifnot(near(solution(ROI_solve(opnc, solver = "coinclp"), "objval"), -4))

## Infeasible and unbounded problems report a status, they do not error.
opinf <- OP(objective = 1,
            constraints = L_constraint(rbind(1, 1), c("<=", ">="), c(1, 5)))
resinf <- ROI_solve(opinf, solver = "coinclp")
stopifnot(solution(resinf, "status_code") == 1L)

opunb <- OP(objective = -1,
            constraints = L_constraint(rbind(1), "<=", 1e30),
            bounds = V_bound(ui = 1, ub = Inf, nobj = 1))
stopifnot(solution(ROI_solve(opunb, solver = "coinclp"), "status_code") == 1L)

## Sparse constraints stay sparse: a simple_triplet_matrix is what ROI keeps.
set.seed(7)
A <- matrix(rbinom(200, 1, 0.2) * runif(200, 1, 3), nrow = 20)
## every row needs a nonzero entry, or the >= rows below are infeasible
for (i in seq_len(20)) A[i, ((i - 1L) %% 10L) + 1L] <- 1
stm <- slam::as.simple_triplet_matrix(A)
opsparse <- OP(objective = runif(10),
               constraints = L_constraint(stm, rep(">=", 20), rep(2, 20)))
ressparse <- ROI_solve(opsparse, solver = "coinclp")
stopifnot(solution(ressparse, "status_code") == 0L)

## The same problem through another solver, if one is installed, must agree.
## Loading the namespace is enough: an ROI plugin registers itself in
## .onLoad, so it does not have to be attached.
if (requireNamespace("ROI.plugin.highs", quietly = TRUE)) {
    other <- ROI_solve(opsparse, solver = "highs")
    stopifnot(near(solution(ressparse, "objval"), solution(other, "objval"), 1e-6))
    other_mix <- ROI_solve(op, solver = "highs")
    stopifnot(near(solution(res, "objval"), solution(other_mix, "objval"), 1e-6))
}

## Controls, old names and new.
stopifnot(near(solution(ROI_solve(op, solver = "coinclp", log_level = 0L,
                                  max_iterations = 1000L,
                                  max_seconds = 30), "objval"), 6315.625))
stopifnot(near(solution(ROI_solve(op, solver = "coinclp",
                                  control = list(amount = 0, iterations = 500,
                                                 seconds = 30)),
                        "objval"), 6315.625))
for (alg in c("auto", "primal", "dual", "barrier")) {
    r <- ROI_solve(op, solver = "coinclp", algorithm = alg)
    stopifnot(near(solution(r, "objval"), 6315.625, 1e-4))
}
stopifnot(near(solution(ROI_solve(op, solver = "coinclp", presolve = FALSE),
                        "objval"), 6315.625))

## Integer variables are refused, with an explanation.
opint <- OP(objective = c(1, 2),
            constraints = L_constraint(rbind(c(1, 1)), "<=", 4),
            types = c("I", "C"))
stopifnot(inherits(try(ROI_solve(opint, solver = "coinclp"), silent = TRUE),
                   "try-error"))

## An out-of-range log level is caught rather than passed to Clp.
stopifnot(inherits(try(ROI_solve(op, solver = "coinclp", log_level = 9),
                       silent = TRUE), "try-error"))
