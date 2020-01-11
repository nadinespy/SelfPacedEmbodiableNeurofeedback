% This script creates boxplots for questionnaire data (subjective ratings  
% for SoO, SoA, ER, MIAB) and for performance data (training and feedback 
% accuracies; average number of movements in rest vs. move task).

% Authors: Nadine Spychala, Niclas Braun.
% License: GNU GPLv3.

clear; close all; clc

addpath '/mydir/scripts/auxiliaries';

MAINPATH = '/mydir';
PATHIN = [MAINPATH, '/analysis/data_aggregation_and_boxplots'];

%% some variable allocation and data loading

% {
fsTitle = 13;                                                                       % define fontsize of figure title

% labelling for figure legends
labels.blocks = {'Training', 'Feedback'};                                           % for subjective ratings
labels.CR = {'Open vs. Flexion', 'Closed vs. Extension', 'Extension vs. Flexion'};  % for training accuracies
labels.FA = {'Rest vs. Move', 'Announce Commands', 'Follow Commands'};              % for feedback accuracies
labels.RM =  {'Rest', 'Move'};                                                      % for average number of movements in rest vs. move task

% load table with all relevant variables
load([PATHIN 'myData.mat'],'myData');

%% plotting questionnaire data

% {
figure('name','subjective rates');

subplot(2,2,1);

SoOtr_stroke = myData(10:18,{'SoOtr'});
SoOtr_stroke.Properties.VariableNames = {'SoOtr_stroke'};
SoOtr_contr = myData(1:9,{'SoOtr'});
SoOtr_contr.Properties.VariableNames = {'SoOtr_contr'};

SoOfb_stroke = myData(10:18,{'SoOfb'});
SoOfb_stroke.Properties.VariableNames = {'SoOfb_stroke'};
SoOfb_contr = myData(1:9,{'SoOfb'});
SoOfb_contr.Properties.VariableNames = {'SoOfb_contr'};

x = [SoOtr_contr{:,:} SoOtr_stroke{:,:} SoOfb_contr{:,:} SoOfb_stroke{:,:}];
group = [ones(1,9) ones(1,9)*2 ones(1,9)*3 ones(1,9)*4];
positions = [1 1.25 1.75 2.0];

boxplot(x,group, 'positions', positions);
title('Sense of Ownership','fontsize',fsTitle)
ylabel('Subjective rating');
ylim([-3.5 3.5]);
hline = refline([0 1]);
hline.LineStyle = '--';
hline.Color = [0 0 0];
median_line = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(median_line, 'Color', 'k');
set(gca,'xtick',[mean(positions(1:2)) mean(positions(3:4))])
set(gca,'xticklabel',labels.blocks)

color = ['r', 'b', 'r', 'b'];
h = findobj(gca,'Tag','Box');

for j=1:length(h)
   patch(get(h(j),'XData'),get(h(j),'YData'),color(j),'FaceAlpha',.5);
end

legend off

subplot(2,2,2);

SoAtr_stroke = myData(10:18,{'SoAtr'});
SoAtr_stroke.Properties.VariableNames = {'SoAtr_stroke'};
SoAtr_contr = myData(1:9,{'SoAtr'});
SoAtr_contr.Properties.VariableNames = {'SoAtr_contr'};

SoAfb_stroke = myData(10:18,{'SoAfb'});
SoAfb_stroke.Properties.VariableNames = {'SoAfb_stroke'};
SoAfb_contr = myData(1:9,{'SoAfb'});
SoAfb_contr.Properties.VariableNames = {'SoAfb_contr'};

x = [SoAtr_contr{:,:} SoAtr_stroke{:,:} SoAfb_contr{:,:} SoAfb_stroke{:,:}];
group = [ones(1,9) ones(1,9)*2 ones(1,9)*3 ones(1,9)*4];
positions = [1 1.25 1.75 2.00];

boxplot(x,group, 'positions', positions);
title('Sense of Agency','fontsize',fsTitle)
ylabel('Subjective rating');
ylim([-3.5 3.5]);
median_line = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(median_line, 'Color', 'k');
hline = refline([0 1]);
hline.LineStyle = '--';
hline.Color = [0 0 0];

set(gca,'xtick',[mean(positions(1:2)) mean(positions(3:4))])
set(gca,'xticklabel',labels.blocks)

color = ['r', 'b', 'r', 'b'];
h = findobj(gca,'Tag','Box');
for j=1:length(h)
   patch(get(h(j),'XData'),get(h(j),'YData'),color(j),'FaceAlpha',.5);
end

c = get(gca, 'Children');
legend off

subplot(2,2,3);

ERtr_stroke = myData(10:18,{'ERtr'});
ERtr_stroke.Properties.VariableNames = {'ERtr_stroke'};
ERtr_contr = myData(1:9,{'ERtr'});
ERtr_contr.Properties.VariableNames = {'ERtr_contr'};

ERfb_stroke = myData(10:18,{'ERfb'});
ERfb_stroke.Properties.VariableNames = {'ERfb_stroke'};
ERfb_contr = myData(1:9,{'ERfb'});
ERfb_contr.Properties.VariableNames = {'ERfb_contr'};

x = [ERtr_contr{:,:} ERtr_stroke{:,:} ERfb_contr{:,:} ERfb_stroke{:,:}];
group = [ones(1,9) ones(1,9)*2 ones(1,9)*3 ones(1,9)*4];
positions = [1 1.25 1.75 2.00];

boxplot(x,group, 'positions', positions);
title('Experiential Realness','fontsize',fsTitle)
ylabel('Subjective rating');
ylim([-3.5 3.5]);
median_line = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(median_line, 'Color', 'k');
hline = refline([0 1]);
hline.LineStyle = '--';
hline.Color = [0 0 0];

set(gca,'xtick',[mean(positions(1:2)) mean(positions(3:4))])
set(gca,'xticklabel',labels.blocks)

color = ['r', 'b', 'r', 'b'];
h = findobj(gca,'Tag','Box');
for j=1:length(h)
   patch(get(h(j),'XData'),get(h(j),'YData'),color(j),'FaceAlpha',.5);
end

c = get(gca, 'Children');

[BL,BLicons] = legend ((c([1 2])),{'Control', 'Stroke'},'fontsize',8);
PatchInLegend = findobj(BLicons, 'type', 'patch');
set(PatchInLegend, 'facea', 0.5)
BL.Location = 'southeast';


subplot(2,2,4);

MIABtr_stroke = myData(10:18,{'MIABtr'});
MIABtr_stroke.Properties.VariableNames = {'MIABtr_stroke'};
MIABtr_contr = myData(1:9,{'MIABtr'});
MIABtr_contr.Properties.VariableNames = {'MIABtr_contr'};

MIABfb_stroke = myData(10:18,{'MIABfb'});
MIABfb_stroke.Properties.VariableNames = {'MIABfb_stroke'};
MIABfb_contr = myData(1:9,{'MIABfb'});
MIABfb_contr.Properties.VariableNames = {'MIABfb_contr'};

x = [MIABtr_contr{:,:} MIABtr_stroke{:,:} MIABfb_contr{:,:} MIABfb_stroke{:,:}];
group = [ones(1,9) ones(1,9)*2 ones(1,9)*3 ones(1,9)*4];
positions = [1 1.25 1.75 2.00];

boxplot(x,group, 'positions', positions);
title('MI-action-Binding','fontsize',fsTitle)
ylabel('Subjective rating');
ylim([-3.5 3.5]);
median_line = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(median_line, 'Color', 'k');
hline = refline([0 1]);
hline.LineStyle = '--';
hline.Color = [0 0 0];

set(gca,'xtick',[mean(positions(1:2)) mean(positions(3:4))])
set(gca,'xticklabel',labels.blocks)

color = ['r', 'b', 'r', 'b'];
h = findobj(gca,'Tag','Box');
for j=1:length(h)
   patch(get(h(j),'XData'),get(h(j),'YData'),color(j),'FaceAlpha',.5);
end
c = get(gca, 'Children');
legend off 

print([PATHIN 'questionnaire_data'], '-dtiff', '-r300');

%}
%% plotting training and feedback accuracies

% {
figure('name','performance data');

% feedback accuracies subplot
subplot(2,1,2);

rmC = myData(1:9,{'FArm_ALL'});
rmC.Properties.VariableNames = {'FArm_contr'};
rmS = myData(10:18,{'FArm_ALL'});
rmS.Properties.VariableNames = {'FArm_stroke'};

acC = myData(1:9,{'FAan_ALL'});
acC.Properties.VariableNames = {'FAan_contr'};
acS = myData(10:18,{'FAan_ALL'});
acS.Properties.VariableNames = {'FAan_stroke'};

fcC = myData(1:9,{'FAfc_ALL'});
fcC.Properties.VariableNames = {'FAfc_contr'};
fcS = myData(10:18,{'FAfc_ALL'});
fcS.Properties.VariableNames = {'FAfc_stroke'};

x = [rmC{:,:}*100 rmS{:,:}*100 acC{:,:}*100 acS{:,:}*100 fcC{:,:}*100 fcS{:,:}*100];
group = [ones(1,9) ones(1,9)*2 ones(1,9)*3 ones(1,9)*4 ones(1,9)*5 ones(1,9)*6];
positions = [1 1.25 1.75 2.00 2.5 2.75];

boxplot(x,group, 'positions', positions);
title('Feedback accuracies','fontsize',fsTitle)
ylabel('Performance (%)');

median_line = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(median_line, 'Color', 'k');
set(gca,'xtick',[mean(positions(1:2)) mean(positions(3:4)) mean(positions(5:6)) ])
set(gca,'xticklabel',labels.FA)

color = ['r', 'b', 'r', 'b','r','b'];
h = findobj(gca,'Tag','Box');
for j=1:length(h)
   patch(get(h(j),'XData'),get(h(j),'YData'),color(j),'FaceAlpha',.5);
end

legend off

% training accuracies subplot
subplot(2,1,1);

ceC = myData(1:9,{'CRce'});
ceC.Properties.VariableNames = {'CRce_contr'};
ceS = myData(10:18,{'CRce'});
ceS.Properties.VariableNames = {'CRce_stroke'};

efC = myData(1:9,{'CRef'});
efC.Properties.VariableNames = {'CRef_contr'};
efS = myData(10:18,{'CRef'});
efS.Properties.VariableNames = {'CRef_stroke'};

ofC = myData(1:9,{'CRof'});
ofC.Properties.VariableNames = {'CRof_contr'};
ofS = myData(10:18,{'CRof'});
ofS.Properties.VariableNames = {'CRof_stroke'};

y = [ofC{:,:} ofC{:,:} ceC{:,:} ceS{:,:} efC{:,:} efS{:,:}];
group = [ones(1,9) ones(1,9)*2 ones(1,9)*3 ones(1,9)*4 ones(1,9)*5 ones(1,9)*6];
positions = [1 1.25 1.75 2.00 2.5 2.75];

boxplot(y,group, 'positions', positions);
title('Training accuracies','fontsize',fsTitle)
ylabel('Performance (%)');
ylim([0 90]);
hline = refline([0 58]);
hline.LineStyle = '--';
hline.Color = [0 0 0];
median_line = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(median_line, 'Color', 'k');
set(gca,'xtick',[mean(positions(1:2)) mean(positions(3:4)) mean(positions(5:6)) ]);
set(gca,'xticklabel',labels.CR);

h = findobj(gca,'Tag','Box');
for j=1:length(h)
   patch(get(h(j),'XData'),get(h(j),'YData'),color(j),'FaceAlpha',.5);
end

c = get(gca, 'Children');
[BL,BLicons] = legend ((c([1 2])),{'Control', 'Stroke'},'fontsize',8);
PatchInLegend = findobj(BLicons, 'type', 'patch');
set(PatchInLegend, 'facea', 0.5)
BL.Location = 'southeast';

print([PATHIN 'performance_data'], '-dtiff', '-r300');

%}

%% plotting average number of movements in rest vs. move

% {
figure; 

rmMovementsInRest_stroke = myData(10:18,{'rmMovementsInRest'});
rmMovementsInRest_stroke.Properties.VariableNames = {'rmMovementsInRest_stroke'};
rmMovementsInRest_contr = myData(1:9,{'rmMovementsInRest'});
rmMovementsInRest_contr.Properties.VariableNames = {'rmMovementsInRest_contr'};

rmMovementsInMove_stroke = myData(10:18,{'rmMovementsInMove'});
rmMovementsInMove_stroke.Properties.VariableNames = {'rmMovementsInMove_stroke'};
rmMovementsInMove_contr = myData(1:9,{'rmMovementsInMove'});
rmMovementsInMove_contr.Properties.VariableNames = {'rmMovementsInMove'};

x = [rmMovementsInRest_contr{:,:} rmMovementsInRest_stroke{:,:} rmMovementsInMove_contr{:,:} rmMovementsInMove_stroke{:,:}];
group = [ones(1,9) ones(1,9)*2 ones(1,9)*3 ones(1,9)*4];
positions = [1 1.25 1.75 2.00];

boxplot(x,group, 'positions', positions);
title('Movement frequencies in rest vs. move','fontsize',fsTitle)
ylabel('Average number of movements');
median_line = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(median_line, 'Color', 'k');
set(gca,'xtick',[mean(positions(1:2)) mean(positions(3:4))]);
set(gca,'xticklabel',labels.RM);

color = ['r', 'b', 'r', 'b'];
h = findobj(gca,'Tag','Box');
for j=1:length(h)
   patch(get(h(j),'XData'),get(h(j),'YData'),color(j),'FaceAlpha',.5);
end

c = get(gca, 'Children');
c = get(gca, 'Children');
[BL,BLicons] = legend ((c([1 2])),{'Control', 'Stroke'},'fontsize',8);
PatchInLegend = findobj(BLicons, 'type', 'patch');
set(PatchInLegend, 'facea', 0.5)
BL.Location = 'northwest';

print([PATHIN 'rmMovement_data'], '-dtiff', '-r300');

%}

