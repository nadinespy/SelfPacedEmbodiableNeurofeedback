% This script loads the trained model from the training block. 

% Required packages/files: 
% BCILAB-1.1 

% Authors: Niclas Braun. 
% License: GNU GPLv3.

clear all; close all; close force all; clc;

cd '/mydir/scripts';
addpath '/mydir/auxiliaries';
addpath '/mydir/BCILAB-1.1'; 
addpath '/mydir/modifiedBCILAB';                                            % folder with modified scripts from bcilab

MAINPATH =  '/mydir/';
PATHIN =   [MAINPATH, 'analysis/online/'];
DATASET = 'nic_FHC_contr01_unilateral_train';                               % specify subject          

%% load trained model

% Arduino codification:
% 0: detach servos
% 1: attach servos
% 2: flexion 30-150
% 3: extension 150-30
% 4: LED on
% 5: LED off

% start bcilab
bcilab;

load([PATHIN DATASET '.mat']);                                              % load trained model

% {
run_readlsl('laststream');
run_readlsl('laststream','type','EEG');
%}
    
pause(5);

% feedback classifier output to LSL
run_writelsl('Model','myModels.of','SourceStream','laststream','LabStreamName','BCI_of','PredictorName','predOF','UpdateFrequency',20);   
run_writelsl('Model','myModels.ce','SourceStream','laststream', 'LabStreamName','BCI_ce','PredictorName','predCE','UpdateFrequency',20);
run_writelsl('Model','myModels.ef','SourceStream','laststream','LabStreamName','BCI_ef','PredictorName','predEF','UpdateFrequency',20);  
