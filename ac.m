%%%
%
% Created by Rx on 19 Mar 08
%
% Purpose:
% - determine optimal sequence of autoclave cycles 12h vs. 14h
% - calculate peak number of steel pallets required
% - calculate interleavers required
% - calculate peak steam demand
% - calculate size of precure staging area
% - calculate effects of improving turn time, cook process
%
% Assumptions:
%
% Each machine is described by the following parameters:
%   - Hatscheck: name [string], hatscheck boolean [0 or 1], width [in],
%     size roller circumference [ft], quantity of tubs [-],
%     stacks per drop [stacks/drop]
%   - NLM: name [string], hatscheck boolean [0 or 1], width [in],
%     stacks per drop [stacks/drop], sf/day [ft2/day]
%
% The machine run plan describes the production run as well as down days.
%
% Product parameters:
%   - name [string], width [in], length [in], thickness [in],
%     felt speed [ft/min], film build [mm/sieve],
%     sheets/stack [sheets/stack], precure duration [min],
%     autoclave cycle [-], autoclave pressure [lb/in2]
%   - implicit steel pallet size [ft]
%
% Production run parameters:
%   - duration [min], waste [%], delay [%]
%
% Constraints:
% - able to load one train at-a-time
% - unlimited steam supply
% - unlimited steel pallet supply
% - 11 autoclaves available (need to add A/C cleaning: 1 A/C per week for 24h)
% - autoclaves are not loaded until a full train can be used
% - autoclaves are 168' long and contain a full set of cars
% - Ace precure moves to the front of the queue as soon as it ripens
%
% To Do:
% - kick out partial pallets when changing products
% - add ability to load short train with orphan stacks
%
% - add interleaver usage and/or count
% - minimize/calculate/constrain adjacent autoclave work
% - add statistics to track minutes waiting to turn (a/c ready)
% - add # trains behind based on 12h precure
% - add steam consumption, max demand
% - convert pressure calculation to rotating vector of values
% - log bottleneck each minute (waiting on PC, AC, OP)
% - place autoclave in maintenance queue (check m_q @ unload)
%%%

1;

printf('\n\n\n-------------------------- SIMULATION START --------------------------\n'); ...

printf('Initializing global variables.\n')
fflush(1);
globals                 % loads globals from file: globals.m

printf('Initializing functions.\n')
fflush(1);
code                    % loads functions from file: code.m

printf('Setting up machine parameters, run plan.\n')
fflush(1);
parameters              % loads parameters from file: parameters.m

printf('Running simulation.\n')
fflush(1);
simulation              % run simulation from file: simulation.m

printf('Simulation complete.\n')
fflush(1);
summary                 % display summary from file: summary.m
