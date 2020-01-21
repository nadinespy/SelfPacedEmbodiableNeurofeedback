% This script conducts CSP-based wavelet analysis on the 
% artifact-corrected, epoched, and pruned data for single and across 
% subjects, including plotting (Figure 4), and derives tables for ERD 
% values and latencies.

% Required packages/files: 
% eeglab13_4_4b
% suptitle.m (should be contained in auxiliaries)
% plotWavelet2.m (should be contained in auxiliaries)
% jt_st_wave.m (should be contained in auxiliaries)
% vline.m (should be contained in auxiliaries)

% Authors: Nadine Spychala, Niclas Braun, Stefan Debener, Jeremy Thorne,
% Edith Bongartz. 
% License: GNU GPLv3.

clear all; close all; clc;

cd '/mydir';
addpath '/mydir/scripts/auxiliaries';
addpath '/mydir/scripts/eeglab13_4_4b'; 
addpath '/mydir/scripts/eeglab13_4_4b/plugins/xdfimport1.12'; 

MAINPATH =  '/mydir/analysis/';
PATHIN1 =   [MAINPATH, 'time_frequency_analysis/ana02_epoching'];
PATHIN2 =   [MAINPATH, 'time_frequency_analysis/ana03_CSP/'];
PATHOUT =  [MAINPATH, 'time_frequency_analysis/ana04_wavelet/'];

%% EEG and time-frequency parameters                              

% start eeglab
eeglab;

epochEvents =   {'f', 'e'};     % 'f' for flexion, 'e' for extension
epo.be =        [-0.8 2.3];     % epoching before edge-artifact removal
epo.MI =        [500 1500];     % MI time interval of interest (after edge-artifact removal)
BL =            [1 500];        % baseline period (after edge-artifact removal)
SR =            500;            % sampling rate
SI =            1000/SR;        % sampling interval (in ms)
freqs =         5:50;           % frequencies to be calculated
tfp1 =          3;              % number of cycles within gaussian for lowest frequency bin 
tfp2 =          8;              % number of cycles within gaussian for highest frequency bin
                                % (the higher, the better the frequency resolution/the worse the temporal resolution)
nbchan =        26;             % number of channels: 24 electrodes and 2 virtual channels
CSPf =          25;             % additional virtual channel for epochs of flexion 
CSPe =          26;             % additional virtual channel for epoch of extension
ROIf =          CSPf;           % region of interest for flexion
ROIe =          CSPe;           % region of interest for extension
ROIl =          9;              % region of interest for left hemisphere (C3)
ROIr =          10;             % region of interest for right hemisphere (C4)

%% calculate edge-artifacts and time scales

times.be =              epo.be(1)*1000:SI:epo.be(2)*1000-SI;                                % time scale before edge-artifact removal, converting time to samples 
                                                                                            % times.be: from -800 to 2289 in steps of two (1550 elements)
