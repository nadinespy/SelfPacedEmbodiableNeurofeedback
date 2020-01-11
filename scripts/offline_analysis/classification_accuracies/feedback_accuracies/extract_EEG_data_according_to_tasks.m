% This script extracts EEG data from the feedback block accordings to the 
% three tasks (rest vs. move task, follow commands task, announce commands 
% task) and saves them in separate files.

% Required packages/files: 
% eeglab13_4_4b
% eeg_load_xdf.m (eeglab plugin)

% Authors: Nadine Spychala, Edith Bongartz. 
% License: GNU GPLv3.

clear all; close all; clc;

%% allocating variables

% distinguish between groups
groups = {'stroke', 'contr'};                                                               

SUBJ_stroke = {'01', '02', '03', '05', '06', '07', '08', '09', '10'};                       % subject numbers in stroke group
SUBJ_contr = {'01', '02', '03', '04', '05', '06', '07', '08', '09'};                        % subject numbers in control group
SUBJ_complete = {SUBJ_stroke; SUBJ_contr};

% initializing paths
cd '/mnt/525C77605C773E33/all my stuff/free robotic hand control/article/scripts for publication check/scripts/offline_analysis/classification_accuracies/feedback_accuracies';
performanceAnalysis_init;

% start eeglab
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

%% extracting data according to the three task

for y = 1:length(groups) 
    
    SUBJ = SUBJ_complete{y};

    % rest vs. move task
    for s = 1:length(SUBJ)
        EEG = eeg_load_xdf([PATHIN4 'nic_FHC_', groups{y}, SUBJ{s},'_unilateral_test.xdf']);
        [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG);
        EEG = eeg_checkset( EEG );
        EEG = pop_editeventvals(EEG,'insert',{1 [] [] []},'changefield',{1 'type' 'rm-begin'},'append',{1 [] [] []},'insert',{2 [] [] []},'insert',{2 [] [] []},'insert',{2 [] [] []},'changefield',{1 'type' ''});
        EEG = eeg_checkset( EEG );
        EEG = pop_epoch( EEG, {  'rm_begin'  }, [0  240], 'newname', ['nic_FHC_', groups{y}, SUBJ{s}, '_unilateral_test_rm.set'], 'epochinfo', 'yes');
        EEG = eeg_checkset( EEG );
        EEG = pop_rmbase( EEG, [0  239998]);
        EEG = eeg_checkset( EEG );
        EEG = pop_saveset( EEG, 'filename', ['nic_FHC_', groups{y}, SUBJ{s}, '_unilateral_test_rm.set'],'filepath', PATHIN1);
    end

    % follow commands task
    for s = 1:length(SUBJ)
        EEG = eeg_load_xdf([PATHIN4 'nic_FHC_', groups{y}, SUBJ{s},'_unilateral_test.xdf']);
        [ALLEEG, EEG CURRENTSET] = eeg_store(ALLEEG, EEG);
        EEG = eeg_checkset( EEG );
        EEG = pop_editeventvals(EEG,'insert',{1 [] [] []},'changefield',{1 'type' 'fc-begin'},'append',{1 [] [] []},'insert',{2 [] [] []},'insert',{2 [] [] []},'insert',{2 [] [] []},'changefield',{1 'type' ''});
        EEG = eeg_checkset( EEG );
        EEG = pop_epoch( EEG, {  'fc_begin'  }, [0  240], 'newname', ['nic_FHC_', groups{y}, SUBJ{s}, '_unilateral_test_fc.set'], 'epochinfo', 'yes');
        EEG = eeg_checkset( EEG );
        EEG = pop_rmbase( EEG, [0  239998]);
        EEG = eeg_checkset( EEG );
        EEG = pop_saveset( EEG, 'filename', ['nic_FHC_', groups{y}, SUBJ{s}, '_unilateral_test_fc.set'],'filepath',PATHIN2);
    end

    % announce commands task
    for s = 1:length(SUBJ)
        EEG = eeg_load_xdf([PATHIN4 'nic_FHC_', groups{y}, SUBJ{s},'_unilateral_test.xdf']);
        [ALLEEG, EEG CURRENTSET] = eeg_store(ALLEEG, EEG);
        EEG = eeg_checkset( EEG );
        EEG = pop_editeventvals(EEG,'insert',{1 [] [] []},'changefield',{1 'type' 'ac-begin'},'append',{1 [] [] []},'insert',{2 [] [] []},'insert',{2 [] [] []},'insert',{2 [] [] []},'changefield',{1 'type' ''});
        EEG = eeg_checkset( EEG );
        EEG = pop_epoch( EEG, { 'ac_begin' }, [0  240], 'newname', ['nic_FHC_', groups{y}, SUBJ{s}, '_unilateral_test_ac.set'], 'epochinfo', 'yes');
        EEG = eeg_checkset( EEG );
        EEG = pop_rmbase( EEG, [0  239998]);
        EEG = eeg_checkset( EEG );
        EEG = pop_saveset( EEG, 'filename', ['nic_FHC_', groups{y}, SUBJ{s}, '_unilateral_test_ac.set'],'filepath', PATHIN3);
    end
    eeglab redraw
end
