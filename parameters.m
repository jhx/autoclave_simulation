1;

% machine parameters
hatscheck_9x5 = struct(
  'name',       'hatscheck_9x5',
  'hatscheck',  1,
  'width',      60,
  'src',        24.5,
  'tubs',       9,
  'stacks',     2);

hatscheck_8x5 = struct(
  'name',       'hatscheck_8x5',
  'hatscheck',  1,
  'width',      60,
  'src',        24.5,
  'tubs',       8,
  'stacks',     2);

hatscheck_8x4 = struct(
  'name',       'hatscheck_8x4',
  'hatscheck',  1,
  'width',      48,
  'src',        24.5,
  'tubs',       8,
  'stacks',     2);

hatscheck_6x5 = struct(
  'name',       'hatscheck_6x5',
  'hatscheck',  1,
  'width',      60,
  'src',        24.5,
  'tubs',       6,
  'stacks',     2);

hatscheck_5x4 = struct(
  'name',       'hatscheck_5x4',
  'hatscheck',  1,
  'width',      48,
  'src',        12.5,
  'tubs',       5,
  'stacks',     2);

nil = struct(
  'name',       'n/a',
  'hatscheck',  1,
  'width',      0,
  'src',        0,
  'tubs',       0,
  'stacks',     0);

nlm = struct(
  'name',       'NLM',
  'hatscheck',  0,
  'width',      24,
  'stacks',     1,
  'sf',         80000);


% activity parameters
changeover = struct(
  'name',       'Changeover');
  
sizechange = struct(
  'name',       'Size Change');
  
washup = struct(
  'name',       'Washup');

idle = struct(
  'name',       'Idle');
  

% product parameters
ezgrid = struct(
  'name',       'EZ-Grid',
  'width',      60,
  'length',     144,
  'thickness',  4/16,
  'felt_speed', 350,
  'film_build', 0.33,
  'sheets',     120,
  'precure',    12*hours,
  'ac_cycle',   1,
  'ac_priority',0,
  'pressure',   130);
  
plank = struct(
  'name',       'Plank',
  'width',      8.25,
  'length',     144,
  'thickness',  5/16,
  'felt_speed', 310,
  'film_build', 0.44,
  'sheets',     96,
  'precure',    12*hours,
  'ac_cycle',   1,
  'ac_priority',0,
  'pressure',   130);

g2 = struct(
  'name',       'G2',
  'width',      60,
  'length',     144,
  'thickness',  1/2,
  'felt_speed', 310,
  'film_build', 0.44,
  'sheets',     78,
  'precure',    12*hours,
  'ac_cycle',   1,
  'ac_priority',0,
  'pressure',   130);
  
md = struct(
  'name',       'MD Trim',
  'width',      3.5,
  'length',     144,
  'thickness',  7/16,
  'felt_speed', 310,
  'film_build', 0.44,
  'sheets',     72,
  'precure',    12*hours,
  'ac_cycle',   1,
  'ac_priority',0,
  'pressure',   130);
  
hld = struct(
  'name',       'HLD Trim',
  'width',      3.5,
  'length',     144,
  'thickness',  3/4,
  'felt_speed', 310*6/7,
  'film_build', (3/4)*25.4/(6*8),
  'sheets',     42,
  'precure',    12*hours,
  'ac_cycle',   2,
  'ac_priority',0,
  'pressure',   130);
  
flexld = struct(
  'name',       'FleXLD Trim',
  'width',      3.5,
  'length',     120,
  'thickness',  1,
  'sheets',     35,
  'precure',    0*hours,
  'ac_cycle',   3,
  'ac_priority',1,
  'pressure',   75);
  
xld = struct(
  'name',       'XLD Trim',
  'width',      7.25,
  'length',     120,
  'thickness',  1,
  'sheets',     35,
  'precure',    0*hours,
  'ac_cycle',   3,
  'ac_priority',1,
  'pressure',   130);
  
rx1 = struct(
  'name',       'Rx.1',
  'width',      60,
  'length',     144,
  'thickness',  1/2,
  'felt_speed', 98*10/3,
  'film_build', 0.5,
  'sheets',     100,
  'precure',    12*hours,
  'ac_cycle',   1,
  'ac_priority',0,
  'pressure',   130);
  
