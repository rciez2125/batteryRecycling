% Specify the baseline assumptions, 50% lithium added to direct cathode
% recovery, baseline scaling factor on transportation assumptions, 50
% runs in the Monte Carlo analysis
monteCarloRuns = 50; 
setLiPercent(0.5);      setTransportSF(1);
runRecyclingModel(monteCarloRuns);

%% run sensitivity analysis on lithium percentages
liEmissionsSensitivityAnalysis 

%% run sensitivity analysis on transportation scaling factor
transportationAnalysis 
