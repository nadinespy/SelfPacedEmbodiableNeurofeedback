% This script calculates CSP filters on the artifact-corrected, epoched, 
% and pruned data (output files from preprocessingICA.m) for each subject.

% Required packages/files: 
% eeglab13_4_4b
% pop_firws (eeglab plugin)
% cov_shrink.m (should be contained in auxiliaries)
% eqTrials.m (should be contained in auxiliaries)
% getERD.m (should be contained in auxiliaries)
% tilefigs.m (should be contained in auxiliaries)

% Authors: Nadine Spychala, Niclas Braun, Stefan Debener, Jeremy Thorne,
% Edith Bongartz. 
% License: GNU GPLv3.

clear all;  close all; clc;

cd '/mydir/scripts';
addpath '/mydir/scripts/auxiliaries';
addpath '/mydir/scripts/eeglab13_4_4b'; 
addpath '/mydir/scripts/eeglab13_4_4b/plugins/xdfimport1.12'; 

MAINPATH =  '/mydir/';
PATHIN =   [MAINPATH, 'analysis/time_frequency_analysis/ana02_epoching'];
PATHOUT =   [MAINPATH, 'analysis/time_frequency_analysis/ana03_CSP/'];

%% variables that distinguish between groups

groups = {'stroke', 'contr'};                                                               

list_stroke = dir(fullfile([PATHIN '/*stroke*train.xdf']));
DATASETS_stroke = {};                                                                       % datasets of stroke group
for d = 1:length(list_stroke)
    DATASETS_stroke = [DATASETS_stroke; list_stroke(d).name(1:end-4)];
end

list_contr = dir(fullfile([PATHIN '/*contr*train.xdf']));
DATASETS_contr = {};                                                                        % datasets of control group
for d = 1:length(list_contr)
    DATASETS_contr = [DATASETS_contr; list_contr(d).name(1:end-4)];
end

DATASETS_complete = {DATASETS_stroke; DATASETS_contr};

SUBJ_stroke = {'01', '02', '03', '05', '06', '07', '08', '09', '10'};                       % subject numbers in stroke group
SUBJ_contr = {'01', '02', '03', '04', '05', '06', '07', '08', '09'};                        % subject numbers in control group
SUBJ_complete = {SUBJ_stroke; SUBJ_contr};

%% allocating variables

epochEvents =   {'f','e'}; 
EPO =           [-2 3];
EPOr =          [-2 -0.5];                                                                  % EPOr --> epoching resting
EPOm =          [0.5 2];                                                                    % EPOm --> epoching moving
nrPat =         4;                                                                          % number of CSP patterns
BPF =           [8 30];
checkAll =      0;

% start eeglab
eeglab;

%% calculate CSP filters

