function hydrogel_main1_detection(parameter,stitch_bf,stitch_488,stitch_532)
project=[];
experiment=[];
cells=[];
start_time=datetime('now','TimeZone','local','Format',' HH:mm:ss');
data_path=parameter.data_path;
fcsfile=parameter.fcsname;
%rawBeadsfilename=[data_path '/9_R6G6.fcs'];
rawhydrogelfilename=[data_path '/' fcsfile,'.fcs'];
%addpath '/home/watson/public/shintaku/github/MatlabCytofUtilities/fcs'
%addpath 'W:\public\shintaku\github\MatlabCytofUtilities\fcs'
%addpath 'W:\public\shintaku\github\image-preprocess-pygellan'

cutoff.cluster=8;
cutoff.radii=15;
cutoff.intensity=5e2;
cutoff.low_intensity=5e2;
parameter.cutoff=cutoff;

parameter.thresholdG=0.5;
parameter.thresholdR=0.5;
parameter.filterMagG=50;
parameter.filterMagR=50;
parameter.mindistance=0.9;
parameter.zfocus=min(parameter.iz_max);
parameter.t_sphericity=0.98;

%     b=uint16(stitch_532(row_shift+1:row_shift+im_size_x2,:,:));
b=uint16(stitch_bf);
R=uint16(stitch_532);
B=uint16(stitch_488);


hydrogel=zscan_detect_hydrogel(b,parameter,'');

[intensity]=frame_measure_intensity_hydrogel(R,hydrogel);
hydrogel.Rintensity=intensity;
[intensity]=frame_measure_intensity_hydrogel(B,hydrogel);
hydrogel.Bintensity=intensity;
figure(2)
visualize_color_image(R,B,b)
end_time=datetime('now','TimeZone','local','Format',' HH:mm:ss');
%delete(p)


%% export an fcs file
% [fcs_hdr]=flowjo_create_fcs_metadata(start_time,end_time,project,experiment,cells,rawBeadsfilename,data_path,length(beads.radii),'beads');
% flowjo_export_data2fcs(rawBeadsfilename, beads, fcs_hdr,'beads')
% 
% [fcs_hdr]=flowjo_create_fcs_metadata(start_time,end_time,project,experiment,cells,rawRedfilename,data_path,length(Gbeads.radii),'beads')
% flowjo_export_data2fcs(rawRedfilename, Rbeads, fcs_hdr,'Red')

 [fcs_hdr]=flowjo_create_fcs_metadata(start_time,end_time,project,experiment,cells,rawhydrogelfilename,data_path,length(hydrogel.radii),'raw_hydrogel');
 flowjo_export_data2fcs(rawhydrogelfilename, hydrogel, fcs_hdr,'raw_hydrogel')


subplot(4,1,1);hist(hydrogel.Bintensity,100);xlabel('Alexa')
subplot(4,1,2);hist(hydrogel.Rintensity,100);xlabel('Cy5')
subplot(4,1,3);hist(hydrogel.Rintensity./hydrogel.Bintensity,100);xlabel('normalized Cy5')
subplot(4,1,4);hist(hydrogel.radii,100);xlabel('radii (pixel)')
end
