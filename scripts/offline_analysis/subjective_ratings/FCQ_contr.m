% This script calculates mean values per subject for each of the four
% phenomenological constructs (SoO, SoA, ER, MIAB, and control items).

% Authors: Nadine Spychala, Edith Bongartz. 
% License: GNU GPLv3.

clear all; close all; clc;

%% allocating variables

MAINPATH =  '/mydir/';
PATHOUT =   [MAINPATH, 'analysis/subjective_ratings/'];

contr = {'01';'02';'03'; '04'; '05';'06';'07'; '08'; '09'};                     % subjects
tmpArray = NaN(9,1);                                                            % array size - corresponding to the number of subjects

%% create tables with raw data

% load FCQ data
FCQrawdata;

% FCQ after training block 
FCQTrainContr = table(FCQ1TrainContr,FCQ2TrainContr, FCQ3TrainContr,FCQ4TrainContr,FCQ5TrainContr,...
    FCQ6TrainContr,FCQ7TrainContr,FCQ8TrainContr,FCQ9TrainContr,FCQ10TrainContr,...
    FCQ11TrainContr,FCQ12TrainContr,FCQ13TrainContr,FCQ14TrainContr,FCQ15TrainContr,'RowNames',contr);

% FCQ after feedback block 
FCQTestContr = table(FCQ1TestContr,FCQ2TestContr, FCQ3TestContr,FCQ4TestContr,FCQ5TestContr,...
    FCQ6TestContr,FCQ7TestContr,FCQ8TestContr,FCQ9TestContr,FCQ10TestContr,...
    FCQ11TestContr,FCQ12TestContr,FCQ13TestContr,FCQ14TestContr,FCQ15TestContr,'RowNames',contr);

%% Sense of Ownership (SoO)
 
SoO_Train_Contr = tmpArray;

for s = 1:length(contr)
    SoOTrtemp = [FCQ8TrainContr(s), FCQ9TrainContr(s), FCQ13TrainContr(s)];     % create temporary array with SoO values of the subject    
    SoO_Train_Contr(s) = nanmean(SoOTrtemp);                                    % calculate mean
end;
 
 SoO_Test_Contr = tmpArray;

for s = 1:length(contr)    
    SoOTetemp = [FCQ8TestContr(s), FCQ9TestContr(s), FCQ13TestContr(s)];        % create temporary array with SoO values of the subject    
    SoO_Test_Contr(s) = nanmean(SoOTetemp);                                     % calculate mean
end;
 
SoOcontr = table(SoO_Train_Contr, SoO_Test_Contr, 'RowNames',contr);
save([PATHOUT 'SoOcontr.mat'], 'SoOcontr');
 
%% Sense of Agency (SoA)
 
SoA_Train_Contr = tmpArray;

for s = 1:length(contr)
    SoATrtemp = [FCQ5TrainContr(s), FCQ10TrainContr(s), FCQ11TrainContr(s)];    % create temporary array with SoA values of the subject
    SoA_Train_Contr(s) = nanmean(SoATrtemp);                                    % calculate mean
end;
 
 SoA_Test_Contr = tmpArray;

for s = 1:length(contr)
    SoATetemp = [FCQ5TestContr(s), FCQ10TestContr(s), FCQ11TestContr(s)];       % create temporary array with SoA values of the subject
    SoA_Test_Contr(s) = nanmean(SoATetemp);                                     % calculate mean
end;
 
SoAcontr = table(SoA_Train_Contr, SoA_Test_Contr, 'RowNames',contr);
save([PATHOUT 'SoAcontr.mat'], 'SoAcontr');
 
%% Experiental Realness (ER)

ER_Train_Contr = tmpArray;

for s = 1:length(contr)
    ERTrtemp = [FCQ4TrainContr(s), FCQ12TrainContr(s), FCQ14TrainContr(s)];     % create temporary array with ER values of the subject
    ER_Train_Contr(s) = mean(ERTrtemp);                                         % calculate mean
end;
 
 ER_Test_Contr = tmpArray;

for s = 1:length(contr)
    ERTetemp = [FCQ4TestContr(s), FCQ12TestContr(s), FCQ14TestContr(s)];        % create temporary array with ER values of the subject
    ER_Test_Contr(s) = mean(ERTetemp);                                          % calculate mean
end;
 
ERcontr = table(ER_Train_Contr, ER_Test_Contr, 'RowNames',contr);
save([PATHOUT 'ERcontr.mat'], 'ERcontr');

%% Motor-Imagery Action Binding (MIAB)

% calculation of ER for each subject in each condition
 
MIAB_Train_Contr = tmpArray;

for s = 1:length(contr)
    MIABTrtemp = [FCQ1TrainContr(s), FCQ2TrainContr(s), FCQ15TrainContr(s)];    % create temporary array with MIAB values of the subject
    MIAB_Train_Contr(s) = mean(MIABTrtemp);                                     % calculate mean
end;
 
 MIAB_Test_Contr = tmpArray;

for s = 1:length(contr)
    MIABTetemp = [FCQ1TestContr(s), FCQ2TestContr(s), FCQ15TestContr(s)];       % create temporary array with MIAB values of the subject
    MIAB_Test_Contr(s) = mean(MIABTetemp);                                      % calculate mean
end;
 
MIABcontr = table(MIAB_Train_Contr, MIAB_Test_Contr, 'RowNames',contr);
save([PATHOUT 'MIABcontr.mat'], 'MIABcontr');

%% control items (CI)

CI_SoO_Train_Contr = NaN(9,1);

for s = 1:length(contr)
    CITrtemp = [FCQ3TrainContr(s), FCQ7TrainContr(s)];                          % create temporary array with CI values of the subject
    CI_SoO_Train_Contr(s) = mean(CITrtemp);                                     % calculate mean
end;

CI_SoO_Test_Contr = NaN(9,1);

for s = 1:length(contr)
    CITetemp = [FCQ3TestContr(s), FCQ7TestContr(s)];                            % create temporary array with CI values of the subject
    CI_SoO_Test_Contr(s) = mean(CITetemp);                                      % calculate mean
end;
 
CI_SoA_Train_Contr = NaN(9,1);                                 

for s = 1:length(contr)
    CI_SoA_Train_Contr(s) = FCQ6TrainContr(s);                                  % only one control item for SoA                                             
end;

CI_SoA_Test_Contr = NaN(9,1);

for s = 1:length(contr)
    CI_SoA_Test_Contr(s) = FCQ6TestContr(s);                                    % only one control item for SoA                    
end;

% mean over control items for SoO and SoA
CI_Train_Contr = NaN(9,1);

for s = 1:length(contr)
    CITrtemp = [FCQ3TrainContr(s), FCQ6TrainContr(s), FCQ7TrainContr(s)];       % create temporary array with CI values of the subject
    CI_Train_Contr(s) = mean(CITrtemp);                                         % calculate mean
end;

CI_Test_Contr = NaN(9,1);

for s = 1:length(contr)
    CITrtemp = [FCQ3TestContr(s), FCQ6TestContr(s), FCQ7TestContr(s)];          % create temporary array with CI values of the subject
    CI_Test_Contr(s) = mean(CITrtemp);                                          % calculate mean
end;


CIcontr = table(CI_SoO_Train_Contr, CI_SoO_Test_Contr, CI_SoA_Train_Contr, CI_SoA_Test_Contr, CI_Train_Contr, CI_Test_Contr, 'RowNames', contr(1:9));
save([PATHOUT 'CIcontr.mat'], 'CIcontr');
