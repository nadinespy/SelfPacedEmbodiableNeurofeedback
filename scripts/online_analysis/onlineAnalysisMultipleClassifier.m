% This script preprocesses and applies CSP filters to EEG data from the 
% training block, trains a predictive model for the three classifiers, 
% and derives training accuracies.

% Required packages/files: 
% BCILAB-1.1
% eeglab13_4_4b

% Authors: Niclas Braun. 
% License: GNU GPLv3.

clear all; close all; clc;

cd '/mydir/scripts';
addpath '/mydir/auxiliaries';
addpath '/mydir/BCILAB-1.1'; 
addpath '/mydir/modifiedBCILAB';                                            % folder with modified scripts from bcilab

% EEG data from training block
DATASET = 'nic_FHC_contr01_unilateral_train';                               % specify subject

MAINPATH = '/mydir/analysis/';
PATHIN = [MAINPATH 'rawdata/'];    
PATHOUT = [MAINPATH 'online/'];

%% Adjustable variables:

% Arduino codification:
% 0: detach servos
% 1: attach servos
% 2: flexion 30-150
% 3: extension 150-30
% 4: LED on
% 5: LED off

% start bcilab
bcilab;

% mobile EEG (1) or stationary (0)
mobile = 1;
if mobile                                                                   % if mobile eeg is used
    chLoc = 'niclas_mobile24.xyz';
    validChannels = 24;                                                     % use all available channels
else
    chLoc = 'elec_59ch.elp';
    validChannels = 59;                                                     % disregard emg and eda channels
end

classes = {{'o'},{'c'},{'e'},{'f'}};                                        % class specifications
nrPat = 4;                                                                  % number of CSP pattern
 
% allocate global variable (for documenting all relevant information)
global subinf;
subinf.BPF = [6 8 28 30];
subinf.EPO = [0 1.5];
subinf.filters = [];
subinf.patterns = [];
subinf.dataset = DATASET;

%% loading dataset

% check for existence of already processed datasets
if ~exist([PATHOUT DATASET '.set'], 'file')
    disp('load xdf rawdata file...');
    EEG = eeg_load_xdf([PATHIN DATASET '.xdf']);
    EEG = eeg_checkset(EEG);                                                % check dataset consistency
    EEG = pop_saveset(EEG, [DATASET '.set'], PATHOUT);                      % save as eeg structure file   
else
    EEG = pop_loadset([DATASET '.set'],PATHOUT);
    eeglab redraw;
end

%% preprocessing

% document number of trials and chance level
[labels,num] = eeg_eventtypes(EEG);

subinf.ef.trials = sum(num(find(strcmp(labels,'e')))+num(find(strcmp(labels,'f'))));
subinf.ce.trials = sum(num(find(strcmp(labels,'c')))+num(find(strcmp(labels,'e'))));
subinf.of.trials = sum(num(find(strcmp(labels,'o')))+num(find(strcmp(labels,'f'))));
subinf.rm.trials = sum(num(find(strcmp(labels,'o')))+num(find(strcmp(labels,'c')))+num(find(strcmp(labels,'e')))+num(find(strcmp(labels,'f'))));

tmp = [num(find(strcmp(labels,'e'))) num(find(strcmp(labels,'f'))); 0.5 0.5];
[tmp, subinf.ef.chanceLevel] = check_classifier(tmp, 0.05, 2); subinf.ef.chanceLevel = (1-subinf.ef.chanceLevel)*100;

tmp = [num(find(strcmp(labels,'c'))) num(find(strcmp(labels,'e'))); 0.5 0.5];
[tmp, subinf.ce.chanceLevel] = check_classifier(tmp, 0.05, 2); subinf.ce.chanceLevel = (1-subinf.ce.chanceLevel)*100;

tmp = [num(find(strcmp(labels,'o'))) num(find(strcmp(labels,'f'))); 0.5 0.5];
[tmp, subinf.of.chanceLevel] = check_classifier(tmp, 0.05, 2); subinf.of.chanceLevel = (1-subinf.of.chanceLevel)*100;

tmp = [num(find(strcmp(labels,'r'))) num(find(strcmp(labels,'m'))); 0.5 0.5];
[tmp, subinf.rm.chanceLevel] = check_classifier(tmp, 0.05, 2); subinf.rm.chanceLevel = (1-subinf.rm.chanceLevel)*100;


% load channel locations and only use specified channels
EEG.data = EEG.data(1:validChannels,:); EEG.nbchan = validChannels;
EEG = pop_chanedit(EEG,'load',[MAIN,'config/',chLoc]);
EEG.chanlocs = EEG.chanlocs(1:validChannels);
chanLab = {EEG.chanlocs.labels};
eeglab redraw;
if mobile 
    EEG = pop_saveset(EEG, [DATASET '.set'], PATHOUT); % save rawdata    
end

%% preprocessing extension vs. flexion

