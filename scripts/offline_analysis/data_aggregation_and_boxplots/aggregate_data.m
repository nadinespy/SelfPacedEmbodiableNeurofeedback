% This script aggregates all output files from
% organize_data_for_aggregation.m one into table.

% Authors: Nadine Spychala, Niclas Braun.
% License: GNU GPLv3.

clear; close all; clc;

addpath '/mydir/scripts/auxiliaries';

MAINPATH = '/mydir';
PATHIN = [MAINPATH, '/analysis/data_aggregation_and_boxplots/'];

%% aggregate all data into one table

Subj = {'Contr01', 'Contr02','Contr03','Contr04','Contr05', 'Contr06','Contr07', 'Contr08','Contr09', 'Stroke01', 'Stroke02', 'Stroke03', 'Stroke05', 'Stroke06', 'Stroke07','Stroke08','Stroke09','Stroke10'}';
Group = {'Control', 'Control', 'Control','Control','Control','Control', 'Control', 'Control','Control','Stroke', 'Stroke', 'Stroke', 'Stroke', 'Stroke', 'Stroke', 'Stroke', 'Stroke', 'Stroke'}';

list_all_data = dir(fullfile([PATHIN '/*.mat']));
all_data = {};                                                                       
for d = 1:length(list_all_data)
    all_data = [all_data; list_all_data(d).name];
end

 for d = 1:length(all_data)
     load([PATHIN all_data{d}]);    
 end
  
Group = table(Subj, Group);

myData = outerjoin(Group,SUM_DG,'Keys', 1, 'MergeKeys',true);
myData = outerjoin(myData,SUM_Ques,'Keys',1,'MergeKeys',true);    
myData = outerjoin(myData,SUM_TA,'Keys',1,'MergeKeys',true);
myData = outerjoin(myData,SUM_FA,'Keys',1,'MergeKeys',true);
myData = outerjoin(myData,SUM_ERD,'Keys',1,'MergeKeys',true);   

save([PATHIN 'myData.mat'], 'myData');
writetable(myData, [PATHIN 'myData.csv']);
