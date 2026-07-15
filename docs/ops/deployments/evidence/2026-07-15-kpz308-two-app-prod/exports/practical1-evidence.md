# Practical 1 PVA Evidence Notes

Generated: 2026-07-15 02:24:41 UTC
Runs included: 2
Fixed teaching seed: 42

Use this export with the comparison CSV from the same browser session.
This export is evidence for your own interpretation.

## Comparison table
run_id	stage	label	scenario	years	reps	PE	Nmed	Nlo95	Nhi95	extinct_reps	surviving_reps	trajectory_available	delta_PE	delta_Nmed	uncertainty_change
1	deterministic_baseline	Deterministic baseline	Deterministic baseline	25	1	0	264	264	264	0	1	TRUE	0	0	baseline
2	environmental_stochasticity	Environmental stochasticity	Environmental stochasticity	50	100	0.33	32	4	62	33	67	TRUE	0.33	-232	wider

## Settings and provenance
run_id	stage	label	setting	value
1	deterministic_baseline	Deterministic baseline	spec_name	teaching_deterministic_baseline
1	deterministic_baseline	Deterministic baseline	spec_years	25
1	deterministic_baseline	Deterministic baseline	spec_reps	1
1	deterministic_baseline	Deterministic baseline	spec_K	NA
1	deterministic_baseline	Deterministic baseline	spec_K_sd	0
1	deterministic_baseline	Deterministic baseline	spec_demographic_stochasticity	FALSE
1	deterministic_baseline	Deterministic baseline	spec_env_sd	0
1	deterministic_baseline	Deterministic baseline	spec_genetics	FALSE
1	deterministic_baseline	Deterministic baseline	spec_n0	31,12,7
2	environmental_stochasticity	Environmental stochasticity	control_env_sd	0.35
2	environmental_stochasticity	Environmental stochasticity	control_K	15
2	environmental_stochasticity	Environmental stochasticity	spec_name	teaching_environmental_stochasticity
2	environmental_stochasticity	Environmental stochasticity	spec_years	50
2	environmental_stochasticity	Environmental stochasticity	spec_reps	100
2	environmental_stochasticity	Environmental stochasticity	spec_K	15
2	environmental_stochasticity	Environmental stochasticity	spec_K_sd	5
2	environmental_stochasticity	Environmental stochasticity	spec_demographic_stochasticity	TRUE
2	environmental_stochasticity	Environmental stochasticity	spec_env_sd	0.35
2	environmental_stochasticity	Environmental stochasticity	spec_genetics	FALSE
2	environmental_stochasticity	Environmental stochasticity	spec_n0	31,12,7

## Interpretation prompts
- What changed between the runs you compared?
- Which output supports your explanation of extinction risk?
- Which output supports your explanation of final abundance and uncertainty?
- What caveat would you report before turning this evidence into a recommendation?

## Student interpretation note
Shared bad years widened uncertainty and reduced abundance relative to the baseline; the result remains conditional on the teaching model assumptions.
