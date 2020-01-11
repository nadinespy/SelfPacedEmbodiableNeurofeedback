% This script aggregates output files from various scripts and derives
% several tables - one for subjective ratings, one for feedback accuracies,
% one for ERD-related values, and one for demographic data. These are 
% further aggregated in aggregate_data.m.

% Authors: Nadine Spychala.
% License: GNU GPLv3.

clear all; close all; clc;

MAINPATH =  '/mydir/analysis/';
PATHIN1 =   [MAINPATH, 'subjective_ratings/'];
PATHIN2 =   [MAINPATH, 'classification_accuracies/feedback_accuracies/ratios/'];
PATHIN3 =   [MAINPATH, 'classification_accuracies/training_accuracies/'];
PATHIN4 =   [MAINPATH, 'time_frequency_analysis/ana03_CSP/'];
PATHIN5 =   [MAINPATH, 'time_frequency_analysis/ana04_wavelet/'];
PATHOUT1 =  [MAINPATH, 'data_aggregation/'];

%% subject variable for all tables

Subj = {'Stroke01', 'Stroke02', 'Stroke03', 'Stroke05', 'Stroke06', 'Stroke07','Stroke08','Stroke09','Stroke10','Contr01', 'Contr02','Contr03','Contr04','Contr05', 'Contr06','Contr07', 'Contr08','Contr09'}';

%% subjective ratings 

% load output files from subjective_ratings.m
list_subjective_ratings = dir(fullfile([PATHIN1 '/*.mat']));
subjective_ratings = {};                                                                       
for d = 1:length(list_subjective_ratings)
    subjective_ratings = [subjective_ratings; list_subjective_ratings(d).name];
end

 for d = 1:length(subjective_ratings)
     load([PATHIN1 subjective_ratings{d}]);    
 end 

% SoO
SoOtr = [SoOstroke{:,{'SoO_Train_Stroke'}};SoOcontr{:,{'SoO_Train_Contr'}}]; 
SoOfb = [SoOstroke{:,{'SoO_Test_Stroke'}};SoOcontr{:,{'SoO_Test_Contr'}}]; 

% SoA
SoAtr = [SoAstroke{:,{'SoA_Train_Stroke'}};SoAcontr{:,{'SoA_Train_Contr'}}]; 
SoAfb = [SoAstroke{:,{'SoA_Test_Stroke'}};SoAcontr{:,{'SoA_Test_Contr'}}]; 

% MIAB
MIABtr = [MIABstroke{:,{'MIAB_Train_Stroke'}};MIABcontr{:,{'MIAB_Train_Contr'}}]; 
MIABfb = [MIABstroke{:,{'MIAB_Test_Stroke'}};MIABcontr{:,{'MIAB_Test_Contr'}}]; 

% ER
ERtr = [ERstroke{:,{'ER_Train_Stroke'}};ERcontr{:,{'ER_Train_Contr'}}]; 
ERfb = [ERstroke{:,{'ER_Test_Stroke'}};ERcontr{:,{'ER_Test_Contr'}}]; 

% control questions
% SoO
SoOtr_c = [CIstroke{:,{'CI_SoO_Train_Stroke'}};CIcontr{:,{'CI_SoO_Train_Contr'}}];
SoOfb_c = [CIstroke{:,{'CI_SoO_Test_Stroke'}};CIcontr{:,{'CI_SoO_Test_Contr'}}];

% SoA
SoAtr_c = [CIstroke{:,{'CI_SoA_Train_Stroke'}};CIcontr{:,{'CI_SoA_Train_Contr'}}];
SoAfb_c = [CIstroke{:,{'CI_SoA_Test_Stroke'}};CIcontr{:,{'CI_SoA_Test_Contr'}}];

% save in one table
SUM_Ques = table(Subj, SoOtr,SoOtr_c, SoOfb,SoOfb_c, SoAtr,SoAtr_c, SoAfb,SoAfb_c, MIABtr,MIABfb,ERtr,ERfb);
save([PATHOUT1 'SUM_Ques.mat'], 'SUM_Ques');

%% feedback accuracies

list_ratios = dir(fullfile([PATHIN2 '/*ratio*.mat']));
list_movement = dir(fullfile([PATHIN2 '/*movement*.mat']));

ratios = {};  
for d = 1:length(list_ratios)
    ratios = [ratios; list_ratios(d).name];
end
 for d = 1:length(ratios)
     load([PATHIN2 ratios{d}]);    
 end 
 
movement = {};
for d = 1:length(list_movement)
    movement = [movement; list_movement(d).name];
end
 for d = 1:length(movement)
     load([PATHIN2 movement{d}]);    
 end 
 
% "follow commands task"
FAfc_rest = [ratiofC_stroke{:,'ratiofCSuccessRestALLuni'}; ratiofC_contr{:,'ratiofCSuccessRestALLuni'}];
FAfc_rest(isnan(FAfc_rest)) = 0;
FAfc_move = [ratiofC_stroke{:,'ratiofCSuccessMoveALLuni'}; ratiofC_contr{:,'ratiofCSuccessMoveALLuni'}];
FAfc_move(isnan(FAfc_move)) = 0;
FAfc_ALL = [ratiofC_stroke{:,'ratiofCSuccessALLuni'}; ratiofC_contr{:,'ratiofCSuccessALLuni'}];
FAfc_ALL(isnan(FAfc_ALL)) = 0;

