function [x_cathode, x_other, x_capacity, elec_mfg, ng_mfg, volume, massPerCell] ...
    = buildCell(Chem, Size)

allData = csvread('PrismaticNumbers.csv', 3,2); 

if Chem == 1
    if Size == 1
        dataIn = csvread('NMC_18650_cell_inputs.csv', 1, 2);
    elseif Size == 2
        dataIn = csvread('NMC_20720_cell_inputs.csv', 1, 2); 
    elseif Size == 3
        dataIn = allData(:, 16:18); 
    elseif Size == 4
        dataIn = allData(:, 13:15); 
    end
elseif Chem == 2
    if Size == 1
        dataIn = csvread('NCA_18650_cell_inputs.csv', 1, 2);  
    elseif Size == 2
        dataIn = csvread('NCA_20720_cell_inputs.csv', 1, 2); 
    elseif Size == 3
        dataIn = allData(:, 10:12); 
    elseif Size == 4
        dataIn = allData(:, 7:9); 
    end
elseif Chem == 3
    if Size == 1
        dataIn = csvread('LFP_18650_cell_inputs.csv', 1, 2); 
    elseif Size == 2
        dataIn = csvread('LFP_20720_cell_inputs.csv', 1, 2); 
    elseif Size == 3 
        dataIn = allData(:, 4:6); 
    elseif Size == 4
        dataIn = allData(:, 1:3); 
    end 
end

x_other = zeros(8,1); 
for i = 1
    pd = makedist('Triangular', 'a', dataIn(i,2), 'b', ...
        dataIn(i,1), 'c', dataIn(i,3));
    x_other(i,1) = random(pd,1,1); 
end

for i=2:3
    pd = makedist('Triangular', 'a', dataIn(i,2), 'b', ...
        dataIn(i,1), 'c', dataIn(i,3));
    x_other(i,1) = random(pd,1,1); 
end

for i=4
    pd = makedist('Triangular', 'a', dataIn(i,2), 'b', ...
        dataIn(i,1), 'c', dataIn(i,3));
    x_cathode = random(pd,1,1); 
end

for i=5:9
    pd = makedist('Triangular', 'a', dataIn(i,2), 'b', ...
        dataIn(i,1), 'c', dataIn(i,3));
    x_other(i-1,1) = random(pd,1,1); 
end

for i=10
    pd = makedist('Triangular', 'a', dataIn(i,2), 'b', ...
        dataIn(i,1), 'c', dataIn(i,3)); %kWh consumed during mfg per kg battery
    mfg_final_energy = random(pd,1,1); % pull a random energy consumption 
end
massPerCell = sum(x_other) + x_cathode; %in grams
ng_mfg = 322/907.185; %based on Dunn et al assumptions  
elec_mfg = mfg_final_energy - ng_mfg; 

%normalize to per kg battery

x_capacity = x_cathode * dataIn(end-1,1) *dataIn(end,1)/1000/massPerCell; %capacity in kWh/kg battery
x_other = x_other./massPerCell; %ratio
x_cathode = x_cathode/massPerCell; %ratio 

volume = pi()*65*9^2; %volume in mm3
if Size==2
    volume = pi()*72*10^2;
end
volume = volume/1000000; %volume in L
volume = volume*1000/massPerCell; %volume per kg battery



