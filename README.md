# ROI.plugin.coinclp

<!-- badges: start -->
[![R-CMD-check](https://github.com/SamLovick/ROI.plugin.coinclp/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/SamLovick/ROI.plugin.coinclp/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

Registers [COIN-OR Clp](https://github.com/coin-or/Clp) with the
[R Optimization Infrastructure](https://cran.r-project.org/package=ROI),
through the [coinclp](https://github.com/SamLovick/coinclp) package.

This revives
[ROI.plugin.clp](https://cran.r-project.org/package=ROI.plugin.clp), archived
from CRAN on 2022-01-08 — not for any fault of its own, but because the
`clpAPI` package it depended on had been archived six weeks earlier. The
solver is now called `"coinclp"` rather than `"clp"`, since ROI takes the
solver name from the package name.

## Installation

Clp itself is a system library; install it first (nothing to do on Windows,
where Rtools supplies it).

```r
# install.packages("remotes")
remotes::install_github("SamLovick/coinclp")
remotes::install_github("SamLovick/ROI.plugin.coinclp")
```

## Use

Loading the package is the whole setup:

```r
library(ROI)
library(ROI.plugin.coinclp)

op <- OP(objective   = c(143, 60),
         constraints = L_constraint(rbind(c(120, 210), c(110, 30), c(1, 1)),
                                    rep("<=", 3), c(15000, 4000, 75)),
         maximum     = TRUE)

res <- ROI_solve(op, solver = "coinclp")

solution(res)            # 21.875 53.125
solution(res, "objval")  # 6315.625
solution(res, "dual")    # 0.0000 1.0375 28.8750
solution(res, "aux")     # $primal row activities, $dual reduced costs
solution(res, "msg")     # the full coinclp result, including iterations
```

Constraints held as a `simple_triplet_matrix`, which is how ROI stores them,
go to Clp as sparse: only the non-zero entries are passed, and the matrix is
never expanded into a full grid of mostly zeros on the way.

## Controls

| Control | Meaning |
| --- | --- |
| `log_level` | Clp's message level, 0 (silent, default) to 4 |
| `max_iterations` | iteration limit |
| `max_seconds` | time limit in seconds |
| `algorithm` | `"auto"`, `"primal"`, `"dual"`, `"barrier"`, `"barrier_nocross"` |
| `presolve` | run Clp's presolve, `TRUE` by default |
| `primal_tolerance`, `dual_tolerance` | simplex tolerances |
| `scaling` | 0 off, 1 equilibrium, 2 geometric, 3 auto, 4 dynamic |

```r
ROI_solve(op, solver = "coinclp", algorithm = "barrier", max_seconds = 30)
```

The names the 2018 plugin used — `amount`, `verbosity_level`, `iterations`,
`seconds` — are still accepted, so scripts written for it keep working after
changing the solver name.

## Differences from ROI.plugin.clp

- Duals, reduced costs and row activities are returned, not just the primal
  solution and the objective value.
- Problems with no constraints, a dense constraint matrix, or an objective
  given as a plain vector are handled; the 2018 plugin errored on all three.
- Status codes cover Clp's full set, including "not solved".
- The `algorithm`, `presolve`, tolerance and `scaling` controls are new.

## Licence

Eclipse Public License, matching COIN-OR and the original plugin. The code
is independent of ROI.plugin.clp by Benoit Thieurmel (datastorm-open), whose
control names are kept for compatibility.
