online analysis

TRAIN.m
% Required packages/files: 
% BCILAB-1.1 
% lsl_loadlib.m
% lsl_outlet.m
% lsl_streaminfo.m

onlineAnalysisMultipleClassifier.m
% Required packages/files: 
% BCILAB-1.1
% eeglab13_4_4b

runClassifier.m
% Required packages/files: 
% BCILAB-1.1 

runFSA.m
% Required packages/files: 
% BCILAB-1.1




offline analysis
---------------------------------------------------------------------------
time-frequency analysis

preprocessingICA.m
% Required packages/files: 
% eeglab13_4_4b
% eeg_load_xdf.m (eeglab plugin)
% pop_firws.m (eeglab plugin)
% niclas_mobile24_proper_labels.elp (should be contained in auxiliaries)

selectionCSP.m
% Required packages/files: 
% eeglab13_4_4b
% pop_firws (eeglab plugin)
% cov_shrink.m (should be contained in auxiliaries)
% eqTrials.m (should be contained in auxiliaries)
% getERD.m (should be contained in auxiliaries)
% tilefigs.m (should be contained in auxiliaries)

time_frequency_analysis.m
% Required packages/files: 
% eeglab13_4_4b
% suptitle.m (should be contained in auxiliaries)
% plotWavelet2.m (should be contained in auxiliaries)
% jt_st_wave.m (should be contained in auxiliaries)
% vline.m (should be contained in auxiliaries)
----------------------------------------------------------------------------
classification accuracies

training accuracies

% training_accuracies.m

feedback accuracies

% extract_EEG_data_according_to_tasks.m
% Required packages/files: 
% eeglab13_4_4b
% eeg_load_xdf.m (eeglab plugin)

% performanceAnalysis_generateANNOUNCE.m
% Required packages/files: 
% eeglab13_4_4b

% performanceAnalysis_generateCOMMAND.m
% Required packages/files: 
% eeglab13_4_4b

% performanceAnalysis_generateRM.m
% Required packages/files: 
% eeglab13_4_4b

% performanceAnalysis_successANNOUNCE.m
% Required packages/files: 
% eeglab13_4_4b
% find_command_index_ranges.m
% find_command_pattern_in_range.m

% performanceAnalysis_successCOMMAND.m
% Required packages/files: 
% eeglab13_4_4b
% find_command_index_ranges.m
% find_command_pattern_in_range.m

% performanceAnalysis_successRM.m
% Required packages/files: 
% eeglab13_4_4b

% save_all_successes_and_failures_in_one_table.m
% get_trial_frequencies.m
% get_chance_level.m.
% extract_number_of_RMmovements.m
----------------------------------------------------------------------------
subjective ratings

% FCQdata_contr.m
% FCQdata_stroke.m
----------------------------------------------------------------------------
data aggregation & boxplots

% organize_data_for_agregation.m
% aggregate_data.m
% boxplots.m
----------------------------------------------------------------------------
statstical testing

% check_distribution_and_variance.m
% NHST.R

