function flowjo_export_data2fcs(filename, hydrogel, hdr,type)
%{'center_x','center_y','zpos','radii','metric','mean_intensity','Green','Red','num_of_G','num_of_R'};
if strcmp(type,'hydrogel')
num_of_gels=length(hydrogel.radii);
data(:,1:3)=hydrogel.centers;
data(:,4)=hydrogel.radii;
data(:,5)=hydrogel.metric;
data(:,6)=hydrogel.intensity;
data(:,7)=hydrogel.intG;
data(:,8)=hydrogel.intR;
data(:,9)=hydrogel.numG;
data(:,10)=hydrogel.numR;
data(:,11)=[1:num_of_gels];
elseif strcmp(type,'raw_hydrogel')
num_of_gels=length(hydrogel.radii);
data(:,1:3)=hydrogel.centers;
data(:,4)=hydrogel.radii;
data(:,5)=hydrogel.metric;
data(:,6)=hydrogel.intensity;
data(:,7)=hydrogel.Bintensity;
data(:,8)=hydrogel.Rintensity;
data(:,9)=hydrogel.Uintensity;
data(:,10)=[1:num_of_gels];
else
num_of_gels=length(hydrogel.radii);
data(:,1:3)=hydrogel.centers;
data(:,4)=hydrogel.radii;
data(:,5)=hydrogel.metric;
data(:,6)=hydrogel.volume;
data(:,7)=hydrogel.Red;
data(:,8)=hydrogel.Green;
data(:,9)=hydrogel.Red_vol;
data(:,10)=hydrogel.Green_vol;
data(:,11)=[1:num_of_gels];
end

marker_names={hdr.par.name};
channel_names={hdr.par.name};
fca_writefcs(filename, data, marker_names,channel_names,hdr)
end