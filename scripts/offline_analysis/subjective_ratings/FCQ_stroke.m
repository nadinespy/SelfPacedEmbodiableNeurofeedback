% This script calculates mean values per subject for each of the four
% phenomenological constructs (SoO, SoA, ER, MIAB, and control items).

% Authors: Nadine Spychala, Edith Bongartz. 
% License: GNU GPLv3.

clear all; close all; clc;

%% allocating variables

MAINPATH =  '/mydir/';
PATHOUT =   [MAINPATH, 'analysis/subjective_ratings/'];

stroke = {'01';'02';'03'; '05';'06';'07'; '08'; '09'; '10'};                    % subjects
tmpArray = NaN(9,1);                                                            % array size - corresponding to the number of subjects

%% create tables with raw data

% load FCQ data
FCQrawdata;

% FCQ after training block 
FCQTrainStroke = table(FCQ1TrainStroke,FCQ2TrainStroke, FCQ3TrainStroke,FCQ4TrainStroke,FCQ5TrainStroke,...
    FCQ6TrainStroke,FCQ7TrainStroke,FCQ8TrainStroke,FCQ9TrainStroke,FCQ10TrainStroke,...
    FCQ11TrainStroke,FCQ12TrainStroke,FCQ13TrainStroke,FCQ14TrainStroke,FCQ15TrainStroke,'RowNames', stroke);

% FCQ after feedback block 
FCQTestStroke = table(FCQ1TestStroke,FCQ2TestStroke, FCQ3TestStroke,FCQ4TestStroke,FCQ5TestStroke,...
    FCQ6TestStroke,FCQ7TestStroke,FCQ8TestStroke,FCQ9TestStroke,FCQ10TestStroke,...
    FCQ11TestStroke,FCQ12TestStroke,FCQ13TestStroke,FCQ14TestStroke,FCQ15TestStroke,'RowNames', stroke);

%% Sense of Ownership (SoO)
 
SoO_Train_Stroke = tmpArray;

for s = 1:length(stroke)
    SoOTrtemp = [FCQ8TrainStroke(s), FCQ9TrainStroke(s), FCQ13TrainStroke(s)];  % create temporary array with SoO values of the subject    
    SoO_Train_Stroke(s) = nanmean(SoOTrtemp);                                   % calculate mean
end;
 
 SoO_Test_Stroke = tmpArray;

for s = 1:length(stroke)    
    SoOTetemp = [FCQ8TestStroke(s), FCQ9TestStroke(s), FCQ13TestStroke(s)];     % create temporary array with SoO values of the subject    
    SoO_Test_Stroke(s) = nanmean(SoOTetemp);                                    % calculate mean
end;
 
SoOstroke = table(SoO_Train_Stroke, SoO_Test_Stroke, 'RowNames',stroke);
save([PATHOUT 'SoOstroke.mat'], 'SoOstroke');
 
%% Sense of Agency (SoA)
 
SoA_Train_Stroke = tmpArray;

for s = 1:length(stroke)
    SoATrtemp = [FCQ5TrainStroke(s), FCQ10TrainStroke(s), FCQ11TrainStroke(s)]; % create temporary array with SoA values of the subject
    SoA_Train_Stroke(s) = nanmean(SoATrtemp);                                   % calculate mean
end;
 
 SoA_Test_Stroke = tmpArray;

for s = 1:length(stroke)
    SoATetemp = [FCQ5TestStroke(s), FCQ10TestStroke(s), FCQ11TestStroke(s)];    % create temporary array with SoA values of the subject
    SoA_Test_Stroke(s) = nanmean(SoATetemp);                                    % calculate mean
end;
 
SoAstroke = table(SoA_Train_Stroke, SoA_Test_Stroke, 'RowNames',stroke);
save([PATHOUT 'SoAstroke.mat'], 'SoAstroke');
 
%% Experiental Realness (ER)

ER_Train_Stroke = tmpArray;

