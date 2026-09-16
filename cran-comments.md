## Test environments

* Windows 11, R 4.5.2
* GitHub Actions: ubuntu-latest (R release, R devel, R oldrel-1),
  macOS-latest (R release), windows-latest (R release)

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.

## Resubmission

The first submission (2026-09-15) failed the Windows incoming pretest with

    Package required but not available: 'coinclp'

because it was made the same day coinclp was published and its Windows binary
had not yet been built. That binary is now on CRAN and coinclp passes CRAN's
Windows checks, so the dependency resolves. The pretest also flagged two
"possibly misspelled" words in DESCRIPTION, ROI and coinclp, arising from a
function call written without quotes; the sentence now uses quoted names.

## Notes for the reviewer

* This package revives ROI.plugin.clp, archived from CRAN on 2022-01-08
  because the clpAPI package it imported had been archived. It is new code
  under a new name rather than a takeover of that package; the solver is
  registered with ROI as "coinclp".
* It imports coinclp, on CRAN since 2026-09-15.
* DESCRIPTION in the repository carries "Remotes: SamLovick/coinclp" for
  continuous integration; that field is stripped from the submitted tarball.
