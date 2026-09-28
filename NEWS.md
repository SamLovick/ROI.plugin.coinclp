# ROI.plugin.coinclp 0.1.0.9000 (development version)

* Title and Description follow CRAN's rule that package, software and API
  names are written in single quotes, and only those: every quoted name is
  now a bare one, with no quoted function call, no acronym in parentheses
  and no double quotes. Requested by CRAN when 0.1.0 was accepted.

# ROI.plugin.coinclp 0.1.0

* First release, reviving ROI.plugin.clp on top of the coinclp package after
  both it and clpAPI were archived from CRAN.
* Registers Clp with ROI as the solver "coinclp", for linear objectives,
  linear constraints, continuous variables and variable bounds, minimising
  or maximising.
* Returns dual values, reduced costs, row activities and the iteration count
  alongside the primal solution and objective value.
* Accepts the control names of the earlier plugin (amount, verbosity_level,
  iterations, seconds) as well as coinclp's own, and adds algorithm,
  presolve, tolerance and scaling controls.
* Handles problems the earlier plugin could not: no constraints at all, a
  dense constraint matrix, and an objective given as a plain numeric vector.
