% This script calculates the number of trials for the explicit commands
% "close", "open", "grasp", and the implicit command "rest."

% Authors: Nadine Spychala, Edith Bongartz. 
% License: GNU GPLv3.

clear all; close all; clc;

% initalize paths
cd '/mydir/scripts/offline_analysis/classification_accuracies/feedback_accuracies';
performanceAnalysis_init;

%% variables that distinguish between groups

groups = {'stroke', 'contr'};                                                               

SUBJ_stroke = {'01', '02', '03', '05', '06', '07', '08', '09', '10'};                       % subject numbers in stroke group
SUBJ_contr = {'01', '02', '03', '04', '05', '06', '07', '08', '09'};                        % subject numbers in control group
SUBJ_complete = {SUBJ_stroke; SUBJ_contr};

%% calculating number of trials for each class

 for y = 1:length(groups) 
    
    SUBJ = SUBJ_complete{y}; 
    
    % create matrices with number of trials per class
    fCnumTrialsCloseUni = [];
    fCnumTrialsOpenUni = [];
    fCnumTrialsGraspUni = [];
    fCnumTrialsRestUni = [];

    aCnumTrialsCloseUni = [];
    aCnumTrialsOpenUni = [];
    aCnumTrialsGraspUni = [];
    aCnumTrialsRestUni = [];

    for s = 1:length(SUBJ)

        load([PATHOUT2, groups{y}, SUBJ{s},'_successALL_unilateral.mat'], ['TrialsPerSubjectAll_' groups{y}]);
        
        if y == 1
            TrialsPerSubjectAll = TrialsPerSubjectAll_stroke;
        else
            TrialsPerSubjectAll = TrialsPerSubjectAll_contr;
        end
        
        d = TrialsPerSubjectAll{:,:};
        
        % follow commands task: command "close" 
        trial_number = length(d(find(~isnan(d(:,1))),1));
        fCnumTrialsCloseUni = [fCnumTrialsCloseUni; trial_number];
        
        % follow commands task: command "open"  
        trial_number = length(d(find(~isnan(d(:,3))),3));
        fCnumTrialsOpenUni = [fCnumTrialsOpenUni; trial_number];
        
        % follow commands task: command "grasp"  
        trial_number = length(d(find(~isnan(d(:,5))),5));
        fCnumTrialsGraspUni = [fCnumTrialsGraspUni; trial_number];
        
        % follow commands task: implicit command "rest" 
        trial_number = length(d(find(~isnan(d(:,8))),8));
        fCnumTrialsRestUni = [fCnumTrialsRestUni; trial_number];
        
        % announce commands task: command "close"  
        trial_number = length(d(find(~isnan(d(:,9))),9));
        aCnumTrialsCloseUni = [aCnumTrialsCloseUni; trial_number];
        
        % announce commands task: command "open"  
        trial_number = length(d(find(~isnan(d(:,11))),11));
        aCnumTrialsOpenUni = [aCnumTrialsOpenUni; trial_number];
        
        % announce commands task: command "grasp"   
        trial_number = length(d(find(~isnan(d(:,13))),13));
        aCnumTrialsGraspUni = [aCnumTrialsGraspUni; trial_number];
        
        % announce commands task: implicit command "rest"  
        trial_number = length(d(find(~isnan(d(:,16))),16));
        aCnumTrialsRestUni = [aCnumTrialsRestUni; trial_number];
    end 
    
     % number of trials per class per subject in one matrix (differentiating between fc & ac)
    if y == 1
        fCnumTrialsUni_stroke = table(fCnumTrialsCloseUni, fCnumTrialsOpenUni, fCnumTrialsGraspUni, fCnumTrialsRestUni, 'RowNames', SUBJ);
        aCnumTrialsUni_stroke = table(aCnumTrialsCloseUni, aCnumTrialsOpenUni, aCnumTrialsGraspUni, aCnumTrialsRestUni, 'RowNames', SUBJ);
       
    else
        fCnumTrialsUni_contr = table(fCnumTrialsCloseUni, fCnumTrialsOpenUni, fCnumTrialsGraspUni, fCnumTrialsRestUni, 'RowNames', SUBJ);
        aCnumTrialsUni_contr = table(aCnumTrialsCloseUni, aCnumTrialsOpenUni, aCnumTrialsGraspUni, aCnumTrialsRestUni, 'RowNames', SUBJ);
    end
    
    save([PATHOUT3 'fCnumTrialsUni_' groups{y} '.mat'], ['fCnumTrialsUni_' groups{y}]);
    save([PATHOUT3 'aCnumTrialsUni_' groups{y} '.mat'], ['aCnumTrialsUni_' groups{y}]);
 end
 