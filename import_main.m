function [stitch,pygellan]=import_main(data_path,sigma)
%clear all
import py.pygellan.magellan_data.MagellanDataset 
%data_path='U:\Shintaku\20200901\nishikawa_beads8R6G3_2';
%sigma=80;%imflatfield parameter



magellan=MagellanDataset(data_path);
num_col_row=cell(magellan.get_num_rows_and_cols());
col=int64(num_col_row{2});
row=int64(num_col_row{1});
pygellan.col=col;pygellan.row=row;
num_frames=uint64(magellan.get_num_frames())-1;
pix_size=magellan.pixel_size_xy_um();
pygellan.num_frames=num_frames;pygellan.pix_size=pix_size;
channel_names=cell(magellan.get_channel_names());
pygellan.channels=channel_names;
for icnt=1:length(channel_names)
    channel(icnt)=string(channel_names{icnt});
end

[ix,iy,iz,iz_max]=zscan_find_focal_plane(magellan,channel(1),col,row);
pygellan.ix=ix;pygellan.iy=iy;pygellan.iz=iz;pygellan.iz_max=iz_max;
%[stitch_405,im_info]=zscan_focused_image(magellan,channel(1),1,sigma,col,row,ix,iy,iz,iz_max,num_frames,1,'stitch_405.tiff');
pygellan.channel=channel;
for icnt=1:length(channel_names)
[stitch.(channel{icnt}),~]=zscan_focused_image(magellan,channel(icnt),1,sigma,col,row,ix,iy,iz,iz_max,num_frames,1,[data_path '\' char(channel(1)) '.tiff']);
%[stitch_532,~]=zscan_focused_image(magellan,channel(3),1,sigma,col,row,ix,iy,iz,iz_max,num_frames,1,cat(2,data_path,'\stitch_532.tiff'));
%[stitch_bf,~]=zscan_focused_image(magellan,channel(1),1,sigma,col,row,ix,iy,iz,iz_max,num_frames,1,cat(2,data_path,'\stitch_bf.tiff'));
end
end