for y = 1%:length(groups)                                                                                % first stroke patients, then controls
    
    DATASETS = DATASETS_complete{y};
    SUBJ = SUBJ_complete{y};
    
    for s = 4%:length(SUBJ)
       
        % show which dataset is currently loaded
        disp(['Conduct analysis for: ' ['nic_FHC_', groups{y}, SUBJ{s}, '_unilateral_train_ica_removed_epoched_pruned.set']]);

        % load formerly selected components, if existent, otherwise create new list
        check = dir(fullfile([PATHOUT ['nic_FHC_', groups{y}, SUBJ{s}, '_unilateral_train_ica_removed_epoched_pruned_CSP.mat']]));
        if ~isempty(check)
            load([PATHOUT 'nic_FHC_', groups{y}, SUBJ{s}, '_unilateral_train_ica_removed_epoched_pruned_CSP.mat']);
        else
            clear CSP
            CSP.f = nan(24,2);                                                                          % CSP filter: CSP.f = 1 --> filter for flexion; CSP.f = 2 --> filter for extension = 1
            CSP.p = nan(2,24);                                                                          % CSP.p --> pattern
            CSP.sel_e = []; CSP.sel_f = [];                                                             % CSP.sel_e --> CSP filter selected for extension; CSP.sel_f --> % CSP filter selected for flexion
        end

        if checkAll || isempty(CSP.sel_f)
            
            % bandpassfilter data for CSP calculation
            EEG = pop_loadset(['nic_FHC_', groups{y}, SUBJ{s}, '_unilateral_train_ica_removed_epoched_pruned.set'], PATHIN);
            EEG = pop_firws(EEG,'fcutoff',BPF(2),'ftype','lowpass','wtype','hann','forder',100);
            EEG = pop_firws(EEG,'fcutoff',BPF(1),'ftype','highpass','wtype','hann','forder',500);
            
            % -------------------------------------------------------------
            % flexion
            % -------------------------------------------------------------
            
            EEGfr = pop_epoch(EEG,epochEvents(1),EPOr,'newname',[SUBJ{s} '_'],'epochinfo','yes');       % EEGfr --> EEG flexion rest 
            EEGfm = pop_epoch(EEG,epochEvents(1),EPOm,'newname',[SUBJ{s} '_'],'epochinfo','yes');       % EEGfm --> EEG flexion move

            % equalize number of trials
            [EEGfr, EEGfm] = eqTrials(EEGfr, EEGfm);

            % calculate CSP filters and patterns
            data1 = reshape(EEGfr.data,size(EEGfr.data,1),[]);                                          % reshape data to channels x all samples
            data2 = reshape(EEGfm.data,size(EEGfm.data,1),[]);

            covar1 = cov_shrink(data1'); covar2 = cov_shrink(data2');
            covar1(~isfinite(covar1)) = 0; covar2(~isfinite(covar2)) = 0;
            [V,tmp] = eig(covar1,covar1+covar2);                                                        % V --> eigenvectoren
            tmpFilters = V(:,[1:nrPat end-nrPat+1:end]);                                                % select the last n patterns and the first n patterns
            P = inv(V);
            tmpPatterns = P([1:nrPat end-nrPat+1:end],:);
            tmpFilters = real(tmpFilters); tmpPatterns = real(tmpPatterns);                             % remove imaginary part, if necessary

            % visualise CSP filters and patterns
            getERD(EEGfr.data, EEGfm.data, {tmpFilters, tmpPatterns'},EEG.chanlocs, 3, 10);
            tilefigs([11:11+nrPat*2-1]);

            % select CSP filters
            disp(' ');
            disp(['Selected filter for flexion MI ' 'nic_FHC_', groups{y}, SUBJ{s}, '_unilateral_train_ica_removed_epoched_pruned_CSP.mat' ' ' num2str(CSP.sel_f)]);
            userFil = input(['Give me the the desired CSP filter for flexion MI: ']);
            disp(['--> Selected the following filter: ' num2str(userFil)]);
            CSP.p(1,:) = tmpPatterns(userFil,:);
            CSP.f(:,1) = tmpFilters(:,userFil);
            CSP.sel_f = userFil;

            % -------------------------------------------------------------
            % extension
            % -------------------------------------------------------------
            
            clc; close all;

            EEGer = pop_epoch(EEG,epochEvents(2),EPOr,'newname',[SUBJ{s} '_'],'epochinfo','yes');       % EEGer --> extension rest
            EEGem = pop_epoch(EEG,epochEvents(2),EPOm,'newname',[SUBJ{s} '_'],'epochinfo','yes');       % EEGem --> extension move

            % Equalize number of trials
            [EEGer, EEGem] = eqTrials(EEGer, EEGem);

            % Calculate CSP filters and patterns
            data1 = reshape(EEGer.data,size(EEGer.data,1),[]);                                          % reshape data to channels x all samples
            data2 = reshape(EEGem.data,size(EEGem.data,1),[]);

            covar1 = cov_shrink(data1'); covar2 = cov_shrink(data2');
            covar1(~isfinite(covar1)) = 0; covar2(~isfinite(covar2)) = 0;
            [V,tmp] = eig(covar1,covar1+covar2);                                                        % V = eigenvectoren
            tmpFilters = V(:,[1:nrPat end-nrPat+1:end]);                                                % select the last n patterns and the first n patterns
            P = inv(V);
            tmpPatterns = P([1:nrPat end-nrPat+1:end],:);         
            tmpFilters = real(tmpFilters); tmpPatterns = real(tmpPatterns);                             % remove imaginary part, if necessary 

            % visualise CSP filters and patterns
            getERD(EEGer.data, EEGem.data, {tmpFilters, tmpPatterns'},EEG.chanlocs, 3, 10);
            tilefigs([11:11+nrPat*2-1]);

            % select CSP filters
            disp(' ');
            disp(['Selected filter for extension MI ' SUBJ{s} ' ' num2str(CSP.sel_e)]);
            userFil = input(['Give me the the desired CSP filter for extension MI: ']);
            disp(['--> Selected the following filter: ' num2str(userFil)]);
            CSP.p(2,:) = tmpPatterns(userFil,:);
            CSP.f(:,2) = tmpFilters(:,userFil);
            CSP.sel_e = userFil;
            
            save([PATHOUT 'nic_FHC_', groups{y}, SUBJ{s}, '_unilateral_train_ica_removed_epoched_pruned_CSP.mat'],'CSP')

            close all;
        end
    end
end
