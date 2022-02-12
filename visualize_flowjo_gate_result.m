function [Signal_bool]=visualize_flowjo_gate_result(fcs_filename,xml_filename,color)
% center_x_col=1;
% center_y_col=2;
gateidnum=1;

%% check out the following repository for I/O fcs and gatingML fiels
% https://github.com/nolanlab/MatlabCytofUtilities.git
%%
%read data from fcs file
[~,fcs_hdr,fcs_data]=fca_readfcs(fcs_filename);

obj=gatingML(xml_filename); %create gatingML object
obj=obj.load_fcs_file(fcs_data,fcs_hdr); %associate the fcs data with these gates

%Note that gate names as specified in the Gating-ML file may be adjusted to
%fit variable name requirements. The original name can be found in 
%obj.gates.(gate_name).name

%apply all gates and report number of cells in each
gateNames=fieldnames(obj.gates);
numGates=length(gateNames);
for i=1:numGates
    obj=obj.apply_gate(gateNames{i});
    num_cells=nnz(obj.gates.(gateNames{i}).inGate);
    display([num2str(num_cells) ' hydrogels/particles found in gate ' obj.gates.(gateNames{i}).name])
    if i==1
        Signal_bool(:,1)=obj.gates.(gateNames{i}).inGate;
    else
        Signal_bool(:,i)=obj.gates.(gateNames{i}).inGate;
    end
        
end
Error_bool=logical(~Signal_bool(:,gateidnum));

%scatter plot of uncompensated data within a gate using a transformation from 
%the Gating-ML file
%trans_names=fieldnames(obj.transforms)

myParams=obj.fcsData.uncompensated.params; %list of measured parameters of uncompensated data
uncompData=obj.fcsData.uncompensated.data; %the full matrix of uncompensated data

Error_data=uncompData(Error_bool(:,gateidnum),:); % filtered data to chosen parameters and cells in the gate
%Error_data2=uncompData(Error_bool2,[1:11]);
%viscircles(Error_data(:,1:2),Error_data(:,4),'Color','blue','LineWidth',0.1); %scatter plot of data
plot(Error_data(:,1),Error_data(:,2),'xb'); %scatter plot of data
Signal_data=uncompData(Signal_bool(:,gateidnum),:);
viscircles(Signal_data(:,1:2),Signal_data(:,4),'Color',color{gateidnum},'LineWidth',0.1); %scatter plot of data
for icnt=2:numGates
Signal_data=uncompData(Signal_bool(:,icnt),:);
viscircles(Signal_data(:,1:2),Signal_data(:,4),'Color',color{icnt-1},'LineWidth',0.1); %scatter plot of data
end
xlabel(myParams{1})
ylabel(myParams{2})
end