function [processed_image,image_props] = process_r_g(unprocessed_image,channel)
%image processing
%   processes the image for quantitative analysis
im=unprocessed_image(:,:,channel); % isolates the color channel
imn=mat2gray(im,[0 2^24-1]); % normalizes the image from 0 to 1, the limits should be consistent with the bit depth of the image (2^16-1, in this case since 16 bit)
I=adaptthresh(imn,.0001,'ForegroundPolarity','bright'); % thresholds the image based on local mean intensity in neighborhood of each pixel
BW1=imbinarize(imn,I); % creates a binary image of 1s and 0s from threshold
BW2=bwareaopen(BW1,100); % eliminates objects that have fewer than 100 pixels
%BW3=imdilate(BW2,strel('sphere',1)); % dilates objects
BW4=imfill(BW2,'holes'); % fills holes of objects
processed_image=BW4;
image_props=regionprops(BW4,im,'all'); %returns all quantitative measurements for each object
%figure(1);imshow(BW4)
%figure(2);imshow(imn,[])
end

