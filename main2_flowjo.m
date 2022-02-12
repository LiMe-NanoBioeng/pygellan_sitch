
function main2_flowjo(fcsfile,hydrogel_xml_filename)
%https://github.com/nolanlab/MatlabCytofUtilities
addpath(genpath('.\MatlabCytofUtilities'));

% ws_name='\11-May-2020';
%  rawbeadsfilename=[data_path '\rawbeads.fcs'];
% rawhydrogelfilename=[data_path '\rawhydrogel.fcs'];
%  beads_xml_filename=[data_path ws_name '_rawbeads.fcs_gates.xml']; 
% hydrogel_xml_filename=[data_path ws_name '_rawhydrogel.fcs_gates.xml']; 
%make the figure
%figure(2)
%visualize_color_image(R,G,b)
hold on
%[bSignal_bool]=visualize_flowjo_gate_result(fcsfile,beads_xml_filename,{'green';'red'});
[hSignal_bool]=visualize_flowjo_gate_result(fcsfile,hydrogel_xml_filename,{'blue'});


end