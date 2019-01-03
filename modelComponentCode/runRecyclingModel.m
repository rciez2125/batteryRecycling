function runRecyclingModel(n)

for a=1:5 %change to 3
    if a == 1
        Chem = 1;       precursorType = 1; % run through both precursor types, nitrates = 1, sulfates = 2
    elseif a == 2
            Chem = 1;   precursorType = 2; % run through different chems NMC = 1, NCA = 2, LFP = 3
    elseif a == 3
        Chem = 2;       precursorType = 1;
    elseif a == 4
        Chem = 2; precursorType = 2;
    else
        Chem = 3; % LFP, 
        precursorType = 3; % only 1 kind of precursor 
    end 
    for b = 1:4 %prismaticShape = 3:4  % change to 3 or 4 (prismatic sizes) 
        Size = b; 
   
simulationRunsUS = zeros(n, 36); 
simulationRunsNWPP = simulationRunsUS; 
simulationRunsRFCM = simulationRunsUS; 
localPollution = zeros(n,1); 
t = getTransportSF; 

for i=1:n
    % build a cell, normalize to per kg of battery
    [x_cathode, x_other, x_capacity, elec_mfg, ng_mfg, volume, massPerCell] = ...
        buildCell(Chem, Size);
    % set for LFP cylindrical

    % pull transportation emissions numbers per kg mile 
    [transportationAssumptions] = calculateTransportAssumptions;
    transportationAssumptions = t*transportationAssumptions; 
    
    % calculate the transportation, other emissions associated with other 
    % cell materials 
        [em_other_embodied, nrg_other_embodied] = ...
            otherMaterialEmissions(x_other);

    
    % calculate transportation, emissions associated with producing the 
    % cathode materials
    [em_transition_embodied, nrg_transition_embodied, em_Li2CO3_transport, ...
        nrg_Li2CO3_transport, em_Li2CO3_embodied,  nrg_Li2CO3_embodied, ...
        elec_drying, ng_drying, elec_calcining, ng_calcining, ...
        em_otherInputs_embodied, nrg_otherInputs_embodied, nickel, ...
        cobaltOxide, manganeseOxide, alumHydroxide, NaOH, Ammonium, ...
        nitric_acid, sulfuric_acid, co2_process] = cathodeProduction(x_cathode, ...
        Chem, precursorType); 
 
    % calculate the emissions from pyrometallurgical recycling and material
    % output
    [cu_offset, fe_offset, ni_offset, co_offset, cement_offset, nrg_pyro, ...
        em_pyro, leachate, elec_pyro, ng_pyro] = ...
        pyroRecycling(x_cathode, x_other, Chem); 

    % calculate pyrometallurgical recycling energy and emissions offsets
    [em_cu_offset, em_fe_offset, em_ni_offset, em_co_offset, ...
        em_cement_offset, nrg_cu_offset, nrg_fe_offset, nrg_ni_offset, ...
        nrg_co_offset, nrg_cement_offset] = pyroOffset(cu_offset, ...
        fe_offset, ni_offset, co_offset, cement_offset); 
    
    em_pyro_offset = em_cu_offset + em_fe_offset + em_ni_offset + ...
        em_co_offset + em_cement_offset; 
    nrg_pyro_offset = nrg_cu_offset + nrg_fe_offset + nrg_ni_offset + ...
        nrg_co_offset + nrg_cement_offset; 

    % calculate the emissions from hydrometallurgical recycling and
    % material output
    [elec_hydro, ng_hydro, em_hydroRecyclingProcess, ...
    nrg_hydroRecyclingProcess, chemsTransportedHydro] = ...
    hydroRecycling(x_cathode, x_other, volume);
    
    % calculate direct recycling emissions
    [elec_direct, ng_direct, maxYield, electrolyte_recoverDired, ...
    haz_solid, rec_steel, em_directProcess, nrg_directProcess, chemsTransportedDirect] =... 
    directRecycling(x_cathode, x_other, volume, massPerCell);
   
    for elec=1:3
        %set electricity emissions and heat input 
        setElectricity(elec); % 1 is US avg, 2 is NWPP, 3 is RFCM
        r = getElectricity; 
        distances = csvread('distanceAssumptions.csv', 2, 1); 
        distances = distances(:, ((elec-1)*3+1):(3*elec)); 
        
        em_other_transport = (transportationAssumptions(:,1)'*distances(1:8,:)'); 
        nrg_other_transport = (transportationAssumptions(:,2)'*distances(1:8,:)'); 
        em_other_transport = sum(em_other_transport'.*x_other); 
        nrg_other_transport = sum(nrg_other_transport'.*x_other); 
        
        em_transition_transport = transportationAssumptions(:,1)'*...
            distances(11:14, :)'*[nickel; cobaltOxide; manganeseOxide; alumHydroxide];

        nrg_transition_transport = transportationAssumptions(:,2)'*...
            distances(11:14, :)'*[nickel; cobaltOxide; manganeseOxide; alumHydroxide]; 

        em_otherInputs_transport = transportationAssumptions(:,1)'*...
            distances(9:10, :)'*[nitric_acid; sulfuric_acid] + ...
            transportationAssumptions(:,1)'*distances(15:16, :)'*[NaOH; Ammonium]; 

        nrg_otherInputs_transport = transportationAssumptions(:,2)'*...
            distances(11:12, :)'*[nitric_acid; sulfuric_acid] + ...
            transportationAssumptions(:,2)'*distances(15:16, :)'*[NaOH; Ammonium]; 
        
        em_direct_transport = sum(transportationAssumptions(:,1)'.* ...
            distances(17,:)) * chemsTransportedDirect; 
        em_hydro_transport = sum(transportationAssumptions(:,1)'.* ...
            distances(18,:)) * chemsTransportedHydro; 
        nrg_direct_transport = sum(transportationAssumptions(:,2)'.* ...
            distances(17,:)) * chemsTransportedDirect; 
        nrg_hydro_transport = sum(transportationAssumptions(:,2)'.* ...
            distances(18,:)) * chemsTransportedHydro; 
        
        % calculate emissions and energy inputs for on-site electricity,
        % natural gas consumption
        em_mfg = elec_mfg*r(1) + ng_mfg*r(3); 
        nrg_mfg = elec_mfg*r(2) + ng_mfg*r(4); 
        
        em_direct = elec_direct*r(1) + ng_direct*r(3) + em_directProcess; 
        nrg_direct = elec_direct*r(2) + ng_direct*r(4) + nrg_directProcess; 
        
        em_drying = elec_drying*r(1) + ng_drying*r(3) + co2_process;
        nrg_drying = elec_drying*r(2) + ng_drying*r(4); 
        
        em_calcining = elec_calcining*r(1) + ng_calcining*r(3);
        nrg_calcining = elec_calcining*r(2) + ng_calcining*r(4);
        
        em_pyro = em_pyro + elec_pyro*r(1) + ng_pyro*r(3); 
        nrg_pyro = nrg_pyro + elec_pyro*r(2) + ng_pyro*r(4); 
        
        em_hydro = elec_hydro *r(1) + ng_hydro*r(3) + em_hydroRecyclingProcess;
        nrg_hydro = elec_hydro*r(2) + ng_hydro*r(4) + nrg_hydroRecyclingProcess;
        
        % calculate direct + hydro recycling offsets
        [em_direct_offset, nrg_direct_offset] = directOffset(x_other, ...
        em_transition_transport, em_transition_embodied, em_drying, ...
        em_otherInputs_transport, em_otherInputs_embodied,...
        em_Li2CO3_transport, em_Li2CO3_embodied, nrg_transition_transport, ...
        nrg_transition_embodied, nrg_drying, nrg_otherInputs_transport,...
        nrg_otherInputs_embodied, nrg_Li2CO3_transport, nrg_Li2CO3_embodied); 
    
        [em_hydro_offset, nrg_hydro_offset] = hydroOffset(x_other, ...
        em_transition_transport, em_transition_embodied, em_drying, em_otherInputs_transport, em_otherInputs_embodied,...
        em_Li2CO3_transport, em_Li2CO3_embodied, nrg_transition_transport, nrg_transition_embodied, ...
        nrg_drying, nrg_otherInputs_transport, nrg_otherInputs_embodied, ...
        nrg_Li2CO3_transport, nrg_Li2CO3_embodied);
        
        % calculate collection emissions
        collectionDistance = 2500; %miles
        em_collection = collectionDistance*transportationAssumptions(3,1); 
        nrg_collection = collectionDistance*transportationAssumptions(3,2);
        
        [em_scrap_offset, nrg_scrap_offset] = scrapOffset(x_other); 
        % export data 
        dataOut = [ x_capacity, ... % 1 storage capacity per kg battery
            maxYield, ... % 2 maximum cathode material that can be recovered
            em_transition_transport + em_Li2CO3_transport + em_otherInputs_transport, ... % 3 cathode transportation emissions
            sum(em_other_transport), ... % 4 other materials transportation emissions
            sum(em_other_embodied), ... % 5 other materials embodied emissions
            em_mfg, ... % 6 cell manufacturing emissions
            em_transition_embodied + em_Li2CO3_embodied + em_otherInputs_embodied, ... % 7 cathode material embodied emissions
            em_drying + em_calcining, ...% 8 cathode manufacturing emissions
            em_collection, ... % 9 collection emissions estimate
            em_pyro, ... % 10 pyrometallurgical recycling emissions
            em_direct, ...% 11 direct recycling emissions 
            em_direct_transport, ... % 12 direct recycling transporation emissions
            em_hydro, ...% 13 hydrometallurgical recycling emissions
            em_hydro_transport, ... % 14 hydrometallurgical recycling transportation emissions 
            em_pyro_offset, ...% 15 pyrometallurgical recycling offset
            em_direct_offset,... % 16 direct recycling offsets
            em_hydro_offset, ... % 17 hydrometallurgical recycling offsets
            nrg_transition_transport + nrg_Li2CO3_transport + nrg_otherInputs_transport, ... % 18 cathode transportation energy
            sum(nrg_other_transport), ... % 19 other materials transportation energy
            sum(nrg_other_embodied), ... % 20 other materials embodied energy
            nrg_mfg, ... % 21 cell manufacturing energy
            nrg_transition_embodied + nrg_Li2CO3_embodied + nrg_otherInputs_embodied, ... % 22 cathode material embodied energy
            nrg_drying + nrg_calcining, ... % 23 cathode manufacturing energy
            nrg_collection, ... % 24 collection energy estimate
            nrg_pyro, ... % 25 pyrometallurgical recycling energy
            nrg_direct, ... % 26 direct recycling energy 
            nrg_direct_transport, ... % 27 direct recycling transportation energy
            nrg_hydro, ... % 28 hydrometallurgical recycling energy
            nrg_hydro_transport, ... % 29 hydrometallurgical recycling transportation energy
            nrg_pyro_offset, ...% 30 pyrometallurgical recycling offset energy
            nrg_direct_offset, ... % 31 direct recycling offset energy 
            nrg_hydro_offset, ... % 32 hydrometallurgical recycling offset energy
            em_scrap_offset, ... % 33 emissions savings from scraps for hydro + direct recycling, not affected by yield 
            nrg_scrap_offset, ... % 34 energy savings from scraps for hydro + direct recycling, not affected by yield
            elec_direct*r(1)/em_direct, ...haz_solid, ... % 35 hazardous solid materials to be disposed of from direct recycling
            ng_direct*r(3)/em_direct]; ...rec_steel]; % 36 steel recovered during direct recycling (can be recycled elsewhere) 
        if elec==1
            simulationRunsUS(i,:) = dataOut;
        elseif elec==2 
            simulationRunsNWPP(i,:) = dataOut; 
        elseif elec==3
            simulationRunsRFCM(i,:) = dataOut; 
        end
        localPollution(i,1) = ng_calcining; 
    end
end
            cd OutputFiles
                if a==1 && b == 1
                    csvwrite('NMC_18650_nitratesUS.csv', simulationRunsUS); 
                    csvwrite('NMC_18650_nitratesNWPP.csv', simulationRunsNWPP); 
                    csvwrite('NMC_18650_nitratesRFCM.csv', simulationRunsRFCM);
                    csvwrite('NMC_18650_nitrates_pollution.csv', localPollution); 
                elseif a==1 && b == 2
                    csvwrite('NMC_20720_nitratesUS.csv', simulationRunsUS); 
                    csvwrite('NMC_20720_nitratesNWPP.csv', simulationRunsNWPP); 
                    csvwrite('NMC_20720_nitratesRFCM.csv', simulationRunsRFCM); 
                    csvwrite('NMC_20720_nitrates_pollution.csv', localPollution); 
                elseif a==2 && b == 1
                    csvwrite('NMC_18650_sulfatesUS.csv', simulationRunsUS); 
                    csvwrite('NMC_18650_sulfatesNWPP.csv', simulationRunsNWPP);
                    csvwrite('NMC_18650_sulfatesRFCM.csv', simulationRunsRFCM); 
                    csvwrite('NMC_18650_sulfates_pollution.csv', localPollution); 
                elseif a==2 && b == 2
                    csvwrite('NMC_20720_sulfatesUS.csv', simulationRunsUS); 
                    csvwrite('NMC_20720_sulfatesNWPP.csv', simulationRunsNWPP);
                    csvwrite('NMC_20720_sulfatesRFCM.csv', simulationRunsRFCM); 
                    csvwrite('NMC_20720_sulfates_pollution.csv', localPollution); 
                elseif a==3 && b == 1
                    csvwrite('NCA_18650_nitratesUS.csv', simulationRunsUS); 
                    csvwrite('NCA_18650_nitratesNWPP.csv', simulationRunsNWPP); 
                    csvwrite('NCA_18650_nitratesRFCM.csv', simulationRunsRFCM); 
                    csvwrite('NCA_18650_nitrates_pollution.csv', localPollution); 
                elseif a==3 && b==2 
                    csvwrite('NCA_20720_nitratesUS.csv', simulationRunsUS); 
                    csvwrite('NCA_20720_nitratesNWPP.csv', simulationRunsNWPP); 
                    csvwrite('NCA_20720_nitratesRFCM.csv', simulationRunsRFCM); 
                    csvwrite('NCA_20720_nitrates_pollution.csv', localPollution); 
                elseif a==4 && b==1
                    csvwrite('NCA_18650_sulfatesUS.csv', simulationRunsUS); 
                    csvwrite('NCA_18650_sulfatesNWPP.csv', simulationRunsNWPP);
                    csvwrite('NCA_18650_sulfatesRFCM.csv', simulationRunsRFCM);
                    csvwrite('NCA_18650_sulfates_pollution.csv', localPollution); 
                elseif a==4 && b==2 
                    csvwrite('NCA_20720_sulfatesUS.csv', simulationRunsUS); 
                    csvwrite('NCA_20720_sulfatesNWPP.csv', simulationRunsNWPP);
                    csvwrite('NCA_20720_sulfatesRFCM.csv', simulationRunsRFCM);
                    csvwrite('NCA_20720_sulfates_pollution.csv', localPollution); 
                elseif a==5 && b == 1
                    csvwrite('LFP_18650_US.csv', simulationRunsUS); 
                    csvwrite('LFP_18650_NWPP.csv', simulationRunsNWPP); 
                    csvwrite('LFP_18650_RFCM.csv', simulationRunsRFCM); 
                    csvwrite('LFP_18650_pollution.csv', localPollution); 
                elseif a==5 && b==2 
                    csvwrite('LFP_20720_US.csv', simulationRunsUS); 
                    csvwrite('LFP_20720_NWPP.csv', simulationRunsNWPP); 
                    csvwrite('LFP_20720_RFCM.csv', simulationRunsRFCM); 
                    csvwrite('LFP_20720_pollution.csv', localPollution);
                elseif a==1 && b==3
                    csvwrite('NMC_PS_nitrates_US.csv', simulationRunsUS); 
                    csvwrite('NMC_PS_nitrates_NWPP.csv', simulationRunsNWPP);
                    csvwrite('NMC_PS_nitrates_RFCM.csv', simulationRunsRFCM);
                elseif a==1 && b==4
                    csvwrite('NMC_PL_nitrates_US.csv', simulationRunsUS); 
                    csvwrite('NMC_PL_nitrates_NWPP.csv', simulationRunsNWPP);
                    csvwrite('NMC_PL_nitrates_RFCM.csv', simulationRunsRFCM);
                elseif a==2 && b==3
                    csvwrite('NMC_PS_sulfates_US.csv', simulationRunsUS); 
                    csvwrite('NMC_PS_sulfates_NWPP.csv', simulationRunsNWPP);
                    csvwrite('NMC_PS_sulfates_RFCM.csv', simulationRunsRFCM);
                elseif a==2 && b==4
                    csvwrite('NMC_PL_sulfates_US.csv', simulationRunsUS); 
                    csvwrite('NMC_PL_sulfates_NWPP.csv', simulationRunsNWPP);
                    csvwrite('NMC_PL_sulfates_RFCM.csv', simulationRunsRFCM);
                elseif a==3 && b==3
                    csvwrite('NCA_PS_nitrates_US.csv', simulationRunsUS); 
                    csvwrite('NCA_PS_nitrates_NWPP.csv', simulationRunsNWPP);
                    csvwrite('NCA_PS_nitrates_RFCM.csv', simulationRunsRFCM);
                elseif a==3 && b==4
                    csvwrite('NCA_PL_nitrates_US.csv', simulationRunsUS); 
                    csvwrite('NCA_PL_nitrates_NWPP.csv', simulationRunsNWPP);
                    csvwrite('NCA_PL_nitrates_RFCM.csv', simulationRunsRFCM);
                elseif a==4 && b==3
                    csvwrite('NCA_PS_sulfates_US.csv', simulationRunsUS); 
                    csvwrite('NCA_PS_sulfates_NWPP.csv', simulationRunsNWPP);
                    csvwrite('NCA_PS_sulfates_RFCM.csv', simulationRunsRFCM);
                elseif a==4 && b==4 
                    csvwrite('NCA_PL_sulfates_US.csv', simulationRunsUS); 
                    csvwrite('NCA_PL_sulfates_NWPP.csv', simulationRunsNWPP);
                    csvwrite('NCA_PL_sulfates_RFCM.csv', simulationRunsRFCM);
                elseif a==5 && b==3
                    csvwrite('LFP_PS_US.csv', simulationRunsUS); 
                    csvwrite('LFP_PS_NWPP.csv', simulationRunsNWPP); 
                    csvwrite('LFP_PS_RFCM.csv', simulationRunsRFCM); 
                elseif a==5 && b==4
                    csvwrite('LFP_PL_US.csv', simulationRunsUS); 
                    csvwrite('LFP_PL_NWPP.csv', simulationRunsNWPP); 
                    csvwrite('LFP_PL_RFCM.csv', simulationRunsRFCM); 
                end
            cd ../
%merge data and save based on location assumptions

    end
end
%load data % included lfp 
for z=1:3
    [NMC18650N, NMC18650S, NMC20720N, NMC20720S,...
        NCA18650N, NCA18650S, NCA20720N, NCA20720S, LFP18650, LFP20720, ...
        NMCPSN, NMCPSS, NMCPLN, NMCPLS, NCAPSN, NCAPSS, NCAPLN, NCAPLS, ...
        LFPPS, LFPPL]=loadResultsData(z); 

    fullData = [NMC18650N, NMC18650S, NMC20720N, NMC20720S,...
        NCA18650N, NCA18650S, NCA20720N, NCA20720S, LFP18650, LFP20720, ...
        NMCPSN, NMCPSS, NMCPLN, NMCPLS, NCAPSN, NCAPSS, NCAPLN, NCAPLS, ...
        LFPPS, LFPPL]; 
    cd OutputFiles
    if z ==1
        csvwrite('USavg.csv', fullData); 
    elseif z == 2
        csvwrite('NWPP.csv', fullData); 
    elseif z == 3
        csvwrite('RFCM.csv', fullData); 
    end
    cd ../
end
 