% This script imposes a trial structure on the EEG data from the "announce
% commands task" of the feedback block.

% Required packages/files: 
% eeglab13_4_4b

% Authors: Nadine Spychala, Edith Bongartz. 
% License: GNU GPLv3.

clear all; close all; clc;

% initializing paths
cd '/mydir/scripts/offline_analysis/classification_accuracies/feedback_accuracies';
performanceAnalysis_init;

%% allocating variables

% distinguish between groups
groups = {'stroke', 'contr'};                                                               

SUBJ_stroke = {'01', '02', '03', '05', '06', '07', '08', '09', '10'};                       % subject numbers in stroke group
SUBJ_contr = {'01', '02', '03', '04', '05', '06', '07', '08', '09'};                        % subject numbers in control group
SUBJ_complete = {SUBJ_stroke; SUBJ_contr};

% define trial length
lat = 5;                                                                                    % trial length of 5 sec for movement being executed after commands "close" and "open"
lat2 = 2*lat;                                                                               % trial length of 10 sec two movements being executed after command "grasp"

% start eeglab
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

%% imposing trial structure

for y = 1:length(groups) 
    
    SUBJ = SUBJ_complete{y};

    for s = 1:length(SUBJ)
        
        EEG = pop_loadset(['nic_FHC_', groups{y}, SUBJ{s}, '_unilateral_test_ac.set'], PATHIN3);
        announce = nan(1,4*60*EEG.srate);                                                           % allocate variable of length 4*60*500 (4 minutes of EEG data recodring, with 500 data points per sec) for storing trial structure 
    
            % store events (commands and movements) in the nan 4*60*500 vector
            for ev = 1:length(EEG.event)
                if strcmp(EEG.event(ev).type,'aC');
                announce(1,int64(EEG.event(ev).latency)) = 1;
                elseif strcmp(EEG.event(ev).type,'f');
                announce(1,int64(EEG.event(ev).latency)) = 2;
                elseif strcmp(EEG.event(ev).type,'aO');
                announce(1,int64(EEG.event(ev).latency)) = 3;
                elseif strcmp(EEG.event(ev).type,'e');
                announce(1,int64(EEG.event(ev).latency)) = 4;
                elseif strcmp(EEG.event(ev).type,'aG');
                announce(1,int64(EEG.event(ev).latency)) = 5;

                elseif strcmp(EEG.event(ev).type,'cC');
                announce(1,int64(EEG.event(ev).latency)) = 1;
                elseif strcmp(EEG.event(ev).type,'cO');
                announce(1,int64(EEG.event(ev).latency)) = 3;
                elseif strcmp(EEG.event(ev).type,'cG');
                announce(1,int64(EEG.event(ev).latency)) = 5;           
                else announce(ev) = nan;
                end
           end

            % define and store trials in the 4*60*500 nan vector (each 5 sec time interval between two commands)
            for d = 1:length(announce)
                if (announce(d) == 1) || (announce(d) == 3) || (announce(d) == 5) 
                    for w = (d+1):length(announce)
                        if (announce(w) == 1) || (announce(w) == 3) || (announce(w) == 5) || (w == length(announce))
                           numTimeWindow = floor((w-d)/(lat*EEG.srate));
                           for j = 1:numTimeWindow
                             announce(d+(j*lat*EEG.srate)) = 6;
                           end
                           break
                        end
                    end
                end
            end

        % keep and save only commands, movements, trials 
        announceIndex = find(~isnan(announce));
        announce2 = announce(find(~isnan(announce))); 
        announce2 = announce2';
        announceIndex = announceIndex';
        ANNOUNCE = [announce2,announceIndex];
        save([PATHOUT1, groups{y}, SUBJ{s}, '_ANNOUNCE_unilateral.mat'],'ANNOUNCE');
    end  
end 
