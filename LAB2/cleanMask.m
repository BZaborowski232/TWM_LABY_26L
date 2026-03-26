function BW = cleanMask(BW)

se = strel('disk', 3);
BW = imopen(BW, se);

BW = imfill(BW, 'holes');

BW = bwareaopen(BW, 300);

se = strel('disk', 2);
BW = imclose(BW, se);

end