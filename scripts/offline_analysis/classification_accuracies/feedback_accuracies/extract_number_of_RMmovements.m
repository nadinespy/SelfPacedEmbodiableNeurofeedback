% This script extracts the mean number of RH movements in rest and movement 
% phases (each of length 30 sec) of the "rest vs. move task" from the
% feedback block.

% Required packages/files: 
% eeglab13_4_4b

% Authors: Nadine Spychala, Edith Bongartz. 
% License: GNU GPLv3.

clear all; close all; clc;

% initializing paths
cd '/mydir/scripts/offline_analysis/classification_accuracies/feedback_accuracies/';
performanceAnalysis_init;

%% allocating variables

% distinguish between groups
groups = {'stroke', 'contr'};                                                               

SUBJ_stroke = {'01', '02', '03', '05', '06', '07', '08', '09', '10'};                       % subject numbers in stroke group
SUBJ_contr = {'01', '02', '03', '04', '05', '06', '07', '08', '09'};                        % subject numbers in control group
SUBJ_complete = {SUBJ_stroke; SUBJ_contr};

% start eeglab
eeglab;

%% extracting number of movements in "rest vs. move task"

 for y = 1:length(groups) 
    
    SUBJ = SUBJ_complete{y};

    RestALL = [];
    MoveALL = [];
    stdRestMoveALL = [];
    RestMoveMeansALL = [];

    for s = 1:length(SUBJ)
        EEG = pop_loadset(['nic_FHC_', groups{y}, SUBJ{s}, '_unilateral_test_rm.set'], PATHIN1);
        
        % insert events (extension/ flexion) in new array (RM)
        RM = nan(1,4*60*EEG.srate);      
         for p=1:length(EEG.event)
           if strcmp(EEG.event(p).type,'f');
              RM(1,int64(EEG.event(p).latency)) = 1;
           elseif strcmp(EEG.event(p).type,'e');
              RM(1,int64(EEG.event(p).latency)) = 1;
           else NaN;
           end
         end
         for t = 1:length(RM)
            if RM(t) == 1;
             RM(t) = 1;
            else RM(t) = 0;
            end
         end
         
         % sum up the triggers in the respective phases
         sumMoveP3 = sum(RM(30001:45000));
         sumRestP4 = sum(RM(45001:60000));
         sumMoveP5 = sum(RM(60001:75000));
         sumRestP6 = sum(RM(75001:90000));
         sumMoveP7 = sum(RM(90001:105000));
         sumRestP8 = sum(RM(105001:120000));
         
         % define number of movement and rest phases, respectively, for each subject
         numMove = 3;
         numRest = 3;
         
         Rest = [sumRestP4; sumRestP6; sumRestP8];
         Move = [sumMoveP3; sumMoveP5; sumMoveP7]; 
         stdRest = std(Rest)/sqrt(numRest);
         stdMove = std(Move)/sqrt(numMove);
         stdRestMove = [stdRest, stdMove];
         
         meanRest = ((sumRestP4+sumRestP6+sumRestP8)/numRest);
         meanMove = ((sumMoveP3+sumMoveP5+sumMoveP7)/numMove);
         RestMoveMeans = [meanRest, meanMove];
         
         % create array across subjects
         RestALL = [RestALL; Rest];
         MoveALL = [MoveALL; Move];
         RestMoveMeansALL = [RestMoveMeansALL; RestMoveMeans];
    end
    
    if y == 1;
        RestMoveMeans_stroke = table(RestMoveMeansALL(:,1), RestMoveMeansALL(:,2), 'RowNames', SUBJ, 'VariableNames',{'meanMovements_rest' 'meanMovements_move'});
    else 
        RestMoveMeans_contr = table(RestMoveMeansALL(:,1), RestMoveMeansALL(:,2), 'RowNames', SUBJ, 'VariableNames',{'meanMovements_rest' 'meanMovements_move'});
    end
    
    save([PATHOUT2 'RMmovements_' groups{y} '.mat'], ['RestMoveMeans_' groups{y}]);
 end
