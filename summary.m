1;

printf('\n\n\n------------------------- SIMULATION SUMMARY -------------------------\n');

printf('Site: %s%s%s\n', site, blanks(38), datestr(now, 31));
printf('Simulation Duration:  %4.1f days (%5.1f hrs or %d min)\n', i/1440, i/60, i);
printf('Elapsed acc. to etime(): %4.1f min (%4.1f sec).\n', ...
  etime(t1, t0)/60, etime(t1, t0));
printf('Elapsed acc. to cputime(): %4.1f min (%4.1f sec).\n', ...
  (tc1-tc0)/60, tc1-tc0);
printf('Written by Doc Walker (19 Mar 2008)\n');
printf('\n');

mpn = {};

for m = 1:length(machine)
  printf('\n');
  lmp = log_machine{m}.parameters;
  if (lmp.hatscheck)
    printf('%s: %1d tub Hatscheck, %2d" wide, %4.1f'' size roller, %1d stack(s)/drop\n',
      lmp.name, lmp.tubs, lmp.width, lmp.src, lmp.stacks);
    for n = 1:length(log_machine{m}.runplan)
      lmr = log_machine{m}.runplan{n};
      if (lmr.running)
        lmrp = lmr.product;
        printf(' #%d: %s (%4.2f"x%5.2f"x%2.0f'') for %4.1f hrs (%d min)\n',
          n, lmrp.name, lmrp.thickness, lmrp.width, lmrp.length/12,
          lmr.duration/60, lmr.duration);
        printf('     %d revs/%3d fpm, %4.2fmm/tub, %d%% scrap, %d%% delay\n',
          revs(lmp, lmrp), lmrp.felt_speed, lmrp.film_build, lmr.waste*100, lmr.delay*100);
        printf('     %4.1f min/drop, %2.0f hr precure, %4.1f sf/sheet, %d sheets/stack\n',
          lmr.interval, lmrp.precure/60, sf_sheet(lmp, lmrp), lmrp.sheets);
        printf('     %5.1f sf/stack, %d stacks/train, %d-%d-%d A/C cycle\n',
          sf_stack(lmp, lmrp), lmr.stacks_train, ac_cycle(lmrp.ac_cycle, :));
        printf('     %d min to load A/C, %d min to unload A/C\n', ...
          k_ac_load_time, k_ac_unload_time);

       % printf('     %5.2f min/drop, %2.0f hr precure\n', lmr.interval, lmrp.precure/60);
       % printf('     %d sheets/stack, %d stacks/train, %d-%d-%d A/C cycle\n',
       %   lmrp.sheets, lmr.stacks_train, ac_cycle(lmrp.ac_cycle, :));
      else
        lmra = lmr.activity;
        printf(' #%d: %s for %4.1f hrs (%d min)\n',
          n, lmra.name, lmr.duration/60, lmr.duration);
      endif
    endfor
  else
    printf('%s: non-Hatscheck, %2d" wide, %1d stack(s)/drop\n',
      lmp.name, lmp.width, lmp.stacks);
    for n = 1:length(log_machine{m}.runplan)
      lmr = log_machine{m}.runplan{n};
      if (lmr.running)
        lmrp = lmr.product;
        printf(' #%d: %s (%4.2f"x%5.2f"x%2.0f'') for %4.1f hrs (%d min)\n',
          n, lmrp.name, lmrp.thickness, lmrp.width, lmrp.length/12,
          lmr.duration/60, lmr.duration);
        printf('     %d%% scrap, %d%% delay\n', lmr.waste*100, lmr.delay*100);
        printf('     %4.1f min/drop, %2.0f hr precure, %4.1f sf/sheet, %d sheets/stack\n',
          lmr.interval, lmrp.precure/60, sf_sheet(lmp, lmrp), lmrp.sheets);
        printf('     %5.1f sf/stack, %d stacks/train, %d-%d-%d A/C cycle\n',
          sf_stack(lmp, lmrp), lmr.stacks_train, ac_cycle(lmrp.ac_cycle, :));
      else
        lmra = lmr.activity;
        printf(' #%d: %s for %4.1f hrs (%d min)\n',
          n, lmra.name, lmr.duration/60, lmr.duration);
      endif
    endfor
  endif
  mpn{end+1} = machine{m}.parameters.name;
endfor


% precure (current)
printf('\nStacks Currently Precuring')
for m = 1:length(machine)
  printf('\n%s (%d stacks): ', log_machine{m}.parameters.name, length(q_precuring{m}));
  if (length(q_precuring{m} > 0))
    stacks = unique(q_precuring{m}(:,1));
    printf('%d ', stacks);
    printf('\n');
  endif
  printf('\n');
endfor


% precure (autoclave backlog)
printf('\nPrecured Stacks / Autoclave Backlog')
if length(q_precured) == 0
  printf('\n(empty)')
endif

for p = 1:length(q_precured)
  printf('\nPC%2d %s (%2d stacks): ', p, log_machine{q_precured{p}.machine}.parameters.name, length(q_precured{p}.stacks));
  stacks = unique(q_precured{p}.stacks);

  for s = 1:length(stacks)
    printf(' %d', stacks(s));
  endfor

endfor
printf('\n')


% autoclaves
printf('\nAutoclaves')
for a = 1:length(q_autoclave)
  if (!isinf(q_autoclave(a).done) || any(autoclave_lifo == a))
    if q_autoclave(a).cycle_id == 0 || q_autoclave(a).machine == 0 || ...
        isempty(q_autoclave(a).machine)
      name = '   ';
    else
      name = log_machine{q_autoclave(a).machine}.parameters.name;
    endif
    printf('\nAC%2d %s (%2d stacks): ', a, name, length(q_autoclave(a).stacks));
    stacks = unique(q_autoclave(a).stacks);
    for s = 1:length(stacks)
      printf(' %5d', stacks(s));
    endfor
  endif
endfor


printf('\n\n');
% mpn = {machine{1}.parameters.name, machine{2}.parameters.name, ...
%   machine{3}.parameters.name, 'TTL'};
mpn{end+1} = 'TTL';
printf('    Stacks Produced  Stacks done PC    Ld     MMSF Produced\n');
printf('    Stacks in PC     Stacks in A/C    Uld     MMSTDF Produced\n');
printf('Day %2s %2s %2s %2s  %2s %2s %2s %2s  A/C     %2s    %2s    %2s    %2s\n', mpn{:}, mpn{:}, mpn{:});
printf('----------------------------------------------------------------------\n');
for d = 1:log_day
  stacks = [log_daily(d).machine.stacks_produced];
  msf = [log_daily(d).machine.sf_produced]/1000;
  mstdft = [log_daily(d).machine.stdft_produced]/1000;
  pcing = [log_daily(d).machine.stacks_precuring];
  pced = [log_daily(d).machine.stacks_precured];
  ac = [log_daily(d).machine.stacks_autoclave];
  tl = log_daily(d).autoclaves_loaded;
  tu = log_daily(d).autoclaves_unloaded;
  printf('%2d  %3d %3d %3d %3d  %3d %3d %3d %3d   %2d  %6.1f %6.1f %6.1f %6.1f\n',
    d, stacks, sum(stacks), pced, sum(pced), tl, msf, sum(msf));
  printf('    %3d %3d %3d %3d  %3d %3d %3d %3d   %2d  %6.1f %6.1f %6.1f %6.1f\n',
    pcing, sum(pcing), ac, sum(ac), tu, mstdft, sum(mstdft));
  printf('----------------------------------------------------------------------\n');
endfor

% add length(wip), autoclaves utilized, max/mean 10'/12' pallets in use, log_precure
