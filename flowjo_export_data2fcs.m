function flowjo_export_data2fcs(parameter,filename, hydrogel, hdr)
%{'center_x','center_y','zpos','radii','metric','mean_intensity','Green','Red','num_of_G','num_of_R'};
num_of_gels=length(hydrogel.radii);
data(:,1:3)=hydrogel.centers;
num_of_par=size(hdr.par);
for icnt=4:num_of_par(2)-2
    data(:,icnt)=hydrogel.(hdr.par(icnt).name);
end
data(:,num_of_par(2)-1)=[1:num_of_gels];
data(:,num_of_par(2))=1; % default value
marker_names={hdr.par.name};
channel_names={hdr.par.name};
fca_writefcs(filename, data, marker_names,channel_names,hdr)
end