for s = 1:length(stroke)
    ERTrtemp = [FCQ4TrainStroke(s), FCQ12TrainStroke(s), FCQ14TrainStroke(s)];  % create temporary array with ER values of the subject
    ER_Train_Stroke(s) = mean(ERTrtemp);                                        % calculate mean
end;
 
 ER_Test_Stroke = tmpArray;

for s = 1:length(stroke)
    ERTetemp = [FCQ4TestStroke(s), FCQ12TestStroke(s), FCQ14TestStroke(s)];     % create temporary array with ER values of the subject
    ER_Test_Stroke(s) = mean(ERTetemp);                                         % calculate mean
end;
 
ERstroke = table(ER_Train_Stroke, ER_Test_Stroke, 'RowNames',stroke);
save([PATHOUT 'ERstroke.mat'], 'ERstroke');

%% Motor-Imagery Action Binding (MIAB)

% calculation of ER for each subject in each condition
 
MIAB_Train_Stroke = tmpArray;

for s = 1:length(stroke)
    MIABTrtemp = [FCQ1TrainStroke(s), FCQ2TrainStroke(s), FCQ15TrainStroke(s)]; % create temporary array with MIAB values of the subject
    MIAB_Train_Stroke(s) = mean(MIABTrtemp);                                    % calculate mean
end;
 
 MIAB_Test_Stroke = tmpArray;

for s = 1:length(stroke)
    MIABTetemp = [FCQ1TestStroke(s), FCQ2TestStroke(s), FCQ15TestStroke(s)];    % create temporary array with MIAB values of the subject
    MIAB_Test_Stroke(s) = mean(MIABTetemp);                                     % calculate mean
end;
 
MIABstroke = table(MIAB_Train_Stroke, MIAB_Test_Stroke, 'RowNames',stroke);
save([PATHOUT 'MIABstroke.mat'], 'MIABstroke');

%% control items (CI)
 
CI_SoO_Train_Stroke = NaN(9,1);

for s = 1:length(stroke)
    CITrtemp = [FCQ3TrainStroke(s), FCQ7TrainStroke(s)];                        % create temporary array with CI values of the subject
    CI_SoO_Train_Stroke(s) = mean(CITrtemp);                                    % calculate mean
end;

CI_SoO_Test_Stroke = NaN(9,1);

for s = 1:length(stroke)
    CITetemp = [FCQ3TestStroke(s), FCQ7TestStroke(s)];                          % create temporary array with CI values of the subject
    CI_SoO_Test_Stroke(s) = mean(CITetemp);                                     % calculate mean
end;
 
CI_SoA_Train_Stroke = NaN(9,1);                                 

for s = 1:length(stroke)
    CI_SoA_Train_Stroke(s) = FCQ6TrainStroke(s);                                % only one control item for SoA                                             
end;

CI_SoA_Test_Stroke = NaN(9,1);

for s = 1:length(stroke)
    CI_SoA_Test_Stroke(s) = FCQ6TestStroke(s);                                  % only one control item for SoA                    
end;

% mean over control items for SoO and SoA
CI_Train_Stroke = NaN(9,1);

for s = 1:length(stroke)
    CITrtemp = [FCQ3TrainStroke(s), FCQ6TrainStroke(s), FCQ7TrainStroke(s)];    % create temporary array with CI values of the subject
    CI_Train_Stroke(s) = mean(CITrtemp);                                        % calculate mean
end;

CI_Test_Stroke = NaN(9,1);

for s = 1:length(stroke)
    CITrtemp = [FCQ3TestStroke(s), FCQ6TestStroke(s), FCQ7TestStroke(s)];       % create temporary array with CI values of the subject
    CI_Test_Stroke(s) = mean(CITrtemp);                                         % calculate mean
end;

CIstroke = table(CI_SoO_Train_Stroke, CI_SoO_Test_Stroke, CI_SoA_Train_Stroke, CI_SoA_Test_Stroke, CI_Train_Stroke, CI_Test_Stroke, 'RowNames', stroke(1:9));
save([PATHOUT 'CIstroke.mat'], 'CIstroke');