% identify strange epochs (separate for both classes)
% {
EEGc1 = pop_epoch(EEG,classes{3},subinf.EPO,'newname',DATASET,'epochinfo','yes');
EEGc1 = pop_jointprob(EEGc1,1,1:size(EEGc1.data,1),3,3,0,0);
EEGc1 = pop_rejepoch(EEGc1,find(EEGc1.reject.rejjp),0);

EEGc2 = pop_epoch(EEG,classes{4},subinf.EPO,'newname',DATASET,'epochinfo','yes');
EEGc2 = pop_jointprob(EEGc2,1,1:size(EEGc2.data,1),3,3,0,0);
EEGc2 = pop_rejepoch(EEGc2,find(EEGc2.reject.rejjp),0);
%}

% filter data
EEGc1 = pop_firws(EEGc1,'fcutoff',subinf.BPF(3),'ftype','lowpass','wtype','hann','forder',100);
EEGc1 = pop_firws(EEGc1,'fcutoff',subinf.BPF(2),'ftype','highpass','wtype','hann','forder',500);
EEGc2 = pop_firws(EEGc2,'fcutoff',subinf.BPF(3),'ftype','lowpass','wtype','hann','forder',100);
EEGc2 = pop_firws(EEGc2,'fcutoff',subinf.BPF(2),'ftype','highpass','wtype','hann','forder',500);

% reshape data to channels x all samples
data1 = reshape(EEGc1.data,size(EEGc1.data,1),[]); 
data2 = reshape(EEGc2.data,size(EEGc2.data,1),[]);

