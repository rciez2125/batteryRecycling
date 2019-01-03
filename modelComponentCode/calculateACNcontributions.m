function [acn_emissions, acn_ng, acn_elec, acn_nrg] = calculateACNcontributions(acn)

fractionAttribution = 0.12005/(1+0.12005+0.17011); 

% to environment
acn_emissions = 0.62959; % kg of CO2 from the get go

% inputs that have emissions
acn_elec = lognrnd(0.29232, 2.827)/3.6; % kWh to MJ
acn_ng = lognrnd(2.0893, 1.2214) + lognrnd(1.1662, 1.2214); % MJ

ammonia = lognrnd(0.50025, 1.2214); % kg 
propylene = lognrnd(1.1804, 1.2214); % kg 
sulfuricAcid = lognrnd(0.05006, 1.2214); % kg 

cathodeAssumptions = csvread('cathodeAssumptions.csv', 1,2); 

pd = makedist('Triangular', 'a', cathodeAssumptions(2,5), 'b', cathodeAssumptions(1,5), ...
    'c', cathodeAssumptions(3,5)); 
acn_emissions = acn_emissions + ammonia * cathodeAssumptions(1,8) + ...
    sulfuricAcid * random(pd,1,1) + propylene* 2.02;  

pd = makedist('Triangular', 'a', cathodeAssumptions(5,5), 'b', cathodeAssumptions(4,5), ...
    'c', cathodeAssumptions(6,5));
acn_nrg = ammonia * cathodeAssumptions(4,8) + sulfuricAcid * random(pd,1,1) + propylene * 62; 

acn_emissions = acn_emissions * fractionAttribution * acn;
acn_ng = acn_ng * fractionAttribution * acn; 
acn_elec = acn_elec * fractionAttribution * acn; 
acn_nrg = acn_nrg * fractionAttribution * acn; 