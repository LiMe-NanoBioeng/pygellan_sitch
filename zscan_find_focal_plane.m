function [ix,iy,iz,iz_max]=zscan_find_focal_plane(magellan,channel,col,row)

ix=int16(zeros(col*row,1));
iy=int16(zeros(col*row,1));
iz=int16(zeros(col*row,1));
iz_max=int16(zeros(col*row,1));

for icol=1:col
    for irow=1:row
        index=irow-1+(icol-1)*row;
        z_slices=cell(magellan.get_z_slices_at(index,0));
        lap_z_slice=double(zeros(length(z_slices),1));
        ix(index+1)=icol;
        iy(index+1)=irow*mod(icol,2)-(mod(icol,2)-1)*(row-irow+1);
        iz_max(index+1)=length(z_slices);
        for icnt=1:length(z_slices)
            g = cell(magellan.read_image(channel,0,int64(z_slices{icnt}),0,index,'False',1,'False'));
             img=uint16(double(uint16(g{1})));
             %[gmag,gdir]=imgradient(img);
             lap_z_slice(icnt)=fmeasure(img,'GDER');%std2(double(img));
        end
        [~,i_lap_z_max]=max(lap_z_slice);
         iz(index+1)=i_lap_z_max;
%             g = cell(magellan.read_image(channel,0,int64(z_slices{i_lap_z_max}),0,index,'False',1,'False'));
%              img=uint16(double(uint16(g{1})).*flatfield_405);
%              imshow(imadjust(imgaussfilt(img)))
         
    end
end
end