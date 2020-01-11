% This scripts conducts Independent Component Analysis (ICA) on the raw EEG 
% data from the training block, and removes bad components and artefacts.

% Required packages/files: 
% eeglab13_4_4b
% eeg_load_xdf.m (eeglab plugin)
% pop_firws.m (eeglab plugin)
% niclas_mobile24_proper_labels.elp (should be contained in auxiliaries)

% Authors: Nadine Spychala, Niclas Braun, Stefan Debener, Jeremy
% Thorne, Edith Bongartz. 
% License: GNU GPLv3.


close all; clear all; clc;

cd '/mydir/scripts';
addpath '/mydir/scripts/auxiliaries';
addpath '/mydir/scripts/eeglab13_4_4b'; 
addpath '/mydir/scripts/eeglab13_4_4b/plugins/xdfimport1.12'; 

MAINPATH =  '/mydir/';
PATHIN1 =   [MAINPATH, 'analysis/rawdata/'];
PATHOUT1 =  [MAINPATH, 'analysis/time_frequency_analysis/ana01_ICA'];
PATHOUT2 =  [MAINPATH, 'analysis/time_frequency_analysis/ana02_epoching'];

%% preprocessing parameters

% start eeglab
eeglab;

[ALLEEG, EEG CURRENTSET ALLCOM] = eeglab;

HPF = 0.3;                                                                                  % high-pass filter
LPF = 40;                                                                                   % low-pass filter

epochEvents     = {'f', 'e'};                                                               % 'f' for flexion, 'e' for extension
epochDuration   = [-2 3];

%% variables that distinguish between groups

groups = {'stroke', 'contr'};                                                               

list_stroke = dir(fullfile([PATHIN1 '/*stroke*train.xdf']));
DATASETS_stroke = {};                                                                       % datasets of stroke group
for d = 1:length(list_stroke)
    DATASETS_stroke = [DATASETS_stroke; list_stroke(d).name(1:end-4)];
end

list_contr = dir(fullfile([PATHIN1 '/*contr*train.xdf']));
DATASETS_contr = {};                                                                        % datasets of control group
for d = 1:length(list_contr)
    DATASETS_contr = [DATASETS_contr; list_contr(d).name(1:end-4)];
end

DATASETS_complete = {DATASETS_stroke; DATASETS_contr};

SUBJ_stroke = {'01', '02', '03', '05', '06', '07', '08', '09', '10'};                       % subject numbers in stroke group
SUBJ_contr = {'01', '02', '03', '04', '05', '06', '07', '08', '09'};                        % subject numbers in control group
SUBJ_complete = {SUBJ_stroke; SUBJ_contr};

%% independent component analysis (ICA)

