# ROI.plugin.coinclp 0.1.1

* The licence changes from EPL to GPL-3. `License: EPL` in an R package
  means EPL 1.0, which the Free Software Foundation and the Eclipse
  Foundation both record as incompatible with the GPL, and this package
  imports `ROI` (GPL-3) and `slam` (GPL-2). The EPL came from the archived
  ROI.plugin.clp, which this package replaces; nothing here is COIN-OR code,
  so there was never a reason to carry it. GPL-3 matches `ROI` itself and
  the other ROI plugins. Raised by David M. German against the archived
  package in 2018 (datastorm-open/ROI.plugin.clp#1), where it went
  unanswered.
* The minimum `coinclp` rises to 0.1.2, the release in which that package
  became MIT. Earlier versions are EPL 1.0, and importing one of those from
  a GPL-3 package would reproduce the incompatibility this release exists to
  remove.
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
