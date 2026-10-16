## ROI.plugin.coinclp 0.1.1

A licence change and the wording CRAN asked for. No change to the code.

### Licence

The package was released as "License: EPL", which in an R DESCRIPTION means
EPL 1.0, the only Eclipse entry in R's licence database. The Free Software
Foundation and the Eclipse Foundation both record EPL 1.0 as incompatible
with the GPL, and this package imports ROI (GPL-3) and slam (GPL-2). The EPL
was inherited from the archived ROI.plugin.clp, which this package replaces;
the point was raised against that package in 2018 and never answered there.

Nothing in this package is COIN-OR code. It is R code over ROI, slam and
coinclp, so GPL-3 is the licence that fits, and it is what ROI itself,
ROI.plugin.glpk and ROI.plugin.lpsolve use. I am the sole author and
copyright holder, so the change is mine to make.

The minimum coinclp rises to 0.1.2 for the same reason: that is the release
in which coinclp became MIT, and importing an earlier EPL 1.0 version from a
GPL-3 package would reproduce the incompatibility this release removes.
coinclp 0.1.2 is on CRAN.

### Wording

Title and Description now write package, software and API names in single
quotes, and only those, as requested when 0.1.0 was accepted. Every quoted
name is a bare one: no quoted function call, no acronym in parentheses, no
double quotes.

## Test environments

* Windows 11, R 4.5.2
* GitHub Actions: ubuntu-latest (R release, R devel, R oldrel-1),
  macOS-latest (R release), windows-latest (R release)

## R CMD check results

0 errors | 0 warnings | 0 notes

## Reverse dependencies

None.

## Note on the repository

DESCRIPTION in the repository carries "Remotes: SamLovick/coinclp" so that
continuous integration can resolve that dependency from source; the field is
stripped from the submitted tarball.
