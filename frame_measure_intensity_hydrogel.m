function [intensity,variance]=frame_measure_intensity_hydrogel(I,hydrogel)
pad=2 ;
num_of_gel=hydrogel.num_of_gel;
hydrogel.intensity=zeros(num_of_gel,1);
%% mean intensity
img_size=size(I);
centers=int16([hydrogel.centers]);
radii=hydrogel.radii;
intensity=zeros(num_of_gel,1);
variance=zeros(num_of_gel,1);
for igel=1:num_of_gel
    [rowstart,rowend,colstart,colend]=...
        frame_create_sub_image(centers(igel,2),centers(igel,1),...
        radii(igel),pad,img_size(1),img_size(2));
    subimage=I(rowstart:rowend,colstart:colend);
    subimg_size=size(subimage);
    C=zeros(subimg_size);
    
    C(round((subimg_size(1)+1)/2),round((subimg_size(2)+1)/2))=1;
    R=bwdist(C);
    Label=R <= radii(igel);
    %vol_Label(:,:,icnt)=int8(vol_Label(:,:,icnt))+int8(Label);
    Lprop=regionprops(Label,subimage,'MeanIntensity','PixelValues');
    intensity(igel)=Lprop.MeanIntensity;
    variance(igel)=sqrt(var(double(Lprop.PixelValues)))/intensity(igel);
end
end