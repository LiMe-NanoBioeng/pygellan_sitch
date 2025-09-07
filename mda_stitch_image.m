
function [stitch,im_info]=mda_stitch_image(MDA,pygellan,i_channel,blend_alpha,sigma,...
    imshow_flag,data_path,filename)
for i_region=min(pygellan.num_regions):max(pygellan.num_regions)
    %% change here if the image size is changed.
    % filet 12 pixels from a side.
    %img_size=2048;img_filet_size=2048-1024;
    img_size=[pygellan.pixY pygellan.pixX];
    omeMeta=MDA{1, 4};
    [index]=find(pygellan.num_regions==i_region);
    col=max(pygellan.col(index))+1;
    row=max(pygellan.row(index))+1;
    
    pre_region=min(find(pygellan.num_regions==i_region))-1;

    iz_max=pygellan.pixZ;
    img=uint16(MDA{1,1}{1,1});
    %imageSize=round(size(img)*(1-overlap));
    %width=imageSize(1,1)*col;% compute the width of the stitched image
    %height=imageSize(1,2)*row;% compute the height of the stitched image

    im_info.img_size=[pygellan.pixY pygellan.pixX];%
    im_info.overlap=[pygellan.overlapY pygellan.overlapX];
    im_info.img_filet_size=img_size-round(im_info.overlap*0.5)+2;% 2 is the magic number
    im_info.PixelSize=pygellan.pix_size;
    width=pygellan.pixX*col-round(im_info.overlap(2)*(col-1));
    height=pygellan.pixY*row-round(im_info.overlap(1)*(row-1));

    % Create a 2-D spatial reference object defining the size of the panorama.
    xLimits = double([1 width]);
    yLimits = double([1 height]);
    panoramaView = imref2d(uint16([height width]), xLimits, yLimits);
    num_frames=pygellan.num_frames;
    %
    % blender = vision.AlphaBlender('Operation', 'Binary mask', ...
    %     'MaskSource', 'Input port');
    blender = vision.AlphaBlender('Operation', 'Blend', ...
        'OpacitySource', 'Input port');
    %
    stitch=uint16(zeros(height,width,iz_max,num_frames));
    pygellan.origin=[double(omeMeta.getPlanePositionY(pre_region,0).value())...
        double(omeMeta.getPlanePositionX(pre_region,0).value())];

    %for i_frames=0:num_frames-1
    i_frames=0;
        for icnt=0:iz_max-1
            % Initialize the "empty" panorama.
            panorama = zeros([height width], 'like', img);
            for icol=1:col
                for irow=1:row
                    %index=irow-1+(icol-1)*row;
                    %z_slices=cell(magellan.get_z_slices_at(index,0));
                    if strcmp(omeMeta.getPixelsDimensionOrder(0).getValue(),"XYCZT")
                    iz_index=i_channel-1+pygellan.num_channels*icnt+...
                        pygellan.num_channels*iz_max*i_frames;
                    elseif  strcmp(omeMeta.getPixelsDimensionOrder(0).getValue(),"XYZCT")
                    iz_index=iz_max*(i_channel-1)+icnt+...
                        pygellan.num_channels*iz_max*i_frames;
                    end
                    %g = cell(magellan.read_image(channel,0,int64(z_slices{iz_index}),...
                    %    i_frames,index,'False',1,'False'));
                    % the order of the images
                    imgindx=irow+row*(icol-1)+pre_region-1;
                    % read metadata from micro-manager
                    metafile=fullfile(data_path,[char(omeMeta.getImageName(imgindx)) '_metadata.txt']);
                    fid = fopen(metafile); % Opening the file
                    raw = fread(fid,inf); % Reading the contents
                    str = char(raw'); % Transformation
                    fclose(fid); % Closing the file
                    %PixelAffine
                    metadata = jsondecode(str); % Using the jsondecode function to parse JSON from string
                    FrameKey=['FrameKey_' num2str(i_frames) '_' num2str(i_channel-1) '_' num2str(icnt)];
                    PixelAffine=[reshape(double(string(strsplit(metadata.(FrameKey).PixelSizeAffine,';'))),[3,2])'; 0 0 1];
                    PixelAffine(1,3)=0;%perhaps mico-manager bug
                    %
                    % change signs to ivert the y axis
                    PixelAffine(1,2)=-PixelAffine(1,2);
                    PixelAffine(2,1)=-PixelAffine(2,1);
                    %if iz_index~=1
                    Xpos=double(omeMeta.getPlanePositionX(imgindx,0).value());
                    Ypos=double(omeMeta.getPlanePositionY(imgindx,0).value());
                    %translationX=width-im_info.img_filet_size(1)-double((Xpos-pygellan.origin(2))/pygellan.pix_size);
                    %translationY=height-im_info.img_filet_size(2)-double((Ypos-pygellan.origin(1))/pygellan.pix_size);
                    tforms1=affine2d(PixelAffine);
                    [translationX,translationY]=transformPointsInverse(tforms1,...
                        (Xpos-pygellan.origin(2)),(Ypos-pygellan.origin(1)));
                    tforms = affine2d([1 0 0; 0 1 0;...
                        width+translationX-im_info.img_size(2)...
                        translationY 1]);
                    g = uint16(MDA{imgindx+1,1}{iz_index+1,1});
                    %img_focus=uint16(imflatfield(double(uint16(g)),sigma));
                    % img_focus=g;
                    % img_focus_filet=...
                    %     img_focus(round((im_info.img_size(1)-im_info.img_filet_size(1))/2)+1:...
                    %     round((im_info.img_size(1)+im_info.img_filet_size(1))/2),...
                    %     round((im_info.img_size(2)-im_info.img_filet_size(2))/2)+1:...
                    %     round((im_info.img_size(2)+im_info.img_filet_size(2))/2));
                    img_focus_filet=g;
                    %pause
                    %imshow(imadjust(img_focus_filet));drawnow;pause()
                    warpedImage = imwarp(img_focus_filet, tforms, 'OutputView', panoramaView);
                    %
                    % Generate a binary mask.
                    mask = double(imwarp(true(size(img_focus_filet,1),size(img_focus_filet,2)), ...
                        tforms, 'OutputView', panoramaView))*blend_alpha;
                    %
                    % Overlay the warpedImage onto the panorama.
                    panorama = step(blender, double(panorama), double(warpedImage), mask);
                    %imshow(imadjust(panorama));
                    % pause
                end
            end
                stitch(:,:,icnt+1,i_frames+1)=uint16(panorama);
            
            if imshow_flag==1
                h=figure(1);
                imshow(imadjust(uint16(stitch(:,:,icnt+1,i_frames+1))))
                title(append('region',string(i_region),...
                    '-T',string(i_frames),...
                    '-',pygellan.channels(i_channel),...
                    '-Z',string(icnt)))
                drawnow
            end
            %pause
        end
    %end
    for it=1:num_frames
        for izz=1:iz_max
            if izz==1 && it==1
                %im32write(stitch(:,:,izz,it),filename);
                imwrite(stitch(:,:,izz,it),...
                    fullfile(data_path,append('region',string(i_region),'_T',string(it),'_',filename)));
            else
                imwrite(stitch(:,:,izz,it),...
                    fullfile(data_path,append('region',string(i_region),'_T',string(it),'_',filename)),...
                    'WriteMode','append');
            end
        end
    end
    close(h)
end
%plot3(ix,iy,iz,'o')
%imshow(imadjust(panorama))
end

