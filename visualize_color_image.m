function visualize_color_image(R,G,b)
        figure(2)
gray=0.3;RGmag=0.3;
graycomp=gray+1;
rgbimage=cat(3,(imadjust(max(R,[],3),[0,RGmag])+gray*imadjust(max(b,[],3)))./graycomp,...
    (imadjust(max(G,[],3),[0,RGmag])+gray*imadjust(max(b,[],3)))./graycomp,...
    gray*imadjust(max(b,[],3)));
imshow(rgbimage);hold on
end