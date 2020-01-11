% This script extracts the training accuracies for each subject from the
% training block and saves them in one table, separately for stroke and 
% control group.

% Authors: Nadine Spychala, Niclas Braun, Edith Bongartz. 
% License: GNU GPLv3.

clear all; close all; clc

MAINPATH = 'mydir';
PATHIN = [MAINPATH, '/analysis/classification_accuracies/training_accuracies/'];
PATHOUT = [MAINPATH, '/analysis/classification_accuracies/training_accuracies/'];

%% variables that distinguish between groups

groups = {'stroke', 'contr'};                                                               

SUBJ_stroke = {'01', '02', '03', '05', '06', '07', '08', '09', '10'};                       % subject numbers in stroke group
SUBJ_contr = {'01', '02', '03', '04', '05', '06', '07', '08', '09'};                        % subject numbers in control group
SUBJ_complete = {SUBJ_stroke; SUBJ_contr};

%% extracting training accuracies

for y = 1:length(groups)                                                                           
    
    SUBJ = SUBJ_complete{y};
    classRates = nan(numel(SUBJ),3);                                                        % allocate across subject variable of size 3 x 9 (three training accuracies x 9 subjects per group)
    
    % extract accuracies
    i = 1;
    for s = 1:length(SUBJ)
        load([PATHIN, 'nic_FHC_', groups{y}, SUBJ{s}, '_unilateral_train.mat']);            % load output from onlineAnalysisMultipleClassifier.m
        classRates(i,1) = (100 - subinf.of.trainloss);
        classRates(i,2) = (100 - subinf.ce.trainloss);
        classRates(i,3) = (100 - subinf.ef.trainloss);

        i = i+1;    
    end
    
    % save in table
    column_names = {'classRatesOF', 'classRatesCE', 'classRatesEF'};
    classRates = table(classRates(:,1), classRates(:,2), classRates(:,3), 'VariableNames', column_names, 'RowNames', SUBJ);
    
    if y == 1;
        classRates_stroke = classRates;
    else
        classRates_contr = classRates;
    end

    save([PATHOUT 'classRates_', groups{y}, '.mat'], ['classRates_' groups{y}])
end 
