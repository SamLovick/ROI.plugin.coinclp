## Test environments

* Windows 11, R 4.5.2, Rtools45 (Clp 1.17.0 from the toolchain)
* GitHub Actions: ubuntu-latest (R release, R devel, R oldrel-1),
  macOS-latest (R release), windows-latest (R release)

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.

## Notes for the reviewer

* This package revives ROI.plugin.clp, archived from CRAN on 2022-01-08
  because the clpAPI package it imported had been archived. It is new code
  under a new name rather than a takeover of that package; the solver is
  registered with ROI as "coinclp".
* It imports coinclp, which interfaces the COIN-OR Clp library. This
  submission therefore has to follow coinclp onto CRAN, not precede it.
* Until then DESCRIPTION carries "Remotes: SamLovick/coinclp" so that
  continuous integration can resolve that dependency from its repository.
  That field is to be removed for the CRAN submission itself.
