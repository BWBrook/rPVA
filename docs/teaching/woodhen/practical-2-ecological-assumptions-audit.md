# Practical 2 Ecological Assumptions Audit

**Gate A2 accepted on 22 July 2026.** This is a scientific decision record for the teacher and development team, not student-facing copy. The pragmatic 2026 choices below are accepted for delivery; deeper model-semantic repair is deferred to the post-teaching interregnum.

## Accepted decisions for the 2026 practical

1. **Female cohorts versus whole birds is a material issue, and the engine conventions are internally inconsistent.** The Woodhen YAML and legacy case-study script define female-cohort trajectories and convert final abundance to whole birds by multiplying by two. However, `recruit_phase()` and its tests update sex ratio as though the same state vector contains total birds. The current Practical 2 compact-evidence layer then sums the raw state while some plots label it as whole birds. Until that deeper semantic mismatch is refactored, replicate-specific sex-ratio conversion would imply more precision than the engine supports. For this teaching release, the least disruptive convention is to preserve the tuned engine, describe its states internally as female-equivalent model units, report whole birds as twice those units, and keep sex ratio locked away from student control. This must be implemented and tested before Gate E is accepted.
2. **Breeding pairs are a model proxy.** Under the model's monogamy and territory assumptions, one territory-holding female represents one breeding pair. Stages 2-7 are therefore summed and stage 1 non-territorial birds are excluded. Males, pair formation, failed pairing, and territory occupancy are not tracked explicitly, so the result is not an observed pair count.
3. **Fewer than 50 pairs is a working warning threshold.** It creates a common management-warning comparison for this practical. It is not a universal minimum viable population, a proven biological tipping point, or an estimate of the number at which intervention would certainly occur. A threshold-sensitivity view is a useful optional extension, not a compulsory task.
4. **The 2019-2024 exercise is a historical reconstruction, not independent validation.** The 2019 starting scale and the post-eradication survival and fecundity changes were used to construct the reconstruction, while the future starting vector was chosen to represent the then-known 2024 scale. Agreement with those endpoints is therefore a plausibility or consistency check, not independent validation.
5. **The monitoring series is informative but not uniform.** Survey season, coverage, chicks, banding-only samples, and carried-forward Mt Gower counts differ. The official values remain a strong teaching record if those differences are taught rather than hidden.
6. **The future baseline starts at 1,654 birds, while the latest official minimum is 1,638.** The 16-bird difference is biologically trivial but epistemically useful: 1,654 is a tuned model state, not an exact census. Retaining it avoids needless recalibration; changing it would align the model with the updated official headline. Either choice should be described honestly.

## How abundance and breeding pairs are represented

The intended Woodhen specification is a female-only stage model: `n0` is documented as females, fecundity is defined per female, K is documented as breeding pairs, and the legacy example doubles the final state to show females plus males. At the supplied 0.5 starting sex ratio, 827 female-equivalent units represent 1,654 birds. The executable recruitment code, however, updates sex ratio using total-count mass balance and adds all recruits to the stage vector. The implementation therefore mixes female-only and total-bird conventions.

For the immediate Practical 2 release, the existing tuned trajectories should be treated as female-equivalent model units and multiplied by two for whole-bird display, matching the established case-study convention. The tracked sex ratio should not be used to produce a seemingly exact varying conversion until the state-accounting semantics are refactored. Recruitment applies a simplified monogamy adjustment, but males are not represented in their own stages. Thus the breeding-pair calculation is best described as a female territory-holder proxy under an assumed available mate, not a direct pair census. Sex ratio remains locked in the compulsory route.

## Locked 2025-2100 future baseline

This table includes every executable field in the locked future specification. 'Tuned for historical illustration' means a value was chosen to give a plausible reconstruction at the correct scale; it does not mean it was statistically estimated.

