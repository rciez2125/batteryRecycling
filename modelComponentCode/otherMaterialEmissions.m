function [e_other_embodied, n_other_embodied] = otherMaterialEmissions(x_other)

%pull embodied energy numbers and normalize to per kg battery 
% load csv data of embodied energy 
embodiedData= csvread('otherMaterialEmbodied.csv', 1, 2);

e_other_embodied = zeros(1, length(embodiedData)); 
n_other_embodied = zeros(1, length(embodiedData)); 
for i=1:length(embodiedData)
    if embodiedData(2,i) == embodiedData(3,i)
        e_other_embodied(1,i) = embodiedData(1,i); 
        n_other_embodied(1,i) = embodiedData(4,i); 
    else %make a triangular distribution 
        pd_e = makedist('Triangular', 'a', embodiedData(2, i), 'b', embodiedData(1, i), 'c', embodiedData(3,i));
        pd_n = makedist('Triangular', 'a', embodiedData(5, i), 'b', embodiedData(4, i), 'c', embodiedData(6,i));
        e_other_embodied(1,i) = random(pd_e, 1,1);
        n_other_embodied(1,i) = random(pd_n, 1,1); 
    end
end

%scale based on input amount of materials 
e_other_embodied = e_other_embodied*x_other; 
n_other_embodied = n_other_embodied*x_other; 
