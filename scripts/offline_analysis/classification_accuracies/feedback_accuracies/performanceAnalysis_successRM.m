% This script derives success rates for the trials in the "announce 
% commands task" of the feedback session.

% Required packages/files: 
% eeglab13_4_4b

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
    ratiormSuccessMoveALLuni = [];
    ratiormSuccessRestALLuni = [];
    ratiormSuccessALLuni = [];

    % derive success rates for rest and movement phases: 
    
    % MOVEMENT: looking into the time windows inbetween the LED onset and the movement that
    % follows; the time window in which the movement takes place, is a success (array contains 1),
    % the ones that precede that time window are a failure (array contains 0, the more time 
    % windows precede the one in which the movement takes place, the more time it took for the 
    % hand to be moved); same for remaining trials within the movement phase.
    
    % REST: looking into the time windows inbetween LED off- and onset; time windows in which a 
    % movement takes place, are a failure (array contains 0), time windows in which no movement 
    % takes place, are a success (array contains 1).
    
    for s = 1:length(SUBJ)
        
        % load output from script performanceAnalysis_generateRM
        load([PATHOUT1, groups{y}, SUBJ{s}, '_RM_unilateral.mat']);
    
        rmMove = [];
        for d = 1:length(RM)
             if RM(d,1) == 2
                 for j = (d+1):length(RM)
                     if RM(j,1) == 6
                        tmpFailure = [];
                        for i = (d+1):j
                            if (RM(i,1) == 1) || (RM(i,1) == 0)
                            rmMove = [rmMove; 1];
                            break
                            else rmMove = [rmMove; 1];
                            end
                        end
                        break
                     end                  
                 end
             end
        end
        
        for k = 1:length(RM)
            if RM(k,1) == 2  
                    for w = (k+1):length(RM)
                        if (RM(w,1) == 3) || (w == length(RM))
                            for i = (k+1):w
                                if RM(i,1) == 6     
                                    for p = (i+1):w
                                        if RM(p,1) == 6  
                                        tmpFailure = [];
                                            for m = (i+1):p
                                                if (RM(m,1) == 1) || (RM(m,1) == 0)                                       
                                                rmMove = [rmMove; 1];
                                                break
                                                else rmMove = [rmMove; 0];
                                                end 
                                            end
                                            break
                                        end
                                    end
                                end
                            end
                            break
                        end
                    end
            end
        end
        
        rmRest = [];
        for d = 1:length(RM)
             if RM(d,1) == 3
                 for j = (d+1):length(RM)
                     if RM(j,1) == 6
                        tmpFailure = [];
                        for i = (d+1):j
                            if (RM(i,1) == 1) || (RM(i,1) == 0)
                            rmRest = [rmRest; 0];
                            break
                            else rmRest = [rmRest; 1];
                            end 
                        end
                        break
                     end              
                 end
             end
        end
        
        for k = 1:length(RM)
            if RM(k,1) == 3  
                    for w = (k+1):length(RM)
                        if (RM(w,1) == 2) || (w == length(RM))
                            for i = (k+1):w
                                if RM(i,1) == 6     
                                    for p = (i+1):w
                                        if RM(p,1) == 6  
                                        tmpFailure = [];
                                            for m = (i+1):p
                                                if (RM(m,1) == 1) || (RM(m,1) == 0)                                       
                                                rmRest = [rmRest; 0];
                                                break
                                                else rmRest = [rmRest; 1];
                                                end 
                                            end
                                            break
                                        end
                                    end
                                end
                            end
                            break
                        end
                    end
            end
        end 
        
        ratiormSuccessMove = sum(rmMove)/length(rmMove);
        ratiormSuccessRest = sum(rmRest)/length(rmRest);
        
        rmSuccess = [rmMove;rmRest];
        ratiormSuccess = sum(rmSuccess)/length(rmSuccess);

        % matching lengths of arrays
        if length(rmMove) < N
           tmp = nan(N-length(rmMove),1);
           rmMove = [rmMove;tmp];
        end
        if length(rmRest) < N
           tmp = nan(N-length(rmRest),1);
           rmRest = [rmRest;tmp];
        end
        if length(rmSuccess) < N
           tmp = nan(N-length(rmSuccess),1);
           rmSuccess = [rmSuccess;tmp];
        end
        
        % save successes and failures per subject
        if y == 1
            TrialsPerSubject_RM_stroke = table(rmMove, rmRest, rmSuccess);
            save([PATHOUT2, groups{y}, SUBJ{s}, '_RMsuccess_unilateral.mat'], 'TrialsPerSubject_RM_stroke');
        else
            TrialsPerSubject_RM_contr = table(rmMove, rmRest, rmSuccess);
            save([PATHOUT2, groups{y}, SUBJ{s}, '_RMsuccess_unilateral.mat'], 'TrialsPerSubject_RM_contr');
        end
        
        % save success rates of all subjects
        ratiormSuccessMoveALLuni = [ratiormSuccessMoveALLuni; ratiormSuccessMove];
        ratiormSuccessRestALLuni = [ratiormSuccessRestALLuni; ratiormSuccessRest];
        ratiormSuccessALLuni = [ratiormSuccessALLuni; ratiormSuccess];
    end
    
    % save success rates of all subjects
    if y == 1
        ratioRM_stroke = table(ratiormSuccessMoveALLuni, ratiormSuccessRestALLuni, ratiormSuccessALLuni, 'RowNames', SUBJ);
        save([PATHOUT2 'ratioRM_' groups{y} '.mat'], 'ratioRM_stroke');
    else
        ratioRM_contr = table(ratiormSuccessMoveALLuni, ratiormSuccessRestALLuni, ratiormSuccessALLuni, 'RowNames', SUBJ);
        save([PATHOUT2 'ratioRM_' groups{y} '.mat'], 'ratioRM_contr');
    end 
end 