| parameter | value | unit | model location | provenance class | source or rationale | temporal assumption | inference limit |
| --- | --- | --- | --- | --- | --- | --- | --- |
| name | woodhen_future_baseline | scenario identifier | inst/extdata/woodhen/05_future_baseline.yaml | inherited from existing practical | Stable internal identity for the unchanged 2025-2100 comparison. | fixed identity | No biological inference. |
| years | 75 | years | inst/extdata/woodhen/05_future_baseline.yaml | inherited from existing practical | The teaching horizon spans 2025-2100. | fixed horizon | Does not imply conditions remain constant in reality. |
| reps | 1000 | simulated futures | inst/extdata/woodhen/_woodhen_base.yaml | inherited from existing practical | One thousand futures is the established Practical 2 comparison standard. | fixed simulation design | Monte Carlo precision does not remove structural or parameter uncertainty. |
| surv | 0.60, 0.75, 0.85, 0.75, 0.75, 0.65, 0.50 | annual probability by model stage 1-7 (documented as female stages) | inst/extdata/woodhen/05_future_baseline.yaml -> run_pva_core() | tuned for historical illustration | Raised early-life survival was chosen to reproduce the post-eradication recovery pattern; it was not estimated from the survey series. | constant from 2025 through 2100 | Common stage changes cannot identify the true mechanism of recovery. |
| stasis | 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.25 | annual probability of remaining in model stage 1-7 | inst/extdata/woodhen/_woodhen_base.yaml -> run_pva_core() | inherited from existing practical | The inherited age-structured survival convention retains adults in the final stage. | constant from 2025 through 2100 | The final stage is an age-class abstraction, not a measured adult transition matrix. |
| fecund | 0.0, 1.5, 3.0, 3.3, 3.0, 2.5, 1.5 | mean fledglings per female by stage 1-7 | inst/extdata/woodhen/05_future_baseline.yaml -> run_pva_core() | tuned for historical illustration | Raised breeding output was chosen to reproduce the post-eradication recovery pattern; it was not estimated from the survey series. | constant from 2025 through 2100 | Common breeding-output changes cannot identify food, rodent, density, or behavioural mechanisms. |
| sex_ratio_init | 0.5 | proportion female | inst/extdata/woodhen/_woodhen_base.yaml -> run_pva_core() | inherited from existing practical | The existing practical starts from an even sex ratio. | initial state, then updated by the model | Sex structure is simplified and male stages are not tracked explicitly. |
| monogamy | TRUE | logical pairing assumption | inst/extdata/woodhen/_woodhen_base.yaml -> recruit_phase() | inherited from existing practical | Woodhens are treated as monogamous; the engine applies a coarse sex-ratio constraint to recruitment. | constant | Pair formation and territory occupancy are not modelled explicitly. |
| n0 | 497, 167, 82, 43, 24, 11, 3 | female-equivalent individuals by stage 1-7 | inst/extdata/woodhen/05_future_baseline.yaml -> run_pva_core() | tuned for historical illustration | The vector sums to 827 female-equivalent units, displayed as 1,654 birds under the legacy 1:1 conversion. The total and stage allocation were chosen for the historical teaching reconstruction. | initial state | Observed total abundance does not identify the seven-stage allocation. |
| demographic_stochasticity | TRUE | logical switch | inst/extdata/woodhen/_woodhen_base.yaml -> run_pva_core() | inherited from existing practical | The existing practical includes individual birth and survival chance. | active every year | Does not represent individual heterogeneity beyond the supplied stochastic processes. |
| env_sd | 0.2 | standard deviation on annual vital-rate draws | inst/extdata/woodhen/_woodhen_base.yaml -> draw_vital_rates() | inherited from existing practical | Inherited annual variation setting; it is not a Woodhen field estimate. | active every year | One value drives both beta-distributed survival and lognormal fecundity variation. |
| K | 500 | breeding pairs | inst/extdata/woodhen/05_future_baseline.yaml -> apply_ceiling_K() | tuned for historical illustration | Chosen as a post-eradication breeding-territory ceiling for the teaching reconstruction; not a measured island carrying capacity. | constant mean | K is breeding-territory capacity, not total bird abundance or mapped habitat area. |
| K_sd | 50 | standard deviation in breeding-pair capacity | inst/extdata/woodhen/05_future_baseline.yaml -> resolve_carrying_capacity() | tuned for historical illustration | Chosen as 10% variation around K for the teaching reconstruction. | redrawn annually | Normal capacity draws are an abstraction and must remain biologically feasible. |
| cat_freq | 0.04 | annual probability | inst/extdata/woodhen/_woodhen_base.yaml -> maybe_apply_catastrophe() | inherited from existing practical | Inherited cyclone-frequency assumption from the existing practical; not a current forecast. | constant annual event probability | Frequency, survival severity, and reproductive severity are separate assumptions. |
| cat_surv | 0.5 | survival multiplier in a catastrophe year | inst/extdata/woodhen/_woodhen_base.yaml -> maybe_apply_catastrophe() | inherited from existing practical | Inherited catastrophe-severity assumption from the existing practical. | applied only in catastrophe years | A common multiplier does not describe cyclone-specific stage effects. |
| cat_repro | 0.75 | fecundity multiplier in a catastrophe year | inst/extdata/woodhen/_woodhen_base.yaml -> maybe_apply_catastrophe() | inherited from existing practical | Inherited catastrophe effect on reproduction from the existing practical. | applied only in catastrophe years | A common multiplier does not describe cyclone timing within a breeding season. |
| genetics | TRUE | logical switch | inst/extdata/woodhen/_woodhen_base.yaml -> genetic_update() | inherited from existing practical | The existing practical includes inbreeding depression and a simplified purging model. | active every year | The genetics module is illustrative rather than a pedigree or genomic model. |
| F_init | 0.4 | inbreeding coefficient | inst/extdata/woodhen/05_future_baseline.yaml -> genetic_update() | tuned for historical illustration | Chosen to represent legacy inbreeding after the earlier bottleneck; not estimated from the 2019 population. | initial state | The starting coefficient is assumed rather than independently estimated here. |
| lethal_equiv | 0.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 | diploid lethal equivalents by stage 1-7 | inst/extdata/woodhen/05_future_baseline.yaml -> genetic_update() | tuned for historical illustration | Reduced from the historical setting to represent prior purging; not newly estimated. | updated by the genetics model | Stage-specific genetic load is simplified. |
| B_on_fec | 0.1 | fecundity scaling per lethal equivalent | inst/extdata/woodhen/_woodhen_base.yaml -> genetic_update() | inherited from existing practical | Inherited link between lethal equivalents and breeding output. | active every year | The fecundity effect is simplified. |
| Ne_N_ratio | 0.8 | ratio | inst/extdata/woodhen/_woodhen_base.yaml -> genetic_update() | inherited from existing practical | Inherited effective-to-census ratio; no Woodhen-specific re-estimation was identified. | active every year | Effective size is not independently estimated for the recovered population. |
| Ne_window | 10 | years | inst/extdata/woodhen/_woodhen_base.yaml -> genetic_update() | inherited from existing practical | Inherited harmonic-memory window for effective population size. | rolling window | The chosen memory window is a modelling convention. |
| purge_kappa | 0 | rate constant | inst/extdata/woodhen/05_future_baseline.yaml -> genetic_update() | tuned for historical illustration | Set to zero in the recovered-population reconstruction so no further purging occurs. | active every year | No continuing purging is represented. |

