function [BW,maskedImage] = cleanMask1grey(RGB,MASK)

% Create empty mask
BW = false(size(RGB,1),size(RGB,2));

% Load Mask
BW = MASK;

% Erode mask with default
radius = 2;
decomposition = 0;
se = strel('disk', radius, decomposition);
BW = imerode(BW, se);

% Close mask with default
radius = 10; % 8
decomposition = 0;
se = strel('disk', radius, decomposition);
BW = imclose(BW, se);

% Open mask with default
radius = 2;
decomposition = 0;
se = strel('disk', radius, decomposition);
BW = imopen(BW, se);

% Create masked image.
maskedImage = RGB;
maskedImage(repmat(~BW,[1 1 3])) = 0;
end
