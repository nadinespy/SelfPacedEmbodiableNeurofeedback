% This script instantiates the ensemble classification algorithm in the 
% feeback block.

% Required packages/files: 
% BCILAB-1.1

% Authors: Niclas Braun. 
% License: GNU GPLv3.

clear all; close all; close force all; clc;

cd '/mydir/scripts';
addpath '/mydir/auxiliaries';
addpath '/mydir/BCILAB-1.1'; 
addpath '/mydir/modifiedBCILAB';                                            % folder with modified scripts from bcilab

%% settings

% Arduino codification:
% 0: detach servos
% 1: attach servos
% 2: flexion 30-150
% 3: extension 150-30
% 4: LED on
% 5: LED off

f =                     1.5;                                                % duration of flexion
e =                     1.5;                                                % duration of extension
durT =                  5000;                                               % total training duration (in sec)
state =                 'o';                                                % state to start with
settings.CP =           2;                                                  % critical phase (in sec)
settings.allowTrans =   1;                                                  % allow immediate transition from flexion to extension?
settings.thr.of =       0.75;                                               % thresholds
settings.thr.ce =       0.75; 
settings.thr.ef =       0.85; 
settings.thr.fe =       0.15; 

refClass =              0.1;                                                % refresh rate of classifier (in sec) 
tol =                   5;                                                  % tolerance (in sec), until classifier stream is considered dead
estimate.of =           0; 
estimate.ce =           0; 
estimate.ef =           0;

% settings of the different tasks
rm.do = 0; rm.idx = 1; rm.iterations = 8; rm.LED = 1; rm.dur = 30;          % 4 minutes
fc.do = 0; fc.dur = 240;                                                    % 4 minutes
ac.do = 0; ac.dur = 240;                                                    % 4 minutes

%% search for and connect to available LSL streams

lib = lsl_loadlib();                                                        % load LSL library 
stream.of = 'BCI_of';
stream.ce = 'BCI_ce';
stream.ef = 'BCI_ef';
stream.triggerBox = 'triggerBox';

% "open vs. flexion classifier" (of)
disp(['Searching for ' stream.of  ' stream...']);
result = {};
while isempty(result)
    result = lsl_resolve_byprop(lib,'name',stream.of,1,1); 
end
inlet.of = lsl_inlet(result{1}, 1);
disp(['--> found ' stream.of '...']);

% "closed vs. extension classifier" (ef)
disp(['Searching for ' stream.ce  ' stream...']);
result = {};
while isempty(result)
    result = lsl_resolve_byprop(lib,'name',stream.ce,1,1); 
end
inlet.ce = lsl_inlet(result{1}, 1);
disp(['--> found ' stream.ce '...']);

% "extension vs. flexion classifier" (ef)
disp(['Searching for ' stream.ef  ' stream...']);
result = {};
while isempty(result)
    result = lsl_resolve_byprop(lib,'name',stream.ef,1,1); 
end
inlet.ef = lsl_inlet(result{1}, 1);
disp(['--> found ' stream.ef '...']);

% trigger box
disp(['Searching for ' stream.triggerBox ' stream...']);
result = {};
while isempty(result)
    result = lsl_resolve_byprop(lib,'name',stream.triggerBox,1,1); end
inlet.triggerBox = lsl_inlet(result{1});
disp(['--> found ' stream.triggerBox '...']);

% create LSL marker stream for hand positions
info = lsl_streaminfo(lib,'HandPositionMarker','Markers',1,0,'cf_string','myuniquesourceid23443');
outlet = lsl_outlet(info);

%% establish connection to arduino

useServos = 0;
% {
useServos = 1;
delete(instrfind('Type', 'serial'));                                        % assure that no serial port is open anymore
s = serial('com6');                                                         % create new serial port object.
set(s,'BaudRate',9600);                                                     % use same baudrate specified in Arduino
fopen(s);                                                                   % open serial port
speed = 0.008;                          

% attach motors and bring them to default position
pause(2);                                                                   % give servo some time to initialize
fprintf(s, '%s\n','1')                                                      % attach servos
pause(2);
%}

%% load BAR figure

figH = figure(10);
subplot(1,3,1)
bar_of = bar(1);
axis([0 2 0 1]);
set(gca,'XTickLabel',{'O vs. F'},'fontsize',20);
thr_line_of = hline(settings.thr.of, ':');

subplot(1,3,2);
bar_ce = bar(1);
axis([0 2 0 1]);
set(gca,'XTickLabel',{'C vs. E'},'fontsize',20);
thr_line_ce = hline(settings.thr.ce, ':');
title('Classifier','fontsize',24);

