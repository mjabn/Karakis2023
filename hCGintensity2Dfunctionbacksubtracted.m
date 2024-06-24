function [sumOfValues, meanIntensity] = hCGintensity2Dfunctionbacksubtracted(unprocessed_image, channel)
    % Extract the specified channel
    im = unprocessed_image(:, :, channel);
    
     % Calculate background intensity using a region of the original image
    backgroundRegion = im(1:50, 1:50); % adjust as needed
    backgroundIntensity = mean(backgroundRegion(:));
    fprintf('Background Intensity: %f\n', backgroundIntensity);
    
    % Subtract the background intensity from the image
    redChannel = double(im) - backgroundIntensity;
    
    % Ensure no negative values after subtraction
    redChannel(redChannel < 0) = 0;
    % Display the original red channel
    %figure; imshow(im, []); title('Original Red Channel');
    
    % Normalize the image from 0 to 1
    imn = mat2gray(redChannel, [0 2^24-1]); % assuming 16-bit image
    
    % Display the normalized image
    %figure; imshow(imn); title('Normalized Image');
    
    % Apply adaptive thresholding
    I = adaptthresh(imn, .0001, 'ForegroundPolarity', 'bright');
    
    % Create binary image
    BW1 = imbinarize(imn, I);
    
    % Display the binary image after thresholding
    %figure; imshow(BW1); title('Binary Image after Thresholding');
    
    % Eliminate objects that have fewer than 100 pixels
    BW2 = bwareaopen(BW1, 100);
    
    % Display the binary image after removing small objects
    %figure; imshow(BW2); title('Binary Image after Area Opening');
    
    % Fill holes in objects
    BW4 = imfill(BW2, 'holes');
    
    % Display the binary image after filling holes
    %figure; imshow(BW4); title('Binary Image after Hole Filling');
    
    % Processed image for further analysis
    processed_image = BW4;
    
    % Get region properties for each object
    %image_props = regionprops(BW4, im, 'all'); % return all quantitative measurements
    
   
    
    % Display the image after background subtraction
    %figure; imshow(redChannel, []); title('Image after Background Subtraction');
    
    % Get sum of all pixel values after background subtraction
    %sumOfValues = sum(redChannel(:));
    sumOfValues = sum(BW4(:));
    
    % Get mean value of image intensity over all image pixels after background subtraction
    %meanIntensity = mean2(redChannel);
    meanIntensity = mean2(BW4);
    
    % Display diagnostic information
    fprintf('Sum of Values: %f\n', sumOfValues);
    fprintf('Mean Intensity: %f\n', meanIntensity);
    %figure(1);imshow(BW4)
    %figure(2);imshow(imn,[])
    %figure(3); imshow (redChannel,[])
end
