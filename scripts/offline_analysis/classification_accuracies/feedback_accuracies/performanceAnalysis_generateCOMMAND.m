% This script imposes a trial structure on the EEG data from the "follow
% commands task" of the feedback block.

% Required packages/files: 
% eeglab13_4_4b

% Authors: Nadine Spychala, Edith Bongartz. 
% License: GNU GPLv3.

clear all; close all; clc;

%% allocating variables

% distinguish between groups
groups = {'stroke', 'contr'};                                                               

SUBJ_stroke = {'01', '02', '03', '05', '06', '07', '08', '09', '10'};                       % subject numbers in stroke group
SUBJ_contr = {'01', '02', '03', '04', '05', '06', '07', '08', '09'};                        % subject numbers in control group
SUBJ_complete = {SUBJ_stroke; SUBJ_contr};

% initializing paths
cd '/mnt/525C77605C773E33/all my stuff/free robotic hand control/article/scripts for publication check/scripts/offline_analysis/classification_accuracies/feedback_accuracies';
performanceAnalysis_init;

% define trial length
lat = 5;                                                                                    % trial length of 5 sec for movement being executed after commands "close" and "open"
lat2 = 2*lat;                                                                               % trial length of 10 sec two movements being executed after command "grasp"

% start eeglab
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

%% imposing trial structure

for y = 1:length(groups) 
    
    SUBJ = SUBJ_complete{y};

    for s = 1:length(SUBJ)

        EEG = pop_loadset(['nic_FHC_', groups{y}, SUBJ{s}, '_unilateral_test_fc.set'], PATHIN2);
        command = nan(1,4*60*EEG.srate);                                                            % allocate variable of length 4*60*500 (4 minutes of EEG data recodring, with 500 data points per sec) for storing trial structure 
    
        % store events (commands and movements) in the nan 4*60*500 vector
        for ev = 1:length(EEG.event)
            if strcmp(EEG.event(ev).type,'cC');
            command(1,int64(EEG.event(ev).latency)) = 1;
            elseif strcmp(EEG.event(ev).type,'f');
            command(1,int64(EEG.event(ev).latency)) = 2;
            elseif strcmp(EEG.event(ev).type,'cO');
            command(1,int64(EEG.event(ev).latency)) = 3;
            elseif strcmp(EEG.event(ev).type,'e');
            command(1,int64(EEG.event(ev).latency)) = 4;
            elseif strcmp(EEG.event(ev).type,'cG');
            command(1,int64(EEG.event(ev).latency)) = 5;
            else command(ev) = nan;
            end          
        end
            
        % define and store trials in the 4*60*500 nan vector (each 5 sec time interval between two commands)
        for d = 1:length(command)
            if (command(d) == 1) || (command(d) == 3) || (command(d) == 5) 
                for w = (d+1):length(command)
                    if (command(w) == 1) || (command(w) == 3) || (command(w) == 5) || (w == length(command))
                       numTimeWindow = floor((w-d)/(lat*EEG.srate));
                       for j = 1:numTimeWindow
                         command(d+(j*lat*EEG.srate)) = 6;
                       end
                       break
                    end
                end
            end
        end

        % keep and save only commands, movements, trials
        commandIndex = find(~isnan(command));
        command2 = command(find(~isnan(command))); 
        command2 = command2';
        commandIndex = commandIndex';
        COMMAND = [command2, commandIndex];
        save([PATHOUT1, groups{y}, SUBJ{s}, '_COMMAND_unilateral.mat'],'COMMAND');
    end
end
        