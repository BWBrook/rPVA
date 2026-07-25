# Practical 2 Shiny App

This installed app is the modular Woodhen investigation workspace. Start,
Calibrate, Investigate, and Compare are implemented as working modules.
Evidence Studio remains a quiet pending band until its implementation gate
lands.

The R session owns the live validated `woodhen_project`. Browser recovery uses
an origin-specific IndexedDB snapshot and explicit Resume action; portable ZIP
packages are the supported cross-browser and cross-host route. Failed restore
or import validation leaves the live project unchanged.

Static tests cover app construction, sourceability, strict snapshot and message
contracts, JavaScript syntax, and responsive CSS boundaries. Real IndexedDB
recovery and rendered responsive behaviour remain browser-acceptance gates.