subplot(1,3,3);
bar_ef = bar(1);
axis([0 2 0 1]);
set(gca,'XTickLabel',{'E vs. F'},'fontsize',20);
thr_line_ef = hline(settings.thr.ef, ':');
thr_line_fe = hline(settings.thr.fe, 'r:');

subplot(1,3,2);

%% wait until recording is started
disp('Press key, when recording is started.')
pause
disp('Ok, lets start.');

%% start training
% {

tmp.of = inlet.of.pull_sample();
tmp.ce = inlet.ce.pull_sample();
tmp.ef = inlet.ef.pull_sample();
pause(3);

dur = tic;
while toc(dur)<durT
    
    % state opened (critical phase)
    if strcmp(state,'ocp')
        
        % get new classifier values
        estimate.of = []; junk = inlet.of.pull_chunk(); while isempty(estimate.of); estimate.of = inlet.of.pull_sample(tol); end;
        estimate.ef = []; junk = inlet.ef.pull_chunk(); while isempty(estimate.ef); estimate.ef = inlet.ef.pull_sample(tol); end;
        estimate.of = estimate.of-1; estimate.ef = estimate.ef-1;

        subplot(1,3,2); title('Opened (critical phase)','fontsize',24);
        outlet.push_sample({'ocp'}); disp('ocp');
        set(bar_of,'YData',0); set(bar_ce,'YData',0); set(bar_ef,'YData',0); drawnow;

        tmpTicCP = tic;       
        while toc(tmpTicCP) < settings.CP && (estimate.ef<settings.thr.ef || estimate.of<settings.thr.of)

            tmpTic = tic; 
            % get new classifier values
            estimate.of = []; junk = inlet.of.pull_chunk(); while isempty(estimate.of); estimate.of = inlet.of.pull_sample(tol); end;
            estimate.ef = []; junk = inlet.ef.pull_chunk(); while isempty(estimate.ef); estimate.ef = inlet.ef.pull_sample(tol); end;
            estimate.of = estimate.of-1; estimate.ef = estimate.ef-1;
            
            % update bar
            set(bar_of,'YData',estimate.of); set(bar_ef,'YData',estimate.ef); drawnow;
 
            % check whether experimenter wants to pause
            tmpPause = inlet.triggerBox.pull_sample(0);    
            if ~isempty(tmpPause) & strcmp(tmpPause,'Pause')
                 currentState = state;
                 state = 'p'; break;
            end

            if rm.do && toc(rm.tic) > rm.dur
               rm.LED = ~rm.LED; rm.tic = tic; rm.idx = rm.idx+1;
               disp(['--> LED ' num2str(rm.LED) ', ' num2str(rm.idx) '. iteration']);
               if rm.LED; 
                   outlet.push_sample({['LED_on']}); 
                   if useServos; fprintf(s, '%s\n','4'); end;
               else
                   outlet.push_sample({['LED_off']});
                   if useServos; fprintf(s, '%s\n','5'); end;
               end
            end

            % check whether any task block is finished
            if rm.do && rm.idx >= rm.iterations || fc.do && toc(fc.tic) >= fc.dur || ac.do && toc(ac.tic) >= ac.dur
                if rm.do; rm.do = 0; disp('End of rm block! '); outlet.push_sample({'rm_end'});   end;
                if fc.do; fc.do = 0; disp('End of fc block! '); outlet.push_sample({'fc_end'}); end;
                if ac.do; ac.do = 0; disp('End of ac block! '); outlet.push_sample({'ac_end'});  end;
                state = 'p2';
                break;
            end 
            
            % wait x ms until new classification output is called
            while toc(tmpTic)<refClass; end;
            
        end;
        if strcmp(state,'p') || strcmp(state,'p2'); continue; end;  % check, if pause is desired

        % if applicable, allow for immediate flexion
        if settings.allowTrans & toc(tmpTicCP) < settings.CP
            if useServos; fprintf(s, '%s\n','2'); end;
            title('Flexion', 'fontsize',24); 
            set(bar_of,'YData', 0); set(bar_ce,'YData',0); set(bar_ef,'YData',0); drawnow;
            outlet.push_sample({'f'}); disp('f');
            tmpP = tic; while toc(tmpP)<(f); end;
            state = 'ccp';
        else
           while toc(tmpTicCP) < settings.CP; end;
           state = 'o';
           
        end
                  
    % state opened
    elseif strcmp(state,'o')
        
        % get new classifier value
        estimate.of = []; junk = inlet.of.pull_chunk(); while isempty(estimate.of); estimate.of = inlet.of.pull_sample(tol); end;
        estimate.of = estimate.of-1;
        
        title('Opened','fontsize',24);
        outlet.push_sample({'o'}); disp('o');        
        set(bar_of,'YData',0); set(bar_ce,'YData',0); set(bar_ef,'YData',0); drawnow;

        tmpTicO = tic;
        while estimate.of<settings.thr.of && toc(tmpTicO)

            tmpTic = tic; 
            
            % get new classifier values
            estimate.of = []; junk = inlet.of.pull_chunk(); while isempty(estimate.of); estimate.of = inlet.of.pull_sample(tol); end;
            estimate.of = estimate.of-1; 

            % check whether experimenter wants to pause
            tmpPause = inlet.triggerBox.pull_sample(0);    
            if ~isempty(tmpPause) & strcmp(tmpPause,'Pause')
                 currentState = state;
                 state = 'p'; break;
            end
            
            % check whether LED state has to be changed
            if rm.do && toc(rm.tic) > rm.dur
               rm.LED = ~rm.LED; rm.tic = tic; rm.idx = rm.idx+1;
               disp(['--> LED ' num2str(rm.LED) ', ' num2str(rm.idx) '. iteration']);
               if rm.LED; 
                   outlet.push_sample({['LED_on']}); 
                   if useServos; fprintf(s, '%s\n','4'); end;
               else
                   outlet.push_sample({['LED_off']});
                   if useServos; fprintf(s, '%s\n','5'); end;
               end
            end
    
            % check whether any task block is finished
            if rm.do && rm.idx >= rm.iterations || fc.do && toc(fc.tic) >= fc.dur || ac.do && toc(ac.tic) >= ac.dur
                if rm.do; rm.do = 0; disp('End of rm block! '); outlet.push_sample({'rm_end'});   end;
                if fc.do; fc.do = 0; disp('End of fc block! '); outlet.push_sample({'fc_end'}); end;
                if ac.do; ac.do = 0; disp('End of ac block! '); outlet.push_sample({'ac_end'});  end;
                state = 'p2';
                break;
            end
            
            % update bar
            set(bar_of,'YData', estimate.of); drawnow;
            
            % wait x ms until new classification output is called
            while toc(tmpTic)<refClass; end;
            
        end;
        if strcmp(state,'p') || strcmp(state,'p2'); continue; end;  % check, if pause is desired
        
        % conduct flexion
        if useServos; fprintf(s, '%s\n','2'); end;
        title('Flexion', 'fontsize',24); 
        set(bar_of,'YData', 0); set(bar_ce,'YData',0); set(bar_ef,'YData',0); drawnow;
        outlet.push_sample({'f'}); disp('f');
        
        tmpP = tic; while toc(tmpP)<(f); end;
        state = 'ccp';
    
    % state closed (critical phase)
    elseif strcmp(state,'ccp')
       
       % get new classifier values
       estimate.ce = []; junk = inlet.ce.pull_chunk(); while isempty(estimate.ce); estimate.ce = inlet.ce.pull_sample(tol); end;
       estimate.ef = []; junk = inlet.ef.pull_chunk(); while isempty(estimate.ef); estimate.ef = inlet.ef.pull_sample(tol); end;
       estimate.ce = estimate.ce-1; estimate.ef = estimate.ef-1;
       
       title('Closed (critical phase)','fontsize',24);
       outlet.push_sample({'ccp'}); disp('ccp');
       
       set(bar_of,'YData',0); set(bar_ce,'YData',0); set(bar_ef,'YData',0); drawnow;

       tmpTicCP = tic;
       
       while toc(tmpTicCP) < settings.CP && (estimate.ef>settings.thr.fe || estimate.ce<settings.thr.ce)

            tmpTic = tic; 
            
            % get new classifier values
            estimate.ce = []; junk = inlet.ce.pull_chunk(); while isempty(estimate.ce); estimate.ce = inlet.ce.pull_sample(tol); end;
            estimate.ef = []; junk = inlet.ef.pull_chunk(); while isempty(estimate.ef); estimate.ef = inlet.ef.pull_sample(tol); end;
            estimate.ce = estimate.ce-1; estimate.ef = estimate.ef-1;
           
            % update bar
            set(bar_ce,'YData', estimate.ce); set(bar_ef,'YData',estimate.ef); drawnow;
           
            % check whether experimenter wants to pause
            tmpPause = inlet.triggerBox.pull_sample(0);    
            if ~isempty(tmpPause) & strcmp(tmpPause,'Pause')
                 currentState = state;
                 state = 'p'; break;
            end
            
            % check whether LED state has to be changed
            if rm.do && toc(rm.tic) > rm.dur
               rm.LED = ~rm.LED; rm.tic = tic; rm.idx = rm.idx+1;
               disp(['--> LED ' num2str(rm.LED) ', ' num2str(rm.idx) '. iteration']);
               if rm.LED; 
                   outlet.push_sample({['LED_on']}); 
                   if useServos; fprintf(s, '%s\n','4'); end;
               else
                   outlet.push_sample({['LED_off']});
                   if useServos; fprintf(s, '%s\n','5'); end;
               end
            end

            % check whether any task block is finished
            if rm.do && rm.idx >= rm.iterations || fc.do && toc(fc.tic) >= fc.dur || ac.do && toc(ac.tic) >= ac.dur
                if rm.do; rm.do = 0; disp('End of rm block! '); outlet.push_sample({'rm_end'});   end;
                if fc.do; fc.do = 0; disp('End of fc block! '); outlet.push_sample({'fc_end'}); end;
                if ac.do; ac.do = 0; disp('End of ac block! '); outlet.push_sample({'ac_end'});  end;
                state = 'p2';
                break;
            end
            
            % wait x ms until new classification output is called
            while toc(tmpTic)<refClass; end;
            
        end;
        if strcmp(state,'p') || strcmp(state,'p2'); continue; end;  % check, if pause is desired
       
        % if applicable allow for immediate extension
        if settings.allowTrans & toc(tmpTicCP) < settings.CP
            title('Extension', 'fontsize',24); 
            set(bar_of,'YData', 0); set(bar_ce,'YData',0); set(bar_ef,'YData',0); drawnow;
            if useServos; fprintf(s, '%s\n','3'); end;
            outlet.push_sample({'e'}); disp('e');
            tmpP = tic; while toc(tmpP)<(f); end;
            state = 'ocp';
        else
           while toc(tmpTicCP) < settings.CP; end;
           state = 'c';
        end
 
    % state closed
    elseif strcmp(state,'c')
        
        % get new classifier values
        estimate.ce = []; junk = inlet.ce.pull_chunk(); while isempty(estimate.ce); estimate.ce = inlet.ce.pull_sample(tol); end;
        estimate.ce = estimate.ce-1; 
        
        title('Closed','fontsize',24);
        outlet.push_sample({'c'}); disp('c');
        
        set(bar_of,'YData',0); set(bar_ce,'YData',0); set(bar_ef,'YData',0); drawnow;
        
        tmpTicC = tic;
        while estimate.ce<settings.thr.ce && toc(tmpTicC)
            
            tmpTic = tic; 
            
            % get new classifier values
            estimate.ce = []; junk = inlet.ce.pull_chunk(); while isempty(estimate.ce); estimate.ce = inlet.ce.pull_sample(tol); end;
            estimate.ce = estimate.ce-1; 
            
            % update bar
            set(bar_ce,'YData',estimate.ce); drawnow;
            
            % check whether experimenter wants to pause
            tmpPause = inlet.triggerBox.pull_sample(0);    
            if ~isempty(tmpPause) & strcmp(tmpPause,'Pause')
                 currentState = state;
                 state = 'p'; break;
            end
            
            % check whether LED state has to be changed
            if rm.do && toc(rm.tic) > rm.dur
               rm.LED = ~rm.LED; rm.tic = tic; rm.idx = rm.idx+1;
               disp(['--> LED ' num2str(rm.LED) ', ' num2str(rm.idx) '. iteration']);
               if rm.LED; 
                   outlet.push_sample({['LED_on']}); 
                   if useServos; fprintf(s, '%s\n','4'); end;
               else
                   outlet.push_sample({['LED_off']});
                   if useServos; fprintf(s, '%s\n','5'); end;
               end
            end

            % check whether any task block is finished
            if rm.do && rm.idx >= rm.iterations || fc.do && toc(fc.tic) >= fc.dur || ac.do && toc(ac.tic) >= ac.dur
                if rm.do; rm.do = 0; disp('End of rm block! '); outlet.push_sample({'rm_end'});   end;
                if fc.do; fc.do = 0; disp('End of fc block! '); outlet.push_sample({'fc_end'}); end;
                if ac.do; ac.do = 0; disp('End of ac block! '); outlet.push_sample({'ac_end'});  end;
                state = 'p2';
                break;
            end

            % wait x ms until new classification output is called
            while toc(tmpTic)<refClass; end;
        end;
        if strcmp(state,'p') || strcmp(state,'p2'); continue; end;  % check, if pause is desired

        % conduct extension
        if useServos; fprintf(s, '%s\n','3'); end;
        title('Extension', 'fontsize',24); 
        set(bar_of,'YData', 0); set(bar_ce,'YData',0); set(bar_ef,'YData',0); drawnow;
        outlet.push_sample({'e'}); disp('e');
            
        tmpP = tic; while toc(tmpP)<(f); end;
        state = 'ocp';
    end
    
    % if a pause command has been send
    if strcmp(state,'p')
        state = currentState;
        rm.do = 0; fc.do = 0; ac.do = 0;
        disp(' ');
        disp('Make Pause / Adjust parameter: ')
        keyboard;
        
        % delete old threshold lines
        delete(thr_line_of);
        delete(thr_line_ce);
        delete(thr_line_ef);
        delete(thr_line_fe);
           
        % paint in new threshold lines
        subplot(1,3,1);
        thr_line_of = hline(settings.thr.of, ':');
        subplot(1,3,2);
        thr_line_ce = hline(settings.thr.ce, ':');
        subplot(1,3,3);
        thr_line_ef = hline(settings.thr.ef, ':');
        thr_line_fe = hline(settings.thr.fe, 'r:');
        subplot(1,3,2);
        
        % check what experimenter wants to do next
        disp(' ');
        disp('Send a trigger to LSL?')
        disp('--> 1: adjust parameter (ap)');
        disp('--> 2: rest some time, move some time (rm_begin)');
        disp('--> 3: follow commands (fc_begin)');
        disp('--> 4: announce commands (ac_begin)');
        disp('--> 5: other event');
        disp('--> 6: finish whole experiment');
        
        tmpEvent = input('Type input: ');
        disp(' ');
        if ~isempty(tmpEvent)
           if tmpEvent == 1
               outlet.push_sample({'ap'}); disp('ap');
           elseif tmpEvent == 2
               disp('Begin of rm block: Press continue to start.');
               state = 'o';
               if useServos; fprintf(s, '%s\n','3'); end; % bring hand into default condition
               while true
                    tmpContinue = inlet.triggerBox.pull_sample(0);    
                    if ~isempty(tmpContinue) & strcmp(tmpContinue,'Continue'); break; end
               end
               outlet.push_sample({'rm_begin'});
               disp(['--> LED ' num2str(rm.LED) ', ' num2str(rm.idx) '. iteration']);
               outlet.push_sample({['LED_on']});
               if useServos; fprintf(s, '%s\n','5'); end;
               rm.do = 1; rm.tic = tic;
           elseif tmpEvent == 3
               disp('Begin of fc block: Press continue to start.');
               state = 'o';
               if useServos; fprintf(s, '%s\n','3'); end; % bring hand into default condition
               while true
                    tmpContinue = inlet.triggerBox.pull_sample(0);    
                    if ~isempty(tmpContinue) & strcmp(tmpContinue,'Continue'); break; end
               end               
               outlet.push_sample({'fc_begin'}); 
               fc.do = 1; fc.tic = tic;
           elseif tmpEvent == 4
               disp('Begin of ac block: Press continue to start.');
               state = 'o';
               if useServos; fprintf(s, '%s\n','3'); end; % bring hand into default condition
               while true
                    tmpContinue = inlet.triggerBox.pull_sample(0);    
                    if ~isempty(tmpContinue) & strcmp(tmpContinue,'Continue'); break; end
               end 
               outlet.push_sample({'ac_begin'});
               ac.do = 1; ac.tic = tic;
           elseif tmpEvent == 5
               tmpEvent = input('Type in special event (as a string):')
               outlet.push_sample({tmpEvent}); disp(tmpEvent);
           elseif tmpEvent == 6
               break;
           end
        end   
    end
    
    % if a block is over
    if strcmp(state,'p2')
        if useServos; fprintf(s, '%s\n','3'); end;                          % bring hand into default condition 
        pause(0.05);
        ledCounter = 1; 
        disp('P2: Press continue to proceed...')
        state = 'p';
        while true
            tmpContinue = inlet.triggerBox.pull_sample(0);    
            if ~isempty(tmpContinue) & strcmp(tmpContinue,'Continue')
                break;
            end
            pause(0.25);
            if useServos && mod(ledCounter,2)==0; fprintf(s, '%s\n','4'); 
            elseif useServos && mod(ledCounter,2)==1; fprintf(s, '%s\n','5');
            end;
            ledCounter = ledCounter+1;
        end
    end
end

if useServos; fprintf(s, '%s\n','0'); end;                                  % switch off LED
delete(instrfind('Type', 'serial'));                                        % remove serial port
disp('Waiting for Syringe')
pause();
outlet.push_sample({'Syringe'});    
disp('Ende des Blocks, vielen Dank!');