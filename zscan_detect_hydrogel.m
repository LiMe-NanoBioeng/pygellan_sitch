function [hydrogel_out]=zscan_detect_hydrogel(stitch,par,circlelabel)
cutoff=par.cutoff;
if strcmp(circlelabel,'intensity')
    ilabel=5;
elseif strcmp(circlelabel,'metric')
    ilabel=6;
elseif strcmp(circlelabel,'radii')
    ilabel=4;
elseif strcmp(circlelabel,'zpos')
    ilabel=3;
else
    ilabel=0;
end
img_size=size(stitch);
dimension=size(img_size);
if dimension(2)==2;
    img_size(3)=1;
end
%% compute the range of intensity
%high_int=0;low_int=2^16-1;
stitch_size=size(stitch);
%intensity=reshape(stitch,[stitch_size(1)*stitch_size(2)*stitch_size(3),1]);
intensity=reshape(stitch,[stitch_size(1)*stitch_size(2),1]);
low_int=double(min(intensity));
high_int=double(max(intensity))/par.imadjust;

% low_int=double(low_int)/2^16;
% high_int=0.2*double(high_int)/2^16;% arbitorary parameter

%% detect hydrogel in 3D

num_of_all_gel=0;
for icnt=1:img_size(3)
    img=uint16(stitch(:,:,icnt));
    cur_high=double(max(img,[],'all'));
%     cur_low=double(min(img,[],'all'));
    %ad_img=imadjust(img,[0 cur_high/high_int]);
    ad_img=imadjust(img);
    figure(1);imshow(ad_img);hold on
    %vol_img(:,:,icnt)=im2uint8(ad_img);
    %% in case edge image is useful
    rho=imgaussfilt(ad_img);
    %rho=locallapfilt(rho,0.9,1.5);% arbitorary parameter

    hydrogel=frame_detect_hydrogel(img,rho,par.sizerange,par.sensitivity,par.edgethreshold,par.metricthreshold,par.radii_overlap);

    num_of_gel=hydrogel.num_of_gel;
    %vol_Label(:,:,icnt)=zeros(size(img));
    
    if num_of_gel>0
        hydrogel.zpos=icnt;%int64(z_slices{icnt});
        viscircles([hydrogel.centers], [hydrogel.radii],'EdgeColor','r','LineWidth',0.2);
        %                 text(hydrogel.centers(:,1),hydrogel.centers(:,2),num2str(hydrogel.mean_intensity),...
        %                     'Color','yellow');
    else
        hydrogel.intensity=[];
        hydrogel.zpos=[];
    end
    if icnt==1;hydrogel_z=hydrogel;else;hydrogel_z(icnt)=hydrogel;end
    num_of_all_gel=hydrogel_z(icnt).num_of_gel+num_of_all_gel;
    
    drawnow
    hold off
    % pause
end
%% cluster hydrogels at 3d positions
centers=[];
for icnt=1:img_size(3)
    num_of_gel(icnt)=hydrogel_z(icnt).num_of_gel;
    if hydrogel_z(icnt).num_of_gel>0
        centers=cat(1,centers,[[hydrogel_z(icnt).centers],...
            linspace(double(icnt),double(icnt),int16(hydrogel_z(icnt).num_of_gel))',...
            [hydrogel_z(icnt).radii],...
            [hydrogel_z(icnt).intensity],...
            [hydrogel_z(icnt).metric]]);
    end
end
%% filter out errors
if isempty(centers)~=1
% true_index=find(~(centers(:,4)>cutoff.radii & centers(:,5)<cutoff.high_intensity)&...
%     centers(:,5)>cutoff.low_intensity);%filtering
true_index=find(~centers(:,4)==0);
%% clustering 3d positioned circles
Z=linkage(centers(true_index,1:2),'average','chebychev');
T=cluster(Z,'cutoff',cutoff.cluster,'Criterion','distance');
%
%
%%
num_of_3dgel=max(T);
centers_max=zeros(length(true_index),6);
for icnt=1:num_of_3dgel
    index=find(T==icnt);
    coef=centers(true_index(index),5).*centers(true_index(index), 6)...
        /sum(centers(true_index(index),5).*centers(true_index(index), 6));
    [v,index_max]=max(coef);
    %             g = cell(magellan.read_image(channel,0,int64(z_slices{icnt}),0,index,'False',1,'False'));
    %             img=uint16(double(uint16(g{1})).*flatfield_405);
    %             [rho,curImage]=pmcfft(im);
    %figure(3);plot(centers(index, 5),centers(index, 6),'o')
    centers_max(icnt,:)=centers(true_index(index(index_max)),:);
    centers_max(icnt,1)=sum(centers(true_index(index),1).*coef);
    centers_max(icnt,2)=sum(centers(true_index(index),2).*coef);
    centers_max(icnt,4)=sum(centers(true_index(index),4).*coef);
    centers_max(icnt,5)=sum(centers(true_index(index),5).*coef);
    centers_max(icnt,6)=sum(centers(true_index(index),6).*coef);
    hydrogel_out.centers(icnt,1:3)=centers_max(icnt,1:3);
    hydrogel_out.radii(icnt,1)=centers_max(icnt,4);
    hydrogel_out.intensity(icnt,1)=centers_max(icnt,5);
    hydrogel_out.metric(icnt,1)=centers_max(icnt,6);
    hydrogel_out.unique(icnt,1)=1;
end
    hydrogel_out.num_of_gel=num_of_3dgel;
%% just visualization
%[v,iz]=max(num_of_gel);
img=uint16(max(stitch,[],3));
ad_img=imadjust(img);
figure(2);
imshow(ad_img);hold on    
viscircles(centers_max(:,1:2),centers_max(:,4),'EdgeColor','r','LineWidth',0.2);
if ilabel~=0;text(centers_max(:,1),centers_max(:,2),num2str(centers_max(:,ilabel)),'Color','Yellow');end
drawnow
hold off
%% visualize the result
figure(3)
%cmap=colormap(jet);
%        color=cmap(uint16(double(T)*double(255/num_of_3dgel)),:);
%viscircles3(centers_max(:,1:2),centers_max(:,4),centers_max(:,3),color);
plot3(centers_max(:,1),centers_max(:,2),centers_max(:,3),'.r')
set(gca,'YDir','reverse')
%%
figure(4)
subplot(1,3,1);scatter(centers(:,4),centers(:,5),'o')
xlabel('radii');ylabel('intensity')
subplot(1,3,2);scatter(centers(:,4),centers(:,6),'o')
xlabel('radii');ylabel('metric')
subplot(1,3,3);scatter(centers(:,5),centers(:,6),'o')
xlabel('intensity');ylabel('metric')
     %end
% end

%axis equal
end
end