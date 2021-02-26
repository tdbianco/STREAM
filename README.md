# BraintoolsUK

This repository contains the Matlab scripts that were used for the test-retest analyses of the Braintools UK study. 
The scripts were custom written for this project by Rianne Haartsen and calls to other scripts from Fieldtrip and custom written script from Luke Mason. 
More detailed information on the study can be found in the publication.

In brief, the Braintools UK study examined a novel gaze-controlled stimulus presentation paradigm for research focusing on evoked potentials as a measure for brain development. 
In addition to feasibility of the paradigm in toddlers, we also examined test-retest reliability over 2 sessions (1-2 weeks interval) for evoked potentials during low-level visual processing and face processing. 

The scripts were written for the following steps:
1) Preparing the EEG and eye-tracking data and harmonise the formats (BraintoolsUKtrt_00_prepdata.m)
2) Segmenting and cleaning the EEG data (BraintoolsUKtrt_01_cleanEEGdata.m)
3) Calculating individual sessions and grand averages to define the time windows of interest for key EEG metrics (BraintoolsUKtrt_02_Individual_GrandAverages.m)
4) Randomly drawing subsets of trials from the data and deriving key EEG metrics from the individual sessions (BraintoolsUKtrt_03_ERPfeatures.m)
5) Plotting the values for key EEG metrics from the test and retest session and calculating intera-class correlation values (BraintoolsUKtrt_04_plot_ICCcalc.m)



(by Rianne Haartsen, Feb 21)