## Compulsory one-factor sensitivity settings

Each row changes one quantity while retaining the common 2025 starting population, 75-year horizon, and other future settings. The two altered settings are bounded teaching choices, not empirical forecasts.

| label | baseline value | setting 1 | setting 2 | unit | permitted range | model quantity | timing | inference limit |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Breeding-territory capacity | 500 | 350 | 250 | breeding pairs | 150 to 750 | K_sensitivity: absolute K [stages not_applicable] | Immediate fixed setting from 2025 through the 75-year projection. | Capacity represents territory holders and does not model spatial habitat quality. |
| All-stage survival | 1 | 0.95 | 0.9 | multiplier on every stage survival | 0.7 to 1.1 | surv_sensitivity: multiply surv [stages 1, 2, 3, 4, 5, 6, 7] | Immediate fixed setting from 2025 through the 75-year projection. | A common multiplier does not identify a particular disease or stress mechanism. |
| Juvenile survival | 1 | 0.85 | 0.7 | multiplier on stages 1-2 survival | 0.5 to 1.1 | juvenile_surv_sensitivity: multiply surv [stages 1, 2] | Immediate fixed setting from 2025 through the 75-year projection. | Only stages 1 and 2 change; later survival is deliberately held fixed. |
| Fecundity | 1 | 0.8 | 0.6 | multiplier on every fecundity value | 0.4 to 1.2 | fecund_sensitivity: multiply fecund [stages 1, 2, 3, 4, 5, 6, 7] | Immediate fixed setting from 2025 through the 75-year projection. | The same multiplier is applied to all fecund stages. |
| Annual catastrophe probability | 0.04 | 0.07 | 0.1 | annual probability | 0 to 0.2 | cat_freq_sensitivity: absolute cat_freq [stages not_applicable] | Immediate fixed setting from 2025 through the 75-year projection. | The setting changes event frequency, not event severity. |
| Catastrophe survival | 0.5 | 0.4 | 0.3 | catastrophe-year multiplier | 0.2 to 1 | cat_surv_sensitivity: absolute cat_surv [stages not_applicable] | Immediate fixed setting from 2025 through the 75-year projection. | The setting changes catastrophe survival, not frequency or reproduction. |
| Environmental variability | 0.2 | 0.25 | 0.3 | standard deviation | 0 to 0.3 | env_sd_sensitivity: absolute env_sd [stages not_applicable] | Immediate fixed setting from 2025 through the 75-year projection. | The model does not impose a shared good-year or bad-year effect across all rates. |
| Habitat-capacity variability | 50 | 75 | 100 | breeding-pair standard deviation | 0 to 150 | K_sd_sensitivity: absolute K_sd [stages not_applicable] | Immediate fixed setting from 2025 through the 75-year projection. | Capacity draws are Normal; every practical setting must satisfy K >= 3*K_sd. |

