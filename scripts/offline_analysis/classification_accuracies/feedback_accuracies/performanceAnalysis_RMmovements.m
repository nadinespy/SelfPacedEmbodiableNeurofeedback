clear all
close all
clc

addpath '/media/nspychala/525C77605C773E33/all my stuff/free robotic hand control/article/matlab/analysis/rawdata'
addpath '/media/nspychala/525C77605C773E33/all my stuff/free robotic hand control/article/matlab/analysis/time-frequency analysis'
addpath '/media/nspychala/525C77605C773E33/all my stuff/free robotic hand control/article/matlab/scripts/auxiliaries';
addpath '/media/nspychala/525C77605C773E33/all my stuff/free robotic hand control/Edith/eeglab13_4_4b'; 
addpath '/media/nspychala/525C77605C773E33/all my stuff/free robotic hand control/Edith/eeglab13_4_4b/plugins/xdfimport1.12'; 
addpath '/media/nspychala/525C77605C773E33/all my stuff/free robotic hand control/article/matlab/analysis/feedback accuracies/dividing EEG data into tasks fC aC RM/announce-behavior'
addpath '/media/nspychala/525C77605C773E33/all my stuff/free robotic hand control/article/matlab/analysis/feedback accuracies/dividing EEG data into tasks fC aC RM/rest-move'
addpath '/media/nspychala/525C77605C773E33/all my stuff/free robotic hand control/article/matlab/analysis/feedback accuracies/dividing EEG data into tasks fC aC RM/follow-commands'

MAINPATH = '/media/nspychala/525C77605C773E33/all my stuff/free robotic hand control/article/matlab/analysis';
PATHIN = [MAINPATH, '/rawdata'];
PATHIN1 = [MAINPATH, '/feedback accuracies/dividing EEG data into tasks fC aC RM/rest-move'];
PATHIN2 = [MAINPATH, '/feedback accuracies/'];
PATHOUT = [MAINPATH, '/feedback accuracies/'];
PATHOUT2 = [MAINPATH, '/feedback accuracies/'];

stroke = {'01', '02', '03', '05', '06' '07', '08', '09', '10'};
contr = {'01', '02', '03', '04', '05', '06' '07', '08', '09'};
EXP = {'_bilateral', '_unilateral'};
EVENTS = {'ocp' 'ccp'  'f'  'e'  'c'  'ap'  'O'  'aO'  'aG'  'aC'  'cO'  'cG'  'cC'  'rm-end'  'rm-begin'  'fc-end' 'fc-begin' 'ac-end' 'ac-begin' 'LED-on' 'LED-off' 'Pause' 'Continue'};

eeglab;

