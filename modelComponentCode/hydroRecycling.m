function [elec_hydro, ng_hydro, em_hydroRecyclingProcess, ...
    nrg_hydroRecyclingProcess, chemsTransported] = ...
    hydroRecycling(x_cathode, x_other, Chem)

em_hydroRecyclingProcess = 0; 
nrg_hydroRecyclingProcess = 0; 

% disassembly & discharge 
%disassembly & discharge same as direct recycling
assumptions = csvread('directRecyclingAssumptions.csv',1,1); 
pd = makedist('Triangular', 'a', assumptions(4+4,1), 'b', ...
    assumptions(3+4,1), 'c', assumptions(5+4,1));
elec_disassembly = random(pd,1,1); 
clear assumptions 
elec_hydro = elec_disassembly; 
ng_hydro = 0;

% crushing cathode + adding NMP to dissolve cathode material 
boiler_efficiency = 0.8; %natural gas boiler
deltaT = 75; 
Cp_cathode = 1.0; % J/gK
Cp_nmp = 2.1; % J/gK
Cp_al = 0.9; % J/gK
nrg_soak = (x_cathode * Cp_cathode + x_other(2,1) * Cp_nmp + ...
    x_other(2,1) * Cp_al)*1000*deltaT; 
ng_soak = nrg_soak/boiler_efficiency/(10^6); % joule to MJ
ng_hydro = ng_hydro + ng_soak; 
% no electricity in the soaking stage
nmp = x_other(2,1); 

% burn off the PVDF & carbon
kiln_efficiency = 0.95; 
ng_filtration = x_cathode * Cp_cathode * 1000 * (700-100)/kiln_efficiency;
ng_filtration = ng_filtration/1000000; % J to MJ
elec_filtration = (0.08*2.93*100/1000) + rand(1)*((0.08*2.93*100/907)-(0.08*2.93*100/1000)); % mmBtu/ton to kWh to kg (assuming metric ton)
em_anode = x_other(4,1) * 44.01/12.01; 
em_electrolyte = x_other(7,1) * 3 * 44.01/88.06; 
em_PVDF = PVDFemissions(x_other); 
em_plastic = x_other(8,1) * 3*44.01/42.08; 

elec_hydro = elec_hydro + elec_filtration; 
ng_hydro = ng_hydro + ng_filtration; 
em_hydroRecyclingProcess = em_hydroRecyclingProcess + em_anode + ...
    em_electrolyte + em_PVDF + em_plastic; 

% electricity of grinding/crushing step, all electricity
pd = makedist('Triangular', 'a',0.02*0.278 , 'b', 1.28*0.278, 'c',9.05*0.278); % from dunn 2014, table 29
elec_crushing = random(pd, 1,1) * x_cathode; % MJ
elec_hydro = elec_hydro + elec_crushing; 

% leaching reactor 
a = 0.1 * 2.93*100/1000;
b = 0.12 * 2.93 *100/1000; 
c = 0.14* 2.93*100/907; 
pd = makedist('Triangular', 'a', a, 'b', b, 'c', c); 
elec_leaching = random(pd,1,1) * x_cathode; %MJ 
elec_hydro = elec_hydro + elec_leaching; 

% acid additives - fix this
precursorRatios = csvread('precursorRatios.csv', 2,1); % used to figure out mass of transition metal + lithium
if Chem == 1
    precursorRatios = precursorRatios(:, 1); 
elseif Chem == 2
        precursorRatios = precursorRatios(:,3); 
elseif Chem == 3
            precursorRatios = precursorRatios(:,5); 
end

mass_li = (x_cathode*(2*6.94/73.891)*(precursorRatios(8+2,1)/precursorRatios(10+2,1))) +...% Li from cathode
    (x_other(6,1)*6.94/(151.905));  % li from electrolyte  
H2O2 = mass_li*2.5; 
citricAcid = mass_li*(2.5*20/1000)/(34.0147*9.8*0.1);

% filtration additives 
sodiumCarbonate = mass_li*105.988/(6.941*2); % for precipitating lithioum carbonate 

em_leachingAdditives = citricAcid*1.51 + H2O2*0 + sodiumCarbonate*0.66;
nrg_leachingAdditives = citricAcid * 38 + sodiumCarbonate * 5.595; 

elec_H2O2 = lognrnd(0.56,1) * 3.6 * H2O2; % converted to MJ
ng_H2O2 = (lognrnd(2.1,1) + lognrnd(0.254,1)) * H2O2; % MJ of natural gas 

em_hydroRecyclingProcess = em_hydroRecyclingProcess + em_leachingAdditives; 
nrg_hydroRecyclingProcess = nrg_hydroRecyclingProcess + nrg_leachingAdditives; 
elec_hydro = elec_hydro + elec_H2O2; 
ng_hydro = ng_hydro + ng_H2O2; 

chemsTransported = citricAcid + sodiumCarbonate + H2O2; 