edgeArtifacts.ms =      (0.5*tfp1./freqs(1)')*1000;                                         % edge-artifact calculation: calculating the size of the data part that is cut off at the end and at the beginning 
edgeArtifacts.samples = length(SI:SI:edgeArtifacts.ms);                      
times.af =              times.be((edgeArtifacts.samples+1):end-edgeArtifacts.samples);      % time scale after edge-artifact removal: cutting off the edges (left and right)
                                                                                            % times.af: time after edge correction, from -500 to 1998 in steps of two (1250 elements)
times_lower_bound =     times.af(1)-2;
times_upper_bound =     times.af(end)+2;
times_index =           (times_lower_bound < times.af) & (times.af < times_upper_bound);
times.af =              times.af(times_index);                                              % times.af: from -498 to 1998 in step size of 2 (1250 elements)

%% variables that distinguish between groups

groups = {'stroke', 'contr'};                                                               

list_stroke = dir(fullfile([PATHIN1 '/*stroke*train*ica*removed*epoched*pruned.set']));
DATASETS_stroke = {};                                                                       % datasets of stroke group
for d = 1:length(list_stroke)
    DATASETS_stroke = [DATASETS_stroke; list_stroke(d).name(1:end-4)];
end

list_contr = dir(fullfile([PATHIN1 '/*contr*train*ica*removed*epoched*pruned.set']));
DATASETS_contr = {};                                                                        % datasets of control group
for d = 1:length(list_contr)
    DATASETS_contr = [DATASETS_contr; list_contr(d).name(1:end-4)];
end

DATASETS_complete = {DATASETS_stroke; DATASETS_contr};

SUBJ_stroke = {'01', '02', '03', '05', '06', '07', '08', '09', '10'};                       % subject numbers in stroke group
SUBJ_contr = {'01', '02', '03', '04', '05', '06', '07', '08', '09'};                        % subject numbers in control group
SUBJ_complete = {SUBJ_stroke; SUBJ_contr};

%% calculate wavelets for single and across subjects

for y = 1:length(groups)                                                                                % first stroke patients, then controls
    
    DATASETS = DATASETS_complete{y};
    SUBJ = SUBJ_complete{y};

    EEG = pop_loadset([DATASETS{1} '.set'],PATHIN1);                                                    % save channel locations
    chanlocs = EEG.chanlocs;
    eeglab redraw

    % single subjects
    % {
    for d = 1:length(DATASETS)
        load([PATHIN2 DATASETS{d} '_CSP.mat']);                                                         % load corresponding CSP-components
        EEG = pop_loadset([DATASETS{d} '.set'],PATHIN1);                                                % load dataset
    
        % add virtual CSP channels
        EEG.data(end+1,:,:) = nan; EEG.data(end+1,:,:) = nan;
        EEG.nbchan = EEG.nbchan+2;
        EEG.chanlocs(end+1).labels = 'CSPf'; EEG.chanlocs(end+1).labels = 'CSPe';
        for t = 1:size(EEG.data,3)
            EEG.data(CSPf,:,t) = EEG.data(1:EEG.nbchan-2,:,t)'*CSP.f(:,1);                              % CSP.f(:,1): CSP filter for flexion
            EEG.data(CSPe,:,t) = EEG.data(1:EEG.nbchan-2,:,t)'*CSP.f(:,2);                              % CSP.f(:,2): CSP filter for extension
        end
    
        EEGf = pop_epoch(EEG,epochEvents(1),epo.be,'epochinfo','yes');                                  % epoching from -0.8 sec to 2.3 sec, relative to trigger 'f'
        EEGe = pop_epoch(EEG,epochEvents(2),epo.be,'epochinfo','yes');                                  % epoching from -0.8 sec to 2.3 sec, relative to trigger 'e'
        
        WAVELETat.f = nan(length(freqs),length(times.af),EEG.nbchan);                                   % allocate space for flexion        
        WAVELETat.e = nan(length(freqs),length(times.af),EEG.nbchan);                                   % allocate space for extension
   
        % flexion 
        for ch = 1:size(EEGf.data,1)             
            tmpWAVELET = nan(length(freqs),length(times.be),size(EEGf.data,3));                         % freqs x samples x trials
            
            % calculate raw wavelet for each channel and each trial from -0.8 to 2.3 (time window specified by times.be)
            for t = 1:size(EEGf.data,3)
                tmpCh = EEGf.data(ch,:,t);
                [tmpWAVELET(:,:,t), fres, tres, foi ] = jt_st_wave(tmpCh,SR,freqs,tfp1,tfp2,times.be);
            end
            tmpWAVELET = tmpWAVELET(:,edgeArtifacts.samples+1:end-edgeArtifacts.samples,:);             % remove edge-artifacts (take part of tmpWAVELET of size times.af)
        
            % calculate wavelet across trials
            % calculate baseline
            base = squeeze(mean(abs(tmpWAVELET).^2,3));                                                 % across trials: freqs x times
            base = mean(base(:,BL(1):BL(2)),2);                                                         % across BL samples: freqs
            base = repmat(base,1,size(tmpWAVELET,2));                                                   % freqs x times
        
            WAVELETat.f(:,:,ch) = (100*(squeeze(mean(abs(tmpWAVELET).^2,3))./base))-100;                % baseline correct and transform into percentage    
        end
    
        % extension
        for ch = 1:size(EEGe.data,1)
            tmpWAVELET = nan(length(freqs),length(times.be),size(EEGe.data,3));                         % freqs x samples x trials
            
            % calculate raw wavelet for each channel and each trial from -0.8 to 2.3 (time window specified by times.be)
            for t = 1:size(EEGe.data,3)
                tmpCh = EEGe.data(ch,:,t);
                tmpWAVELET(:,:,t) = jt_st_wave(tmpCh,SR,freqs,tfp1,tfp2,times.be);
            end
            tmpWAVELET = tmpWAVELET(:,edgeArtifacts.samples+1:end-edgeArtifacts.samples,:);             % remove edge-artifacts (take part of tmpWAVELET of size times.af)
        
            % calculate wavelet across trials
            % calculate baseline
            base = squeeze(mean(abs(tmpWAVELET).^2,3));                                                 % across trials: freqs x times
            base = mean(base(:,BL(1):BL(2)),2);                                                         % across BL samples: freqs
            base = repmat(base,1,size(tmpWAVELET,2));                                                   % freqs x times

            WAVELETat.e(:,:,ch) = (100*(squeeze(mean(abs(tmpWAVELET).^2,3))./base))-100;                % baseline correct and transform into percentage
        end
        
        save([PATHOUT DATASETS{d} '_WAVELETat.mat'],'WAVELETat');
    end 
    %}

    % across subjects
    % {
    WAVELETas.f = nan(length(freqs),length(times.af),nbchan,length(DATASETS));                          % allocate space for flexion 
    WAVELETas.e = nan(length(freqs),length(times.af),nbchan,length(DATASETS));                          % allocate space for extension 
 
    
    problems = {};                                                                                      % save datasets that could not be loaded                                              
    for d = 1:length(DATASETS)  
        if exist([PATHOUT  '/' DATASETS{d} '_WAVELETat.mat']) == 2
            load([PATHOUT '/' DATASETS{d} '_WAVELETat.mat']);                                          % load wavelets of current subject
        else
            problems = [problems; DATASETS{d}]
            continue;
        end
          
        WAVELETas.f(:,:,:,d) = WAVELETat.f; 
        WAVELETas.e(:,:,:,d) = WAVELETat.e;             
    end

    WAVELETas.f = mean(WAVELETas.f,4);                                                                  % wavelets across all subjects for flexion
    WAVELETas.e = mean(WAVELETas.e,4);                                                                  % wavelets across all subjects for extension

    save([PATHOUT 'WAVELETas_UNI' groups{y} '.mat'],'WAVELETas');
    %}
end

%% plot wavelets and ERDs across subjects (Figure 4)

% visualisation parameters

ERDv =      [10 25];        % ERD to be visualised 
clims2 =    [-70 70];       % limits for the scale of power changes in the frequencies 
fsLabels =  14;             % font size title plot 
fig.as =    5;
titles =    {'Time-frequency results across stroke patients', 'Across control subjects'};      

for y = 1:length(groups)                                                                                % first stroke patients, then controls
    
    DATASETS = DATASETS_complete{y};
    SUBJ = SUBJ_complete{y};
  
    load([PATHOUT '/WAVELETas_UNI' groups{y} '.mat']);

    tmpFig = fig.as+1;
    figure(tmpFig)

    suptitle(titles{y});
    set(findobj(gcf, 'type','axes'), 'Visible','off');

    % flexion
    axes('Position',[0.18,0.7,0.2,0.2])
    tmpTopo = squeeze(mean(WAVELETas.f(find(freqs==ERDv(1)):find(freqs==ERDv(2)),:,:)));
    tmpTopo = std(tmpTopo);
    topoplot(tmpTopo,chanlocs,'maplimits','maxmin');
    myHandles = plotWavelet2(times.af,freqs,WAVELETas.f(:,times_index,ROIf),tmpFig,ERDv,[0 0 0.5 0.7],clims2);

    axes(myHandles.timeFreqPlot); title('Flexion','fontsize',fsLabels);
    vline(epo.MI(1),{'r--','linewidth',1.5}); vline(epo.MI(2),{'r--','linewidth',1.5});
    ylabel('Frequency','fontsize',fsLabels);
    xlabel('Time (in ms)','fontsize',fsLabels);
    axes(myHandles.erdPlot);axis([times.af(1) times.af(end) clims2(1) clims2(2)]);
    vline(epo.MI(1),{'r--','linewidth',1.5}); vline(epo.MI(2),{'r--','linewidth',1.5});

    % extension
    axes('Position',[0.68,0.7,0.2,0.2])
    tmpTopo = squeeze(mean(WAVELETas.e(find(freqs==ERDv(1)):find(freqs==ERDv(2)),:,:)));
    tmpTopo = std(tmpTopo);
    topoplot(tmpTopo,chanlocs,'maplimits','maxmin');
    myHandles = plotWavelet2(times.af,freqs,WAVELETas.e(:,times_index,ROIe),tmpFig,ERDv,[0.5 0 0.5 0.7],clims2);
    
    axes(myHandles.timeFreqPlot); title('Extension','fontsize',fsLabels);
    vline(epo.MI(1),{'r--','linewidth',1.5}); vline(epo.MI(2),{'r--','linewidth',1.5});
    axes(myHandles.erdPlot);axis([times.af(1) times.af(end) clims2(1) clims2(2)]);
    vline(epo.MI(1),{'r--','linewidth',1.5}); vline(epo.MI(2),{'r--','linewidth',1.5});

    set(gcf,'units','points','position',[10,10,600,400])
    set(gcf, 'PaperPositionMode','auto')

    savefig([PATHOUT 'ERDs_CSPbased_across_' groups{y} '_subjects.fig']);
    print([PATHOUT 'ERDs_CSPbased_across_' groups{y} '_subjects'], '-dtiff', '-r300');
    
    close all
end 

%% get CSP-based ERD values

for y = 1:length(groups)                                                                                % first stroke patients, then controls                                                                                                                                                             % first stroke patients, then controls
    
    DATASETS = DATASETS_complete{y};
    SUBJ = SUBJ_complete{y};
  
    load([PATHOUT 'WAVELETas_UNI' groups{y} '.mat']);
    
    ERDtrainFuni = nan(length(DATASETS),1); 
    ERDtrainEuni = nan(length(DATASETS),1);

    for d = 1:length(DATASETS)
        load([PATHOUT DATASETS{d} '_WAVELETat.mat']);    
        ERDtrainFuni(d,1) = mean(mean(WAVELETat.f(find(freqs==ERDv(1)):find(freqs==ERDv(2)), find(times.af==epo.MI(1)):find(times.af==epo.MI(2)),CSPf)));
        ERDtrainEuni(d,1) = mean(mean(WAVELETat.e(find(freqs==ERDv(1)):find(freqs==ERDv(2)), find(times.af==epo.MI(1)):find(times.af==epo.MI(2)),CSPe)));
    end
    
    if y == 1
        SUM_ERDuni_CSP_stroke = table(DATASETS, ERDtrainFuni, ERDtrainEuni);
    else
        SUM_ERDuni_CSP_contr = table(DATASETS, ERDtrainFuni, ERDtrainEuni);
    end
    
    save([PATHOUT 'SUM_ERDuni_CSP_' groups{y} '.mat'], ['SUM_ERDuni_CSP_' groups{y}]);
end 

%% get ERD latencies

for y = 1:length(groups)                                                                                 % first stroke patients, then controls
    
    DATASETS = DATASETS_complete{y};
    SUBJ = SUBJ_complete{y};
  
    load([PATHOUT 'WAVELETas_UNI' groups{y} '.mat']);
    
    ERD_threshold = -30;
    ERDlatency =    [];
    tmpFig =        1;

    for d = 1:length(DATASETS)
        load([PATHOUT DATASETS{d} '_WAVELETat.mat']);
   
        WAVELETat_threshold = WAVELETat.f(:,times_index,CSPf);
        WAVELETat_threshold(WAVELETat_threshold > ERD_threshold) = 0;
        WAVELETat_threshold(WAVELETat_threshold <= ERD_threshold) = 1;
        WAVELETat_threshold = WAVELETat_threshold*50;

        % extract latency
        t_time = sum(WAVELETat_threshold);
        times.threshold = times.af;
        times.threshold = times.threshold(250:end);
        times.threshold = times.threshold(t_time(250:end) > 0);
        ERDlatency_tmp = prctile(times.threshold,20);
        ERDlatency = [ERDlatency;  ERDlatency_tmp];
    
    end

    if y == 1
        ERDlatency_stroke = table(ERDlatency, 'RowNames', SUBJ);
    else 
        ERDlatency_contr = table(ERDlatency, 'RowNames', SUBJ);
    end
    
    save([PATHOUT 'ERDlatency_' groups{y} '.mat'], ['ERDlatency_' groups{y}]);
end
