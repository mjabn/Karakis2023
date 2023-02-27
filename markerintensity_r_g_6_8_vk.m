
clc
clear all
close all
tic % measures time for code to run
%%set up
%put images in Documents or on PC (don't use google drive for storing
%images. this can make the code take a very long time to run)
%%Make folder with condition name. then 3 folders within that for the cell
%%lines then 14 folders within each cell line folder labeled as
%%dirnamevariable shows. Each folder will contain 1 image from that
%%condition and cell line. I take 7 images per plate (or well if using
%%24-well) and 2 replicates, so 14 images total for 1 condition. 

%% calling image locations - CHANGE THESE TO MATCH YOUR FILE LOCATIONS
%Change dirname_c dirnameconstant dirnamevariable and sheetname%
%everything else keep constant
dirname_c='G:\My Drive\Research\Term TSCM based paper\IF for quant\'; % calls file location folder for control image **keep slash at the end of this line
dirnameconstant='G:\My Drive\Research\Term TSCM based paper\IF for quant'; % part of the dirname that will not change **no slash at the end of this line
dirnamevariable=["Okae EVT"]; % part of the dirname that changes per image (there is a max of 702 condition)
sheetname='CT30 Okae d6 3-28.xlsx';% output excel sheet name must be in (or will creat a file in) the folder matlab is open in **Any data already in this sheet will be writin over** 
%% naming variables
cyto_or_nuc_r=3; % 1 for cytoplasm expression, 2 for nuclear expression, 3 for both **individual expression not working well**
cyto_or_nuc_g=2; % 1 for cytoplasm expression, 2 for nuclear expression, 3 for both **individual expression not working well**
r=50; % radius in pixels - if a cell is detected within this radius - not counted as single cell. 1.2 um/pixel conversion
%creating variables for later
A_R=[];
A_G=[];
A_R2=[];
H=[];
NE=[];

%Currently set up so that dirnamevariable is at the very end of dirnameconstant and dinamevariable is each image
%Can also change it so that you have all images in 1 file and the dirnamevariable is the condition name
%% processes the control
imagelist=dir(fullfile(dirname_c,'*.tif'));% identifies files that end with .tif within that folder
%%
for i=1:length(imagelist)
%     disp('Working on Imaging')

file_c=strcat(dirname_c,imagelist(i).name); % creates a variable with the full path to image # 1 (the file)
im_c=imread(file_c); % reads the image into a variable with the format it is saved in

%%process function: input image from imread and channel (1:red 2:green 3:blue) output image and properties of the image
[Redim_c,Color_cr]=process_r_g(im_c,1);
[Greenim_c,Color_cg]=process_r_g(im_c,2);
[Blueim_c,Blue_c]=process_r_g(im_c,3);
%%
for j=1:numel(Blue_c)
    ctrsB_c(j,1:2)=Blue_c(j).Centroid; % loop goes through each element and extracts centroids of each structure in the blue channel
end
%%
for j=1:numel(Color_cr)
    ctrs1_cr(j,1:2)=Color_cr(j).Centroid; % loop goes through each element and extracts centroid from structure in the red channel
end
for j=1:numel(Color_cg)
    ctrs1_cg(j,1:2)=Color_cg(j).Centroid; % loop goes through each element and extracts centroid from structure in the green channel
end
for j=1:numel(Blue_c)
    pxdn_c=Blue_c(j).PixelIdxList; %identifies the particular pixel ID for each object. Identifies where the cells are
    k=length(pxdn_c);
    pxdnd_Bc(1:k,j)=pxdn_c; % contains all the pixel IDs for the blue channel. List of where all cells are in the image
end

%%
%Analyzes control images and outputs and average control expression for red and green
if length(Color_cr)~=0 
Expc_cr(i)=control_expresion_r_g(Color_cr,Blue_c,pxdnd_Bc,ctrsB_c,ctrs1_cr,cyto_or_nuc_r);
else Expc_cr(i)=1;
end
if Expc_cr(i)<1
    Expc_cr(i)=1;
end

if length(Color_cg)~=0 
Expc_cg(i)=control_expresion_r_g(Color_cg,Blue_c,pxdnd_Bc,ctrsB_c,ctrs1_cg,cyto_or_nuc_g);
else Expc_cg(i)=1;
end
if Expc_cg(i)<1
    Expc_cg(i)=1;
