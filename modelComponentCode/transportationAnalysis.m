SFs = [1, 2, 4]; 
monteCarloRuns = 50; 
types = 10; 
dataHolder1 = zeros(7*4*size(SFs,2), 9, 3); 
dataHolder2 = zeros(7*4*size(SFs,2), 9, 3); 

for z=1:3
    setLiPercent(0.5);
    setTransportSF(SFs(z));
    runRecyclingModel(monteCarloRuns);
    for s = 1:4
        [mfgSummaryPlotData, recyclingSummaryPlots, plotDiffYieldPyroDirect,...
            plotDiffYieldNothingDirect, plotDiffYieldHydroDirect, ...
            transportDataSummary, mfgFullData] = formatPlotData(s, 1);
        dataHolder1((s-1)*7+1+(z-1)*28:s*7+(z-1)*28,:,:) = transportDataSummary; 
        [mfgSummaryPlotData, recyclingSummaryPlots, plotDiffYieldPyroDirect,...
            plotDiffYieldNothingDirect, plotDiffYieldHydroDirect, ...
            transportDataSummary, mfgFullData] = formatPlotData(s, 2);
        dataHolder2((s-1)*7+1+(z-1)*28:s*7+(z-1)*28,:,:) = transportDataSummary; 
    end
end

% print the numbers I want
% raw transportation emissions for base case and US avg 
disp('Cylindrical'); 
disp('transportation kg per kg in US avg baseline');
disp(dataHolder1(1, 1:3, 1));
disp('lb'); disp(dataHolder1(1, 1:3, 2));
disp('ub'); disp(dataHolder1(1, 1:3, 3));

disp('collection kg per kg in US avg baseline');
disp(dataHolder1(2, 1:3, 1));
disp('lb'); disp(dataHolder1(2, 1:3, 2));
disp('ub'); disp(dataHolder1(2, 1:3, 3));

disp('transportation + collection kg per kg in US avg baseline');
disp(dataHolder1(3, 1:3, 1));
disp('lb'); disp(dataHolder1(3, 1:3, 2));
disp('ub'); disp(dataHolder1(3, 1:3, 3));

disp('percentages for different recycling - baseline');
disp(dataHolder1(5:7, 1:3, 1));
disp('lb'); disp(dataHolder1(5:7, 1:3, 2));
disp('ub'); disp(dataHolder1(5:7, 1:3, 3));


% write a csv file
outVersion1 = zeros(7*4*size(SFs,2)*3, 9); 
outVersion2 = outVersion1; 
for t = 1:size(SFs,2)
    outVersion1((t-1)*28*3+1:t*28*3, :) = dataHolder1(:, :, t); 
    outVersion2((t-1)*28*3+1:t*28*3, :) = dataHolder2(:, :, t); 
end
cd OutputFiles
    csvwrite('transportationAnalysisDataCylindrical.csv', outVersion1); 
    csvwrite('transportationAnalysisDataPrismatic.csv', outVersion2); 
cd ../

% rows are :
% 1 - transportation kg per kg
% 2 - collection kg per kg
% 3 - transportation + collection
% 4 - percentage of manufacturing emissions 
% 5 - percentage of pyro recycling emissions
% 6 - percentage of hydro recycling emissions
% 7 - percentage of direct recycling emissions 
% repeating by units (kg per kg, kg per kWh, MJ per kg, MJ per kWh) and
% then by percentile, then by scaling factor 

% columns are % NMC (US, NWPP, RFCM), NCA (US, NWPP, RFCM),  LFP (US, NWPP,
% RFCM) 

