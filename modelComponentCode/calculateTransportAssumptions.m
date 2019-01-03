function [transportationAssumptions] = calculateTransportAssumptions

% load data from a CSV file

transportationAssumptions = csvread('transportationAssumptions.csv', 1,1); 
transportationAssumptions = transportationAssumptions/907.185; %convert to per kg mile 

% make triangular distributions and pull a number

