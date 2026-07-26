# Practical 2 Shiny App

This installed app is the modular Woodhen investigation workspace. Start,
Calibrate, Investigate, Compare, and the Evidence Studio portfolio are
implemented as working modules. Evidence Studio exports selected source
material as one project-derived ZIP containing a DOCX dossier and numbered
plot/table companions; the export is session-local and does not alter the
portfolio.

The R session owns the live validated `woodhen_project`. Browser recovery uses
an origin-specific IndexedDB snapshot and explicit Resume action; portable ZIP
packages are the supported cross-browser and cross-host route. Failed restore
or import validation leaves the live project unchanged.

Static tests cover app construction, sourceability, strict snapshot and message
contracts, JavaScript syntax, and responsive CSS boundaries. Real IndexedDB
recovery and rendered responsive behaviour remain browser-acceptance gates.
