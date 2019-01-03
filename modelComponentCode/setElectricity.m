function setElectricity(market)
global elec_emissions
global elec_input
global ng_emissions
global ng_energy

dataIn = csvread('electricityFactors.csv', 1,1);


elec_emissions = dataIn(1, market+1);
elec_input = dataIn(2,market+1); 

ng_emissions = dataIn(1,1);
ng_energy = dataIn(2,1); 