%% REST VS MOVE - stroke patients
% {
Rest_strokeALL = [];
Move_strokeALL = [];
stdRestMove_strokeALL = [];
RestMoveMeans_strokeALL = [];
         
for s = 1:length(stroke)
    for e = 2 % 1 = bilateral / 2 = unilateral
        
        % EEG = pop_loadset(['nic_FHC_stroke', SUBJ{s}, EXP{e}, '_test_rm.set'], '\\134.106.150.131\data\projects\nic_FHC\data\offlineAnalysis\rest-movement\');
        EEG = pop_loadset(['nic_FHC_stroke', stroke{s}, EXP{e}, '_test_rm.set'], PATHIN1);
    
        % loading particular dadaset
        % EEG = pop_loadset(['nic_FHC_stroke13_bilateral_test_rm.set'], PATHIN1);
        
        % mean of rest vs. move: insert events (extension/ flexion) in 
        % new array (RM)
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
         
         % summing up the triggers in the respective phases
         sumMoveP3 = sum(RM(30001:45000));
         sumRestP4 = sum(RM(45001:60000));
         sumMoveP5 = sum(RM(60001:75000));
         sumRestP6 = sum(RM(75001:90000));
         sumMoveP7 = sum(RM(90001:105000));
         sumRestP8 = sum(RM(105001:120000));
         
         % define number of movement and resting phases, respectively 
         % for each subject
         numMove = 3;
         numRest = 3;
         
         Rest_stroke = [sumRestP4; sumRestP6; sumRestP8];
         Move_stroke = [sumMoveP3; sumMoveP5; sumMoveP7]; 
         stdRest_stroke = std(Rest_stroke)/sqrt(numRest);
         stdMove_stroke = std(Move_stroke)/sqrt(numMove);
         stdRestMove_stroke = [stdRest_stroke, stdMove_stroke];
         
         meanRest_stroke = ((sumRestP4+sumRestP6+sumRestP8)/numRest);
         meanMove_stroke = ((sumMoveP3+sumMoveP5+sumMoveP7)/numMove);
         RestMoveMeans_stroke = [meanRest_stroke, meanMove_stroke];
         
         % create array across subjects
         Rest_strokeALL = [Rest_strokeALL; Rest_stroke];
         Move_strokeALL = [Move_strokeALL; Move_stroke];
         stdRestMove_strokeALL = [stdRestMove_strokeALL; stdRestMove_stroke];
         RestMoveMeans_strokeALL = [RestMoveMeans_strokeALL; RestMoveMeans_stroke];
         
    end
end

RestMoveMeans_stroke = table(RestMoveMeans_strokeALL(:,1), RestMoveMeans_strokeALL(:,2), 'RowNames', stroke, 'VariableNames',{'meanMovements_rest' 'meanMovments_move'});
save([PATHIN2 '\RMmovements_stroke.mat'], 'RestMoveMeans_stroke');
%} 

%% REST VS MOVE - control subjects
% {
Rest_contrALL = [];
Move_contrALL = [];
stdRestMove_contrALL = [];
RestMoveMeans_contrALL = [];
         
for s = 1:length(contr)
    for e = 2 % 1 = bilateral / 2 = unilateral
        
        % EEG = pop_loadset(['nic_FHC_contr', SUBJ{s}, EXP{e}, '_test_rm.set'], '\\134.106.150.131\data\projects\nic_FHC\data\offlineAnalysis\rest-movement\');
        EEG = pop_loadset(['nic_FHC_contr', contr{s}, EXP{e}, '_test_rm.set'], PATHIN1);
    
        % loading particular dadaset
        % EEG = pop_loadset(['nic_FHC_contr13_bilateral_test_rm.set'], PATHIN1);
        
        % mean of rest vs. move: insert events (extension/ flexion) in 
        % new array (RM)
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
         
         % summing up the triggers in the respective phases
         sumMoveP3 = sum(RM(30001:45000));
         sumRestP4 = sum(RM(45001:60000));
         sumMoveP5 = sum(RM(60001:75000));
         sumRestP6 = sum(RM(75001:90000));
         sumMoveP7 = sum(RM(90001:105000));
         sumRestP8 = sum(RM(105001:120000));
         
         % define number of movement and resting phases, respectively 
         % for each subject
         numMove = 3;
         numRest = 3;
         
         Rest_contr = [sumRestP4; sumRestP6; sumRestP8];
         Move_contr = [sumMoveP3; sumMoveP5; sumMoveP7]; 
         stdRest_contr = std(Rest_contr)/sqrt(numRest);
         stdMove_contr = std(Move_contr)/sqrt(numMove);
         stdRestMove_contr = [stdRest_contr, stdMove_contr];
         
         meanRest_contr = ((sumRestP4+sumRestP6+sumRestP8)/numRest);
         meanMove_contr = ((sumMoveP3+sumMoveP5+sumMoveP7)/numMove);
         RestMoveMeans_contr = [meanRest_contr, meanMove_contr];
         
         % create array across subjects
         Rest_contrALL = [Rest_contrALL; Rest_contr];
         Move_contrALL = [Move_contrALL; Move_contr];
         stdRestMove_contrALL = [stdRestMove_contrALL; stdRestMove_contr];
         RestMoveMeans_contrALL = [RestMoveMeans_contrALL; RestMoveMeans_contr];
         
    end
end
RestMoveMeans_contr = table(RestMoveMeans_contrALL(:,1), RestMoveMeans_contrALL(:,2), 'RowNames', contr, 'VariableNames',{'meanMovements_rest' 'meanMovments_move'});
save([PATHIN2 '\RMmovements_contr.mat'], 'RestMoveMeans_contr');
%}
