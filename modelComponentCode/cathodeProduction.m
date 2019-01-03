function [e_transition_embodied, n_transition_embodied, e_Li2CO3_transport, ...
    n_Li2CO3_transport, e_Li2CO3_embodied,  n_Li2CO3_embodied, elec_drying, ...
    ng_drying, elec_calcining, ng_calcining, e_otherInputs_embodied, ...
    n_otherInputs_embodied, nickel, cobaltOxide, manganeseOxide, ...
    alumHydroxide, NaOH, Ammonium, nitric_acid, sulfuric_acid, ...
    co2_process] ... % new variables 
    = cathodeProduction(x_cathode, Chem, precursorType)

%kilnEfficiency = 0.95; % efficiency of natural gas drying/calcining kilns
ni_nitrate = 0; mn_nitrate = 0; co_nitrate = 0; 
ni_sulfate = 0; mn_sulfate = 0; co_sulfate = 0; 

precursorRatios = csvread('precursorRatios.csv', 2,1); % fixed
Li2CO3_assumptions = csvread('lithiumCarbonateGREETAssumptions.csv', 1,1); %fine  
cathodeAssumptions = csvread('cathodeAssumptions.csv',1,2); 
transitionMetalRatios = csvread('transitionMetalProcessing.csv',1,2); 
energyInputs = csvread('cathodeEnergyAssumptions.csv',1,1); % fixed

%pull the correct precursor ratio data and calculate energy consumption for
%calcining and drying steps 
if Chem == 1
    energyInputs = energyInputs(:,1);
    if precursorType == 1
        precursorRatios = precursorRatios(:, 1); 
    elseif precursorType == 2
        precursorRatios = precursorRatios(:, 2); 
    end
    % calcining and drying energy consumption (natural gas kiln)
    pd = makedist('Triangular', 'a', energyInputs(5,1), 'b', energyInputs(4,1), 'c', energyInputs(6,1)); 
    energy_calcining = x_cathode*random(pd,1,1); % returns in kWh/kg  
    pd = makedist('Triangular', 'a', energyInputs(2,1), 'b', energyInputs(1,1), 'c', energyInputs(3,1));
elseif Chem == 2
    energyInputs = energyInputs(:,2); 
    if precursorType == 1
        precursorRatios = precursorRatios(:, 3); 
    elseif precursorType == 2
        precursorRatios = precursorRatios(:, 4); 
    end
    % calcining and drying energy consumption (natural gas kiln)
    pd = makedist('Triangular', 'a', energyInputs(5,1), 'b', energyInputs(4,1), 'c', energyInputs(6,1)); 
    energy_calcining = x_cathode*random(pd,1,1); % returns in kWh/kg 
    pd = makedist('Triangular', 'a', energyInputs(2,1), 'b', energyInputs(1,1), 'c', energyInputs(3,1)); 
elseif Chem == 3
    precursorRatios = precursorRatios(:, 5); 
    energyInputs = energyInputs(:,3); 
    pd = makedist('Triangular', 'a', energyInputs(5,1), 'b', energyInputs(4,1), 'c', energyInputs(6,1)); 
    energy_calcining = x_cathode*random(pd,1,1); % returns in kWh/kg 
    pd = makedist('Triangular', 'a', energyInputs(2,1), 'b', energyInputs(1,1), 'c', energyInputs(3,1)); 
end

x_Li2CO3 = x_cathode * precursorRatios(8+2,1)/precursorRatios(10+2,1); 
alumHydroxide = x_cathode * precursorRatios(9+2,1)/precursorRatios(10+2,1); 

cathode_precursors = x_cathode * precursorRatios(7+2,1)/precursorRatios(10+2,1);
NaOH = cathode_precursors * precursorRatios(4,1)/precursorRatios(6+2,1); 
Ammonium = cathode_precursors * precursorRatios(5,1)/precursorRatios(6+2,1);
phosphoric_acid = x_cathode * precursorRatios(6,1)/precursorRatios(12,1); 
iron_sulfate = x_cathode * precursorRatios(7,1)/precursorRatios(12,1); 
energy_drying = x_cathode * random(pd,1,1)/1000; 

if Chem < 3
    if precursorType == 1
        ni_nitrate = cathode_precursors * precursorRatios(1,1)/precursorRatios(6+2,1); 
        co_nitrate = cathode_precursors * precursorRatios(2,1)/precursorRatios(6+2,1); 
        mn_nitrate = cathode_precursors * precursorRatios(3,1)/precursorRatios(6+2,1); 
    elseif precursorType==2
        ni_sulfate = cathode_precursors * precursorRatios(1,1)/precursorRatios(6+2,1); 
        co_sulfate = cathode_precursors * precursorRatios(2,1)/precursorRatios(6+2,1); 
        mn_sulfate = cathode_precursors * precursorRatios(3,1)/precursorRatios(6+2,1);
    end
end
    
ng_calcining = energy_calcining;
elec_calcining = 0;  

ng_drying = energy_drying;
elec_drying= 0; 

