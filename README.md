# Autoclave Simulation


## Overview

### Purpose

- Determine optimal sequence of autoclave cycles 12h vs. 14h
- Calculate peak number of steel pallets required
- Calculate interleavers required
- Calculate peak steam demand
- Calculate size of precure staging area
- Calculate effects of improving turn time, cook process

### Assumptions

Each machine is described by the following parameters:

  - Hatscheck: name [string], hatscheck boolean [0 or 1], width [in],
    size roller circumference [ft], quantity of tubs [-],
    stacks per drop [stacks/drop]
  - NLM: name [string], hatscheck boolean [0 or 1], width [in],
    stacks per drop [stacks/drop], sf/day [ft2/day]

The machine run plan describes the production run as well as down days.

### Product parameters

  - name [string], width [in], length [in], thickness [in],
    felt speed [ft/min], film build [mm/sieve],
    sheets/stack [sheets/stack], precure duration [min],
    autoclave cycle [-], autoclave pressure [lb/in2]
  - implicit steel pallet size [ft]

### Production run parameters

  - duration [min], waste [%], delay [%]

## Constraints:

- Able to load one train at-a-time
- Unlimited steam supply
- Unlimited steel pallet supply
- 11 autoclaves available, though this may be over-ridden in the site-specific runplan (need to add A/C cleaning: 1 A/C per week for 24h)
- Autoclaves are not loaded until a full train can be used
- Autoclaves are 168' long and contain a full set of cars, though length may be over-ridden in the site-specific runplank
- Ace precure moves to the front of the queue as soon as it ripens


## Usage

This simulation is configured using a text editor and is intended to be run from the Octave / Matlab command line.

1. Edit the `runplan.m` file to configure the site name.

    File: `runplan.m`
    ```matlab
    % Pulaski -- 2 lines: SM1, SM2
    site = 'Pulaski';
    ```
    The simulation will then load the site-specific run plan from the file `runplan_SITE.m`.

1. Edit the `runplan_Pulaski.m` file to configure the site-specific machines, products, & schedule, overriding default values as-appropriate.

    ```matlab
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
  
    ...
    ```

1. Launch Octave / Matlab.

    ```sh
    $ octave
    GNU Octave (aarch64-apple-darwin25.2.0) version 11.1.0
    Copyright (C) 1993-2026 The Octave Project Developers.
    License GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>

    This is free software; see the source code for copying conditions.
    There is NO WARRANTY, to the extent permitted by law.  For details, type 'warranty'.

    Home page:            <https://octave.org>
    Support resources:    <https://octave.org/support>
    Improve Octave:       <https://octave.org/get-involved>

    For changes from previous versions, type 'news'.
    ```

4. Run simulation from the Octave / Matlab command line.
    
    ```text
    octave:1> ac



    -------------------------- SIMULATION START --------------------------
    Initializing global variables.
    Initializing functions.
    Setting up machine parameters, run plan.
      - Loading run plan "runplan_Pulaski"
      - Machine Configuration
        SM1: Plank ( 7.25 in, 1% waste, 0% delay) until 7200 min elapsed
        SM2: Plank ( 7.25 in, 1% waste, 0% delay) until 1440 min elapsed
        n/a: Idle until 20160 min elapsed
        Autoclaves (10), Queue: 1 4 7 10 2 5 8 3 6 9 
      - Simulation Configuration
        Duration: 14.0 day(s)
    Running simulation.
    .........................2........................3........................4........................5........................6........................7........................8........................9........................10........................11........................12........................13........................14.......................Simulation complete.
    
    ...
    ```

5. Clear memory before re-running simulation (e.g. after adjusting parameters).

    ```text
    octave:2> clear
    octave:3> ac
    
    ...
    ```
