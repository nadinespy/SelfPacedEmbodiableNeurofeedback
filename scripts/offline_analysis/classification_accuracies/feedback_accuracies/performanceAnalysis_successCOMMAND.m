% This script derives success rates for the trials in the "follow 
% commands task" of the feedback session.

% Required packages/files: 
% eeglab13_4_4b
% find_command_index_ranges.m
% find_command_pattern_in_range.m

% Authors: Nadine Spychala, Edith Bongartz. 
% License: GNU GPLv3.

clear all; close all; clc;

%% allocating variables

% initalize paths
cd '/mnt/525C77605C773E33/all my stuff/free robotic hand control/article/scripts for publication check/scripts/offline_analysis/classification_accuracies/feedback_accuracies';
performanceAnalysis_init; 

N = 90;                                                                                     % standard length of matrices being created (so that they can be concatinated)

%% variables that distinguish between groups

groups = {'stroke', 'contr'};                                                               

SUBJ_stroke = {'01', '02', '03', '05', '06', '07', '08', '09', '10'};                       % subject numbers in stroke group
SUBJ_contr = {'01', '02', '03', '04', '05', '06', '07', '08', '09'};                        % subject numbers in control group
SUBJ_complete = {SUBJ_stroke; SUBJ_contr};

%% deriving success rates

