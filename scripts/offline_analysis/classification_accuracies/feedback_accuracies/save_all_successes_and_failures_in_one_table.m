% This script saves successes and failures from all tasks ("rest vs. move 
% task", "follow commands task", "announce commands task") of the feedback 
% block into one table.

% Authors: Nadine Spychala, Edith Bongartz. 
% License: GNU GPLv3.

clear all; close all; clc;

% initialize paths
cd '/mydir/scripts/offline_analysis/classification_accuracies/feedback_accuracies';
performanceAnalysis_init;

%% variables that distinguish between groups

groups = {'stroke', 'contr'};                                                               

SUBJ_stroke = {'01', '02', '03', '05', '06', '07', '08', '09', '10'};                       % subject numbers in stroke group
SUBJ_contr = {'01', '02', '03', '04', '05', '06', '07', '08', '09'};                        % subject numbers in control group
SUBJ_complete = {SUBJ_stroke; SUBJ_contr};

%% load successes and failures of all tasks and save them in one table per subject

for y = 1:length(groups) 
    
    SUBJ = SUBJ_complete{y};

    for s = 1:length(SUBJ)
        load([PATHOUT2, groups{y}, SUBJ{s}, '_fCsuccess_unilateral.mat'], ['TrialsPerSubject_fC_' groups{y}]);
        load([PATHOUT2, groups{y}, SUBJ{s},'_aCsuccess_unilateral.mat'], ['TrialsPerSubject_aC_' groups{y}] );
        load([PATHOUT2, groups{y}, SUBJ{s},'_RMsuccess_unilateral.mat'], ['TrialsPerSubject_RM_' groups{y}]);
        
        TrialsPerSubjectAll_tmp = [];
        
        if y == 1
            for t = 1:19
                if t < 9
                    TrialsPerSubjectAll_tmp(:,t) = TrialsPerSubject_fC_stroke{:,t};
                elseif (8 < t) && (t < 17)
                    TrialsPerSubjectAll_tmp(:,t) = TrialsPerSubject_aC_stroke{:,t-8};
                else
                    TrialsPerSubjectAll_tmp(:,t) = TrialsPerSubject_RM_stroke{:,t-16};
                end
            end
        else
            for t = 1:19
                if t < 9
                    TrialsPerSubjectAll_tmp(:,t) = TrialsPerSubject_fC_contr{:,t};
                elseif (8 < t) && (t < 17)
                    TrialsPerSubjectAll_tmp(:,t) = TrialsPerSubject_aC_contr{:,t-8};
                else
                    TrialsPerSubjectAll_tmp(:,t) = TrialsPerSubject_RM_contr{:,t-16};
                end
            end
        end
        
        if y == 1
            TrialsPerSubjectAll_stroke = array2table(TrialsPerSubjectAll_tmp, 'VariableNames',{'fCMoveClose', 'fCRestClose', 'fCMoveOpen',...
            'fCRestOpen', 'fCMoveGrasp', 'fCRestGrasp', 'fCMove', 'fCRest', 'aCMoveClose', 'aCRestClose', 'aCMoveOpen', 'aCRestOpen',...
            'aCMoveGrasp', 'aCRestGrasp', 'aCMove', 'aCRest', 'rmMove', 'rmRest', 'rmSuccess'}); 
        else
            TrialsPerSubjectAll_contr = array2table(TrialsPerSubjectAll_tmp, 'VariableNames',{'fCMoveClose', 'fCRestClose', 'fCMoveOpen',...
            'fCRestOpen', 'fCMoveGrasp', 'fCRestGrasp', 'fCMove', 'fCRest', 'aCMoveClose', 'aCRestClose', 'aCMoveOpen', 'aCRestOpen',...
            'aCMoveGrasp', 'aCRestGrasp', 'aCMove', 'aCRest', 'rmMove', 'rmRest', 'rmSuccess'}); 
        end
        
        save([PATHOUT2, groups{y}, SUBJ{s}, '_successALL_unilateral.mat'], ['TrialsPerSubjectAll_' groups{y}]);
    end
    
end 