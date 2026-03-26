img = imread('test1.jpg');
output = img;

%% lista kolorów i funkcji
colors = {
    'green', @segGreen;
    'red', @segRed;
    'blue', @segBlue;
    'yellow', @segYellow;
    'pink', @segPink;
    'grey', @segGrey;
    'black', @segBlack;
    'navy', @segNavy;
    'white', @segWhite
};

for k = 1:size(colors,1)

    colorName = colors{k,1};
    segmentFunc = colors{k,2};
    
    [BW, ~] = segmentFunc(img);
    BW = cleanMask(BW);
    
    properties = analyzeRegions(BW);
    
    for i = 1:length(properties)
        
        if properties(i).Area < 300
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

imshow(output);