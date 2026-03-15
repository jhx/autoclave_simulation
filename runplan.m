1;

% autoclave parameters
ac_cycle = [2 8 2; 2 8 4; 4 8 2]; % matrix containing A/C cycles SM1 SM2 Ace

% PULASKI -- 2 lines: SM1, SM2
site = 'Pulaski';

% Tacoma_2 -- 1 line: SM2
% site = 'Tacoma_2';

% load site-specific run plan
printf('%s- Loading run plan "%s"\n', blanks(2), ['runplan_' site])
feval(['runplan_' site])
