clc;
clear;
close all;

% ===== Wczytanie obrazu =====
img = imread('test4.png');
output = img;

%% ===== Lista kolorów i funkcji segmentacji =====
colors = {
    'green', @segGreen;
    'red',   @segRed;
    'pink',  @segPink;
    'yellow',@segYellow;
    'navy',  @segNavy;
    'grey',  @segGrey;
    'black', @segBlack
};

%% ===== Przetwarzanie każdego koloru =====
for k = 1:size(colors,1)

    colorName = colors{k,1};
    segmentFunc = colors{k,2};
    
    % ===== Segmentacja koloru =====
    [BW, ~] = segmentFunc(img);
    
    % ===== Czyszczenie maski =====
    [BW, ~] = cleanMask(img, BW);
    
    % ===== Analiza regionów =====
    properties = analyzeRegions(BW);
    
    % ===== Iteracja po obiektach =====
    for i = 1:length(properties)
        
        % ===== FILTR: małe obiekty =====
        if properties(i).Area < 500
            continue;
        end
        
        % ===== FILTR: szum / nieregularności =====
        if properties(i).Solidity < 0.85
            continue;
        end
        
        % ===== FILTR: bardzo wydłużone =====
        bbox = properties(i).BoundingBox;
        ratio = bbox(3) / bbox(4);
        if ratio > 2 || ratio < 0.5
            continue;
        end
        
        % ===== FILTR: bardzo duże (np. długopisy) =====
        if properties(i).Area > 5000
            continue;
        end

        % ===== KLASYFIKACJA KSZTAŁTU =====
        shape = classifyShape(properties(i));
        
        % ===== ETYKIETA =====
        label = [colorName ' ' shape];
        
        % ===== RYSOWANIE =====
        output = insertObjectAnnotation(output, ...
            'rectangle', ...
            properties(i).BoundingBox, ...
            label);
    end
end

%% ===== Wyświetlenie wyniku =====
figure;
imshow(output);
title('Wynik klasyfikacji: kolor + kształt');

imwrite(output, 'test4_wynik.png');