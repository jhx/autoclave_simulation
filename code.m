1;

% function calculates throughput based on PCI/PDI fundamentals
function result = interval(machine, product)
  if (machine.hatscheck)
    pieces_wide = floor(machine.width/product.width);
    pieces_long = floor(machine.src*12/product.length);
    revs = revs(machine, product);
    sf_per_min = product.felt_speed/revs*product.width*pieces_wide/144*product.length* ...
      pieces_long/machine.src;
    result = machine.stacks*product.sheets*pieces_wide*product.width/sf_per_min;
  else
    result = 24*60*sf_stack(machine, product)/machine.sf;
  endif
endfunction

% function calculates revs based on machine/product parameters
function result = revs(machine, product)
  if (machine.hatscheck)
    result = floor((product.thickness*25.4)/(machine.tubs*product.film_build));
  else
    result = NA;
  endif
endfunction

% function calculates standard feet based on product parameters
function result = stdft(product)
  % add default parameter to delete sf
  % return conversion factor if 1 arg
  % return calc'd stdft if 2 args
  result = product.thickness/(5/16);
endfunction

% function calculates square feet per sheet based on machine/product parameters
function result = sf_sheet(machine, product)
  pieces_wide = floor(machine.width/product.width);
  result = 2/machine.stacks*pieces_wide*product.width*product.length/144;
endfunction

% function calculates square feet per stack based on machine/product parameters
function result = sf_stack(machine, product)
  % add default parameter to delete machine
  % assume machine.width=60, machine.tubs <> NA
  result = product.sheets*sf_sheet(machine, product);
endfunction

% function converts raw minutes to military time
function result = min2time(offset, i)
  result = mod(floor(offset/100+i/60), 24)*100+mod(offset+i, 60);
endfunction
