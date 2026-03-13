% TACOMA 2
% run plan sequence for each machine
m = 0;

% autoclave parameters
autoclave_lifo = [1 4 2 5 3 6]; % LIFO queue of autoclaves to be loaded
k_autoclave_length = 200; % autoclave length, [ft]


% BEGIN run plan for next machine
n = 0;
machine{++m}.parameters = hatscheck_9x5;
machine{m}.parameters.name = 'SM2';

machine{m}.runplan{++n} = struct(
  'activity',   idle,
  'duration',   0*hours);

machine{m}.runplan{++n} = struct(
  'product',    plank,
  'duration',   3*days,
  'waste',      2/100,
  'delay',      3/100);
machine{m}.runplan{n}.product.felt_speed = 138.5*2;
machine{m}.runplan{n}.product.sheets = 92;

machine{m}.runplan{++n} = struct(
  'activity',   washup,
  'duration',   8*hours);

machine{m}.runplan{++n} = struct(
  'product',    plank,
  'duration',   3*days+16*hours,
  'waste',      2/100,
  'delay',      3/100);
machine{m}.runplan{n}.product.felt_speed = 138.5*2;
machine{m}.runplan{n}.product.sheets = 92;


% BEGIN run plan for next machine
n = 0;
machine{++m}.parameters = nil;
machine{m}.runplan{++n} = struct(
  'activity',   idle,
  'duration',   14*day);


% BEGIN run plan for next machine
n = 0;
machine{++m}.parameters = nil;
machine{m}.runplan{++n} = struct(
  'activity',   idle,
  'duration',   14*day);
