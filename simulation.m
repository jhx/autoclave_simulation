1;

% simulation
t0=clock();
tc0=cputime();

for i = 1:k_duration
  if (mod(i, 1*hour) == 1)
    printf('.');
    fflush(1);
  endif
  % setup log for each day on minute #1 of day
  if (mod(i, 1*day) == 1)
    ++log_day;
    log_daily = [log_daily log_daily_template];
    if (log_day > 1)
      for m = 1:length(machine)
        log_daily(log_day).machine(m).stacks_precuring = ...
          [log_daily(log_day-1).machine(m).stacks_precuring];
        log_daily(log_day).machine(m).stacks_precured = ...
          [log_daily(log_day-1).machine(m).stacks_precured];
        log_daily(log_day).machine(m).stacks_autoclave = ...
          [log_daily(log_day-1).machine(m).stacks_autoclave];
      endfor
      printf('%d', log_day);
	  fflush(1);
    endif
  endif
  
  for m = 1:length(machine)
    % calculate statistics each day
    mr = machine{m}.runplan{1};
    if (mr.running && ++machine{m}.runplan{1}.acc >= mr.interval)
      machine{m}.runplan{1}.acc -= mr.interval;
      p = mr.product.precure;
      
      # append stack(s) to precure queue
      for n = 1:machine{m}.parameters.stacks
        q_precuring{m} = [q_precuring{m}; i i+p];
        ++log_daily(log_day).machine(m).stacks_produced;
        log_daily(log_day).machine(m).sf_produced += ...
          sf_stack(machine{m}.parameters, mr.product);
        log_daily(log_day).machine(m).stdft_produced += stdft(mr.product)* ...
          sf_stack(machine{m}.parameters, mr.product);
        ++log_daily(log_day).machine(m).stacks_precuring;
      endfor
    
      % fix where stacks/train is pulled from;
      % also add threshold for making short train for excessive down day or
      % product changeover to new autoclave cycle
      % assemble precure into blocks of stacks for autoclave queue
      s = mr.stacks_train;
      while (rows(q_precuring{m}) >= s && i >= q_precuring{m}(s, 2))
        c = length(q_precured);
        q_precured{c+1}.stacks = [q_precuring{m}(1:s, 1)];
        q_precured{c+1}.cycle = mr.product.ac_cycle;
        q_precured{c+1}.machine = m;
        q_precuring{m}(1:s, :) = [];
        log_daily(log_day).machine(m).stacks_precured += s;
        log_daily(log_day).machine(m).stacks_precuring -= s;
        % need to fix problem where newest stacks will always move to front
        % of queue if no autoclaves are available
        % (temporarily disabled)
        if (mr.product.ac_priority && false)
          q_precured = q_precured([c+1 1:c]);
        endif
      endwhile
      journal{end+1} = sprintf('%11d: %s produced %1d stack(s); precure complete @ %d', ...
        i, machine{m}.parameters.name, machine{m}.parameters.stacks, i+p);
    endif
    
    if (i >= mr.done)
      % rotate machine{m}.runplan
      machine{m}.runplan = machine{m}.runplan([2:length(machine{m}.runplan) 1]);
      machine{m}.runplan{1}.done = machine{m}.runplan{1}.duration + i;
      mr = machine{m}.runplan{1};
      if (mr.running)
        machine{m}.runplan{1}.acc = 0;
        journal{end+1} = sprintf('%11d: %s: %s (%5.2f in, %d%% waste, %d%% delay) until %d', ...
          i, machine{m}.parameters.name, mr.product.name, mr.product.width, ...
          round(100*mr.waste), round(100*mr.delay), mr.done);
      else
        journal{end+1} = sprintf('%5d-%5d: %s: %s', ...
          i,  ...
          machine{m}.runplan{1}.done,  ...
          machine{m}.parameters.name,  ...
          mr.activity.name);
      endif
    endif
  endfor
  
  % check whether autoclave is ready to be unloaded
  if (i >= min([q_autoclave.done]) && i >= ac_ok_to_turn)
    a = find(i >= [q_autoclave.done])(1);
    
    % transfer from autoclave to WIP
    wip = [wip q_autoclave(a).stacks'];
    
    % update statistics
    qa = q_autoclave(a);
    log_daily(log_day).machine(qa.machine).stacks_autoclave -= length(qa.stacks);
    ++log_daily(log_day).autoclaves_unloaded;
    
    % remove stacks from autoclave, reset cycle, queue timeout
    q_autoclave(a).cycle_id = 0;
    q_autoclave(a).cycle_seq = [];
    q_autoclave(a).cycle_dur = 0;
    q_autoclave(a).done = Inf;
    q_autoclave(a).stacks = [];
    q_autoclave(a).machine = 0;
    
    % set autoclave turn timeout so next train waits until turn is complete
    ac_ok_to_turn = i+k_ac_unload_time;
    
    % add current autoclave vessel to beginning of sequence to mark it as unloaded
    autoclave_lifo = [a autoclave_lifo];
    
    journal{end+1} = sprintf('%5d-%5d: Unloaded #%d autoclave (No. %d)', ...
      i, ac_ok_to_turn, a, log_daily(log_day).autoclaves_unloaded);
  endif
  
  % check whether turn time is cleared and an autoclave vessel is available
  if (i >= ac_ok_to_turn && length(autoclave_lifo) > 0 && length(q_precured) > 0)
    a = autoclave_lifo(1);
    qp = q_precured{1};
    
    % load current autoclave with oldest precure stacks
    q_autoclave(a).stacks = q_precured{1}.stacks;
    q_autoclave(a).cycle_id = q_precured{1}.cycle;
    q_autoclave(a).cycle_seq = ac_cycle(q_autoclave(a).cycle_id, :);
    q_autoclave(a).cycle_dur = sum(q_autoclave(a).cycle_seq)*60;
    q_autoclave(a).machine = q_precured{1}.machine;
    
    % set autoclave turn timeout so next train waits until turn is complete
    ac_ok_to_turn = i+k_ac_load_time;
    
    % set current autoclave queue timeout
    q_autoclave(a).done = ac_ok_to_turn+q_autoclave(a).cycle_dur;
    
    % update statistics
    qa = q_autoclave(a);
    log_daily(log_day).machine(qa.machine).stacks_precured -= length(qa.stacks);
    log_daily(log_day).machine(qa.machine).stacks_autoclave += length(qa.stacks);
    ++log_daily(log_day).autoclaves_loaded;
    
    journal{end+1} = sprintf('%5d-%5d: Loaded AC%d autoclave on %d-%d-%d cycle; cook complete @ %d (No. %d)', ...
      i, ac_ok_to_turn, a, q_autoclave(a).cycle_seq, q_autoclave(a).done,
      log_daily(log_day).autoclaves_loaded);
    
    % remove stacks from precure
    q_precured(1) = [];
    
    % remove current autoclave vessel from sequence to mark it as loaded
    autoclave_lifo(1) = [];
    
  endif
  
  % calculate statistics every 10 cycles
  if (mod(i, 1000) == 0)
    log_precure = [log_precure cellfun('rows', q_precuring)'];
    log_daily(log_day).pallet_12ft_in_use = [log_daily(log_day).pallet_12ft_in_use sum(
      [log_daily(log_day).machine(1:length(machine)).stacks_precuring]+
      [log_daily(log_day).machine(1:length(machine)).stacks_precuring]+
      [log_daily(log_day).machine(1:length(machine)).stacks_autoclave])];
    % log_daily(log_day).pallet_10ft_in_use = [log_daily(log_day).pallet_10ft_in_use sum(
    %   [log_daily(log_day).machine(3).stacks_precuring]+
    %   [log_daily(log_day).machine(3).stacks_precuring]+
    %   [log_daily(log_day).machine(3).stacks_autoclave])];
    log_daily(log_day).autoclaves_in_use = [log_daily(log_day).autoclaves_in_use
      sum([q_autoclave.cycle_id]>0)];
  endif
  
endfor

t1=clock();
tc1=cputime();

% END of working code






% need to redo pressure curve calculation to be more efficient
% calculate pressure curve for each cycle type
% n=1;
% charge=ac_cycle(n, 1)*60;
% cook=ac_cycle(n, 2)*60;
% discharge=ac_cycle(n, 3)*60;
% ac_sm1_pressure = (ac_max_pressure(n)/charge):(ac_max_pressure(n)/charge):ac_max_pressure(n);
% ac_sm1_pressure(charge+1:charge+cook) = ac_max_pressure(n);
% ac_sm1_pressure(charge+cook:charge+cook+discharge) = \
%  ac_max_pressure(n):-(ac_max_pressure(n)/discharge):0;

% n=2;
% charge=ac_cycle(n, 1)*60;
% cook=ac_cycle(n, 2)*60;
% discharge=ac_cycle(n, 3)*60;
% ac_sm2_pressure = (ac_max_pressure(n)/charge):(ac_max_pressure(n)/charge):ac_max_pressure(n);
% ac_sm2_pressure(charge+1:charge+cook) = ac_max_pressure(n);
% ac_sm2_pressure(charge+cook:charge+cook+discharge) = \
%   ac_max_pressure(n):-(ac_max_pressure(n)/discharge):0;

% n=3;
% charge=ac_cycle(n, 1)*60;
% cook=ac_cycle(n, 2)*60;
% discharge=ac_cycle(n, 3)*60;
% ac_ace_pressure = (ac_max_pressure(n)/charge):(ac_max_pressure(n)/charge):ac_max_pressure(n);
% ac_ace_pressure(charge+1:charge+cook) = ac_max_pressure(n);
% ac_ace_pressure(charge+cook:charge+cook+discharge) = \
%   ac_max_pressure(n):-(ac_max_pressure(n)/discharge):0;












#  # calculate pressure for each autoclave
#  for n = 1:11
#    # retrieve indices for autoclaves using SM1 cycle
#    idx = find(q_ac(1, :)==1);
#    if (length(idx) > 0)
#      idx_press = sum(ac_cycle(q_ac(1, idx), :)')*60-q_ac(2, idx)+i;
#      idx_press(idx_press < 1) = 1;
#      idx_press(idx_press > length(ac_sm1_pressure)) = length(ac_sm1_pressure);
#      ac_pressure(idx) = ac_sm1_pressure(idx_press);
#    endif
#    
#    # retrieve indices for autoclaves using SM2 cycle
#    idx = find(q_ac(1, :)==2);
#    if (length(idx) > 0)
#      idx_press = sum(ac_cycle(q_ac(1, idx), :)')*60-q_ac(2, idx)+i;
#      idx_press(idx_press < 1) = 1;
#      idx_press(idx_press > length(ac_sm2_pressure)) = length(ac_sm2_pressure);
#      ac_pressure(idx) = ac_sm2_pressure(idx_press);
#    endif
#  endfor
