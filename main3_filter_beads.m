
function [Mdl1]=main3_filter_beads(obj,gate)
obj=obj.apply_gate(gate);
fcsData =obj.fcsData.uncompensated;
%fcsData.table = table(fcsData.data(:,4:9),'VariableNames',fcsData.params(1,4:9))
fcsData.gate=obj.gates.(gate).inGate;
%tic
rng('default')
t = templateTree('Reproducible',true);

Mdl1 = fitcensemble(fcsData.data(:,4:8),fcsData.gate,'OptimizeHyperparameters','auto','Learners',t, ...
    'HyperparameterOptimizationOptions',struct('AcquisitionFunctionName','expected-improvement-plus'))
%toc
%rsLoss1 = resubLoss(Mdl1)
end