function [Gbeads,Rbeads]=frame_remove_duplicated_hydrogel(Rbeads,Gbeads,mindistance)
% num_of_Gbeads=Gbeads.num_of_gel;%size(Gbeads.radii);
% num_of_Rbeads=Rbeads.num_of_gel;%size(Rbeads.radii);
meanradius=mean(Gbeads.radii);

[distance,flag]=compute_distance_matrix(Rbeads,Gbeads,mindistance,2);
[col,row]=find(distance<mindistance);

num_of_dup=size(col);
for icnt=1:num_of_dup(1)
    if Gbeads.metric(row(icnt))*Gbeads.intensity(row(icnt))<...
            Rbeads.metric(col(icnt))*Rbeads.intensity(col(icnt))
        Gbeads.unique(row(icnt))=false;
    elseif Gbeads.metric(row(icnt))*Gbeads.intensity(row(icnt))==...
            Rbeads.metric(col(icnt))*Rbeads.intensity(col(icnt))
        if abs(meanradius-Gbeads.radii(row(icnt)))<=abs(meanradius-Rbeads.radii(col(icnt)))
            Rbeads.unique(col(icnt))=false;
        else
            Gbeads.unique(col(icnt))=false;
        end
    else
        Rbeads.unique(col(icnt))=false;
    end
end

end