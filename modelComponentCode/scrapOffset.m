function [em_cu_offset, em_al_offset, em_steel_offset, nrg_cu_offset, nrg_al_offset, ...
        nrg_steel_offset] = scrapOffset(x_other)

otherMaterialEmbodied = csvread('otherMaterialEmbodied.csv', 1,2); 
% add hydro offsets for special items

% emissions/energy offsets associated with metals/other components
em_cu_offset = x_other(3,1) * otherMaterialEmbodied(1,3); 
nrg_cu_offset = x_other(3,1) * otherMaterialEmbodied(4,3); 

pd = makedist('Triangular', 'a', otherMaterialEmbodied(2,2), ...
	'b', otherMaterialEmbodied(1,2), 'c', otherMaterialEmbodied(3,2));
em_al_offset = x_other(2,1) * random(pd,1,1);
pd = makedist('Triangular', 'a', otherMaterialEmbodied(5,2), ...
	'b', otherMaterialEmbodied(4,2), 'c', otherMaterialEmbodied(6,2));
nrg_al_offset = x_other(2,1) * random(pd,1,1);

pd = makedist('Triangular', 'a', otherMaterialEmbodied(2,1), ...
	'b', otherMaterialEmbodied(1,1), 'c', otherMaterialEmbodied(3,1));
em_steel_offset = x_other(1,1) * random(pd,1,1);
pd = makedist('Triangular', 'a', otherMaterialEmbodied(5,1), ...
	'b', otherMaterialEmbodied(4,1), 'c', otherMaterialEmbodied(6,1));
nrg_steel_offset = x_other(1,1) * random(pd,1,1);
