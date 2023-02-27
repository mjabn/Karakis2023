function [A21_r1,A21_g1,A22_r,ne34,h1]=pixal_comparing_r_g(Blue,Color_r,Color_g,Expc_r,Expc_g,r,cyto_or_nuc_r,cyto_or_nuc_g)
%determines each cell's expression intensity of both red and green stains
    %%same as control
    clear ctrs
    for j=1:numel(Blue)
        ctrs(j,1:2)=Blue(j).Centroid; % loop goes through each element and extracts centroids from blue stain
    end
    %% calculates the pixel intensity of the color pixels and determines their pixel location (pixel ID)
    clear pxdn
    clear pxdnd
    for j=1:numel(Blue)
        pxdn=Blue(j).PixelIdxList; % identifies the particular pixel ID for each object. Identifies where the cells are
        k=length(pxdn);
        pxdnd(1:k,j)=pxdn; % contains all the pixel IDs for the blue channel. List of where all cells are in the image
    end
    %% calculates red and green expression intensity
    A21_r=pixals(Color_r,Blue,pxdnd,Expc_r,cyto_or_nuc_r,ctrs);
    A21_g=pixals(Color_g,Blue,pxdnd,Expc_g,cyto_or_nuc_g,ctrs);
    A21_r1(:,1)=A21_r(:,1);
    A21_g1(:,1)=A21_g(:,1);         
    %% determines the number of neighbors - don't really work with anymore
    clear Y
    clear h
    h=NaN(numel(Blue),1);
    for k=1:numel(Blue)    
        Y=ctrs(k,:);
        [idx,dist]=rangesearch(ctrs,Y,r); %outputs how far each centroid is from all other centroids within radius r
        [f,g]=cellfun(@size,dist); %g determines how many cells are within radius r (includes current cell)
        h(k,1)=(g-1); %need to subtract current cell from total number            
    end
h1(:,1)=h(:,1); %%number of neighbors output
%% excluding data that isn't right
% for i=1:numel(Blue)
%     if A21_r1(i,1)==0 && A21_g1(i,1)==0 %if there's no green or red stain - exclude (likely not a cell)
%         A21_r1(i)=nan();
%         A21_g1(i)=nan();
%         h1(i)=nan();
%     end
% end
%%eliminates NaNs from matrix
% A21_r1(~any(~isnan(A21_r1),2),:)=[];
% A21_g1(~any(~isnan(A21_g1),2),:)=[];
% h1(~any(~isnan(h1),2),:)=[];

%%determines which cells are red+ and only includes them in ne variable
ne32=[];
ne3=0;
for y=1:length(A21_r1)
    if(A21_r1(y)>0)
        ne32(y,1)=h1(y,1);
    else ne32(y,1)=NaN;
    end
end
ne34(:,1)=ne32(:,1);
%outputs red stain for only single cells (h=0)
% for y=1:length(A21_r1)
% if h1(y,1)==0
%     A22_r(y,1)=A21_r1(y,1);
% else A22_r(y,1)=nan();
% end
% end

for y=1:length(A21_r1)
    if A21_r1(y,1)<=0
    A21_r2(y,1)=1;
    else A21_r2(y,1)=A21_r1(y,1);
    end
end
for y=1:length(A21_g1)
    if A21_g1(y,1)<=0
    A21_g2(y,1)=1;
    else A21_g2(y,1)=A21_g1(y,1);
    end
end
for y=1:length(A21_g2)
    A22_r(y,1)=A21_g2(y,1)/A21_r2(y,1);   
end


ne33=ne34(~isnan(ne34)); %eliminates nans from matrix
for l=1:length(ne33)
    if(ne33(l,1)==0)
        ne3=ne3+1; %totals the # of single cells
    end
end       
        

end