## Prospective threat catalogue

The three settings provide increasing exploratory pressure. They are scenario assumptions that students must interpret, not claims about the most likely future.

| label | ecological process | baseline value | setting 1 | setting 2 | setting 3 | unit | model quantity | timing | inference limit |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Novel disease | A new disease reduces survival across affected life stages. | 1.00 | 0.95 | 0.9 | 0.85 | survival multiplier | disease_survival: multiply surv [stages 1, 2, 3, 4, 5, 6, 7] | Step or linear change; step is the current default. | Disease effects are not estimated; reproduction may change only as a separately named advanced component. |
| Habitat contraction or degradation | Loss or degradation reduces available breeding territories. | 500 | 425 | 350 | 250 | breeding pairs | habitat_capacity: absolute K [stages not_applicable] | Step or linear change; step is the current default. | Habitat quality has no independent model field and K_sd remains locked in the compulsory route. |
| Sea-level rise pathway | Inundation and saline intrusion progressively reduce lowland habitat. | 500 | 425 | 350 | 250 | breeding pairs at horizon | linear_habitat_pathway: absolute K [stages not_applicable] | Linear change across the projection only. | Sea-level rise is represented only by a linear K habitat pathway, not a sea-level parameter. |
| Increased cyclone pressure | Cyclones occur more often across the projection horizon. | 0.04 | 0.07 | 0.1 | 0.15 | annual probability | cyclone_frequency: absolute cat_freq [stages not_applicable] | Step or linear change; step is the current default. | Low, moderate, and high change cat_freq only to .07/.10/.15; cat_repro is never silently included. |
| Invasive-predator reinvasion | Predator return reduces juvenile and subadult survival. | 1.00 | 0.85 | 0.7 | 0.5 | stages 1-2 survival multiplier | juvenile_survival: multiply surv [stages 1, 2] | Step or linear change; step is the current default. | The mapping is a design analogue and not an estimated causal reversal of eradication benefits. |
| Chronic environmental variability | Demographic conditions vary more strongly among years. | 0.20 | 0.225 | 0.25 | 0.3 | standard deviation | demographic_variability: absolute env_sd [stages not_applicable] | Step or linear change; step is the current default. | env_sd affects both survival beta draws and fecundity lognormal draws. |

## Prospective intervention catalogue

Interventions modify a named threatened parent. A better simulated outcome means the action offsets part of that assumed threat under the model; it does not establish field effectiveness or feasibility.