end
end
Expc_r=mean(Expc_cr); % mean expression intensity of all cells in the control image for red
Expc_g=mean(Expc_cg); % mean intensity of expression of all cells in the control image for green
%% processes the images
for x=1:length(dirnamevariable)
%x=1; %used this for checking code
A_R=[];
A_G=[];
A_R2=[];
H=[];
NE=[];
dirnames=dirnameconstant+"\"+dirnamevariable(x)+"\";
dirname=dirnames{1}; % converts to pc location
disp(dirname)
images=dir(fullfile(dirname,'*.tif'));% Identifies files that end with .tif within that folder
%%
for i=1:length(images)
    disp('Working on Imaging')
    file=strcat(dirname,images(i).name); % creates a variable with the full path to each image in the folder
    im=imread(file); % reads the image into variable im, with the format it is saved in
   %% same processing as control
    [Blueim,Blue]=process_r_g(im,3);
    [Colorim_r,Color_r]=process_r_g(im,1);
    [Colorim_g,Color_g]=process_r_g(im,2);
    %% essentially does the same thing as the control_expression_r_g function
    %output is each cell's red and green expression intensity
    %A21_r=red expression intensity A21_g=green expression intensity
    %A22_r=red expression intensity of single cells ne=number of neighbors
    %for red+ cells h=number of neighbors for all cells
    [A21_r,A21_g,A22_r,ne,h]=pixal_comparing_r_g(Blue,Color_r,Color_g,Expc_r,Expc_g,r,cyto_or_nuc_r,cyto_or_nuc_g);
    %% combines all the data for all of the images
    %combines red expression data
    len_ar=length(A_R);
    for n=1:(length(A21_r))
        A_R((n+len_ar))=A21_r(n);
    end
    %combines green expression data
    len_ag=length(A_G);
    for n=1:(length(A21_g))
        A_G((n+len_ag))=A21_g(n);
    end
    %combines single cell red expression data
    len_ar2=length(A_R2);
    for n=1:(length(A22_r))
        A_R2((n+len_ar2))=A22_r(n);
    end
    %combines neighbors data
    len_h=length(H);
    for n=1:(length(h))
        H((n+len_h))=h(n);
    end
    %combines red+ neighbors data
    len_ne=length(NE);
    for n=1:(length(ne))
        NE((n+len_ne))=ne(n);
    end
v=dirnamevariable(x); %defines the sheet name as the dirnamevariable(x) (1-R7)

end
%% writes individual image data into the excel sheet labeled 1-R7
% writematrix("Red",sheetname,'Sheet',v,'Range',"A1:A"+"1",'UseExcel',true)%writes the condition name
% writematrix("Green",sheetname,'Sheet',v,'Range',"B1:B"+"1",'UseExcel',true)%writes the condition name
% writematrix("Neighbors",sheetname,'Sheet',v,'Range',"C1:C"+"1",'UseExcel',true)%writes the condition name
% writematrix("Neighbors with mean",sheetname,'Sheet',v,'Range',"D1:D"+"1",'UseExcel',true)%writes the condition name
% writematrix("Red no neighbors",sheetname,'Sheet',v,'Range',"E1:E"+"1",'UseExcel',true)%writes the condition name
% writematrix(A_R(:),sheetname,'Sheet',v,'Range',"A2:A"+(length(A_R)+1),'UseExcel',true)%writes the expresion value
% writematrix(A_G(:),sheetname,'Sheet',v,'Range',"B2:B"+(length(A_G)+1),'UseExcel',true)%writes the expresion value
% writematrix(H(:),sheetname,'Sheet',v,'Range',"C2:C"+(length(H)+1)+"2",'UseExcel',true)
% writematrix(NE(:),sheetname,'Sheet',v,'Range',"D2:D"+(length(H)+1)+"2",'UseExcel',true)
% writematrix(A_R2(:),sheetname,'Sheet',v,'Range',"E2:E"+(length(H)+1)+"2",'UseExcel',true)

%% Writes all of data combined into the excel sheet "all"
clear a_r a_g
a_r=A_R;
a_g=A_G;
disp("printing to "+sheetname)
writematrix("Red",sheetname,'Sheet',v,'Range',"A1:A"+"1",'UseExcel',true)%writes the condition name
writematrix(a_r(:),sheetname,'Sheet',v,'Range',"A2:A"+(length(a_r)+1),'UseExcel',true)%writes the expresion value
writematrix("Green",sheetname,'Sheet',v,'Range',"B1:B"+"1",'UseExcel',true)%writes the condition name
writematrix(a_g(:),sheetname,'Sheet',v,'Range',"B2:B"+(length(a_g)+1),'UseExcel',true)
writematrix("Neighbor",sheetname,'Sheet',v,'Range',"C1:C"+"1",'UseExcel',true)%writes the condition name
writematrix("Neighbor with mean",sheetname,'Sheet',v,'Range',"D1:D"+"1",'UseExcel',true)%writes the condition name
writematrix("Red no neighbor",sheetname,'Sheet',v,'Range',"E1:E"+"1",'UseExcel',true)
writematrix(H(:),sheetname,'Sheet',v,'Range',"C2:C"+(length(H)+1)+"2",'UseExcel',true)
writematrix(NE(:),sheetname,'Sheet',v,'Range',"D2:D"+(length(H)+1)+"2",'UseExcel',true)
writematrix(A_R2(:),sheetname,'Sheet',v,'Range',"E2:E"+(length(h)+1)+"2",'UseExcel',true)
end
toc