% calculate covariance matrices
covar1 = cov(data1'); 
covar2 = cov(data2');
covar1(~isfinite(covar1)) = 0; 
covar2(~isfinite(covar2)) = 0;

% CSP between class1 and class2
disp(' ');
disp('Calculate CSP between extension vs. flexion...')
[V,tmp] = eig(covar1,covar1+covar2);                                        % V = eigenvectoren             
filters = V(:,[1:nrPat end-nrPat+1:end]);                                   % select the last n patterns and the first n patterns
P = inv(V);
patterns = P([1:nrPat end-nrPat+1:end],:);

getERD(EEGc1.data,EEGc2.data,{filters,patterns'},EEGc1.chanlocs,3,10);      % visualise CSP filters and patterns

% select CSP filters
userFil = input('Give me the the desired CSP filters: ');
disp(['--> Selected the following filters: ' num2str(userFil)]);
subinf.ef.patterns = patterns(userFil,:);
subinf.ef.filters = filters(:,userFil);
subinf.ef.selFilters = userFil;
close([11:11+nrPat*2-1]);

%% preprocessing closed vs. extension

% identify strange epochs (separate for both classes)
% {
EEGc1 = pop_epoch(EEG,classes{2},subinf.EPO,'newname',DATASET,'epochinfo','yes');
EEGc1 = pop_jointprob(EEGc1,1,1:size(EEGc1.data,1),3,3,0,0);
EEGc1 = pop_rejepoch(EEGc1,find(EEGc1.reject.rejjp),0);

EEGc2 = pop_epoch(EEG,classes{3},subinf.EPO,'newname',DATASET,'epochinfo','yes');
EEGc2 = pop_jointprob(EEGc2,1,1:size(EEGc2.data,1),3,3,0,0);
EEGc2 = pop_rejepoch(EEGc2,find(EEGc2.reject.rejjp),0);
%}

% filter data
EEGc1 = pop_firws(EEGc1,'fcutoff',subinf.BPF(3),'ftype','lowpass','wtype','hann','forder',100);
EEGc1 = pop_firws(EEGc1,'fcutoff',subinf.BPF(2),'ftype','highpass','wtype','hann','forder',500);
EEGc2 = pop_firws(EEGc2,'fcutoff',subinf.BPF(3),'ftype','lowpass','wtype','hann','forder',100);
EEGc2 = pop_firws(EEGc2,'fcutoff',subinf.BPF(2),'ftype','highpass','wtype','hann','forder',500);

% reshape data to channels x all samples
data1 = reshape(EEGc1.data,size(EEGc1.data,1),[]); 
data2 = reshape(EEGc2.data,size(EEGc2.data,1),[]);

% calculate covariance matrices
covar1 = cov(data1'); 
covar2 = cov(data2');
covar1(~isfinite(covar1)) = 0; 
covar2(~isfinite(covar2)) = 0;

% CSP between class1 and class2
disp(' ');
disp('Calculate CSP between closed vs. extension...')
[V,tmp] = eig(covar1,covar1+covar2);                                        % V = eigenvectoren              
filters = V(:,[1:nrPat end-nrPat+1:end]);                                   % select the last n patterns and the first n patterns
P = inv(V);
patterns = P([1:nrPat end-nrPat+1:end],:);

getERD(EEGc1.data,EEGc2.data,{filters,patterns'},EEGc1.chanlocs,3,10);      % visualise CSP filters and patterns

% select CSP filters
userFil = input('Give me the the desired CSP filters: ');
disp(['--> Selected the following filters: ' num2str(userFil)]);
subinf.ce.patterns = patterns(userFil,:);
subinf.ce.filters = filters(:,userFil);
subinf.ce.selFilters = userFil;
close([11:11+nrPat*2-1]);

%% preprocessing opened vs. flexion

% identify strange epochs (separate for both classes)
% {
EEGc1 = pop_epoch(EEG,classes{1},subinf.EPO,'newname',DATASET,'epochinfo','yes');
EEGc1 = pop_jointprob(EEGc1,1,1:size(EEGc1.data,1),3,3,0,0);
EEGc1 = pop_rejepoch(EEGc1,find(EEGc1.reject.rejjp),0);

EEGc2 = pop_epoch(EEG,classes{4},subinf.EPO,'newname',DATASET,'epochinfo','yes');
EEGc2 = pop_jointprob(EEGc2,1,1:size(EEGc2.data,1),3,3,0,0);
EEGc2 = pop_rejepoch(EEGc2,find(EEGc2.reject.rejjp),0);
%}

% filter data
EEGc1 = pop_firws(EEGc1,'fcutoff',subinf.BPF(3),'ftype','lowpass','wtype','hann','forder',100);
EEGc1 = pop_firws(EEGc1,'fcutoff',subinf.BPF(2),'ftype','highpass','wtype','hann','forder',500);
EEGc2 = pop_firws(EEGc2,'fcutoff',subinf.BPF(3),'ftype','lowpass','wtype','hann','forder',100);
EEGc2 = pop_firws(EEGc2,'fcutoff',subinf.BPF(2),'ftype','highpass','wtype','hann','forder',500);

% reshape data to channels x all samples
data1 = reshape(EEGc1.data,size(EEGc1.data,1),[]); 
data2 = reshape(EEGc2.data,size(EEGc2.data,1),[]);

% calculate covariance matrices
covar1 = cov(data1'); 
covar2 = cov(data2');
covar1(~isfinite(covar1)) = 0; 
covar2(~isfinite(covar2)) = 0;

% CSP between class1 and class2
disp(' ');
disp('Calculate CSP between opened vs. flexion...')
[V,tmp] = eig(covar1,covar1+covar2);                                        % V = eigenvectoren             
filters = V(:,[1:nrPat end-nrPat+1:end]);                                   % select the last n patterns and the first n patterns
P = inv(V);
patterns = P([1:nrPat end-nrPat+1:end],:);

getERD(EEGc1.data,EEGc2.data,{filters,patterns'},EEGc1.chanlocs,3,10);      % visualise CSP filters and patterns

% select CSP filters
userFil = input('Give me the the desired CSP filters: ');
disp(['--> Selected the following filters: ' num2str(userFil)]);
subinf.of.patterns = patterns(userFil,:);
subinf.of.filters = filters(:,userFil);
subinf.of.selFilters = userFil;
close([11:11+nrPat*2-1]);

%% train classifier

% load dataset
mytrainset = io_loadset([PATHOUT DATASET '.set']);

% specify approach
myapproach = {'CSP', 'SignalProcessing',{'FIRFilter',subinf.BPF,'EpochExtraction',subinf.EPO,'Resampling',{},'ChannelSelection',{'Channels',chanLab}},...
                             'Prediction',{'MachineLearning',{'Learner' ,'logreg'}}};                        
% extension vs. flexion
subinf.patterns = subinf.ef.patterns; subinf.filters = subinf.ef.filters;
[subinf.ef.trainloss,myModels.ef,subinf.ef.laststats] = bci_train('Data',mytrainset,'Approach',myapproach,'TargetMarkers', [classes(3), classes(4)]);
subinf.ef.trainloss = subinf.ef.trainloss*100;

% closed vs. extension
subinf.patterns = subinf.ce.patterns; subinf.filters = subinf.ce.filters;
[subinf.ce.trainloss,myModels.ce,subinf.ce.laststats] = bci_train('Data',mytrainset,'Approach',myapproach,'TargetMarkers', [classes(2), classes(3)]);
subinf.ce.trainloss = subinf.ce.trainloss*100;

% opened vs. flexion
subinf.patterns = subinf.of.patterns; subinf.filters = subinf.of.filters;
[subinf.of.trainloss,myModels.of,subinf.of.laststats] = bci_train('Data',mytrainset,'Approach',myapproach,'TargetMarkers', [classes(1), classes(4)]);
subinf.of.trainloss = subinf.of.trainloss*100;

% display classification rates:
disp(' ');
disp('Classification errors:');
disp(['extension vs flexion: ' num2str(subinf.ef.trainloss)])
disp(['closed vs extension: ' num2str(subinf.ce.trainloss)])
disp(['opened vs flexion: ' num2str(subinf.of.trainloss)])

save([PATHOUT DATASET '.mat'],'myModels','subinf');
