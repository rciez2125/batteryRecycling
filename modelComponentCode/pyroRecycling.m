function [cu_offset, fe_offset, ni_offset, co_offset, ...
    cement_offset, nrg_pyro, em_pyro, leachate, elec_pyro, ng_pyro] = pyroRecycling(x_cathode, x_other, Chem)

% smelting emissions are independent of everything

alloyPct = csvread('alloyPercentages.csv', 1,1); 
precursorRatios = csvread('precursorRatios.csv', 2,1);
transitionMetalMix = csvread('transitionMetalProcessing.csv', 1,2); 
smeltInputs = csvread('smeltingInputs.csv',1,1); 
pyroAssumptions = csvread('pyroProcessAssumptions.csv',1,1); 

pd = makedist('Triangular', 'a', pyroAssumptions(8,1), 'b', pyroAssumptions(7,1), 'c', pyroAssumptions(9,1)); 
ng_consumed = random(pd,1,1);       ng_pyro = ng_consumed; 
em_pyro = pyroAssumptions(1,1);     nrg_pyro = pyroAssumptions(4,1); 

smeltInputs = [smeltInputs(:,1)./smeltInputs(1,1), smeltInputs(:,2:end)]; 
smeltInputs = smeltInputs(2:end,:); 

copper_content = x_other(3,1); % per kg battery
iron_content = smeltInputs(3,4)*smeltInputs(3,1)...
    + x_other(1,1); % per kg battery, some from slag, most from canisters
if Chem == 3
    iron_content = iron_content + x_cathode * 55.845/175.76; % for LFP iron content 
end

if Chem == 1
    precursorRatios = precursorRatios(:,1:2); 
elseif Chem == 2
    precursorRatios = precursorRatios(:,3:4); 
elseif Chem == 3
    precursorRatios = precursorRatios(:,5);
end

nickel_content = 0;
cobalt_content = 0; 
if Chem < 3
    nickel_content = x_cathode*precursorRatios(7+2,1)/precursorRatios(10+2,1)*mean([precursorRatios(1,1)*...
        transitionMetalMix(2,4)/(precursorRatios(6+2,1)*transitionMetalMix(1,4)),...
        precursorRatios(1,2)*transitionMetalMix(2,1)/(precursorRatios(6+2,2)*transitionMetalMix(1,1))]);  

    cobalt_content = x_cathode*precursorRatios(7+2,1)/precursorRatios(10+2,1)*mean([precursorRatios(2,1)*...
        transitionMetalMix(2,5)/(precursorRatios(6+2,1)*transitionMetalMix(1,5)),...
        precursorRatios(2,2)*transitionMetalMix(2,2)/(precursorRatios(6+2,2)*transitionMetalMix(1,2))]);  
    cobalt_content = cobalt_content *58.933/74.933; %correct for cobalt oxide molar mass
end

cu_offset = alloyPct(1,1)*copper_content;
ni_offset = alloyPct(1,2)*nickel_content; 
fe_offset = alloyPct(1,3)*iron_content; 
co_offset = alloyPct(1,4)*cobalt_content; 
alloy = cu_offset + ni_offset + fe_offset + co_offset;

cement_offset = alloyPct(2,1)*copper_content + alloyPct(2,2)*nickel_content ...
    + alloyPct(2,3)*iron_content + alloyPct(2,4)*cobalt_content +... % metals that doesn't go to alloy
    x_other(2,1) + sum(smeltInputs(:,1)'*smeltInputs(:,6:8)') + ...
    smeltInputs(:,1)'*smeltInputs(:,end) + ...% other stuff from limestone, sand, slag
    (x_cathode*(2*6.94/73.891)*(precursorRatios(8+2,1)/precursorRatios(10+2,1)))*(2*6.94+16)/6.94 +...% Li2O from cathode
    (x_other(6,1)*6.94/(151.905))*(2*6.94+16)/6.94;% Li2O from electrolyte

pd = makedist('Triangular', 'a', pyroAssumptions(11,2), 'b', ...
    pyroAssumptions(10,2), 'c', pyroAssumptions(12,2)); %energy inputs in table 30
elec_leaching = random(pd,1,1); 

elec_cu_leach = alloy*elec_leaching;
alloy = alloy - cu_offset; 

elec_fe_leach = alloy*elec_leaching;

em_pyro = em_pyro + co_offset*pyroAssumptions(1,4); 
nrg_pyro = nrg_pyro + co_offset*pyroAssumptions(4,4);

% add emissions from plastic, electrolyte, graphite combustion 
em_anode = x_other(4,1) * 44.01/12.01; 
em_electrolyte = x_other(7,1) * 3 * 44.01/88.06; 
em_PVDF = PVDFemissions(x_other); 
em_plastic = x_other(8,1) * 3*44.01/42.08; 

em_pyro = em_pyro + em_anode + em_electrolyte + em_plastic + em_PVDF; 

elec_pyro =  elec_cu_leach + elec_fe_leach;

leachate = 0; 