for y = 1:length(groups) 
    
    SUBJ = SUBJ_complete{y};  
    
    % allocate variables for different commands ("open", "close", "grasp"), and separately for rest and movement trials
    ratiofCSuccessMoveCloseALLuni = []; 
    ratiofCSuccessRestCloseALLuni = [];
    ratiofCSuccessCloseALLuni = [];

    ratiofCSuccessMoveOpenALLuni = []; 
    ratiofCSuccessRestOpenALLuni = [];
    ratiofCSuccessOpenALLuni = [];

    ratiofCSuccessMoveGraspALLuni = []; 
    ratiofCSuccessRestGraspALLuni = [];
    ratiofCSuccessGraspALLuni = [];

    ratiofCSuccessMoveALLuni = [];
    ratiofCSuccessRestALLuni = [];
    ratiofCSuccessALLuni = [];

    % derive success rates for different commands, and separately for rest and movement trials: 
    
    % MOVEMENT: looking into the time windows inbetween the given command and the movement that
    % follows; the time window in which the movement takes place, is a success (array contains 1),
    % the ones that precede that time window are a failure (array contains 0, the more time 
    % windows precede the one in which the movement takes place, the more time it took for the 
    % hand to be moved).
    
    % REST: looking into the time windows inbetween the movement after the given command and the 
    % next command, time windows in which a movement takes place, are a failure (array contains 0),
    % time windows in which no movement takes place, are a success (array contains 1).
 
    for s = 1:length(SUBJ)
        
        % load output from script performanceAnalysis_generateCOMMAND.m
        load([PATHOUT1, groups{y}, SUBJ{s}, '_COMMAND_unilateral.mat']);
        
        % command "close"       
        command_ranges_close = find_command_index_ranges(COMMAND, 1);                                       % find relevant intervals 
        [fCMoveClose, fCRestClose] = find_command_pattern_in_range(COMMAND, command_ranges_close, 1);       % categorize trials as either successful or unsuccessful
        
        ratiofCSuccessMoveClose = sum(fCMoveClose)/length(fCMoveClose);                                     % derive success rate for moving trials (TPs)
        ratiofCSuccessRestClose = sum(fCRestClose)/length(fCRestClose);                                     % derive success rates for resting trials (TNs)
        
        fCSuccessClose = [fCRestClose;fCRestClose];
        ratiofCSuccessClose = sum(fCSuccessClose)/length(fCSuccessClose);                                   % derive overall success rate
        
        % command "open"    
        command_ranges_open = find_command_index_ranges(COMMAND, 3);
        [fCMoveOpen, fCRestOpen] = find_command_pattern_in_range(COMMAND, command_ranges_open, 1);
        
        ratiofCSuccessMoveOpen = sum(fCMoveOpen)/length(fCMoveOpen);
        ratiofCSuccessRestOpen = sum(fCRestOpen)/length(fCRestOpen);
        
        fCSuccessOpen = [fCMoveOpen;fCRestOpen];
        ratiofCSuccessOpen = sum(fCSuccessOpen)/length(fCSuccessOpen);
        
        % command "grasp"
        command_ranges_grasp = find_command_index_ranges(COMMAND, 5);
        [fCMoveGrasp, fCRestGrasp] = find_command_pattern_in_range(COMMAND, command_ranges_grasp, 2);

        ratiofCSuccessMoveGrasp = sum(fCMoveGrasp)/length(fCMoveGrasp);
        ratiofCSuccessRestGrasp = sum(fCRestGrasp)/length(fCRestGrasp);
        
        fCSuccessGrasp = [fCMoveGrasp;fCRestGrasp];
        ratiofCSuccessGrasp = sum(fCSuccessGrasp)/length(fCSuccessGrasp);
        
        % success rates across commands
        fCMove = [fCMoveClose;fCMoveOpen;fCMoveGrasp];
        fCRest = [fCRestClose;fCRestOpen;fCRestGrasp];
        
        ratiofCSuccessMove = sum(fCMove)/length(fCMove);
        ratiofCSuccessRest = sum(fCRest)/length(fCRest);
        
        fCSuccess = [fCMove;fCRest];
        ratiofCSuccess = sum(fCSuccess)/length(fCSuccess);
        
        % matching lengths of arrays
        if length(fCMoveClose) < N
            tmp = nan(N-length(fCMoveClose),1);
            fCMoveClose = [fCMoveClose;tmp];
        end
        if length(fCRestClose) < N
            tmp = nan(N-length(fCRestClose),1);
            fCRestClose = [fCRestClose;tmp];
        end
        if length(fCMoveOpen) < N
            tmp = nan(N-length(fCMoveOpen),1);
            fCMoveOpen = [fCMoveOpen;tmp];
        end
        if length(fCRestOpen) < N
            tmp = nan(N-length(fCRestOpen),1);
            fCRestOpen = [fCRestOpen;tmp];
        end
        if length(fCMoveGrasp) < N
            tmp = nan(N-length(fCMoveGrasp),1);
            fCMoveGrasp = [fCMoveGrasp;tmp];
        end
        if length(fCRestGrasp) < N
           tmp = nan(N-length(fCRestGrasp),1);
           fCRestGrasp = [fCRestGrasp;tmp];
        end
        if length(fCMove) < N
            tmp = nan(N-length(fCMove),1);
            fCMove = [fCMove;tmp];
        end
        if length(fCRest) < N
           tmp = nan(N-length(fCRest),1);
           fCRest = [fCRest;tmp];
        end

        % save successes and failures per subject
        if y == 1
            TrialsPerSubject_fC_stroke = table(fCMoveClose, fCRestClose, fCMoveOpen, fCRestOpen, fCMoveGrasp, fCRestGrasp, fCMove, fCRest);
            save([PATHOUT2, groups{y}, SUBJ{s}, '_fCsuccess_unilateral.mat'], 'TrialsPerSubject_fC_stroke');
        else
            TrialsPerSubject_fC_contr = table(fCMoveClose, fCRestClose, fCMoveOpen, fCRestOpen, fCMoveGrasp, fCRestGrasp, fCMove, fCRest);
            save([PATHOUT2, groups{y}, SUBJ{s}, '_fCsuccess_unilateral.mat'], 'TrialsPerSubject_fC_contr');
        end
        
        % store success rates in across subject variable
        ratiofCSuccessMoveCloseALLuni = [ratiofCSuccessMoveCloseALLuni; ratiofCSuccessMoveClose];
        ratiofCSuccessRestCloseALLuni = [ratiofCSuccessRestCloseALLuni; ratiofCSuccessRestClose];
        ratiofCSuccessCloseALLuni = [ratiofCSuccessCloseALLuni; ratiofCSuccessClose];
            
        ratiofCSuccessMoveOpenALLuni = [ratiofCSuccessMoveOpenALLuni; ratiofCSuccessMoveOpen];
        ratiofCSuccessRestOpenALLuni = [ratiofCSuccessRestOpenALLuni; ratiofCSuccessRestOpen];
        ratiofCSuccessOpenALLuni = [ratiofCSuccessOpenALLuni; ratiofCSuccessOpen];
            
        ratiofCSuccessMoveGraspALLuni = [ratiofCSuccessMoveGraspALLuni; ratiofCSuccessMoveGrasp];
        ratiofCSuccessRestGraspALLuni = [ratiofCSuccessRestGraspALLuni; ratiofCSuccessRestGrasp];
        ratiofCSuccessGraspALLuni = [ratiofCSuccessGraspALLuni; ratiofCSuccessGrasp];
            
        ratiofCSuccessMoveALLuni = [ratiofCSuccessMoveALLuni; ratiofCSuccessMove]; 
        ratiofCSuccessRestALLuni = [ratiofCSuccessRestALLuni; ratiofCSuccessRest];
        ratiofCSuccessALLuni = [ratiofCSuccessALLuni; ratiofCSuccess];      
    end
    
    % save success rates of all subjects
    if y==1
        ratiofC_stroke = table(ratiofCSuccessMoveCloseALLuni, ratiofCSuccessRestCloseALLuni, ratiofCSuccessCloseALLuni, ratiofCSuccessMoveOpenALLuni,...,
        ratiofCSuccessRestOpenALLuni, ratiofCSuccessOpenALLuni, ratiofCSuccessMoveGraspALLuni, ratiofCSuccessRestGraspALLuni, ratiofCSuccessGraspALLuni,...
        ratiofCSuccessMoveALLuni, ratiofCSuccessRestALLuni, ratiofCSuccessALLuni, 'rowNames', SUBJ);
        save([PATHOUT2 'ratiofC_' groups{y} '.mat'], 'ratiofC_stroke');
    else 
        ratiofC_contr = table(ratiofCSuccessMoveCloseALLuni, ratiofCSuccessRestCloseALLuni, ratiofCSuccessCloseALLuni, ratiofCSuccessMoveOpenALLuni,...,
        ratiofCSuccessRestOpenALLuni, ratiofCSuccessOpenALLuni, ratiofCSuccessMoveGraspALLuni, ratiofCSuccessRestGraspALLuni, ratiofCSuccessGraspALLuni,...
        ratiofCSuccessMoveALLuni, ratiofCSuccessRestALLuni, ratiofCSuccessALLuni, 'rowNames', SUBJ);
        save([PATHOUT2 'ratiofC_' groups{y} '.mat'], 'ratiofC_contr');
    end
end
