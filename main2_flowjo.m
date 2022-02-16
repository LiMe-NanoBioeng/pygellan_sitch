
function [obj]=main2_flowjo(gate,fcsfile,xml_filename)
%https://github.com/nolanlab/MatlabCytofUtilities
addpath(genpath('.\MatlabCytofUtilities'));

hold on

%% check out the following repository for I/O fcs and gatingML files
% https://github.com/nolanlab/MatlabCytofUtilities.git
%%
%read data from fcs file
[~,fcs_hdr,fcs_data]=fca_readfcs(fcsfile);

obj=gatingML(xml_filename); %create gatingML object
obj=obj.load_fcs_file(fcs_data,fcs_hdr); %associate the fcs data with these gates

visualize_flowjo_gate_result(obj,gate,{'red'});


end