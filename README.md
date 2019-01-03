# batteryRecycling
code associated with battery recycling process comparison

The code was written in MATLAB 2016a, earlier and later versions might not be compatible. 

To run the code, the folder (SI_RecyclingLi-IonBatteries) and all subfolders should be added to the working path.

runAnalysis runs the recycling model for the baseline assumptions, different sensitivity analyses (lithium percentage added, transportation distances), and produces the included in the manuscript and SI by calling the runRecyclingModel function.

The parameters specified are the number of runs in the Monte Carlo simulation (5000), the percentage of lithium replaced (must be between 0 and 1, with a baseline value of 0.5), and the transportation scaling factor (baseline of 1). 

Run time is dependent on the number of simulations included in the Monte Carlo analysis. For 50 runs, the initial baseline model is complete in ~1 minute, with the sensitivity analyses taking longer because of additional parameter specifications and repeated simulations (~3 minutes for lithium percentage sensitivity analysis, ~2 minutes for the transportation distance sensitivity analysis). 

runRecyclingModel calls several functions:

buildCell: constructs a cell within uncertainty bounds specified for different cell dimensions and chemistries, and normalizes the components to one kg battery

calculateTransportationAssumptions: pulls assumed emissions and energy inputs for different transportation methods. 

otherMaterialEmissions: retrieves the embodied emissions and energy associated with cell materials excluding the cathode.

cathodeProduction: retrieves the embodied emissions and energy associated with cathode precursor materials, and the energy consumed during the cathode production process.

pyroRecycling: calculates the energy and emissions associated with a pyrometallurgical process, in addition to the products that are recovered through this process

pyroOffset: calculates the emissions and energy offsets associated with the outputs collected during the pyrometallurgical recycling process

hydroRecycling: calculates the energy and emissions associated with the hydrometallurgical recycling process

hydroOffset: calculates the emissions and energy offsets associated with the outputs collected during the hydrometallurgical recycling process

directRecycling: calculates the energy and emissions associated with the direct recycling process

directOffset: calculates the emissions and energy offsets associated with using the outputs collected during the direct recycling process as inputs to new cell manufacturing

scrapOffset: calculates the emissions and energy offsets associated with the cell hardware scrap collected during the hydrometallurgical and direct recycling processes


--------------------------------------------------------------------------------

liEmissionsSensitivityAnalysis varies the percentage of lithium that is replaced, runs the recycling model, and produces figures with the associated data

transportationAnalysis reads data associated with different scaling factors on the distances traveled, and produces output data of interest. 
