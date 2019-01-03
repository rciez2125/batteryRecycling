function r = getElectricity
global elec_emissions
global elec_input
global ng_emissions
global ng_energy 
r = [elec_emissions; elec_input; ng_emissions; ng_energy]; 