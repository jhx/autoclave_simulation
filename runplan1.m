% run plan sequence for each machine
m = 0;


% BEGIN run plan for next machine
n = 0;
machine{++m}.parameters = hatscheck_6x5;
machine{m}.parameters.name = 'SM1';
machine{m}.runplan{++n} = struct(
  'product',    ezgrid,
  'duration',   3*days,
  'waste',      3/100,
  'delay',      2/100);
  
machine{m}.runplan{++n} = struct(
  'activity',   washup,
  'duration',   8*hours);
  
machine{m}.runplan{++n} = struct(
  'product',    plank,
  'duration',   3*days+16*hours,
  'waste',      3/100,
  'delay',      4/100);


% BEGIN run plan for next machine
n = 0;
machine{++m}.parameters = hatscheck_6x5;
machine{m}.parameters.name = 'SM2';
machine{m}.runplan{++n} = struct(
  'product',    hld,
  'duration',   1*day,
  'waste',      3/100,
  'delay',      4/100);
  
machine{m}.runplan{++n} = struct(
  'activity',   washup,
  'duration',   8*hours);
  
machine{m}.runplan{++n} = struct(
  'product',    hld,
  'duration',   5*days+16*hours,
  'waste',      3/100,
  'delay',      4/100);


% BEGIN run plan for next machine
n = 0;
machine{++m}.parameters = nlm;
machine{m}.runplan{++n} = struct(
  'activity',   washup,
  'duration',   1*day);
  