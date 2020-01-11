% This script instantiates the training block.

clear all; close all; clc;

% Required packages/files: 
% BCILAB-1.1 
% lsl_loadlib.m
% lsl_outlet.m
% lsl_streaminfo.m

% Authors: Niclas Braun. 
% License: GNU GPLv3.

cd '/mydir/scripts';
addpath '/mydir/auxiliaries';
addpath '/mydir/BCILAB-1.1'; 
addpath '/mydir/modifiedBCILAB';                                            % folder with modified scripts from bcilab

%% allocating variables

l =                 0.33;                                                   % LED onset ~333ms before servo onset
f =                 1.5;                                                    % duration of flexion
e =                 1.5;                                                    % duration of extension
o =                 2;                                                      % duration of open
c =                 2;                                                      % duration of closed
intermittend =      0; 
k =                 1;                                                      % only use occasional movements

ISIbo =             [3 3];                                                  % inter-stimulus interval (ISI) before opened
ISIbc =             [3 3];                                                  % ISI before closed

durT =              720;                                                    % total training duration in sec
countTrials =       0;

%% establish connection to LSL

% load library:
lib = lsl_loadlib();
info = lsl_streaminfo(lib,'HandPositionMarker','Markers',1,0,'cf_string','myuniquesourceid23443');
outlet = lsl_outlet(info);

% wait until recording is started
disp('Press key, when recording is started.')
pause
disp('Ok, lets start.');

%% establish connection to arduino

useServos = 1;
useLED = 1;
if useLED
    delete(instrfind('Type', 'serial'));                                    % assure that no serial port is open anymore
    s = serial('com6');                                                     % areate new serial port object. 
    set(s,'BaudRate',9600);                                                 % ase same baudrate specified in Arduino
    fopen(s);                                                               % open serial port
end
if useServos
    % attach motors and bring them to default position
    pause(2);                                                               % give servo some time to initialize
    fprintf(s, '%s\n','1')                                                  % attach servos
    pause(2);
end

%% start training

dur = tic;
while toc(dur)<durT
    
     % { 
     grasp = tic;
     
     % new trial
     disp('');disp('--> t'); 
     outlet.push_sample({'t'});                                             % start of trial
     
     % ISI before opened
     tmpJitter = (ISIbo(2)-ISIbo(1)).*rand(1,1)+ISIbo(1);     
     tmpTic = tic; while toc(tmpTic)<tmpJitter; end;
     
     % opened
     disp('--> o');
     outlet.push_sample({'o'});                                             % start of trial
     tmpP = tic; while toc(tmpP)<o; end     

     % LED on
     if useLED; fprintf(s, '%s\n','4'); end;
     outlet.push_sample({'LEDon'});                                         % start of trial
     disp('--> LEDon');
     tmpP = tic; while toc(tmpP)<l; end                                     % wait for x ms
     
     % flexion
     if useServos && k; fprintf(s, '%s\n','2'); end;
     outlet.push_sample({'f'});       
     countTrials = countTrials +1;
     disp(['--> f ' num2str(countTrials)]);
     tmpP = tic; while toc(tmpP)<f; end
     
     % LED off
     if useLED; fprintf(s, '%s\n','5'); end;
     outlet.push_sample({'LEDoff'});                                        % start of trial
     disp('--> LEDoff');
     
     % ISI before closed
     tmpJitter = (ISIbc(2)-ISIbc(1)).*rand(1,1)+ISIbc(1);     
     tmpTic = tic; while toc(tmpTic)<tmpJitter; end;
     
     % closed
     tmpP = tic; while toc(tmpP)<l; end                                     % wait for x ms     
     disp('--> c');
     outlet.push_sample({'c'});           
     tmpP = tic; while toc(tmpP)<c; end

     % LED on
     if useLED; fprintf(s, '%s\n','4'); end;
     outlet.push_sample({'LEDon'});                                         % start of trial
     disp('--> LEDon');
     tmpP = tic; while toc(tmpP)<l; end                                     % wait for x ms
     
     % extension
     if useServos && k; fprintf(s, '%s\n','3'); end;
     disp('--> e');
     outlet.push_sample({'e'});          
     tmpP = tic; while toc(tmpP)<e; end
 
     % LED off
     if useLED; fprintf(s, '%s\n','5'); end;
     disp('--> LEDoff');
     outlet.push_sample({'LEDoff'});      
     disp(['Duration of grasp: ' num2str(toc(grasp)) ' / Total duration: ' num2str(toc(dur)/60)]);     
     %}
     
     if intermittend; k = ~k; end;
    pause(1)
    toc(dur)
end

disp('Waiting for EMG')
pause();
outlet.push_sample({'EMG'}); 
disp('--> EMG');
disp('Ende des Blocks, vielen Dank!');