e_Li2CO3_embodied = x_Li2CO3 * Li2CO3_assumptions(1,1); 
e_Li2CO3_transport = x_Li2CO3 * Li2CO3_assumptions(1,2); 

n_Li2CO3_embodied = x_Li2CO3 * Li2CO3_assumptions(2,1); 
n_Li2CO3_transport = x_Li2CO3 * Li2CO3_assumptions(2,2); 

% calculate nitric/sulfuric acid & other material inputs 
nitric_acid = ni_nitrate * transitionMetalRatios(3, 4)/transitionMetalRatios(1,4)...
    + co_nitrate * transitionMetalRatios(3, 5)/transitionMetalRatios(1,5)...
    + mn_nitrate * transitionMetalRatios(3, 6)/transitionMetalRatios(1,6); 
sulfuric_acid = ni_sulfate * transitionMetalRatios(3, 1)/transitionMetalRatios(1,1)...
    + co_sulfate * transitionMetalRatios(3, 2)/transitionMetalRatios(1,2) ...
    + mn_sulfate * transitionMetalRatios(3, 3)/transitionMetalRatios(1,3);  

% other emissions from nickel/cobalt/manganese sulfate production (natural
% gas inputs)
nickel = ni_nitrate * transitionMetalRatios(2, 4)/transitionMetalRatios(1,4)...
    + ni_sulfate*transitionMetalRatios(2, 1)/transitionMetalRatios(1,1); 
cobaltOxide = co_nitrate * transitionMetalRatios(2, 5)/transitionMetalRatios(1,5)...
    + co_sulfate*transitionMetalRatios(2, 2)/transitionMetalRatios(1,2); 
manganeseOxide = mn_nitrate * transitionMetalRatios(2, 6)/transitionMetalRatios(1,6)...
    + mn_sulfate* transitionMetalRatios(2, 3)/transitionMetalRatios(1,3);

for i=1:2
    pd_ni = makedist('Triangular', 'a',cathodeAssumptions(2+3*(i-1),1), 'b', cathodeAssumptions(1+3*(i-1),1), 'c', cathodeAssumptions(3+3*(i-1),1)); 
    pd_CoO = makedist('Triangular', 'a',cathodeAssumptions(2+3*(i-1),2), 'b', cathodeAssumptions(1+3*(i-1),2), 'c', cathodeAssumptions(3+3*(i-1),2));
    pd_MnO = makedist('Triangular', 'a',cathodeAssumptions(2+3*(i-1),3), 'b', cathodeAssumptions(1+3*(i-1),3), 'c', cathodeAssumptions(3+3*(i-1),3));
    pd_AlOH3 = makedist('Triangular', 'a',cathodeAssumptions(2+3*(i-1),4), 'b', cathodeAssumptions(1+3*(i-1),4), 'c', cathodeAssumptions(3+3*(i-1),4));
    pd_phosphoric_acid = makedist('Triangular', 'a',cathodeAssumptions(2+3*(i-1),9), 'b', cathodeAssumptions(1+3*(i-1),9), 'c', cathodeAssumptions(3+3*(i-1),9));
    pd_iron_sulfate = makedist('Triangular', 'a',cathodeAssumptions(2+3*(i-1),10), 'b', cathodeAssumptions(1+3*(i-1),10), 'c', cathodeAssumptions(3+3*(i-1),10));
    if i==1
    e_transition_embodied = nickel*random(pd_ni,1,1) + cobaltOxide * random(pd_CoO,1,1) + ...
    manganeseOxide * random(pd_MnO,1,1) + alumHydroxide * random(pd_AlOH3,1,1) + ...
    ni_sulfate * transitionMetalRatios(4, 1) + phosphoric_acid * random(pd_phosphoric_acid,1,1) + ...
    iron_sulfate * random(pd_iron_sulfate,1,1); 
    elseif i==2
    n_transition_embodied = nickel*random(pd_ni,1,1) + cobaltOxide * random(pd_CoO,1,1) + ...
    manganeseOxide * random(pd_MnO,1,1) + alumHydroxide * random(pd_AlOH3,1,1) + ...
    ni_sulfate * transitionMetalRatios(5, 1) + phosphoric_acid * random(pd_phosphoric_acid,1,1) + ...
    iron_sulfate * random(pd_iron_sulfate,1,1);
    end
end
                    
e_otherInputs_embodied = nitric_acid * cathodeAssumptions(1,6) + sulfuric_acid * cathodeAssumptions(1,5) + ...
    NaOH * cathodeAssumptions(1,7) + Ammonium * cathodeAssumptions(1,8); 

n_otherInputs_embodied = nitric_acid * cathodeAssumptions(4,6) + sulfuric_acid * cathodeAssumptions(4,5) ...
    + NaOH * cathodeAssumptions(4,7) + Ammonium * cathodeAssumptions(4,8);

if Chem == 3
    co2_process = x_cathode * 1.5*44.01/157.76;
else 
    co2_process = 0;
end
                  

 