clc;
clear;
close all;

img = imread('test4.png');
output = img;

colors = {
    'green', @segGreen;
    'red',   @segRed;
    'pink',  @segPink;
    'yellow',@segYellow;
    'navy',  @segNavy;
    'grey',  @segGrey;
    'black', @segBlack
};

for k = 1:size(colors,1)

    colorName = colors{k,1};
    segmentFunc = colors{k,2};
    
    [BW, ~] = segmentFunc(img);
    
    [BW, ~] = cleanMask(img, BW);
    
    properties = analyzeRegions(BW);
    
    for i = 1:length(properties)
        
        if properties(i).Area < 500
            continue;
        end
        
        if properties(i).Solidity < 0.85
            continue;
        end
        
        bbox = properties(i).BoundingBox;
        ratio = bbox(3) / bbox(4);
        if ratio > 2 || ratio < 0.5
            continue;
        end
        
        if properties(i).Area > 5000
            continue;
        end

        shape = classifyShape(properties(i));
        
        label = [colorName ' ' shape];
        
        output = insertObjectAnnotation(output, ...
            'rectangle', ...
            properties(i).BoundingBox, ...
            label);
    end
end

figure;
imshow(output);
title('Wynik klasyfikacji: kolor + kształt');

imwrite(output, 'test4_wynik.png');