| label | setting 1 | setting 2 | setting 3 | unit | direction | timing | parent relationship | inference limit |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Habitat protection or restoration | 0.25 | 0.5 | 1 | fraction of threatened K recovered | Restores threatened K toward 500. | Step or linear recovery after a chosen onset. | Requires a habitat-contraction or sea-level-rise parent with a named K change. | Recovery cannot exceed the locked baseline in the compulsory route. |
| Strengthened biosecurity or renewed eradication | 0.25 | 0.5 | 1 | fraction of parent vital-rate loss recovered | Restores predator-affected survival or fecundity toward baseline. | Step or linear recovery after a chosen onset. | Requires a predator-reinvasion parent and offsets only its named survival or fecundity changes. | Full recovery means the model baseline, not proof of eradication success. |
| Targeted survival or breeding improvement | 0.25 | 0.5 | 1 | fraction of named vital-rate loss recovered | Restores one named survival or fecundity component toward baseline. | Step or linear recovery after a chosen onset. | Requires one named survival or fecundity change in the parent threat. | Above-baseline uplift requires a separately named advanced component. |
| Captive breeding and supplementation | 5 | 10 | 15 | stage-2 female-equivalent pairs per year | Adds birds without changing the parent threat. | Three annual releases beginning at the chosen onset. | May be added to a threat parent; it supplements stage 2 rather than reversing the threat. | The engine repeats one release vector; it does not support event-triggered or year-varying amounts. |
| Emergency response | 0.25 | 0.5 | 0.75 | fraction of catastrophe-survival loss recovered | Raises catastrophe survival toward 1. | Step or linear response after a chosen onset. | Requires the increased-cyclone-pressure parent; it changes severity, not the parent's frequency increase. | cat_repro may be an advanced explicit component but is not silently included in cyclone presets. |

## Observed post-eradication recovery evidence

The recommended teaching series uses exact published counts rather than interpolating the graph. It deliberately records incompatible sampling frames and source differences. The 2019 release figure and April 2024 banding sample should not be treated as directly comparable abundance surveys.

| event period | reported count | count type | survey coverage | interpretation note |
| --- | --- | --- | --- | --- |
| December 2018 | 221 | known minimum annual count | Annual survey; inaccessible birds may be missed. | Pre-eradication benchmark. |
| late 2019 to January 2020 | 208 selected; primary paper reports 228 | release count, not a population census | Captive-managed birds released; free-living birds are not represented consistently. | The official graph uses 208, while the peer-reviewed account reports 233 captured, five deaths, and 228 released in January 2020. Neither is a census estimate for the same sampling frame as later surveys. |
| November 2020 | 443 | survey count | Comparable post-eradication survey. | First comparable post-release survey point. |
| March 2021 | 598 | survey count | Comparable post-eradication survey. | Rapid increase continued. |
| November-December 2021 | 551 adults/juveniles plus 14 chicks | survey count with chicks reported separately | About 20% of the Mt Gower summit was not surveyed; Big Slope and other areas were also unsurveyed. | The count is lower than March 2021, but season and incomplete coverage differ; the report considered the island population likely above 560. |
| March 2022 | 778 | survey count | Two-week autumn survey; reported as the second autumn post-eradication survey. | The increase continued; the survey is supported by a peer-reviewed review of the captive-management programme. |
| December 2022 | 1,147 selected; primary paper reports 1,108 | survey count | Three-week survey including Mt Gower. | Use the Board's final 1,147 count for the teaching series; the earlier peer-reviewed paper reports 1,108, likely reflecting a different data cut. |
| April 2024 | 598 banded | banding sample, not a population estimate | Settlement and parts of the Permanent Park Preserve; designed to band unbanded birds before the full survey. | Do not plot 598 as total abundance: this was a targeted banding sample ahead of the full November survey. |
| November-December 2024 | 1,535 adults/juveniles plus 26 chicks; official minimum 1,638 | derived minimum known population | Accessible areas surveyed directly; Mt Gower was excluded and 77 birds from its 2022 count were carried forward. | The 1,638 headline is useful but is not one simultaneous whole-island census: it combines 1,561 accessible-area birds with the 77-bird Mt Gower count from 2022. |

For the 2026 teaching series, use 208 as the release marker because it matches the existing reconstruction and Board graph, and use the Board's final 1,147 count for December 2022. Keep the alternative published values as brief notes only: the peer-reviewed account reports 228 birds released after five of 233 captive birds died, and its earlier December 2022 data cut reports 1,108. No further reconciliation of 208 and 228, or 1,108 and 1,147, is required for this delivery.

