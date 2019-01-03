function [e_cu_offset, e_fe_offset, e_ni_offset, e_co_offset, ...
    e_cement_offset, n_cu_offset, n_fe_offset, n_ni_offset, n_co_offset, ...
    n_cement_offset] = ...
    pyroOffset(cu_offset, fe_offset, ni_offset, co_offset, cement_offset)

otherMaterialEmbodied = csvread('otherMaterialEmbodied.csv', 1,2); 
cathodeMaterial = csvread('cathodeAssumptions.csv', 1,2); 
pyroOffset = csvread('pyroOffset.csv',1,1); 

e_cu_offset = cu_offset * otherMaterialEmbodied(1,3); 
n_cu_offset = cu_offset * otherMaterialEmbodied(4,3); 

e_fe_offset = fe_offset * pyroOffset(2,1); 
n_fe_offset = fe_offset * pyroOffset(5,1); 

pd = makedist('Triangular', 'a',pyroOffset(2,3), 'b',pyroOffset(1,3), 'c', pyroOffset(3,3)); %not sure if these should be the same as other model 
e_ni_offset = ni_offset * random(pd,1,1) * (17.008 + 58.69)/58.69; %scale nickel output to nickel hydroxide
pd = makedist('Triangular', 'a',pyroOffset(5,3), 'b',pyroOffset(4,3), 'c', pyroOffset(6,3));
n_ni_offset = ni_offset * random(pd,1,1) * (17.008 + 58.69)/58.69;  %scale nickel output to nickel hydroxide

pd = makedist('Triangular', 'a', cathodeMaterial(2,2), 'b',cathodeMaterial(1,2), 'c', cathodeMaterial(3,2));
e_co_offset = co_offset * (random(pd,1,1)); 
e_co_offset = e_co_offset * (15.99 + 58.93)/58.93; %scale for CoO

pd = makedist('Triangular', 'a', cathodeMaterial(5,2), 'b',cathodeMaterial(4,2), 'c', cathodeMaterial(6,2));
n_co_offset = co_offset * (random(pd,1,1));
n_co_offset = n_co_offset * (15.99 + 58.93)/58.93; %scale for CoO

e_cement_offset = cement_offset * pyroOffset(1,2); 
n_cement_offset = cement_offset * pyroOffset(4,2); 

%should probably have these pull from a csv file