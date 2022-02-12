function [stitch,pygellan]=import_main(data_path,sigma,imagedata)
%clear all
import py.pygellan.magellan_data.MagellanDataset

magellan=MagellanDataset(data_path);
num_col_row=cell(magellan.get_num_rows_and_cols());
col=int64(num_col_row{2});
row=int64(num_col_row{1});
num_frames=uint64(magellan.get_num_frames())-1;
pix_size=magellan.pixel_size_xy_um();
channel_names=cell(magellan.get_channel_names());

pygellan.col=col;pygellan.row=row;
pygellan.num_frames=num_frames;pygellan.pix_size=pix_size;
pygellan.channels=channel_names;
for icnt=1:length(channel_names)
    channel(icnt)=string(channel_names{icnt});
end
pygellan.channel=channel;

if isempty(imagedata)
    [ix,iy,iz,iz_max]=zscan_find_focal_plane(magellan,channel(1),col,row);
    pygellan.ix=ix;pygellan.iy=iy;pygellan.iz=iz;pygellan.iz_max=iz_max;

    for icnt=1:length(channel_names)
        [stitch.(channel{icnt}),~]=zscan_focused_image(magellan,channel(icnt),1,sigma,col,row,ix,iy,iz,iz_max,num_frames,1,fullfile(data_path,[char(channel{icnt}) '.tiff']));
    end
else
    stitch=[];
end
end