% {
for y = 1:length(groups)
    
    DATASETS = DATASETS_complete{y};
    SUBJ = SUBJ_complete{y};
    
    for s = 1:length(SUBJ)           
        EEG = eeg_load_xdf([PATHIN1, DATASETS{s}, '.xdf']);                                 % load xdf file
        file = ['CURRENT FILE: ',EEG.filename];
        disp(file); 
        EEG = pop_editset( EEG, 'setname', [DATASETS{s} '.set']);
        EEG = pop_chanedit(EEG, 'load',{[MAINPATH 'scripts/auxiliaries/niclas_mobile24_proper_labels.elp'] 'filetype' 'autodetect'});
        
        % filter & dummy epoch data (2 sec)
        EEG = pop_firws(EEG,'fcutoff',LPF,'ftype','lowpass','wtype','hann','forder',100);
        EEG = pop_firws(EEG,'fcutoff',HPF,'ftype','highpass','wtype','hann','forder',500);

        % create dummy events
        duration = 2.5;
        num = floor(EEG.xmax/duration)-1;     
        pnts = 1;
        eeg_eventtypes(EEG)
        ep = length(EEG.event);
        
        for i = 1:num
            EEG.event(ep+i).type = 999;
            EEG.event(ep+i).latency = pnts;
            EEG.event(ep+i).urevent = ep;
            pnts = pnts + (EEG.srate * duration);
        end

        % epoch according to dummy events
        EEG = pop_epoch(EEG,{999},[0 duration],'newname',[DATASETS{s} '_dummEpoched.set'],'epochinfo','yes');

        % prune data
        EEG = pop_jointprob(EEG,1,[1:24],3,3,0,0);
        EEG = pop_rejkurt(EEG,1,[1:24],3,3,0,0);
        EEG = eeg_rejsuperpose(EEG,1,1,1,1,1,1,1,1);
        EEG = pop_rejepoch(EEG, EEG.reject.rejglobal,0);
        EEG = pop_editset( EEG, 'setname',[DATASETS{s} '_filt_epochs_pruned.set']);
            
        % run ICA     
        EEG = pop_runica(EEG, 'extended',1,'interupt','on');   

        % store ICA weights
        icawinv = EEG.icawinv;
        icasphere = EEG.icasphere;
        icaweights = EEG.icaweights;
        icachansind = EEG.icachansind;

        % reload data
        EEG = eeg_load_xdf([PATHIN1, DATASETS{s} '.xdf']);
        EEG = pop_chanedit(EEG, 'load',{[MAINPATH 'scripts/auxiliaries/niclas_mobile24_proper_labels.elp'] 'filetype' 'autodetect'});
     
        % import ICA weights in the original dataset
        EEG.icawinv = icawinv;
        EEG.icasphere = icasphere;
        EEG.icaweights = icaweights;
        EEG.icachansind = icachansind;

        % save data with ICA info
        EEG = pop_saveset(EEG, 'filename', [DATASETS{s} '_ica.set'], 'filepath', PATHOUT1);
  
        clear EEG
        clear ALLEEG
    end
end

eeglab redraw;

%}

%% epoching and bad components rejection

% {
for y = 1:length(groups)
    
    DATASETS = DATASETS_complete{y};
    SUBJ = SUBJ_complete{y};
    
    for s = 1:length(SUBJ) 
        
        clear eeglab
        
        EEG = pop_loadset('filename', [DATASETS{s} '_ica.set'], 'filepath', PATHOUT1);      % load data (entailing ICA) 
        EEG = pop_chanedit(EEG, 'load',{[MAINPATH 'scripts/auxiliaries/niclas_mobile24_proper_labels.elp'] 'filetype' 'autodetect'});
            
        % filter & epoch data
        EEG = pop_firws(EEG,'fcutoff',HPF,'ftype','highpass','wtype','hann','forder',500);
        EEG = pop_epoch(EEG, epochEvents, epochDuration, 'newname', SUBJ{s}, 'epochinfo', 'yes');
        EEG = pop_rmbase(EEG, [epochDuration(1)*1000 0]);
        EEG.setname = [DATASETS{s} '_ica_epoched.set'];           

        % reject bad components
        EEG = pop_selectcomps(EEG, [1:24]);
        EEG.badcomps = input('badcomps: ');
        EEG = pop_subcomp( EEG, EEG.badcomps, 0);        
        EEG = pop_editset( EEG, 'setname', [DATASETS{s} '_ica_removed_epoched']);
        EEG.setname = [DATASETS{s} '_ica_removed_epoched.set'];
        EEG = pop_saveset( EEG, 'filename', [DATASETS{s} '_ica_removed_epoched.set'], 'filepath', PATHOUT1);
            
    end 
    close all
end
%}

%% artifact removal

% {
for y = 1:length(groups)
    
    DATASETS = DATASETS_complete{y};
    SUBJ = SUBJ_complete{y};
    
    for s = 1:length(SUBJ)      
        EEG = pop_loadset([DATASETS{s} '_ica_removed_epoched.set'],PATHOUT1);           % load preprocessed data 

        % remove remaining non-stereotypical artifacts    
        EEG = pop_jointprob(EEG,1,1:EEG.nbchan,3,3,0,0); 
        EEG = pop_rejkurt(EEG,1,1:EEG.nbchan,3,3,0,0);
        EEG = eeg_rejsuperpose(EEG,1,1,1,1,1,1,1,1);
        EEG = pop_rejepoch(EEG,find(EEG.reject.rejglobal),0);

        % store new dataset
        pop_saveset(EEG,[DATASETS{s} '_ica_removed_epoched_pruned.set'],PATHOUT2); 
    end                 
end
%}
