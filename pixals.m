function [A21] = pixals(other,Blue,pxdnd,Expc,location,ctrs)
%calculates expression intensity for red and green stain
%%This code is essentially the same as control_expression_r_g. 
if numel(other)~=0
    clear ctrs2
    for j=1:numel(other)
        ctrs2(j,1:2)=other(j).Centroid;% loop goes through each element and extracts centroids from color stain (red or green)
    end
    
    %% only use if you want to see the image - otherwise leave commented to speed up processing
    %     figure(3);imshow(BWrgb)
    %     hold on
    %     plot(ctrs(:,1),ctrs(:,2),'r*')
    %     plot(ctrs2(:,1),ctrs2(:,2),'b*')
    %     hold off
    
    %%
    clear pxde
    clear pxded
    clear pxdev
    clear pxdevd
    pxded=[];
    pxdevd=[];
    for j=1:numel(other)
        pxde=other(j).PixelIdxList; % identifies the particular pixel ID for each object. Identifies where the color pixels are (red or green)
        k=numel(pxde);
        pxded(1:k,j)=pxde; % contains all the pixel IDs for the color channel (red or green). List of where all color pixels are in the image
        pxdev=other(j).PixelValues;
        pxdevd(1:k,j)=pxdev; % contains all the pixel values of the color channel (red or green). These values will be used to measure intensity.
    end
    clear pxden
    pxden=zeros(size(pxdevd));
    %%
    clear pxdu
        [pxdu,ia,ib]=intersect(pxdnd,pxded); % outputs commom values of pixel ID (overlap between DAPI and Color pixel locations)
    %%
if location~=3 % for either nuclear or cytoplasm expression - doesnt work well. needs work.
for j=1:length(pxdu)% for all overlapping pixel IDs
    pxdu1=pxdu(j,1);
    for k=1:length(pxded)%for each value of color pixel location
        C=size(pxded); 
        for l=1:C(:,2) %goes through each value of the color pixel location list
            if pxded(k,l)==pxdu1 %if any value of the pixal ID is common between blue and color channel (red or green)
                pxden(k,l)=pxdevd(k,l);
                pxdevd(k,l)=zeros();%replace pixel value of zero 
            else 
                pxdevd(k,l)=pxdevd(k,l); %if not pixel value stays
            end
        end
    end
end
end

 % end result is a list of all nuclear pixel values (common IDs)=pxden and
 % a list of all cytoplasm pixel values (uncommon IDs)=pxdevd

    %%
    clear mat
    clear mintens
    if location~=2 %for cytoplasm and both expression locations
    mat=double(pxdevd);%converts the pixels value to doubles (allows for next step)
    mat(~pxdevd)=NaN;%converts all the zeros to NaN
    mintens=mean(mat,'omitnan');%finds the mean excluding NaN values
    else %for nuclear expression location
    mat=double(pxden); %converts the pixels value to doubles (allows for next step)
    mat(~pxden)=NaN;%converts all the zeros to NaN
    mintens=mean(mat,'omitnan');%finds the mean excluding NaN values
    end
    
    %% if you want to see the images in Matlab - uncomment (otherwise comment because it slows down the code)
    %    figure(17);imshow(imn2,[]);
    %     hold on
    %     plot(ctrs(:,1),ctrs(:,2),'r*')
    %     hold off
    %% this is matching the intensity of the color pixels found above to each cell (dapi or blue object)
    clear d1
    clear d2
    clear I
    for j=1:numel(Blue)
        for z=1:numel(other)
            d1(j,z)=pdist([ctrs(j,:);ctrs2(z,:)]); % calculates distance (euclidean distance) between centroids of Blue and Color objects (red or green)
        end
    end
    [d2,I]=min(d1,[],2); %d2_c contains the minimum of the distances for each Blue object K_c contains the indices or which color object was closest to the blue object
    %%
    for j=1:numel(Blue)
        for z=1:numel(Blue)
            d3(j,z)=pdist([ctrs(j,:);ctrs(z,:)]); % calculates distance (euclidean distance) between centroids of Blue and Color objects (red or green)
        end
    end
    d3(d3==0)=NaN;
    d4=min(d3,[],2,'omitnan'); %d2_c contains the minimum of the distances for each Blue object K_c contains the indices or which color object was closest to the blue object
    %%
    clear EE
    clear GG
    for j=1:numel(Blue)
        EE=I(j,1);
        GG(j,1)=mintens(1,EE); %finds the mean pixel value of the object that is closest to the dapi object
    end
    %%
    for j=1:numel(Blue)
        if d2(j,1)>d4(j,1)
            GG(j,1)=0; %if the distance from a blue centroid is greater than 30 pixels away from a color centroid, the cell is marked as having 0 expression
        end
    end
    
    GG(isnan(GG))=0;
    %%
    clear GGr
    GGr=GG/Expc; %subtracts background control expression
    %GGr=GG;
    %%
    
    %%
    b=numel(Blue);
    Expa(1:b)=NaN(); %defines Expa
    %%
    Expa(1:b)=GGr(1:b); %replaces NaN with expression data
        %%


A22=reshape(Expa,[],1);
A21=A22;
%turns all expression data that is less than 0 into 0 expression
% for k=1:length(A22)
%     if(A22(k)<0)
%      A21(k)=0;   
%     end
% end
else
    for j=1:numel(Blue)
        A21(j,1)=0;
    end
end

