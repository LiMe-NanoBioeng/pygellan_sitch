function visualize_flowjo_gate_result(obj,gate,color)
% center_x_col=1;
% center_y_col=2;
gateidnum=1;
%
if strcmp(gate,'machine_learning')
    index=find(ismember(obj.fcsData.uncompensated.params,'bool'));
    Signal_bool(:,gateidnum)=obj.fcsData.uncompensated.data(:,index);
    num_cells=nnz(Signal_bool(:,gateidnum));
    display([num2str(num_cells) ' hydrogels/particles found in gate ' gate])
else
    obj=obj.apply_gate(gate);
    num_cells=nnz(obj.gates.(gate).inGate);
    Signal_bool(:,gateidnum)=obj.gates.(gate).inGate;
    %compare(:,1)=obj.gates.(gate).inGate;
    %compare(:,2)=obj.fcsData.uncompensated.data(:,11);
    display([num2str(num_cells) ' hydrogels/particles found in gate ' obj.gates.(gate).name])
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
Signal_data=uncompData(logical(Signal_bool(:,gateidnum)),:);
viscircles(Signal_data(:,1:2),Signal_data(:,4),'Color',color{gateidnum},'LineWidth',0.1); %scatter plot of data
end