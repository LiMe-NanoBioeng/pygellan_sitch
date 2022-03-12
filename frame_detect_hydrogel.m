function [hydrogel]=frame_detect_hydrogel(I,rho,sizerange,sensitivity,edgethreshold,metricthreshold,radii_overlap)

[centers, radii, metric] = imfindcircles(rho,sizerange,...
'Sensitivity',sensitivity,'EdgeThreshold',edgethreshold,'ObjectPolarity','bright','Method','PhaseCode');
%% create hydrogel structure
th_metric=find(metric>metricthreshold);
hydrogel = struct('centers',centers(th_metric,:),...
    'radii',radii(th_metric),...
    'metric',metric(th_metric));
num_of_gel=length(hydrogel.radii);
hydrogel.num_of_gel=num_of_gel;
hydrogel.unique=true(size(hydrogel.radii));
[intensity,variance]=frame_measure_intensity_hydrogel(imgradient(I),hydrogel);
hydrogel.intensity=intensity;
hydrogel.variance=variance;
%hydrogel.var=variance;


%% find unique hydrogel
if hydrogel.num_of_gel>1
    [hydrogel,~]=frame_remove_duplicated_hydrogel(hydrogel,hydrogel,mean(radii)*radii_overlap);
end
%
unique_gels=find(hydrogel.unique);
fieldlist=fieldnames(hydrogel);
for icnt=1:length(fieldlist)
    length_of_field=length(hydrogel.(fieldlist{icnt}));
    if length_of_field>1
        hydrogel.(fieldlist{icnt})=hydrogel.(fieldlist{icnt})(unique_gels,:);
    end
end
num_of_gel=length(unique_gels);
hydrogel.num_of_gel=num_of_gel;

end