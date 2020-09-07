function [distance,flag]=compute_distance_matrix(Gbeads,hydrogel,minidistance,exclude)
% exclude is a flag that considers the radii of circles
% if two circles overlap, the distance gives a negative value when the exclude==1.
% 20191021 hirofumi shintaku
bcnt=size(Gbeads.centers);
hcnt=size(hydrogel.centers);
Gcenters=Gbeads.centers;
hcenters=hydrogel.centers;
Gradii=Gbeads.radii;
hradii=hydrogel.radii;
%distance=zeros(bcnt(1),hcnt(1));
flag=false(bcnt(1),hcnt(1));
for dimension=1:hcnt(2)
    Gx=repmat(Gcenters(:,dimension),1,hcnt(1));
    hx=repmat(hcenters(:,dimension)',bcnt(1),1);
%     Gx=tall(Gx);
%     hx=tall(hx);
    if dimension>1
        hxyz=cat(3,hxyz,hx);
        Gxyz=cat(3,Gxyz,Gx);
    else
        hxyz=hx;
        Gxyz=Gx;
    end
end
clear hx Gx
if exclude ==3
    distance=vecnorm(hxyz-Gxyz,2,3);
    clear hxyz Gxyz
%     distance=gather(distance);
    flag(distance<minidistance)=1;
elseif exclude==0
    %distance matrix considering diameters of two circles
    distance=vecnorm(hxyz-Gxyz,2,3);
    clear hxyz Gxyz
    Gr=repmat(Gradii,1,hcnt(1));
    hr=repmat(hradii',bcnt(1),1);
%     Gr=tall(Gr);hr=tall(hr);
    distance=(distance-Gr-hr)./(Gr+hr);
%     distance=gather(distance);
    flag(distance<minidistance)=1;
elseif exclude==2
    distance=vecnorm(hxyz(:,:,1:2)-Gxyz(:,:,1:2),2,3);
    clear hxyz Gxyz
    Gr=repmat(Gradii(:),1,hcnt(1));
    hr=repmat(hradii(:)',bcnt(1),1);
%     Gr=tall(Gr);hr=tall(hr);
    distance=min(distance+hr-Gr,distance+Gr-hr);
%     distance=gather(distance);
    flag(distance<minidistance)=1;
end
end