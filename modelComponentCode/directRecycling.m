function [elec_direct, ng_direct, maxYield, electrolyte_recovered, ...
    haz_solid, rec_steel, em_directProcess, nrg_directProcess, chemsTransported] = ...
    directRecycling(x_cathode, x_other, volume, massPerCell) 

assumptions = csvread('directRecyclingAssumptions.csv',1,1); 

% disassembly & discharge 
pd = makedist('Triangular', 'a', assumptions(4+4,1), 'b', assumptions(3+4,1), 'c', assumptions(5+4,1));
elec_disassembly = random(pd,1,1); 

% assume outer canister is 90% removed--> back to 0%
cell_mass = x_cathode + sum(x_other); 
rec_steel = 1*x_other(1); %changed from 0.9
cell_mass = cell_mass - rec_steel; 

volume = volume -(x_other(1)*0.9/7.7); %remove the extra canister volume from calculations 
massPerCell = massPerCell * (1-(x_other(1)/(x_cathode+sum(x_other)))); 

% electrolyte extraction
pd = makedist('Triangular', 'a', .891-0.034, 'b', .891, 'c', 0.891+0.034); % from Grutzke et al 2015 
recoveryYield = random(pd,1,1);

pd = makedist('Triangular', 'a', assumptions(3+4,2), 'b', assumptions(4+4,2), 'c', assumptions(5+4,2)); 
elec_extraction = random(pd,1,1); %electricity to liquify 1 kg of CO2 

%pd = makedist('Triangular', 'a', 0.1, 'b', 0.1*2, 'c', 0.1*4); %assume volume = volume of vessel for extraction 
%co2_consumed = random(pd,1,1)/0.1*volume; %volume of co2 consumed per kg battery

pd = makedist('Triangular', 'a', 600, 'b', 750, 'c', 900); 
co2_consumed = random(pd,1,1)/massPerCell; %L
co2_consumed = co2_consumed *1.101; % convert volume of liquid co2 to mass

%pd = makedist('Triangular', 'a', 135, 'b', 180, 'c', 225); 
%co2_consumed = random(pd,1,1)/(massPerCell*1-(x_other(1)/(x_cathode + sum(x_other)))); %l 
%co2_consumed = co2_consumed * 0.865; %mass 

elec_extraction = co2_consumed * elec_extraction; %electricity consumed to liquify the co2 needed per kg battery
electrolyte_recovered = recoveryYield*(x_other(6,1)+x_other(7,1)); 
cell_mass = cell_mass - electrolyte_recovered; %subtract electrolyte mass

% ACN
acn = (0.5/1000)*(3/4)*30; %l of acn/cell 
acn = acn*0.786; % kg of acn/cell 
acn = acn/massPerCell; 
[acn_emissions, acn_ng, acn_elec, acn_nrg] = calculateACNcontributions(acn);  

% Propylene carbonate
pc_solvent = (0.5/1000)*(1/4)*30; % l of pc 
pc_solvent = pc_solvent * 1.205; % kg of pc
pc_solvent = pc_solvent/massPerCell; 
pd = makedist('Triangular', 'a', assumptions(2, 6), 'b', assumptions(1,6), 'c', assumptions(3,6)); 
em_pc_solvent = random(pd,1,1) * pc_solvent;
pd = makedist('Triangular', 'a', assumptions(5,6), 'b', assumptions(4,6)', 'c', assumptions(6,6)); 
nrg_pc_solvent = pc_solvent * random(pd,1,1); 

% size reduction 
pd = makedist('Triangular', 'a', assumptions(3+4,3)/(x_cathode + ...
    sum(x_other)), 'b', assumptions(3+4,3)/cell_mass, 'c', assumptions(3+4,3)/x_cathode);
elec_sizeReduc = random(pd,1,1); 

% final separation
pd = makedist('Triangular', 'a', assumptions(3+4,4)/(x_cathode + ...
    sum(x_other)), 'b', assumptions(3+4,4)/cell_mass, 'c', assumptions(3+4,4)/x_cathode);
elec_separation = random(pd,1,1); 

maxYield = x_cathode; 
haz_solid = cell_mass - x_cathode; 

em_PVDF = PVDFemissions(x_other); 
em_anode = x_other(4,1) * 44.01/12.01; 
em_electrolyte = x_other(7,1) * 3 * 44.01/88.06; 
em_plastic = x_other(8,1) * 3*44.01/42.08; 

chemsTransported = acn + pc_solvent; 
elec_direct = elec_disassembly + elec_extraction + elec_sizeReduc + elec_separation + acn_elec;
ng_direct = acn_ng; 
nrg_directProcess = nrg_pc_solvent + acn_nrg; 
em_directProcess = em_pc_solvent + acn_emissions + em_PVDF + em_anode + em_electrolyte + em_plastic; 