function [stitch,pygellan]=import_main(data_path,sigma)
%clear all
%import py.pygellan.magellan_data.MagellanDataset
%import py.ndstorage.NDTiffPyramidDataset

listing=dir(data_path);
if any(matches({listing.name}, "Full resolution"))
    import py.ndstorage.Dataset
    %magellan=MagellanDataset(data_path);
    magellan=Dataset(data_path);
    axes=dictionary(magellan.axes);
    %num_col_row=cell(magellan.get_num_rows_and_cols());
    %col=int64(num_col_row{2});
    col=length(axes('column'));
    %row=int64(num_col_row{1});
    row=length(axes('row'));
    channel_names=axes('channel');
    num_of_channels=length(axes('channel'));
    num_of_z=length(axes('z'));
    num_frames=length(axes('time'));
    %num_frames=uint64(magellan.get_num_frames())-1;
    %pix_size=magellan.pixel_size_xy_um();

    metadata=dictionary(magellan.summary_metadata);
    pix_size=cell2mat(metadata('PixelSize_um'));
    %% register meta data in pygellan
    pygellan.col=col;pygellan.row=row;pygellan.pixZ=num_of_z;
    pygellan.num_frames=num_frames;pygellan.pix_size=pix_size;
   % pygellan.channels=channel_name;
    % channel names
    for icnt=1:length(channel_names);channel(icnt)=string(channel_names{icnt});end
    pygellan.channel=channel;
 
    % [ix,iy,iz,iz_max]=zscan_find_focal_plane(magellan,...
    %     channel(1),pygellan,'pygellan');
    [iz_max]=zscan_find_focal_plane(magellan,...
        channel(1),pygellan,'pygellan');
    % [ix,iy,iz,iz_max]=zscan_find_focal_plane(magellan,...
    %     channel(1),pygellan,'pygellan');

    %pygellan.ix=ix;pygellan.iy=iy;pygellan.iz=iz;
    pygellan.iz_max=iz_max;

    for icnt=1:length(channel_names)
%        [stitch.(extractAfter(string(channel_names{icnt}),'_')),~]=...
%            zscan_focused_image(magellan,channel(icnt),1,sigma,col,row,ix,iy,iz,iz_max,num_frames,1,fullfile(data_path,[char(channel{icnt}) '.tiff']));
        [stitch.(extractAfter(string(channel_names{icnt}),'_')),~]=...
            zscan_focused_image(magellan,channel(icnt),1,sigma,pygellan,1,...
            fullfile(data_path,[char(channel{icnt}) '.tiff']));
    end
else
    import py.pycromanager

    tif=dir(strcat(data_path,'/*ome.tif'));
    %metadata_file=dir(strcat(data_path,'/*metadata.txt'))
    region=cellstr(string(extractBefore(extractAfter({tif.name},'_Pos-'),'-')'));
    pos=regexp({tif.name}, '_Pos-\d+-(.*)\.ome\.tif', 'tokens')';
    posX=str2double(extractBefore(string(pos),'_'));
    posY=str2double(extractAfter(string(pos),'_'));
    tifinfo=cell2struct([{tif.name}',region,pos,num2cell(posX),num2cell(posY)],...
        {'filename','region','pos','X','Y'},2);
    col=posX;
    row=posY;
    MDA=bfopen(fullfile(data_path,tifinfo(1).filename));

    omeMeta=MDA{1, 4};
    stackSizeX = omeMeta.getPixelsSizeX(0).getValue(); % image width, pixels
    stackSizeY = omeMeta.getPixelsSizeY(0).getValue(); % image height, pixels
    stackSizeC = omeMeta.getPixelsSizeC(0).getValue(); % number of C
    iz_max = omeMeta.getPixelsSizeZ(0).getValue(); % number of Z slices
    num_frames = omeMeta.getPixelsSizeT(0).getValue(); % number of T
    stackPixelsOrder = omeMeta.getPixelsDimensionOrder(0);
    pix_size = double(omeMeta.getPixelsPhysicalSizeX(0).value());
    for icnt=0:max(col+1)*max(row+1)-1;ImageNameList(icnt+1)=string(omeMeta.getImageName(icnt));end
    
    if max(col)+1>1
        [~,ImageName,~]=fileparts(tifinfo(find(posX,1,"first")).filename);
        stackPlanePosX0=double(omeMeta.getPlanePositionX(0,0).value());
        ix2index=strmatch(extractBefore(ImageName,"."),ImageNameList);
        stackPlanePosX1=double(omeMeta.getPlanePositionX(ix2index-1,0).value());
        pygellan.overlapX=stackSizeX-(stackPlanePosX1-stackPlanePosX0)/pix_size;
    end
    if max(row)+1>1
        [~,ImageName,~]=fileparts(tifinfo(find(posY,1,"first")).filename);
        stackPlanePosY0=double(omeMeta.getPlanePositionY(0,0).value());
        iy2index=strmatch(extractBefore(ImageName,"."),ImageNameList);
        stackPlanePosY1=double(omeMeta.getPlanePositionY(iy2index-1,0).value());
        pygellan.overlapY=stackSizeY-(stackPlanePosY1-stackPlanePosY0)/pix_size;
    end
    for icnt=0:stackSizeC-1;channel_names(icnt+1) =...
            cell(omeMeta.getChannelName(0,icnt));end
    pygellan.pixX=stackSizeX;
    pygellan.pixY=stackSizeY;
    pygellan.pixZ=iz_max;
    
    pygellan.col=col;pygellan.row=row;

    pygellan.num_frames=num_frames;
    pygellan.num_channels=stackSizeC;
    pygellan.pix_size=pix_size;
    pygellan.channels=channel_names;
    pygellan.num_regions=cellfun(@str2num, region);

    % [ix,iy,iz,iz_max]=zscan_find_focal_plane(MDA,channel_names(1),...
    %     pygellan,'MDA');

    for icnt=1:length(channel_names)
        [stitch.(extractAfter(channel_names{icnt},'_')),~]=...
            mda_stitch_image(MDA,pygellan,icnt,1,sigma,1,data_path,...
            [char(channel_names{icnt}) '.tiff']);
    end
end

 %   [ix,iy,iz,iz_max]=zscan_find_focal_plane(magellan,channel(1),col,row);
 %   pygellan.ix=ix;pygellan.iy=iy;pygellan.iz=iz;pygellan.iz_max=iz_max;



end
