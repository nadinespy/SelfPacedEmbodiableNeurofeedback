% This script initializes all relevant paths for: 

% extract_EEG_data_according_to_tasks.m,
% performanceAnalysis_generateANNOUNCE.m, 
% performanceAnalysis_generateCOMMAND.m
% performanceAnalysis_generateRM.m
% performanceAnalysis_successANNOUNCE.m,
% performanceAnalysis_successCOMMAND.m,
% performanceAnalysis_successRM.m,
% save_all_successes_and_failures_in_one_table.m,
% get_trial_frequencies.m,
% get_chance_level.m,
% extract_number_of_RMmovements.m.

%% paths

addpath '/mydir/scripts/auxiliaries';
addpath '/mydir/scripts/eeglab13_4_4b'; 
addpath '/mydir/scripts/eeglab13_4_4b/plugins/xdfimport1.12'; 

MAINPATH = '/mydir/analysis';
PATHIN1 = [MAINPATH, '/classification_accuracies/feedback_accuracies/extracting_EEG_data_according_to_tasks/rest_move'];
PATHIN2 = [MAINPATH, '/classification_accuracies/feedback_accuracies/extracting_EEG_data_according_to_tasks/follow_commands'];
PATHIN3 = [MAINPATH, '/classification_accuracies/feedback_accuracies/extracting_EEG_data_according_to_tasks/announce_behavior'];
PATHIN4 = [MAINPATH, '/rawdata/'];
PATHOUT1 = [MAINPATH, '/classification_accuracies/feedback_accuracies/imposing_trial_structure/'];
PATHOUT2 = [MAINPATH, '/classification_accuracies/feedback_accuracies/ratios/'];
PATHOUT3 = [MAINPATH, '/classification_accuracies/feedback_accuracies/trial_frequencies/'];
