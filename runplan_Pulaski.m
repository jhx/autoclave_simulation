% PULASKI
% run plan sequence for each machine
m = 0;

% override Globals (globals.m)
% autoclave parameters
k_ac_load_time = 30;    % number of minutes it takes to load autoclave train
k_ac_unload_time = 23;  % number of minutes it takes to unload autoclave train
k_autoclave_length = 200; % autoclave length, [ft]

% override Parameters (parameters.m)
autoclave_lifo = [1 4 7 10 2 5 8 3 6 9]; % LIFO queue of autoclaves to be loaded


% BEGIN run plan for next machine
n = 0;
machine{++m}.parameters = hatscheck_9x5;
machine{m}.parameters.name = 'SM1';

machine{m}.runplan{++n} = struct(
  'product',    plank,
  'duration',   5*days,
  'waste',      1/100,
  'delay',      0/100);
% machine{m}.runplan{n}.product.felt_speed = 138.3*2;
% machine{m}.runplan{n}.product.sheets = 92;
% matching Zach's model
machine{m}.runplan{n}.product.felt_speed = 264;
machine{m}.runplan{n}.product.sheets = 108;
machine{m}.runplan{n}.product.width = 7.25;

machine{m}.runplan{++n} = struct(
  'activity',   idle,
  'duration',   48*hours);


% machine{m}.runplan{++n} = struct(
%   'activity',   washup,
%   'duration',   8*hours);
%
% machine{m}.runplan{++n} = struct(
%   'product',    plank,
%   'duration',   3*days+16*hours,
%   'waste',      0/100,
%   'delay',      0/100);
% machine{m}.runplan{n}.product.felt_speed = 138.3*2;
% machine{m}.runplan{n}.product.sheets = 92;


% BEGIN run plan for next machine
n = 0;
machine{++m}.parameters = hatscheck_9x5;
machine{m}.parameters.name = 'SM2';

machine{m}.runplan{++n} = struct(
  'product',    plank,
  'duration',   1*days,
  'waste',      1/100,
  'delay',      0/100);
% machine{m}.runplan{n}.product.felt_speed = 132.3*2;
% machine{m}.runplan{n}.product.sheets = 92;
machine{m}.runplan{n}.product.felt_speed = 264;
machine{m}.runplan{n}.product.sheets = 108;
machine{m}.runplan{n}.product.width = 7.25;

machine{m}.runplan{++n} = struct(
  'activity',   washup,
  'duration',   8*hours);

  machine{m}.runplan{++n} = struct(
    'product',    plank,
    'duration',   16*hours+5*days,
    'waste',      1/100,
    'delay',      0/100);
  % machine{m}.runplan{n}.product.felt_speed = 132.3*2;
  % machine{m}.runplan{n}.product.sheets = 92;
  machine{m}.runplan{n}.product.felt_speed = 264;
  machine{m}.runplan{n}.product.sheets = 108;
  machine{m}.runplan{n}.product.width = 7.25;

% machine{m}.runplan{++n} = struct(
%   'product',    plank,
%   'duration',   5*days+16*hours,
%   'waste',      2/100,
%   'delay',      3/100);
% machine{m}.runplan{n}.product.felt_speed = 132.3*2;
% machine{m}.runplan{n}.product.sheets = 92;


% BEGIN run plan for next machine
n = 0;
machine{++m}.parameters = nil;
machine{m}.runplan{++n} = struct(
  'activity',   idle,
  'duration',   14*day);
