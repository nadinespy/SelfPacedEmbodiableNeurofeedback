% Function for the performance analysis
% Function to generate the success patterns for one specific command
% Input arguments:
% 1. COMMAND or ANNOUNCE matrix (from script performanceAnalysis_generateCOMMAND/_generateANNOUNCE) 
% 2. command specific command_ranges (output of function find_command_index_ranges)
% 3. Number of Movements to accomplisch the command close/ open = 1, grasp = 2
% Output: 
% 1. Success-array for movement phases (1 = success, 0 = failure)
% 2. Success-array for rest phases (1 = success, 0 = failure)


function [movement_phases, rest_phases] = find_command_pattern_in_range(trigger_matrix, command_ranges, number_actions_to_finish)
	movement_phases = [];
	rest_phases = [];
	for range_index = 1:length(command_ranges(:,1))
		trigger_start = command_ranges(range_index, 1);
        trigger_start = trigger_start + 1; % + 1, because the first position is the command (e.g. 5) and is not included into the movement phase
		trigger_end = command_ranges(range_index, 2);
		trigger_area = trigger_matrix(trigger_start:trigger_end, 1);
		accomplish_index = find(trigger_area == 2 | trigger_area == 4, number_actions_to_finish);
        if  number_actions_to_finish > length(accomplish_index) && isempty(trigger_area) == 0 % in case no movement occurs in movementphase (or only one in grasp-task)
            accomplish_index = length(trigger_area);
        end 
        accomplish_index = max(accomplish_index);
		movement_phase = false(accomplish_index, 1); 
		movement_phase(trigger_area(1:accomplish_index) == 2) = true; 
		movement_phase(trigger_area(1:accomplish_index) == 4) = true;
        rest_phase_begin = accomplish_index + 1;
		rest_phase = false(length(trigger_area)-accomplish_index, 1);
		rest_phase(trigger_area(rest_phase_begin:end) == 6) = true;
		movement_phases = [movement_phases; movement_phase];
		rest_phases = [rest_phases; rest_phase];
	end
end