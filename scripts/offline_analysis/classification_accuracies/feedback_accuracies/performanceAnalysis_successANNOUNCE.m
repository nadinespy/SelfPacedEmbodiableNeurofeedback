% This script derives success rates for the trials in the "announce 
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
    ratioaCSuccessMoveCloseALLuni = []; 
    ratioaCSuccessRestCloseALLuni = [];
    ratioaCSuccessCloseALLuni = [];

    ratioaCSuccessMoveOpenALLuni = []; 
    ratioaCSuccessRestOpenALLuni = [];
    ratioaCSuccessOpenALLuni = [];

    ratioaCSuccessMoveGraspALLuni = []; 
    ratioaCSuccessRestGraspALLuni = [];
    ratioaCSuccessGraspALLuni = [];

    ratioaCSuccessMoveALLuni = [];
    ratioaCSuccessRestALLuni = [];
    ratioaCSuccessALLuni = []; 

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
        
        % load output from script performanceAnalysis_generateANNOUNCE.m
        load([PATHOUT1, groups{y}, SUBJ{s}, '_ANNOUNCE_unilateral.mat']);
        
        % command "close"
        command_ranges_close = find_command_index_ranges(ANNOUNCE, 1);                                      % find relevant intervals 
        [aCMoveClose, aCRestClose] = find_command_pattern_in_range(ANNOUNCE, command_ranges_close, 1);      % categorize trials as either successful or unsuccessful
      
        ratioaCSuccessMoveClose = sum(aCMoveClose)/length(aCMoveClose);                                     % derive success rate for moving trials (TPs)
        ratioaCSuccessRestClose = sum(aCRestClose)/length(aCRestClose);                                     % derive success rates for resting trials (TNs)
        
        aCSuccessClose = [aCMoveClose;aCRestClose];
        ratioaCSuccessClose = sum(aCSuccessClose)/length(aCSuccessClose);                                   % derive overall success rate
        
        % command "open"              
        command_ranges_open = find_command_index_ranges(ANNOUNCE, 3);
        [aCMoveOpen, aCRestOpen] = find_command_pattern_in_range(ANNOUNCE, command_ranges_open, 1);
        
        ratioaCSuccessMoveOpen = sum(aCMoveOpen)/length(aCMoveOpen);
        ratioaCSuccessRestOpen = sum(aCRestOpen)/length(aCRestOpen);
        
        aCSuccessOpen = [aCMoveOpen;aCRestOpen];
        ratioaCSuccessOpen = sum(aCSuccessOpen)/length(aCSuccessOpen);
        
        % command "grasp"
        command_ranges_grasp = find_command_index_ranges(ANNOUNCE, 5);
        [aCMoveGrasp, aCRestGrasp] = find_command_pattern_in_range(ANNOUNCE, command_ranges_grasp, 2);
        
        ratioaCSuccessMoveGrasp = sum(aCMoveGrasp)/length(aCMoveGrasp);
        ratioaCSuccessRestGrasp = sum(aCRestGrasp)/length(aCRestGrasp);
        
        aCSuccessGrasp = [aCMoveGrasp;aCRestGrasp];
        ratioaCSuccessGrasp = sum(aCSuccessGrasp)/length(aCSuccessGrasp);
        
        % success rates across commands
        aCMove = [aCMoveClose;aCMoveOpen;aCMoveGrasp];
        aCRest = [aCRestClose;aCRestOpen;aCRestGrasp];
        
        ratioaCSuccessMove = sum(aCMove)/length(aCMove);
        ratioaCSuccessRest = sum(aCRest)/length(aCRest);
        
        aCSuccess = [aCMove;aCRest];
        ratioaCSuccess = sum(aCSuccess)/length(aCSuccess);
        
        % matching lengths of arrays
        if length(aCMoveClose) < N
            tmp = nan(N-length(aCMoveClose),1);
            aCMoveClose = [aCMoveClose;tmp];
        end
        if length(aCRestClose) < N
            tmp = nan(N-length(aCRestClose),1);
            aCRestClose = [aCRestClose;tmp];
        end
        if length(aCMoveOpen) < N
            tmp = nan(N-length(aCMoveOpen),1);
            aCMoveOpen = [aCMoveOpen;tmp];
        end
        if length(aCRestOpen) < N
            tmp = nan(N-length(aCRestOpen),1);
            aCRestOpen = [aCRestOpen;tmp];
        end
        if length(aCMoveGrasp) < N
            tmp = nan(N-length(aCMoveGrasp),1);
            aCMoveGrasp = [aCMoveGrasp;tmp];
        end
        if length(aCRestGrasp) < N
           tmp = nan(N-length(aCRestGrasp),1);
           aCRestGrasp = [aCRestGrasp;tmp];
        end
        if length(aCMove) < N
            tmp = nan(N-length(aCMove),1);
            aCMove = [aCMove;tmp];
        end
        if length(aCRest) < N
           tmp = nan(N-length(aCRest),1);
           aCRest = [aCRest;tmp];
        end
        
        % save successes and failures per subject
        if y == 1
            TrialsPerSubject_aC_stroke = table(aCMoveClose, aCRestClose, aCMoveOpen, aCRestOpen, aCMoveGrasp, aCRestGrasp, aCMove, aCRest);
            save([PATHOUT2, groups{y}, SUBJ{s}, '_aCsuccess_unilateral.mat'], 'TrialsPerSubject_aC_stroke');
        else
            TrialsPerSubject_aC_contr = table(aCMoveClose, aCRestClose, aCMoveOpen, aCRestOpen, aCMoveGrasp, aCRestGrasp, aCMove, aCRest);
            save([PATHOUT2, groups{y}, SUBJ{s}, '_aCsuccess_unilateral.mat'], 'TrialsPerSubject_aC_contr');
        end
        
        % store success rates in across subject variable
        ratioaCSuccessMoveCloseALLuni = [ratioaCSuccessMoveCloseALLuni; ratioaCSuccessMoveClose];
        ratioaCSuccessRestCloseALLuni = [ratioaCSuccessRestCloseALLuni; ratioaCSuccessRestClose];
        ratioaCSuccessCloseALLuni = [ratioaCSuccessCloseALLuni; ratioaCSuccessClose];
            
        ratioaCSuccessMoveOpenALLuni = [ratioaCSuccessMoveOpenALLuni; ratioaCSuccessMoveOpen];
        ratioaCSuccessRestOpenALLuni = [ratioaCSuccessRestOpenALLuni; ratioaCSuccessRestOpen];
        ratioaCSuccessOpenALLuni = [ratioaCSuccessOpenALLuni; ratioaCSuccessOpen];
            
        ratioaCSuccessMoveGraspALLuni = [ratioaCSuccessMoveGraspALLuni; ratioaCSuccessMoveGrasp];
        ratioaCSuccessRestGraspALLuni = [ratioaCSuccessRestGraspALLuni; ratioaCSuccessRestGrasp];
        ratioaCSuccessGraspALLuni = [ratioaCSuccessGraspALLuni; ratioaCSuccessGrasp];
            
        ratioaCSuccessMoveALLuni = [ratioaCSuccessMoveALLuni; ratioaCSuccessMove]; 
        ratioaCSuccessRestALLuni = [ratioaCSuccessRestALLuni; ratioaCSuccessRest];
        ratioaCSuccessALLuni = [ratioaCSuccessALLuni; ratioaCSuccess];     
   end
   
   % save success rates of all subjects
   if y==1
        ratioaC_stroke = table(ratioaCSuccessMoveCloseALLuni, ratioaCSuccessRestCloseALLuni,...
        ratioaCSuccessCloseALLuni, ratioaCSuccessMoveOpenALLuni, ratioaCSuccessRestOpenALLuni, ratioaCSuccessOpenALLuni, ratioaCSuccessMoveGraspALLuni,...
        ratioaCSuccessRestGraspALLuni, ratioaCSuccessGraspALLuni, ratioaCSuccessMoveALLuni, ratioaCSuccessRestALLuni, ratioaCSuccessALLuni, 'rowNames', SUBJ);
        save([PATHOUT2 'ratioaC_' groups{y} '.mat'], 'ratioaC_stroke');
   else
        ratioaC_contr = table(ratioaCSuccessMoveCloseALLuni, ratioaCSuccessRestCloseALLuni,...
        ratioaCSuccessCloseALLuni, ratioaCSuccessMoveOpenALLuni, ratioaCSuccessRestOpenALLuni, ratioaCSuccessOpenALLuni, ratioaCSuccessMoveGraspALLuni,...
        ratioaCSuccessRestGraspALLuni, ratioaCSuccessGraspALLuni, ratioaCSuccessMoveALLuni, ratioaCSuccessRestALLuni, ratioaCSuccessALLuni, 'rowNames', SUBJ);
        save([PATHOUT2 'ratioaC_' groups{y} '.mat'], 'ratioaC_contr');
   end
 end 
    