% "accounce commands task"
FAan_rest = [ratioaC_stroke{:,'ratioaCSuccessRestALLuni'}; ratioaC_contr{:,'ratioaCSuccessRestALLuni'}];
FAan_rest(isnan(FAan_rest)) = 0;
FAan_move = [ratioaC_stroke{:,'ratioaCSuccessMoveALLuni'}; ratioaC_contr{:,'ratioaCSuccessMoveALLuni'}];
FAan_move(isnan(FAan_move)) = 0;
FAan_ALL = [ratioaC_stroke{:,'ratioaCSuccessALLuni'}; ratioaC_contr{:,'ratioaCSuccessALLuni'}];
FAan_ALL(isnan(FAan_ALL)) = 0;

% "rest vs. move task"
FArm_rest = [ratioRM_stroke{:,'ratiormSuccessRestALLuni'}; ratioRM_contr{:,'ratiormSuccessRestALLuni'}];
FArm_rest(isnan(FArm_rest)) = 0;
FArm_move = [ratioRM_stroke{:,'ratiormSuccessMoveALLuni'}; ratioRM_contr{:,'ratiormSuccessMoveALLuni'}];
FArm_move(isnan(FArm_move)) = 0;
FArm_ALL = [ratioRM_stroke{:,'ratiormSuccessALLuni'}; ratioRM_contr{:,'ratiormSuccessALLuni'}];
FArm_ALL(isnan(FArm_ALL)) = 0;

% "movements in rest vs. move task"
rmMovementsInRest = [RestMoveMeans_stroke{:,'meanMovements_rest'}; RestMoveMeans_contr{:,'meanMovements_rest'}];
rmMovementsInMove = [RestMoveMeans_stroke{:,'meanMovements_move'}; RestMoveMeans_contr{:,'meanMovements_move'}];

% overall mean
mean_fc_ac_rm = (FAfc_ALL+FAan_ALL+FArm_ALL)/3;

% save in one table
SUM_FA = table(Subj, FAfc_rest, FAfc_move, FAfc_ALL, FAan_rest, FAan_move, FAan_ALL, FArm_rest, FArm_move, FArm_ALL, mean_fc_ac_rm, rmMovementsInRest, rmMovementsInMove);
save([PATHOUT1 'SUM_FA.mat'], 'SUM_FA');

%% training accuracies

list_training_accuracies = dir(fullfile([PATHIN3 '*class*.mat']));
training_accuracies = {};                                                                       
for d = 1:length(list_training_accuracies)
    training_accuracies = [training_accuracies; list_training_accuracies(d).name];
end

 for d = 1:length(training_accuracies)
     load([PATHIN3 training_accuracies{d}]);    
 end 
 
TAof = [classRates_stroke{:,{'classRatesOF'}}; classRates_contr{:,{'classRatesOF'}}];

TAce = [classRates_stroke{:,{'classRatesCE'}}; classRates_contr{:,{'classRatesCE'}}];

TAef = [classRates_stroke{:,{'classRatesEF'}}; classRates_contr{:,{'classRatesEF'}}];

% overall mean
mean_of_ce_ef = (TAof+TAce+TAef)/3;

% save in one table
SUM_TA = table(Subj, TAof, TAce, TAef, mean_of_ce_ef);
save([PATHOUT1 'SUM_TA.mat'], 'SUM_TA');

%% ERD values, latencies and CSP criteria

list_ERD = dir(fullfile([PATHIN5 '*ERD*.mat']));
ERD = {};                                                                       
for d = 1:length(list_ERD)
    ERD = [ERD; list_ERD(d).name];
end
 for d = 1:length(ERD)
     load([PATHIN5 ERD{d}]);    
 end

list_CSP = dir(fullfile([PATHIN4 'CSP*.mat']));
CSP = {};                                                                       
for d = 1:length(list_CSP)
    CSP = [CSP; list_CSP(d).name];
end
 for d = 1:length(CSP)
     load([PATHIN4 CSP{d}]);    
 end
 
ERDtrainFuni = [SUM_ERDuni_CSP_stroke{:,'ERDtrainFuni'};SUM_ERDuni_CSP_contr{:,'ERDtrainFuni'}];
ERDtrainEuni = [SUM_ERDuni_CSP_stroke{:,'ERDtrainEuni'};SUM_ERDuni_CSP_contr{:,'ERDtrainEuni'}];
         
% latencies
ERDlatency = [ERDlatency_stroke{:,'ERDlatency'};ERDlatency_contr{:,'ERDlatency'}];

% CSP criteria
CSPcriteria = [CSPstroke{'SUM',:}, CSPcontr{'SUM',:}]';

% save in one table
SUM_ERD = table(Subj, ERDtrainFuni, ERDtrainEuni, ERDlatency, CSPcriteria);
save([PATHOUT1 'SUM_ERD.mat'], 'SUM_ERD');

%% demographic data

% load demographic data
demographic_data;

% save in one table
SUM_DG = table(Subj, Sex, Age, MSS, FM, Sen, MOCA, StS, StL);
save([PATHOUT1 'SUM_DG.mat'], 'SUM_DG');
