% This script calculates CSP filters on the artifact-corrected, epoched, 
% and pruned data (output files from preprocessingICA.m) for each subject.

% Authors: Nadine Spychala, Edith Bongartz. 
% License: GNU GPLv3.

clear all; close all; clc;

MAINPATH =  '/mydir/';
PATHOUT = [MAINPATH, 'analysis/time_frequency_analysis/ana03_CSP/'];

%% allocating variables
stroke = {'stroke01', 'stroke02', 'stroke03', 'stroke05', 'stroke06', 'stroke07', 'stroke08', 'stroke09', 'stroke10'}; 
contr = {'contr01', 'contr02', 'contr03', 'contr04', 'contr05', 'contr06', 'contr07', 'contr08', 'contr09'}; 

% CSP filter criteria
% 1. originate from sensorimotor areas (cf. Pattern)
% 2. originate from sensorimotor areas (cf. Filters)
% 3. distributional differences in both classes (cf. box plot)
% 4. distributional differende in single-trial visualization
% 5. left hemisphere ERD (blue) - right hemisphere ERS (red)
% 6. normal distribution (box plot)

criteria = {'PatternF', 'FilterF', 'boxplotF', 'trial-visualizationF', 'ERD/ERS_F', 'normal_distrF', 'PatternE', 'FilterE', 'boxplotE', 'trial-visualizationE', 'ERD/ERS_E', 'normal_distrE', 'SUM'};

%% evaluation of CSP filters for stroke patients
% one value (true or false) for each criteria (see above) (f = flexion, e = extension)

stroke01_f = [0 0 1 0 0 1]';
stroke01_e = [0 0 0 0 0 1]';
stroke02_f = [1 1 0 0 1 1]';
stroke02_e = [1 1 1 0 1 1]';
stroke03_f = [1 0 1 0 0 1]';
stroke03_e = [1 0 1 1 0 1]';
stroke05_f = [1 0 1 1 1 1]';
stroke05_e = [1 1 1 1 1 1]';
stroke06_f = [1 1 1 1 1 1]';
stroke06_e = [0 1 1 0 1 1]';
stroke07_f = [1 1 1 1 1 1]';
stroke07_e = [1 1 1 1 1 1]';
stroke08_f = [1 0 1 0 1 1]';
stroke08_e = [1 1 1 1 0 1]';
stroke09_f = [1 1 1 1 1 1]';
stroke09_e = [1 1 1 1 0 1]';
stroke10_f = [1 1 1 0 0 1]';
stroke10_e = [0 1 1 1 0 1]';

% table seperated for flexion and extension
CSPstrokeF_E = table(stroke01_f, stroke01_e, stroke02_f, stroke02_e, stroke03_f, stroke03_e, stroke05_f, stroke05_e, stroke06_f, stroke06_e,...
    stroke07_f, stroke07_e, stroke08_f, stroke08_e, stroke09_f, stroke09_e, stroke10_f, stroke10_e);

SUMcorrect = [];
for j= 1:width(CSPstrokeF_E)
   if mod(j,2) == 1
    SUMcorrect = [SUMcorrect; sum([CSPstrokeF_E{1:6,j}; CSPstrokeF_E{1:6,j+1}])];
   end
end

CSPstroke = table([stroke01_f(1:6); stroke01_e(1:6); SUMcorrect(1)], [stroke02_f(1:6); stroke02_e(1:6); SUMcorrect(2)], [stroke03_f(1:6); stroke03_e(1:6); SUMcorrect(3)], [stroke05_f(1:6); stroke05_e(1:6); SUMcorrect(4)], [stroke06_f(1:6); stroke06_e(1:6); SUMcorrect(5)],...
    [stroke07_f(1:6); stroke07_e(1:6); SUMcorrect(6)], [stroke08_f(1:6); stroke08_e(1:6); SUMcorrect(7)], [stroke09_f(1:6); stroke09_e(1:6); SUMcorrect(8)], [stroke10_f(1:6); stroke10_e(1:6); SUMcorrect(9)], 'RowNames', criteria, 'VariableNames', stroke);
save([PATHOUT 'CSPstroke.mat'], 'CSPstroke');

%% evaluation of CSP filters for control subjects
% one value (true or false) for each criteria (see above) (f = flexion, e = extension)

contr01_f = [1 1 1 1 1 1]';
contr01_e = [1 1 1 0 1 1]';
contr02_f = [1 0 1 1 1 1]';
contr02_e = [1 1 1 1 1 1]';
contr03_f = [1 0 1 1 1 1]';
contr03_e = [0 1 1 1 1 1]';
contr04_f = [1 0 1 1 0 1]';
contr04_e = [1 1 1 1 1 0]';
contr05_f = [1 0 1 1 0 1]';
contr05_e = [0 0 1 1 0 1]';
contr06_f = [0 0 0 0 0 1]';
contr06_e = [1 0 1 1 0 0]';
contr07_f = [1 0 1 1 0 0]';
contr07_e = [1 0 1 1 1 1]';
contr08_f = [0 0 1 0 0 1]';
contr08_e = [0 0 1 0 0 1]';
contr09_f = [1 1 1 0 1 1]';
contr09_e = [1 1 1 1 0 1]';

% table seperated for flexion and extension
CSPcontrF_E = table(contr01_f, contr01_e, contr02_f, contr02_e, contr03_f, contr03_e,contr04_f, contr04_e, contr05_f, contr05_e, contr06_f, contr06_e,...
    contr07_f, contr07_e, contr08_f, contr08_e, contr09_f, contr09_e);

SUMcorrect = [];
for j= 1:width(CSPcontrF_E)
   if mod(j,2) == 1
    SUMcorrect = [SUMcorrect; sum([CSPcontrF_E{1:6,j}; CSPcontrF_E{1:6,j+1}])];
   end
end

CSPcontr = table([contr01_f(1:6); contr01_e(1:6); SUMcorrect(1)], [contr02_f(1:6); contr02_e(1:6); SUMcorrect(2)], [contr03_f(1:6); contr03_e(1:6); SUMcorrect(3)],...
    [contr04_f(1:6); contr04_e(1:6); SUMcorrect(4)],[contr05_f(1:6); contr05_e(1:6); SUMcorrect(5)], [contr06_f(1:6); contr06_e(1:6); SUMcorrect(6)],...
    [contr07_f(1:6); contr07_e(1:6); SUMcorrect(7)], [contr08_f(1:6); contr08_e(1:6); SUMcorrect(8)], [contr09_f(1:6); contr09_e(1:6); SUMcorrect(9)], 'RowNames', criteria, 'VariableNames', contr);
save([PATHOUT 'CSPcontr.mat'], 'CSPcontr');
