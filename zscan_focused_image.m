
%function [stitch,im_info]=zscan_focused_image(magellan,channel,blend_alpha,sigma,...
%    col,row,ix,iy,iz,iz_max,num_frames,imshow_flag,filename)
function [stitch,im_info]=zscan_focused_image(magellan,channel,blend_alpha,sigma,...
    pygellan,imshow_flag,filename)
%% change here if the image size is changed.
% filet 12 pixels from a side.
%img_size=2048;img_filet_size=2048-1024;
img_size=double(magellan.image_width);
overlap=double(magellan.overlap);
img_filet_size=img_size-overlap(1);
col=pygellan.col;
row=pygellan.row;
zdepth=pygellan.pixZ;
num_frames=pygellan.num_frames;
%upper=min(iz_max-iz);
%lower=min(iz);

% Read pair of image (index 1 and 2) and calculate overlap
%z_slices=cell(magellan.get_z_slices_at(0,0));
%g = cell(magellan.read_image(channel(1),0,int64(z_slices{1}),0,0,'False',1,'False'));
axes=pyargs("channel", channel, "z", int32(0), "time", int32(0), "row", int32(0),"column", int32(0));
img = int16(magellan.read_image(axes));
%pymetadata=g{1,2};
%X0pos=pymetadata{'XPositionUm'};
%Y0pos=pymetadata{'YPositionUm'};

%z_slices=cell(magellan.get_z_slices_at(1,0));
%g = cell(magellan.read_image(channel,0,int64(z_slices{1}),0,1,'False',1,'False'));
%pymetadata=g{1,2};
%Xpos=pymetadata{'XPositionUm'};
%Ypos=pymetadata{'YPositionUm'};
%PixelSize=pymetadata{'PixelSizeUm'};
%overlap=1-sqrt((Xpos-X0pos)^2+(Ypos-Y0pos)^2)/PixelSize/img_size;

%imageSize=round(size(img)*(1-overlap));
%width=imageSize(1,1)*col;
%height=imageSize(1,2)*row;
width=int16(magellan.image_width)*col;
height=int16(magellan.image_height)*row;
%im_info.PixelSize=PixelSize;
im_info.overlap=overlap;
im_info.im_size=img_size;
im_info.im_filet_size=img_filet_size;
% width  = round(xMax - xMin);
% height = round(yMax - yMin);
% 
% Create a 2-D spatial reference object defining the size of the panorama.
xLimits = double([1 width]);
yLimits = double([1 height]);
panoramaView = imref2d(uint16([height width]), xLimits, yLimits);

% 
% blender = vision.AlphaBlender('Operation', 'Binary mask', ...
%     'MaskSource', 'Input port');
blender = vision.AlphaBlender('Operation', 'Blend', ...
    'OpacitySource', 'Input port');   

%
stitch=uint16(zeros(height,width,zdepth,num_frames+1));
for i_frames=0:num_frames
    for icnt=0:zdepth-1
        % Initialize the "empty" panorama.
        panorama = zeros([height width], 'like', img);
        for icol=0:col-1
            for irow=0:row-1
                index=irow+(icol)*row;
                axes=pyargs("channel", channel, "z", int32(icnt), "time", int32(0), "row", int32(irow),"column", int32(icol));
                img = int16(magellan.read_image(axes));
                %z_slices=cell(magellan.get_z_slices_at(index,0));
                %iz_index=iz(index+1)-lower+icnt+1;
                %g = cell(magellan.read_image(channel,0,int64(z_slices{iz_index}),i_frames,index,'False',1,'False'));

                if index~=0
                %     translationX=(1-overlap(1))*double((ix(index+1)-1))*double(img_size);
                %     translationY=(1-overlap(1))*double((iy(index+1)-1))*double(img_size);
                    translationX=(1-overlap(1))*double(icol)*double(img_size);
                    translationY=(1-overlap(1))*double(irow)*double(img_size);
                    tforms = affine2d([1 0 0; 0 1 0; translationX translationY 1]);
                else
                    tforms = affine2d([1 0 0; 0 1 0; 0 0 1]);
                end
                img_focus=uint16(imflatfield(double(uint16(img)),sigma));

                img_focus_filet=img_focus((img_size-img_filet_size)/2+1:(img_size+img_filet_size)/2,...
                    (img_size-img_filet_size)/2+1:(img_size+img_filet_size)/2);
                %pause
                %imshow(imadjust(img_focus_filet));drawnow;pause()
                
                warpedImage = imwarp(img_focus_filet, tforms, 'OutputView', panoramaView);
                %
                % Generate a binary mask.
                mask = double(imwarp(true(size(img_focus_filet,1),size(img_focus_filet,2)), tforms, 'OutputView', panoramaView))*blend_alpha;
                %
                % Overlay the warpedImage onto the panorama.
                panorama = step(blender, double(panorama), double(warpedImage), mask);
            end
        end
        stitch(:,:,icnt+1,i_frames+1)=uint16(panorama);
        if imshow_flag==1
            figure(2)
            imshow(imadjust(uint16(stitch(:,:,icnt+1,i_frames+1))))
            title(channel)
            drawnow
        end
        %pause
    end
end
for it=1:num_frames+1
    for izz=1:zdepth %upper+lower
        if izz==1 && it==1
            %im32write(stitch(:,:,izz,it),filename);
            imwrite(stitch(:,:,izz,it),filename);
        else
            imwrite(stitch(:,:,izz,it),filename,'WriteMode','append');
        end
    end
end
%plot3(ix,iy,iz,'o')
%imshow(imadjust(panorama))
end

