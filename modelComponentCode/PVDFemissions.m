function [em_pvdf] = PVDFemissions(x_other)

split1 = 0;
split2 = 1 - split1; 
em_pvdf_pfcs = split1*x_other(5,1)/107000 ...% moles of PVDF 
    * 88*6500*...
    (107000/64.0360)/2; % equivalent forcing from PFCs  -->this is the low end


em_pvdf = split2*x_other(5,1)/64.0360 * (12.01+16*2) + em_pvdf_pfcs; 