rx2 = struct(
  'name',       'Rx.2',
  'width',      60,
  'length',     144,
  'thickness',  1/2,
  'felt_speed', 98*10/3*6/8/2,
  'film_build', 0.5,
  'sheets',     100,
  'precure',    12*hours,
  'ac_cycle',   1,
  'ac_priority',0,
  'pressure',   130);


% moved to runplan file
% autoclave parameters
% autoclave_lifo = [1 4 7 10 2 5 8 11 3 6 9]; % LIFO queue of autoclaves to be loaded
ac_cycle = [2 8 2; 2 8 4; 4 8 2]; % matrix containing A/C cycles SM1 SM2 Ace

% retrieve pre-saved run plan sequence
% 3 lines: SM1, SM2, NLM
% runplan0

% 2 lines: SM1, SM2
% runplan1

% PULASKI -- 2 lines: SM1, SM2
site = 'Pulaski';

% Tacoma_2 -- 1 line: SM2
% site = 'Tacoma_2';

% load site-specific run plan
printf('%s- Loading run plan "%s"\n', blanks(2), ['runplan_' site])
feval(['runplan_' site])

% initial calculations of stack drop intervals for each machine, product
printf('%s- Machine Configuration\n', blanks(2))
for m = 1:length(machine)
  for n = 1:length(machine{m}.runplan)
    machine{m}.runplan{n}.running = isfield(machine{m}.runplan{n},'product');
    machine{m}.runplan{n}.done = machine{m}.runplan{n}.duration;
    if (machine{m}.runplan{n}.running)
      p = machine{m}.runplan{n}.product;
      w = machine{m}.runplan{n}.waste;
      d = machine{m}.runplan{n}.delay;
      machine{m}.runplan{n}.stacks_train = floor(k_autoclave_length*12/ ...
        (p.length+k_pallet_spacing));
      machine{m}.runplan{n}.interval = interval(machine{m}.parameters, p)/(1-w)/(1-d);
      machine{m}.runplan{n}.acc = 0;
    endif
  endfor
  
  mr = machine{m}.runplan{1};
  if (mr.running)
    journal{end+1} = ...
      sprintf('%11d: %s: %s (%5.2f in, %d%% waste, %d%% delay) until %d', ...
      m, machine{m}.parameters.name, mr.product.name, mr.product.width, ...
      round(100*mr.waste), round(100*mr.delay), mr.done);
      printf('%s%s: %s (%5.2f in, %d%% waste, %d%% delay) until %d min elapsed\n', ...
        blanks(4), machine{m}.parameters.name, mr.product.name, ...
        mr.product.width, round(100*mr.waste), round(100*mr.delay), mr.done)
  else
    journal{end+1} = sprintf('%11d: %s: %s until %d', ...
      m, machine{m}.parameters.name, mr.activity.name, mr.done);
    printf('%s%s: %s until %d min elapsed\n', ...
      blanks(4), machine{m}.parameters.name, mr.activity.name, mr.done)
  endif
    
  % initialize log_daily_template
  log_daily_template.machine(m).stacks_produced = 0;
  log_daily_template.machine(m).sf_produced = 0;
  log_daily_template.machine(m).stdft_produced = 0;
  log_daily_template.machine(m).stacks_precuring = 0;
  log_daily_template.machine(m).stacks_precured = 0;
  log_daily_template.machine(m).stacks_autoclave = 0;
endfor

printf('%sAutoclaves (%d), Queue: ', blanks(4), length(autoclave_lifo));
printf('%d ', autoclave_lifo);
printf('\n');

q_precuring = cell(1, length(machine)); % stack FIFO for product currently in precure

% set inital log parameters
log_machine = machine; % maintain snapshot of original runplan for summary page
log_day = 0;

% set simulation duration
k_duration = 14*days;   % duration of simulation
printf('%s- Simulation Configuration\n', blanks(2));
printf('%sDuration: %4.1f day(s)\n', blanks(4), k_duration/days);
