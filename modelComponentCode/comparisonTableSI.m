USavg = csvread('USavg.csv');
NWPP = csvread('NWPP.csv');
RFCM = csvread('RFCM.csv');

% sum the parts, manufacturing, and total (with transportation)
transportationDataUSkg = zeros(size(USavg,1),8); 
materialDataUSkg = zeros(size(USavg,1),8); 
manufacturingDataUSkg = zeros(size(USavg,1),8); 

transportationDataUSMJ = zeros(size(USavg,1),8); 
materialDataUSMJ = zeros(size(USavg,1),8); 
manufacturingDataUSMJ = zeros(size(USavg,1),8);

energyDensity = zeros(size(USavg,1), 8); 
for i=1:8
    m = 28*(i-1);
    for n=1:size(USavg,1)
        energyDensity(n,i) = USavg(n, 1+m); 
        
        transportationDataUSkg(n,i) = sum(USavg(n, 3+m:4+m))/USavg(n, 1+m);
        materialDataUSkg(n,i) =  (USavg(n, 5+m) + USavg(n, 7+m))/USavg(n, 1+m);
        manufacturingDataUSkg(n,i) = (USavg(n, 6+m) + USavg(n, 8+m))/USavg(n, 1+m);
        
        transportationDataUSMJ(n,i) = sum(USavg(n, 14+m:15+m))/USavg(n, 1+m);
        materialDataUSMJ(n,i) =  (USavg(n, 16+m) + USavg(n, 18+m))/USavg(n, 1+m);
        manufacturingDataUSMJ(n,i) = (USavg(n, 17+m) + USavg(n, 19+m))/USavg(n, 1+m);
    end
end

energyDensity = [reshape(energyDensity(:,1:4), [], 1), reshape(energyDensity(:,5:8), [], 1)]; 
transportationDataUSkg = [reshape(transportationDataUSkg(:, 1:4), [], 1), reshape(transportationDataUSkg(:, 5:8), [], 1)]; 
transportationDataUSMJ = [reshape(transportationDataUSMJ(:, 1:4), [], 1), reshape(transportationDataUSMJ(:, 5:8), [], 1)];
materialDataUSkg = [reshape(materialDataUSkg(:, 1:4), [], 1), reshape(materialDataUSkg(:, 5:8), [], 1)]; 
materialDataUSMJ = [reshape(materialDataUSMJ(:, 1:4), [], 1), reshape(materialDataUSMJ(:, 5:8), [], 1)];
manufacturingDataUSkg = [reshape(manufacturingDataUSkg(:, 1:4), [], 1), reshape(manufacturingDataUSkg(:, 5:8), [], 1)]; 
manufacturingDataUSMJ = [reshape(manufacturingDataUSMJ(:, 1:4), [], 1), reshape(manufacturingDataUSMJ(:, 5:8), [], 1)];

totalUSkg = transportationDataUSkg + materialDataUSkg + manufacturingDataUSkg; 
totalUSMJ = transportationDataUSMJ + materialDataUSMJ + manufacturingDataUSMJ; 

% spit out NMC numbers
disp('NMC energy density')
median(energyDensity(:,1))

disp('NMC baseline kg')
a = [median(materialDataUSkg(:,1)), median(manufacturingDataUSkg(:,1)), median(totalUSkg(:,1))]

disp('NMC lower bound kg')
a = [prctile(materialDataUSkg(:,1), 2.5), prctile(manufacturingDataUSkg(:,1), 2.5), prctile(totalUSkg(:,1), 2.5)]

disp('NMC upper bound kg')
a = [prctile(materialDataUSkg(:,1), 97.5), prctile(manufacturingDataUSkg(:,1), 97.5), prctile(totalUSkg(:,1), 97.5)]

disp('NMC baseline MJ')
a = [median(materialDataUSMJ(:,1)), median(manufacturingDataUSMJ(:,1)), median(totalUSMJ(:,1))]

disp('NMC lower bound MJ')
a = [prctile(materialDataUSMJ(:,1), 2.5), prctile(manufacturingDataUSMJ(:,1), 2.5), prctile(totalUSMJ(:,1), 2.5)]

disp('NMC upper bound MJ')
a = [prctile(materialDataUSMJ(:,1), 97.5), prctile(manufacturingDataUSMJ(:,1), 97.5), prctile(totalUSMJ(:,1), 97.5)]

% spit out NCA numbers
disp('NCA energy density')
median(energyDensity(:,2))

disp('NCA baseline kg')
a = [median(materialDataUSkg(:,2)), median(manufacturingDataUSkg(:,2)), median(totalUSkg(:,2))]

disp('NCA lower bound kg')
a = [prctile(materialDataUSkg(:,2), 2.5), prctile(manufacturingDataUSkg(:,2), 2.5), prctile(totalUSkg(:,2), 2.5)]

disp('NCA upper bound kg')
a = [prctile(materialDataUSkg(:,2), 97.5), prctile(manufacturingDataUSkg(:,2), 97.5), prctile(totalUSkg(:,2), 97.5)]

disp('NCA baseline MJ')
a = [median(materialDataUSMJ(:,2)), median(manufacturingDataUSMJ(:,2)), median(totalUSMJ(:,2))]

disp('NCA lower bound MJ')
a = [prctile(materialDataUSMJ(:,2), 2.5), prctile(manufacturingDataUSMJ(:,2), 2.5), prctile(totalUSMJ(:,2), 2.5)]

disp('NCA upper bound MJ')
a = [prctile(materialDataUSMJ(:,2), 97.5), prctile(manufacturingDataUSMJ(:,2), 97.5), prctile(totalUSMJ(:,2), 97.5)]