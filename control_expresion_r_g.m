function [Expc]=control_expresion_r_g(color_c,Blue_c,pxdnd_Bc,ctrsB_c,ctrs1_c,location)
%%Analyzes the control image expression intensity and outputs and average
%%control expression intensity
    %will be used later as background subtraction.
%% calculates the pixel intensity of the color pixels and determines their pixel location (pixel ID)
for j=1:numel(color_c)
    pxde_c=color_c(j).PixelIdxList; % identifies the particular pixel ID for each object. Identifies where the color pixels are (red or green)
    k=numel(pxde_c);
    pxded_c(1:k,j)=pxde_c; % contains all the pixel IDs for the color channel (red or green). List of where all color pixels are in the image
    pxdev_c=color_c(j).PixelValues;
    pxdevd_c(1:k,j)=pxdev_c; % contains all the pixel values of the color channel (red or green). These values will be used to measure intensity.
end
pxdnc=zeros(size(pxdevd_c));
%%
[pxdu_c]=intersect(pxdnd_Bc,pxded_c);%outputs commom values of pixel ID (overlap between DAPI and Color pixel locations)
 if location~=3 % for either nuclear or cytoplasm expression - doesnt work well. needs work.
for j=1:length(pxdu_c)% for all overlapping pixel IDs
    pxdu1_c=pxdu_c(j,1);
    for k=1:length(pxded_c)%for each value of dapi pixel location
        C=size(pxded_c); 
        for l=1:C(:,2) %goes through each value of the dapi pixel location list
            if pxded_c(k,l)==pxdu1_c %if any value of the pixal ID is common between blue and color channel (red or green)
                pxdnc(k,l)=pxdevd_c(k,l);
                pxdevd_c(k,l)=zeros();%replace pixel value of zero 
            else
                pxdevd_c(k,l)=pxdevd_c(k,l); %if not pixel value stays
            end
        end
    end
end
 end
 % end result is a list of all nuclear pixel values (common IDs)=pxdnc and
 % a list of all cytoplasm pixel values (uncommon IDs)=pxdevd_c

%%
if location~=2 %for cytoplasm and both expression locations
px_c=double(pxdevd_c);%converts the pixels value to doubles (allows for next step)
px_c(~pxdevd_c)=NaN;%converts all the zeros to NaN
mintens_c=mean(px_c,'omitnan');%finds the mean excluding NaN values
else %for nuclear expression location
px_c=double(pxdnc);%converts the pixels value to doubles (allows for next step)
px_c(~pxdnc)=NaN;%converts all the zeros to NaN
mintens_c=mean(px_c,'omitnan');%finds the mean excluding NaN values
end
%% if you want to see the images in Matlab - uncomment (otherwise comment because it slows down the code)
%     figure(17);imshow(imn2,[]);
%     hold on
%     plot(ctrs(:,1),ctrs(:,2),'r*')
%     hold off
%% this is matching the intensity of the color pixels found above to each cell (dapi or blue object)
clear d1
clear d2
clear I
for j=1:numel(Blue_c)
    for h=1:numel(color_c)
        d1_c(j,h)=pdist([ctrsB_c(j,:);ctrs1_c(h,:)]); % calculates distance (euclidean distance) between centroids of Blue and Color objects (red or green)
    end
end
[d2_c,K_c]=min(d1_c,[],2);%d2_c contains the minimum of the distances for each Blue object K_c contains the indices or which color object was closest to the blue object 

%%
    for j=1:numel(Blue_c)
        for z=1:numel(Blue_c)
            d3_c(j,z)=pdist([ctrsB_c(j,:);ctrsB_c(z,:)]); % calculates distance (euclidean distance) between centroids of Blue and Color objects (red or green)
        end
    end
    d3_c(d3_c==0)=NaN;
    d4_c=min(d3_c,[],2,'omitnan'); %d2_c contains the minimum of the distances for each Blue object K_c contains the indices or which color object was closest to the blue object
 
    %%
    clear loc_c
    clear Expc_c
for j=1:numel(Blue_c)
    loc_c=K_c(j,1);
    Expc_c(j,1)=mintens_c(1,loc_c); %finds the mean pixel value of the object that is closest to the dapi object
end
   %%
    for j=1:numel(Blue_c)
        if d2_c(j,1)>d4_c(j,1)
            Expc_c(j,1)=0; %if the distance from a blue centroid is greater than 30 pixels away from a color centroid, the cell is marked as having 0 expression
        end
    end
%%
Expc_c(isnan(Expc_c))=0;% replaces all NaNs with 0
%%
% for j=1:numel(Blue_c)
%     if d2_c(j,1)>30
%         Expc_c(j,1)=zeros(); %if the distance from a blue centroid is greater than 30 pixels away from a color centroid, the cell is marked as having 0 expression
%     end
% end
%%
Expc=mean(Expc_c); % mean expression intensity of all cells in control image
end