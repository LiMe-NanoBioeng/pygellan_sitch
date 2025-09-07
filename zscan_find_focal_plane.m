%function [ix,iy,iz,iz_max]=zscan_find_focal_plane(magellan,channel,pygellan,Type)
function [i_lap_z_max]=zscan_find_focal_plane(magellan,channel,pygellan,Type)
col=pygellan.col;
row=pygellan.row;
zdepth=pygellan.pixZ;
%%
% 
% ix=int16(zeros(col*row,1)); % 
% iy=int16(zeros(col*row,1));
% iz=int16(zeros(col*row,1));
% iz_max=int16(zeros(col*row,1));

    for icol=1:col
        for irow=1:row
    %%        index=irow-1+(icol-1)*row;
    %        lap_z_slice=double(zeros(zdepth,1));
    %        ix(index+1)=icol;
    %        iy(index+1)=irow*mod(icol,2)-(mod(icol,2)-1)*(row-irow+1);
    %        iz_max(index+1)=zdepth;
            for icnt=1:zdepth %potentially icnt should be 0:zdepth-1
                if  strcmp(Type, 'pygellan')
                %g = cell(magellan.read_image(channel,0,icnt,0,index,'False',1,'False'));
                axes=pyargs("channel", channel, "z", int32(icnt-1), "time", int32(0), "row", int32(irow-1),"column", int32(icol-1));
                g = magellan.read_image(axes);
                
                elseif strcmp(Type,'MDA')
                        iz_index= 1+pygellan.num_channels*icnt;
                        %g = cell(magellan.read_image(channel,0,int64(z_slices{iz_index}),...
                        %    i_frames,index,'False',1,'False'));
                        % the order of the images
                        imgindx=irow+row*(icol-1)+pre_region-1;
                    g=uint16(MDA{imgindx+1,1}{iz_index,1});
                end
                 img=uint16(double(uint16(g)));
                 %[gmag,gdir]=imgradient(img);
                 lap_z_slice(icnt)=fmeasure(img,'GDER');%std2(double(img));
            end
            [~,i_lap_z_max]=max(lap_z_slice);
    %%         iz(index+1)=i_lap_z_max;
    %             g = cell(magellan.read_image(channel,0,int64(z_slices{i_lap_z_max}),0,index,'False',1,'False'));
    %              img=uint16(double(uint16(g{1})).*flatfield_405);
    %              imshow(imadjust(imgaussfilt(img)))
             
        end
    end
end