For the 2024 endpoint, 1,535 adults and juveniles plus 26 chicks were recorded in accessible areas. The official minimum of 1,638 adds 77 Mt Gower birds carried forward from 2022 because Mt Gower was not surveyed in 2024. That is a useful minimum-known-population headline, but not one simultaneous whole-island count.

## Omitted processes and inference limits

| omitted process | consequence |
| --- | --- |
| Explicit males and pair formation | Breeding-pair abundance is a female-holder proxy, not an explicit count of paired males and females. |
| Spatial habitat and territory occupancy | K scenarios compare abstract territory capacity, not mapped areas, quality, movement, or local refugia. |
| Observation error and survey effort | Historical agreement cannot distinguish ecological dynamics from changing count coverage or detectability. |
| Density dependence below K | The model imposes a ceiling but does not represent gradual crowding effects before that ceiling. |
| Road mortality and other cause-specific mortality | A changed survival rate cannot identify which mortality source produced the response. |
| Rodent-food-web mechanisms | The recovery reconstruction cannot attribute observed growth separately to predation release, food supply, behaviour, or correlated ecosystem change. |
| Climate and sea-level mechanisms | Sea-level rise is only a declining-K pathway and environmental variability is not a climate projection. |
| Management cost and feasibility | An intervention that helps in the simulation is not automatically practical, affordable, permitted, or socially acceptable. |
| Parameter uncertainty and model-form uncertainty | One thousand futures describe process stochasticity under chosen settings; they do not span uncertainty in the settings or model structure. |

## Deferred 2027 professionalisation

After the 2026 delivery, define one consistent state unit across recruitment, sex ratio, density regulation, abundance summaries, and breeding-pair risk; then recalibrate the Woodhen scenarios and regression-test both practicals. Revisit primary parameter provenance and the survey-series discrepancies only if they materially affect that refactor. None of this deferred work blocks the accepted 2026 teaching release.

## Sources

- O'Dwyer et al. (2024), *Protection and mortality of non-target terrestrial bird species during the eradication of rodents on Lord Howe Island*: https://doi.org/10.1007/s10530-023-03161-w
- Lord Howe Island Board, November-December 2021 survey report, March 2022 Board papers: https://www.lhib.nsw.gov.au/sites/default/files/2023-03/ED23_1446%20-%20Board%20Papers%20-%20Open%20-%20March%202022.pdf
- Mitchell et al. (2023), *Lessons Learned for Pre-Emptive Capture Management*: https://pmc.ncbi.nlm.nih.gov/articles/PMC10000061/
- Lord Howe Island Board, December 2022 survey, February 2023 Board papers: https://www.lhib.nsw.gov.au/sites/default/files/2023-02/Agenda%20and%20Business%20Papers%20February%202023.pdf
- Lord Howe Island Board, April 2024 banding update: https://www.lhib.nsw.gov.au/news/householder-woodhen-banding-results-april-2024
- Lord Howe Island Board, November-December 2024 survey update: https://www.lhib.nsw.gov.au/news/householder-woodhen-survey-results
- Brook and Lim (1997), *How secure is the Lord Howe Island Woodhen?*: https://doi.org/10.1071/PC970125

## Gate A2 accepted decisions

1. Accept the provenance classes and baseline rationales as sufficient for the time-constrained 2026 delivery.
2. Accept the two sensitivity settings and three threat/intervention settings as biologically useful bounded teaching choices.
3. Accept the documented default timing assumptions, including linear sea-level-driven habitat contraction and step defaults elsewhere.
4. Preserve the tuned engine, treat state values as female-equivalent model units, report whole birds as twice those values, keep sex ratio locked, and record the mixed state semantics as technical debt for 2026-2027 repair.
5. Accept the female territory-holder proxy for the shared fewer-than-50-pair working warning threshold with its stated limitations.
6. Use the official 1,638 minimum as the recovery pop-out headline while explaining that it includes the 77-bird Mt Gower count carried forward from 2022.
7. Retain the tuned 1,654-bird future starting state and describe it as a model state rather than an exact census.
