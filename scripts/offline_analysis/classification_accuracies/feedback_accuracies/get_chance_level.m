% This script evaluates the chance levels for the feedback accuracies 
% (based on Billinger et al., 2012). 

% Authors: Nadine Spychala, Edith Bongartz. 
% License: GNU GPLv3.

clear all; close all; clc;

%% loading files

% initalize paths
cd '/mnt/525C77605C773E33/all my stuff/free robotic hand control/article/scripts for publication check/scripts/offline_analysis/classification_accuracies/feedback_accuracies';
performanceAnalysis_init;

SUBJ = {'Stroke01', 'Stroke02', 'Stroke03', 'Stroke05', 'Stroke06', 'Stroke07', 'Stroke08', 'Stroke09', 'Stroke10', 'Contr01', 'Contr02', 'Contr03', 'Contr04', 'Contr05', 'Contr06', 'Contr07', 'Contr08', 'Contr09'};                          

% load output from script get_trial_frequencies.m
load([PATHOUT3 'fCnumTrialsUni_stroke.mat']);
load([PATHOUT3 'fCnumTrialsUni_contr.mat']);
load([PATHOUT3 'aCnumTrialsUni_stroke.mat']);
load([PATHOUT3 'aCnumTrialsUni_contr.mat']);

%% get chance levels for each subject, separately for the "follow commands task" and "announce commands task" 

% "follow commands task"
checkClass_fC_stroke = [];
for j = 1:length(SUBJ)/2
    [X, acc] = check_classifier([fCnumTrialsUni_stroke{j,1},fCnumTrialsUni_stroke{j,2},fCnumTrialsUni_stroke{j,3},fCnumTrialsUni_stroke{j,4}], 0.05,4); 
    checkClass_fC_stroke = [checkClass_fC_stroke; [X, acc]];
end
    
checkClass_fC_contr = [];
for j = 1:length(SUBJ)/2
    [X, acc] = check_classifier([fCnumTrialsUni_contr{j,1},fCnumTrialsUni_contr{j,2},fCnumTrialsUni_contr{j,3},fCnumTrialsUni_contr{j,4}], 0.05,4); 
    checkClass_fC_contr = [checkClass_fC_contr; [X, acc]];
end

% "announce commands task"
checkClass_aC_stroke = [];
for j = 1:length(SUBJ)/2
    [X, acc] = check_classifier([aCnumTrialsUni_stroke{j,1},aCnumTrialsUni_stroke{j,2},aCnumTrialsUni_stroke{j,3},aCnumTrialsUni_stroke{j,4}], 0.05,4); 
    checkClass_aC_stroke = [checkClass_aC_stroke; [X, acc]];
end
    
checkClass_aC_contr = [];
for j = 1:length(SUBJ)/2
    [X, acc] = check_classifier([aCnumTrialsUni_contr{j,1},aCnumTrialsUni_contr{j,2},aCnumTrialsUni_contr{j,3},aCnumTrialsUni_contr{j,4}], 0.05,4); 
    checkClass_aC_contr = [checkClass_aC_contr; [X, acc]];
end

% save all chance levels in one table
checkClass_fC = [checkClass_fC_stroke; checkClass_fC_contr];
checkClass_aC = [checkClass_aC_stroke; checkClass_aC_contr];
    
checkClass_allGroupsAndTasks = table(SUBJ', checkClass_fC,  checkClass_aC);
save([PATHOUT3 'checkClass_allGroupsAndTasks.mat'], 'checkClass_allGroupsAndTasks');
