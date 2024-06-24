clc
clear all
close all
%%
%% calling image locations - CHANGE THESE TO MATCH YOUR FILE LOCATIONS
%Change dirname_c dirnameconstant dirnamevariable and sheetname%
%everything else keep constant
dirname_c="D:\Insulin proposal and images\STB data\IC\"; % calls file location folder for control image **keep slash at the end of this line
dirnameconstant="D:\Insulin proposal and images\STB data\8_11_23 STB processed\experimental"; % part of the dirname that will not change **no slash at the end of this line
dirnamevariable=["condition 1","condition 2"]; % part of the dirname that changes per image (there is a max of 702 condition)
sheetname='STB analysis.xlsx';% output excel sheet name must be in (or will creat a file in) the folder matlab is open in **Any data already in this sheet will be writin over**
%% put the unprocessed image in a loop
%% processes the control
imagelist=dir(fullfile(dirname_c,'*.tif'));% identifies files that end with .tif within that folder
%%
for i=1:length(imagelist)
 disp('Working on Imaging')

file_c=strcat(dirname_c,imagelist(i).name); % creates a variable with the full path to image # 1 (the file)
im_c=imread(file_c); % reads the image into a variable with the format it is saved in

%%process function: input image from imread and channel (1:red 2:green 3:blue) output image and properties of the image
[RedSum_c(:,i),Red_mean_c(:,i)]=hCGintensity2Dfunctionbacksubtracted(im_c,1);(i);
%[RedSum_c(:,i),Red_mean_c(:,i)]=hCGintensity2Dfunctionbacksubtract(im_c,2);(i); %green

%[Greenim_c,Color_cg]=process_r_g(im_c,2);
[Blueim_c,Blue_c]=process_r_g(im_c,3);
% Get the total number of objects in Blue_c
    
end
total_objects_Blue_c = numel(Blue_c);


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
    [RedSum(:,i),Red_mean(:,i)]=hCGintensity2Dfunctionbacksubtracted(im,1);(i); % 1 is red channel
  %  [Colorim_g,Color_g]=process_r_g(im,2);
    v=dirnamevariable(x); 
end
total_objects_Blue = numel(Blue);
    disp("printing to "+sheetname)
writematrix("Red_Sum",sheetname,'Sheet',v,'Range',"A1:A"+"1",'UseExcel',true)%writes the condition name
writematrix(RedSum(:),sheetname,'Sheet',v,'Range',"A2:A"+(length(RedSum)+1),'UseExcel',true)%writes the expresion value
writematrix("Red_Mean",sheetname,'Sheet',v,'Range',"B1:B"+"1",'UseExcel',true)%writes the condition name
writematrix(Red_mean(:),sheetname,'Sheet',v,'Range',"B2:B"+(length(Red_mean)+1),'UseExcel',true)

writematrix("RedSum_c",sheetname,'Sheet',v,'Range',"C1:C"+"1",'UseExcel',true)%writes the condition name
writematrix(RedSum_c(:),sheetname,'Sheet',v,'Range',"C2:C"+(length(RedSum_c)+1),'UseExcel',true)%writes the expresion value
writematrix("Red_mean_c",sheetname,'Sheet',v,'Range',"D1:D"+"1",'UseExcel',true)%writes the condition name
writematrix(Red_mean_c(:),sheetname,'Sheet',v,'Range',"D2:D"+(length(Red_mean_c)+1),'UseExcel',true)%writes the expresion value

% Print total number of objects to Excel
writematrix("Total Objects Blue_c", sheetname, 'Sheet', v, 'Range', "F1", 'UseExcel', true)
writematrix(total_objects_Blue_c, sheetname, 'Sheet', v, 'Range', "F2", 'UseExcel', true)

writematrix("Total Objects Blue", sheetname, 'Sheet', v, 'Range', "E1", 'UseExcel', true)
writematrix(total_objects_Blue, sheetname, 'Sheet', v, 'Range', "E2", 'UseExcel', true)
end 