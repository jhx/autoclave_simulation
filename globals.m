1;

% disable screen pager
page_screen_output(0);

% enable immediate output to screen
page_output_immediately(1);

hour = hours = 60;
day = days = 24*hours;

% miscellaneous simulation constants
k_ac_load_time = 15;    % number of minutes it takes to load autoclave train
k_ac_unload_time = 15;  % number of minutes it takes to unload autoclavetrain

k_start_time = 0700;    % offset in 24h format
% all autoclaves assumed to be same length for now; need to fix this
k_autoclave_length = 175; % autoclave length, [ft]
k_pallet_spacing = 2 + 2; % pallet is __" longer than product + __" clearance between

% precure queues
q_precured = {}; % stack FIFO (14 ea for SM, 16 ea for Ace) ready for autoclaves

% autoclave queues & constants
clear q_autoclave;
q_autoclave(1:20) = struct(
  'done',       Inf,
  'cycle_id',   0,
  'cycle_seq',  [],
  'cycle_dur',  0,
  'stacks',     []);

ac_pressure_log = []; % matrix containing record of A/C pressures over time
ac_ok_to_turn = 0;    % OK to turn next train once i exceeds this number

% logs, reporting tools
journal = {};                % transaction record
wip = [];                    % vector containing all WIP produced
log_precure = [];            % vector containing periodic count of all precure
log_daily = [];              % struct containing log data for each day
log_daily_template = struct(
  'autoclaves_in_use',   [],
  'autoclaves_loaded',  0,
  'autoclaves_unloaded',0,
  'pallet_12ft_in_use', [],
  'pallet_10ft_in_use', [],
  'machine',            struct(
    'stacks_produced',          0,
    'sf_produced',              0,
    'stdft_produced',           0,
    'stacks_precuring',         0,
    'stacks_precured',          0,
    'stacks_autoclave',         0));

log_daily_template.autoclaves_in_use = 0;
log_daily_template.autoclaves_loaded = 0;
log_daily_template.autoclaves_unloaded = 0;
log_daily_template.pallet_12ft_in_use = [];
log_daily_template.pallet_10ft_in_use = [];

