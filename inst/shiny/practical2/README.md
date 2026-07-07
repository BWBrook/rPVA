# Practical 2 Shiny App

This is the browser scaffold for the Practical 2 Woodhen Management Lab. It
uses the public Woodhen teaching API in `R/woodhen_management_api.R` and base
Shiny only.

The app gives students bounded choices:

- run the core Woodhen management scenarios,
- run one-factor sensitivity presets,
- save a comparison CSV and evidence-notes Markdown file,
- turn model outputs into a short management recommendation.

Students use named scenario and sensitivity presets in this app. Each result
remains interpretable because the choices are bounded.

The app is designed for local classroom testing first. Hosted class release,
access control, persistent student workspaces, and production monitoring belong
in separate release gates.
