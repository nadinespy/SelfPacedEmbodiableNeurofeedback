% Function for the performance analysis
% Function to find the relevant intervals for one chosen command (eg. 1,3, or 5)
% Input arguments: 
% 1. COMMAND or ANNOUNCE matrix (from script performanceAnalysis_generateCOMMAND/ performanceAnalysis_generateANNOUNCE) 
% 2. the command to look for: 1 = close, 3 = open  or 5 = grasp
% Output: Matrix command_ranges, needed for the following function find_commans_pattern_in_range

function [command_ranges] = find_command_index_ranges(trigger_matrix, command_to_find)
	trigger_type = trigger_matrix(:,1);
	command_beginnings = find(trigger_type == command_to_find);
	possible_command_endings = find(trigger_type == 1 | trigger_type == 3 | trigger_type == 5);
	possible_command_endings = [possible_command_endings; length(trigger_type)];
	command_ranges = nan(length(command_beginnings), 2);
	for command_range_index = 1:length(command_beginnings);
		command_beginning = command_beginnings(command_range_index);
		command_ending_index = find(possible_command_endings > command_beginning, 1);
        command_ending = possible_command_endings(command_ending_index);
        content_of_ending = trigger_type(command_ending);
        if isempty(content_of_ending) == 1
           command_ranges = command_ranges(1:end-1,:);
        elseif content_of_ending == 1 || content_of_ending == 3 || content_of_ending == 5
            command_ending = command_ending -1;
        end
		command_ranges(command_range_index,:) = [command_beginning, command_ending];
	end
end
	
	
