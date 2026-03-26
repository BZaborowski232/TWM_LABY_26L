img = imread('test.jpg');
output = img;

%% ===== GREEN =====
[BW, ~] = segmentGreen(img);
BW = cleanMask(BW);
properties = analyzeRegions(BW);

for i = 1:length(properties)
    
    if properties(i).Area < 200
        continue;
    end
    
    c = properties(i).Circularity;
    e = properties(i).Extent;
    
    if c > 0.9
        shape = 'circle';
    elseif e > 0.6
        shape = 'square';
    else
        shape = 'other';
    end
    
    label = ['green ' shape];
    
    output = insertObjectAnnotation(output, ...
        'rectangle', ...
        properties(i).BoundingBox, ...
        label);
end

%% ===== RED =====
[BW, ~] = segmentRed(img);
BW = cleanMask(BW);
properties = analyzeRegions(BW);

for i = 1:length(properties)
    
    if properties(i).Area < 200
        continue;
    end
    
    c = properties(i).Circularity;
    e = properties(i).Extent;
    
    if c > 0.9
        shape = 'circle';
    elseif e > 0.6
        shape = 'square';
    else
        shape = 'other';
    end
    
    label = ['red ' shape];
    
    output = insertObjectAnnotation(output, ...
        'rectangle', ...
        properties(i).BoundingBox, ...
        label);
end

%% ===== BLUE =====
[BW, ~] = segmentBlue(img);
BW = cleanMask(BW);
properties = analyzeRegions(BW);

for i = 1:length(properties)
    
    if properties(i).Area < 200
        continue;
    end
    
    c = properties(i).Circularity;
    e = properties(i).Extent;
    
    if c > 0.9
        shape = 'circle';
    elseif e > 0.6
        shape = 'square';
    else
        shape = 'other';
    end
    
    label = ['blue ' shape];
    
    output = insertObjectAnnotation(output, ...
        'rectangle', ...
        properties(i).BoundingBox, ...
        label);
end

%% ===== BEIGE =====
[BW, ~] = segmentBeige(img);
BW = cleanMask(BW);
properties = analyzeRegions(BW);

for i = 1:length(properties)
    
    if properties(i).Area < 200
        continue;
    end
    
    c = properties(i).Circularity;
    e = properties(i).Extent;
    
    if c > 0.9
        shape = 'circle';
    elseif e > 0.6
        shape = 'square';
    else
        shape = 'other';
    end
    
    label = ['beige ' shape];
    
    output = insertObjectAnnotation(output, ...
        'rectangle', ...
        properties(i).BoundingBox, ...
        label);
end

%% ===== ORANGE =====
[BW, ~] = segmentOrange(img);
BW = cleanMask(BW);
properties = analyzeRegions(BW);

for i = 1:length(properties)
    
    if properties(i).Area < 200
        continue;
    end
    
    c = properties(i).Circularity;
    e = properties(i).Extent;
    
    if c > 0.9
        shape = 'circle';
    elseif e > 0.6
        shape = 'square';
    else
        shape = 'other';
    end
    
    label = ['orange ' shape];
    
    output = insertObjectAnnotation(output, ...
        'rectangle', ...
        properties(i).BoundingBox, ...
        label);
end

%% ===== GREY =====
[BW, ~] = segmentGrey(img);
BW = cleanMask(BW);
properties = analyzeRegions(BW);

for i = 1:length(properties)
    
    if properties(i).Area < 200
        continue;
    end
    
    c = properties(i).Circularity;
    e = properties(i).Extent;
    
    if c > 0.9
        shape = 'circle';
    elseif e > 0.6
        shape = 'square';
    else
        shape = 'other';
    end
    
    label = ['grey ' shape];
    
    output = insertObjectAnnotation(output, ...
        'rectangle', ...
        properties(i).BoundingBox, ...
        label);
end

%% ===== WYNIK =====
imshow(output);