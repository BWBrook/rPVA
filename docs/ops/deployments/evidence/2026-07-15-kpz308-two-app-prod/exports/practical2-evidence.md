# Practical 2 Woodhen Evidence Notes

Generated: 2026-07-15 02:25:36 UTC
Scenarios included: 9
Fixed teaching seed: 123

This export can include core management results and bounded sensitivity results from the same browser session.
Use one-factor sensitivity runs to explain how assumptions affect management advice.
Compare horizons before ranking scenarios.
PE = 0 means zero observed extinctions in this simulation, with this seed and replicate count.

## Comparison table
scenario_id	section	label	changed_parameter	change_label	teaching_note	choice_prompt	evidence_prompt	horizon_note	pe_zero_prompt	scenario	years	reps	PE	Nmed	Nlo95	Nhi95	extinct_reps	surviving_reps	trajectory_available
01_no_mgmt	core_management	No intervention	none	Historical mountain-top restricted population	This is the restricted historical population without a new management action.	Use this as the no-action comparison point.	Use this row to show the risk of taking no extra action.	Forty-year management horizon.	PE = 0 means no replicate crossed extinction during this run. Report the horizon, seed, and replicate count with this value.	No intervention	40	1000	0.666	16	1	31	666	334	FALSE
02_pig_control	core_management	Pig control	K	Increase habitat ceiling to 70 breeding pairs plus floaters	This scenario tests whether increased habitat access lowers risk.	Ask whether habitat recovery changes extinction risk and final abundance.	Use this row to compare risk after habitat access improves.	Forty-year management horizon.	PE = 0 means no replicate crossed extinction during this run. Report the horizon, seed, and replicate count with this value.	Pig control	40	1000	0.566	57	2	184	566	434	FALSE
03_captive_pig	core_management	Captive breeding plus pig control	release schedule	Add releases after captive breeding and pig control	This scenario tests whether captive breeding releases add recovery support.	Ask whether release support changes the recovery story.	Use this row to compare release support against habitat-only action.	Forty-year management horizon.	PE = 0 means no replicate crossed extinction during this run. Report the horizon, seed, and replicate count with this value.	Captive breeding plus pig control	40	1000	0.082	119	4	199	82	918	FALSE
04_rodent_eradication	core_management	Rodent eradication	survival and fecundity	Short-term check after rodent eradication	This short-horizon scenario checks the effect of rodent eradication after recovery.	Ask what a short-horizon recovery check shows about near-term recovery limits.	Use this row to discuss a short recovery check.	Short 5-year horizon. Compare it carefully with longer runs.	PE = 0 means no replicate crossed extinction during this run. Report the horizon, seed, and replicate count with this value.	Rodent eradication	5	1000	0	832	340	1386	0	1000	FALSE
05_future_baseline	core_management	Future baseline	future baseline	Longer future baseline after major recovery	This longer future baseline shows the recovered population under current assumptions.	Ask how a long-horizon recovered baseline should temper management advice.	Use this row to discuss long-term recovered-population assumptions.	Long 75-year horizon. Use it for future robustness, not direct ranking against short checks.	PE = 0 means no replicate crossed extinction during this run. Report the horizon, seed, and replicate count with this value.	Future baseline	75	1000	0	1510	1109	1957	0	1000	FALSE
sensitivity_default	sensitivity	Sensitivity baseline	none	Reference future sensitivity case	This is the reference case for one-factor sensitivity checks.	Use this as the sensitivity reference row.	Use this row as the reference for sensitivity comparisons.	Long 75-year horizon. Use it for future robustness, not direct ranking against short checks.	PE = 0 means no replicate crossed extinction during this run. Report the horizon, seed, and replicate count with this value.	Sensitivity baseline	75	1000	0	1510	1109	1957	0	1000	FALSE
survival_minus_10pct	sensitivity	Survival minus 10 percent	surv	Survival rates multiplied by 0.90	This tests whether lower survival weakens confidence in the advice.	Choose this if survival under disease or stress concerns you.	Compare PE, Nmed, and interval width with the sensitivity baseline.	Long 75-year horizon. Use it for future robustness, not direct ranking against short checks.	PE = 0 means no replicate crossed extinction during this run. Report the horizon, seed, and replicate count with this value.	Survival minus 10 percent	75	1000	0	1484	1091	1968	0	1000	FALSE
K_250	sensitivity	Habitat ceiling K = 250	K	Habitat ceiling set to 250	This tests whether a lower habitat ceiling limits abundance.	Choose this if habitat area or territory availability concerns you.	Compare the abundance interval with the sensitivity baseline.	Long 75-year horizon. Use it for future robustness, not direct ranking against short checks.	PE = 0 means no replicate crossed extinction during this run. Report the horizon, seed, and replicate count with this value.	Habitat ceiling K = 250	75	1000	0	745	466	1070	0	1000	FALSE
cat_freq_0.10	sensitivity	Catastrophe frequency = 0.10	cat_freq	Annual catastrophe probability set to 0.10	This tests whether more frequent catastrophes change long-term risk.	Choose this if cyclone frequency concerns you.	Compare risk and uncertainty with the sensitivity baseline.	Long 75-year horizon. Use it for future robustness, not direct ranking against short checks.	PE = 0 means no replicate crossed extinction during this run. Report the horizon, seed, and replicate count with this value.	Catastrophe frequency = 0.10	75	1000	0	1483	1052	1975	0	1000	FALSE

