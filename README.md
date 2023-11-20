This is an adaptation of the BrainTools UK scripts authored by Dr R. Haartsen to prepare, process, clean and extract Face Event Related Potentials collected with the MATLAB framework TaskEngine (developed by Dr Luke Mason) - see below. The set of adapted scripts include:

    BraintoolsUKtrt_00_prepdata.m
    BraintoolsUKtrt_01_cleanEEGdata.m
    BraintoolsUKtrt_02_Individual_GrandAverages.m
    BraintoolsUKtrt_03_ERPfeatures.m
And the associated functions:
    BrtUKtrt_032a_randomNs_indivERPs.m
    BrtUK_01a_Preprocess_Allcond.m
    BrtUK_01ab_preproc_cleandata.m 
    
See the pull history and the Notes for specifics on how and why modifications and alterations were applied.

The current set of scripts produce:

Plots:
        
        percentage valid trials when the participants were looking (eye-tracking measured)
        percentage available EEG trials for participants with valid trials > 60%

Datasets:
        
        trackers of available and cleaned data
        grand-averages of event-related potentials by condition (faces upright and checkerboards)
        event-related potentials features based random sampling of trials by condition (faces upright and checkerboards) 
        
Currently, for comparability, grand-averages and features are calculated for P7 and P8 (where face event-related potentials are stronger).

Notes

The pulls summarise some bugs in the code, defined as "unexpected errors that prevent the scripts' progression". These are due to exceptions in the data that were not encountered or anticipated during the development of these scripts for BrainTools UK. The main unifying reason behind these bugs is that the data does not comply with the '1 row 1 observation, 1 column 1 variable' format (know in data science as tidy). This prevents visual inspection and certain instances of automatic progression, needing the implementation of recursive programming throughout and hard coded conditions. As a long term objective, the data ought to be restructured to a tidy format before processing to improve easiness of use and velocity.

BraintoolsUK

This repository contains the Matlab scripts that were used for the test-retest analyses of the Braintools UK study. The scripts were custom written for this project by Rianne Haartsen and calls to other scripts from Fieldtrip and custom written script from Luke Mason (pre-processing) and Emily J.H. Jones (peak identification). More detailed information on the study can be found in the publication.

In brief, the Braintools UK study examined the feasibility and test-retest reliability of a novel gaze-controlled stimulus presentation paradigm for research focusing on evoked potentials as a measure for brain development. The study introduces the toolbox Braintools that involves gaze-contingent stimulus presentation of stimuli and simultaneous EEG recordings. The toolbox further includes Matlab scripts for automated harmonised analyses of the EEG data. Feasibility and test-retest reliability were examined in 61 2.5 to 4-year-old toddlers across 2 sessions (with 1-2 weeks interval) for evoked potentials during low-level visual processing and face processing.

The scripts were written for the following preprocessing steps and analyses:

For test-retest reliability of ERPs during low-level visual processing and face processing:
1) Preparing the EEG and eye-tracking data and harmonise the formats (BraintoolsUKtrt_00_prepdata.m)
2) Segmenting and cleaning the EEG data (BraintoolsUKtrt_01_cleanEEGdata.m calling to: BrTUK_01a_Preprocess_Allcond.m, BrTUK_trialfun_BraintoolsUKtrt_FastERP.m, BrtUK_01aa_NumberTrials_ERPs.m, and BrTUK_01ab_preproc_cleandata.m)
3) Calculating individual sessions and grand averages to define the time windows of interest for key EEG metrics (BraintoolsUKtrt_02_Individual_GrandAverages.m)
4) Randomly drawing subsets of trials from the data and deriving key EEG metrics from the individual sessions (BraintoolsUKtrt_03_ERPfeatures.m calling to: BrtUKtrt_03a_randomNs_indivERPs.m, BrtUKtrt_03_AllERPfeatures.m, and BrtUKtrt_03c_PeakValid.m)
5) Plotting the values for key EEG metrics from the test and retest session and calculating intra-class correlation values (BraintoolsUKtrt_04_plot_ICCcalc.m calling to ICC.m by Salarian (2021) on MATLAB Central File Exchange)


For the test-retest reliability of face inversion effects:
1) Randomly drawing subsets of trials from the data for the faces up and inverted conditions and deriving key EEG metrics from the individual ERPs (BraintoolsUKtrt_13_ConditionEffects_ERPfeatures.m follows up on data from step 2 in the test-retest reliability for ERPs during low-level visual processing and face processing. The function calls to BrtUKtrt_03a_randomNs_indivERPs.m, BrtUKtrt_03_AllERPfeatures.m, and BrtUKtrt_03c_PeakValid.m)
2) Plotting the values for key EEG metrics from the test and retest session and calculating intra-class correlation values (BraintoolsUKtrt_14_ConditionEffects_plot_ICCcalc.m calling to ICC.m by Salarian (2021) on MATLAB Central File Exchange)



For the internal consistency of ERP measures:
1) Randomly drawing subsets of trials from the data for each condition and deriving key EEG metrics from the ERPs averaged across alternating trials from the subset (BraintoolsUKtrt_23_InternalConsistency_ERPfeatures.m follows up on data from step 2 in the test-retest reliability for ERPs during low-level visual processing and face processing. The function calls to BrtUKtrt_232a_alternatingNs_indivERPs.m, BrtUKtrt_03_AllERPfeatures.m, and BrtUKtrt_03c_PeakValid.m)
2) Plotting the values for key EEG metrics from the set A and B of trials and calculating intra-class correlation values (BraintoolsUKtrt_24_ InternalConsistency_plot_ICCcalc.m calling to ICC.m by Salarian (2021) on MATLAB Central File Exchange)

(by Rianne Haartsen, June 21)
