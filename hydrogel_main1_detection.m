
rawBeadsfilename=[data_path '/rawbeads.fcs'];
rawhydrogelfilename=[data_path '/rawhydrogel.fcs'];
%addpath '/home/watson/public/shintaku/github/MatlabCytofUtilities/fcs'
addpath 'W:\public\shintaku\github\MatlabCytofUtilities\fcs'
addpath 'W:\public\shintaku\github\image-preprocess-pygellan'
parameter.sensitivity=0.90;
parameter.edgethreshold=0.1;
parameter.sizerange=[20 80];
parameter.metricthreshold=0.01;
parameter.imadjust=0.06;
parameter.radii_overlap=0.5;
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
parameter.zfocus=min(iz_max);
parameter.t_sphericity=0.98;

%     b=uint16(stitch_532(row_shift+1:row_shift+im_size_x2,:,:));
b=uint16(stitch_bf);

%% detect fluorescence particles
R=uint16(stitch_488);
hydrogel=zscan_detect_hydrogel(R,parameter,'');
[intensity]=frame_measure_intensity_hydrogel(R,hydrogel);
hydrogel.Rintensity=intensity;
B=uint16(stitch_488);
[intensity]=frame_measure_intensity_hydrogel(B,hydrogel);
hydrogel.Bintensity=intensity;
figure(2)
visualize_color_image(R,B,b)
%     %beads = zscan_detect_particle(G,R,parameter);
%     if index~=1
%         hydrogel_all(index)=hydrogel;
%         if hydrogel.num_of_gel~=0
%             hydrogel_all(index).centers(:,1)=hydrogel_all(index).centers(:,1);
%             hydrogel_all(index).centers(:,2)=hydrogel_all(index).centers(:,2)+double(row_shift);
%         end
% %        beads_all(index)=beads;
% %        beads_all(index).centers(:,1)=beads_all(index).centers(:,1);
% %        beads_all(index).centers(:,2)=beads_all(index).centers(:,2)+double(row_shift);
%     else
% %        beads_all=beads;
%     end
%        hydrogel_all=hydrogel;
%end
% for jcnt=2:row_run-1
%     index=jcnt;
%     index_1=jcnt-1;
%     zscan_remove_duplication;
% end

%hydrogel=combine_all_frame_data(hydrogel_all);
%beads=combine_all_frame_data(beads_all);

% b=uint16(stitch_405(1:row_shift+im_size_x2,:,:));
% R=uint16(stitch_532(1:row_shift+im_size_x2,:,:));
% G=uint16(stitch_488(1:row_shift+im_size_x2,:,:));
% figure(2);hold off
% visualize_color_image(R,G,b);hold on
% viscircles(beads.centers(:,1:2),beads.radii,'Color','Red','LineWidth',0.1);
% viscircles(hydrogel.centers(:,1:2),hydrogel.radii,'Color','Blue','LineWidth',0.1);
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


subplot(4,1,1);hist(hydrogel_all.Bintensity,100);xlabel('Alexa')
subplot(4,1,2);hist(hydrogel_all.Rintensity,100);xlabel('Cy5')
subplot(4,1,3);hist(hydrogel_all.Rintensity./hydrogel_all.Bintensity,100);xlabel('normalized Cy5')
subplot(4,1,4);hist(hydrogel_all.radii,100);xlabel('radii (pixel)')