## Settings and provenance
run_id	scenario_id	section	label	setting	value
1	01_no_mgmt	core_management	No intervention	meta_source_yaml	01_no_mgmt.yaml
1	01_no_mgmt	core_management	No intervention	meta_changed_parameter	none
1	01_no_mgmt	core_management	No intervention	meta_change_label	Historical mountain-top restricted population
1	01_no_mgmt	core_management	No intervention	spec_name	woodhen_no_intervention
1	01_no_mgmt	core_management	No intervention	spec_years	40
1	01_no_mgmt	core_management	No intervention	spec_reps	1000
1	01_no_mgmt	core_management	No intervention	spec_K	10
1	01_no_mgmt	core_management	No intervention	spec_K_sd	1
1	01_no_mgmt	core_management	No intervention	spec_demographic_stochasticity	TRUE
1	01_no_mgmt	core_management	No intervention	spec_env_sd	0.2
1	01_no_mgmt	core_management	No intervention	spec_genetics	TRUE
1	01_no_mgmt	core_management	No intervention	spec_cat_freq	0.04
1	01_no_mgmt	core_management	No intervention	spec_cat_surv	0.5
1	01_no_mgmt	core_management	No intervention	spec_cat_repro	0.75
1	01_no_mgmt	core_management	No intervention	spec_F_init	0.2
1	01_no_mgmt	core_management	No intervention	spec_surv	0.35,0.65,0.85,0.75,0.75,0.65,0.5
1	01_no_mgmt	core_management	No intervention	spec_n0	9,3,2,1,1,1,1
2	02_pig_control	core_management	Pig control	meta_source_yaml	02_pig_control.yaml
2	02_pig_control	core_management	Pig control	meta_changed_parameter	K
2	02_pig_control	core_management	Pig control	meta_change_label	Increase habitat ceiling to 70 breeding pairs plus floaters
2	02_pig_control	core_management	Pig control	spec_name	woodhen_pig_control
2	02_pig_control	core_management	Pig control	spec_years	40
2	02_pig_control	core_management	Pig control	spec_reps	1000
2	02_pig_control	core_management	Pig control	spec_K	70
2	02_pig_control	core_management	Pig control	spec_K_sd	7
2	02_pig_control	core_management	Pig control	spec_demographic_stochasticity	TRUE
2	02_pig_control	core_management	Pig control	spec_env_sd	0.2
2	02_pig_control	core_management	Pig control	spec_genetics	TRUE
2	02_pig_control	core_management	Pig control	spec_cat_freq	0.04
2	02_pig_control	core_management	Pig control	spec_cat_surv	0.5
2	02_pig_control	core_management	Pig control	spec_cat_repro	0.75
2	02_pig_control	core_management	Pig control	spec_F_init	0.2
2	02_pig_control	core_management	Pig control	spec_surv	0.35,0.65,0.85,0.75,0.75,0.65,0.5
2	02_pig_control	core_management	Pig control	spec_n0	9,3,2,1,1,1,1
3	03_captive_pig	core_management	Captive breeding plus pig control	meta_source_yaml	03_captive_pig.yaml
3	03_captive_pig	core_management	Captive breeding plus pig control	meta_changed_parameter	release schedule
3	03_captive_pig	core_management	Captive breeding plus pig control	meta_change_label	Add releases after captive breeding and pig control
3	03_captive_pig	core_management	Captive breeding plus pig control	spec_name	woodhen_captive_pig
3	03_captive_pig	core_management	Captive breeding plus pig control	spec_years	40
3	03_captive_pig	core_management	Captive breeding plus pig control	spec_reps	1000
3	03_captive_pig	core_management	Captive breeding plus pig control	spec_K	70
3	03_captive_pig	core_management	Captive breeding plus pig control	spec_K_sd	7
3	03_captive_pig	core_management	Captive breeding plus pig control	spec_demographic_stochasticity	TRUE
3	03_captive_pig	core_management	Captive breeding plus pig control	spec_env_sd	0.2
3	03_captive_pig	core_management	Captive breeding plus pig control	spec_genetics	TRUE
3	03_captive_pig	core_management	Captive breeding plus pig control	spec_cat_freq	0.04
3	03_captive_pig	core_management	Captive breeding plus pig control	spec_cat_surv	0.5
3	03_captive_pig	core_management	Captive breeding plus pig control	spec_cat_repro	0.75
3	03_captive_pig	core_management	Captive breeding plus pig control	spec_F_init	0.2
3	03_captive_pig	core_management	Captive breeding plus pig control	spec_surv	0.35,0.65,0.85,0.75,0.75,0.65,0.5
3	03_captive_pig	core_management	Captive breeding plus pig control	spec_n0	9,3,2,1,1,1,1
4	04_rodent_eradication	core_management	Rodent eradication	meta_source_yaml	04_rodent_eradication.yaml
4	04_rodent_eradication	core_management	Rodent eradication	meta_changed_parameter	survival and fecundity
4	04_rodent_eradication	core_management	Rodent eradication	meta_change_label	Short-term check after rodent eradication
4	04_rodent_eradication	core_management	Rodent eradication	spec_name	woodhen_rat_eradication
4	04_rodent_eradication	core_management	Rodent eradication	spec_years	5
4	04_rodent_eradication	core_management	Rodent eradication	spec_reps	1000
4	04_rodent_eradication	core_management	Rodent eradication	spec_K	500
4	04_rodent_eradication	core_management	Rodent eradication	spec_K_sd	50
4	04_rodent_eradication	core_management	Rodent eradication	spec_demographic_stochasticity	TRUE
4	04_rodent_eradication	core_management	Rodent eradication	spec_env_sd	0.2
4	04_rodent_eradication	core_management	Rodent eradication	spec_genetics	TRUE
4	04_rodent_eradication	core_management	Rodent eradication	spec_cat_freq	0.04
4	04_rodent_eradication	core_management	Rodent eradication	spec_cat_surv	0.5
4	04_rodent_eradication	core_management	Rodent eradication	spec_cat_repro	0.75
4	04_rodent_eradication	core_management	Rodent eradication	spec_F_init	0.4
4	04_rodent_eradication	core_management	Rodent eradication	spec_surv	0.6,0.75,0.85,0.75,0.75,0.65,0.5
4	04_rodent_eradication	core_management	Rodent eradication	spec_n0	62,17,9,6,5,3,2
5	05_future_baseline	core_management	Future baseline	meta_source_yaml	05_future_baseline.yaml
5	05_future_baseline	core_management	Future baseline	meta_changed_parameter	future baseline
5	05_future_baseline	core_management	Future baseline	meta_change_label	Longer future baseline after major recovery
5	05_future_baseline	core_management	Future baseline	spec_name	woodhen_future_baseline
5	05_future_baseline	core_management	Future baseline	spec_years	75
5	05_future_baseline	core_management	Future baseline	spec_reps	1000
5	05_future_baseline	core_management	Future baseline	spec_K	500
5	05_future_baseline	core_management	Future baseline	spec_K_sd	50
5	05_future_baseline	core_management	Future baseline	spec_demographic_stochasticity	TRUE
5	05_future_baseline	core_management	Future baseline	spec_env_sd	0.2
5	05_future_baseline	core_management	Future baseline	spec_genetics	TRUE
5	05_future_baseline	core_management	Future baseline	spec_cat_freq	0.04
5	05_future_baseline	core_management	Future baseline	spec_cat_surv	0.5
5	05_future_baseline	core_management	Future baseline	spec_cat_repro	0.75
5	05_future_baseline	core_management	Future baseline	spec_F_init	0.4
5	05_future_baseline	core_management	Future baseline	spec_surv	0.6,0.75,0.85,0.75,0.75,0.65,0.5
5	05_future_baseline	core_management	Future baseline	spec_n0	497,167,82,43,24,11,3
6	sensitivity_default	sensitivity	Sensitivity baseline	meta_source_yaml	sensitivity_analysis.yaml
6	sensitivity_default	sensitivity	Sensitivity baseline	meta_changed_parameter	none
6	sensitivity_default	sensitivity	Sensitivity baseline	meta_change_label	Reference future sensitivity case
6	sensitivity_default	sensitivity	Sensitivity baseline	spec_name	woodhen_sensitivity
6	sensitivity_default	sensitivity	Sensitivity baseline	spec_years	75
6	sensitivity_default	sensitivity	Sensitivity baseline	spec_reps	1000
6	sensitivity_default	sensitivity	Sensitivity baseline	spec_K	500
6	sensitivity_default	sensitivity	Sensitivity baseline	spec_K_sd	50
6	sensitivity_default	sensitivity	Sensitivity baseline	spec_demographic_stochasticity	TRUE
6	sensitivity_default	sensitivity	Sensitivity baseline	spec_env_sd	0.2
6	sensitivity_default	sensitivity	Sensitivity baseline	spec_genetics	TRUE
6	sensitivity_default	sensitivity	Sensitivity baseline	spec_cat_freq	0.04
6	sensitivity_default	sensitivity	Sensitivity baseline	spec_cat_surv	0.5
6	sensitivity_default	sensitivity	Sensitivity baseline	spec_cat_repro	0.75
6	sensitivity_default	sensitivity	Sensitivity baseline	spec_F_init	0.4
6	sensitivity_default	sensitivity	Sensitivity baseline	spec_surv	0.6,0.75,0.85,0.75,0.75,0.65,0.5
6	sensitivity_default	sensitivity	Sensitivity baseline	spec_n0	497,167,82,43,24,11,3
7	survival_minus_10pct	sensitivity	Survival minus 10 percent	meta_source_yaml	sensitivity_analysis.yaml
7	survival_minus_10pct	sensitivity	Survival minus 10 percent	meta_changed_parameter	surv
7	survival_minus_10pct	sensitivity	Survival minus 10 percent	meta_change_label	Survival rates multiplied by 0.90
7	survival_minus_10pct	sensitivity	Survival minus 10 percent	spec_name	woodhen_sensitivity
7	survival_minus_10pct	sensitivity	Survival minus 10 percent	spec_years	75
7	survival_minus_10pct	sensitivity	Survival minus 10 percent	spec_reps	1000
7	survival_minus_10pct	sensitivity	Survival minus 10 percent	spec_K	500
7	survival_minus_10pct	sensitivity	Survival minus 10 percent	spec_K_sd	50
7	survival_minus_10pct	sensitivity	Survival minus 10 percent	spec_demographic_stochasticity	TRUE
7	survival_minus_10pct	sensitivity	Survival minus 10 percent	spec_env_sd	0.2
7	survival_minus_10pct	sensitivity	Survival minus 10 percent	spec_genetics	TRUE
7	survival_minus_10pct	sensitivity	Survival minus 10 percent	spec_cat_freq	0.04
7	survival_minus_10pct	sensitivity	Survival minus 10 percent	spec_cat_surv	0.5
7	survival_minus_10pct	sensitivity	Survival minus 10 percent	spec_cat_repro	0.75
7	survival_minus_10pct	sensitivity	Survival minus 10 percent	spec_F_init	0.4
7	survival_minus_10pct	sensitivity	Survival minus 10 percent	spec_surv	0.54,0.675,0.765,0.675,0.675,0.585,0.45
7	survival_minus_10pct	sensitivity	Survival minus 10 percent	spec_n0	497,167,82,43,24,11,3
8	K_250	sensitivity	Habitat ceiling K = 250	meta_source_yaml	sensitivity_analysis.yaml
8	K_250	sensitivity	Habitat ceiling K = 250	meta_changed_parameter	K
8	K_250	sensitivity	Habitat ceiling K = 250	meta_change_label	Habitat ceiling set to 250
8	K_250	sensitivity	Habitat ceiling K = 250	spec_name	woodhen_sensitivity
8	K_250	sensitivity	Habitat ceiling K = 250	spec_years	75
8	K_250	sensitivity	Habitat ceiling K = 250	spec_reps	1000
8	K_250	sensitivity	Habitat ceiling K = 250	spec_K	250
8	K_250	sensitivity	Habitat ceiling K = 250	spec_K_sd	50
8	K_250	sensitivity	Habitat ceiling K = 250	spec_demographic_stochasticity	TRUE
8	K_250	sensitivity	Habitat ceiling K = 250	spec_env_sd	0.2
8	K_250	sensitivity	Habitat ceiling K = 250	spec_genetics	TRUE
8	K_250	sensitivity	Habitat ceiling K = 250	spec_cat_freq	0.04
8	K_250	sensitivity	Habitat ceiling K = 250	spec_cat_surv	0.5
8	K_250	sensitivity	Habitat ceiling K = 250	spec_cat_repro	0.75
8	K_250	sensitivity	Habitat ceiling K = 250	spec_F_init	0.4
8	K_250	sensitivity	Habitat ceiling K = 250	spec_surv	0.6,0.75,0.85,0.75,0.75,0.65,0.5
8	K_250	sensitivity	Habitat ceiling K = 250	spec_n0	497,167,82,43,24,11,3
9	cat_freq_0.10	sensitivity	Catastrophe frequency = 0.10	meta_source_yaml	sensitivity_analysis.yaml
9	cat_freq_0.10	sensitivity	Catastrophe frequency = 0.10	meta_changed_parameter	cat_freq
9	cat_freq_0.10	sensitivity	Catastrophe frequency = 0.10	meta_change_label	Annual catastrophe probability set to 0.10
9	cat_freq_0.10	sensitivity	Catastrophe frequency = 0.10	spec_name	woodhen_sensitivity
9	cat_freq_0.10	sensitivity	Catastrophe frequency = 0.10	spec_years	75
9	cat_freq_0.10	sensitivity	Catastrophe frequency = 0.10	spec_reps	1000
9	cat_freq_0.10	sensitivity	Catastrophe frequency = 0.10	spec_K	500
9	cat_freq_0.10	sensitivity	Catastrophe frequency = 0.10	spec_K_sd	50
9	cat_freq_0.10	sensitivity	Catastrophe frequency = 0.10	spec_demographic_stochasticity	TRUE
9	cat_freq_0.10	sensitivity	Catastrophe frequency = 0.10	spec_env_sd	0.2
9	cat_freq_0.10	sensitivity	Catastrophe frequency = 0.10	spec_genetics	TRUE
9	cat_freq_0.10	sensitivity	Catastrophe frequency = 0.10	spec_cat_freq	0.1
9	cat_freq_0.10	sensitivity	Catastrophe frequency = 0.10	spec_cat_surv	0.5
9	cat_freq_0.10	sensitivity	Catastrophe frequency = 0.10	spec_cat_repro	0.75
9	cat_freq_0.10	sensitivity	Catastrophe frequency = 0.10	spec_F_init	0.4
9	cat_freq_0.10	sensitivity	Catastrophe frequency = 0.10	spec_surv	0.6,0.75,0.85,0.75,0.75,0.65,0.5
9	cat_freq_0.10	sensitivity	Catastrophe frequency = 0.10	spec_n0	497,167,82,43,24,11,3

## Interpretation prompts
- Which scenario gives the strongest evidence for lower extinction risk?
- Which scenario gives the strongest evidence for higher final abundance?
- Which uncertainty interval should temper your recommendation?
- Which one-factor sensitivity result changes your confidence?
- What condition would change your advice?

## Student analytical choice
- Decision lens: reduce near-term extinction risk
- Chosen sensitivity: survival_minus_10pct
- Biological reason: Test whether the management ranking is robust to one biologically plausible change.
- Expected direction: The selected change should alter abundance while preserving the main management comparison.
- Observed result: The bounded sensitivity set completed and produced distinct scenario outcomes.
- Confidence change: Confidence increases if the preferred option remains useful across the bounded checks.
- Caveat: This is a teaching model and does not replace field validation or implementation constraints.

## Student interpretation note
The management and bounded-sensitivity results provide a reproducible basis for comparing Woodhen options, subject to model scope and implementation constraints.
