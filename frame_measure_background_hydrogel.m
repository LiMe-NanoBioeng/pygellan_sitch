function [intensity]=frame_measure_background_hydrogel(I,hydrogel)
pad=2 ;
num_of_gel=hydrogel.num_of_gel;
hydrogel.intensity=zeros(num_of_gel,1);
%% mean intensity
img_size=size(I);
centers=int16([hydrogel.centers]);
radii=hydrogel.radii;
intensity=zeros(num_of_gel,1);
for igel=1:num_of_gel
%     [rowstart,rowend,colstart,colend]=...
%         frame_create_sub_image(centers(igel,2),centers(igel,1),...
%         radii(igel),pad,img_size(1),img_size(2));
%     subimage=I(rowstart:rowend,colstart:colend);
%    subimg_size=size(subimage);
    C=zeros(img_size);
    
    C(centers(2),centers(1))=1;
    R=bwdist(C);
    Label=R <= radii(igel);
    %vol_Label(:,:,icnt)=int8(vol_Label(:,:,icnt))+int8(Label);
    Lprop=regionprops(Label,subimage,'MeanIntensity');
    intensity(igel)=Lprop.MeanIntensity;
end

end