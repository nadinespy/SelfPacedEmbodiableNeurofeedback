% This script tests normality and variance homogeneity (Kolmogorov-Smirnov 
% and Levene test) for variables from myData.mat.

% Authors: Nadine Spychala.
% License: GNU GPLv3.

clear; close all; clc;

addpath '/mydir/scripts/auxiliaries';

MAINPATH = '/mydir';
PATHIN = [MAINPATH, '/analysis/data_aggregation_and_boxplots/'];
PATHOUT = [MAINPATH, '/analysis/statistical_testing/'];

%% testing for normality and variance homogeneity

load([PATHIN 'myData.mat'])

% variables of interest for which to compute KS-test and Levene test
variablesOfInterest = {'ERDtrainFuni', 'ERDtrainEuni', 'ERDlatency',...
    'CSPcriteria', 'mean_of_ce_ef', 'mean_fc_ac_rm', 'rmMovementsInMove', 'rmMovementsInRest',...
    'SoOtr', 'SoOfb', 'SoAtr', 'SoAfb', 'ERtr', 'ERfb', 'MIABtr', 'MIABfb'};

% prepare table for the results
varNames1 = {'variables', 'h_p_contr', 'h_p_stroke'};
normality = table(variablesOfInterest', zeros(length(variablesOfInterest),2), zeros(length(variablesOfInterest),2), 'VariableNames', varNames1);

varNames2 = {'variables', 'p'};
variance = table(variablesOfInterest', zeros(length(variablesOfInterest),1), 'VariableNames', varNames2);
group = [1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2];

% do the tests (for normality: for each variable of interest, separately for each group (stroke and control)
for s = 1:size(variablesOfInterest,2); 
        [h, p] = kstest(myData{1:9,variablesOfInterest(s)});
        normality(s,2) = table([h, p]);
        [h, p] = kstest(myData{10:18,variablesOfInterest(s)});
        normality(s,3) = table([h, p]);
        
        set(0,'DefaultFigureVisible','off')
        p = vartestn(myData{:,variablesOfInterest(s)}, group,'TestType','LeveneAbsolute');
        variance(s,2) = table(p);
end

save([PATHOUT 'ks_test.mat'], 'normality');
save([PATHOUT 'levene_test.mat'], 'variance');
