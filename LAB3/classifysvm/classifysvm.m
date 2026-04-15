%% Parametry działania
% Powtarzalne wyniki
close all ;
rng('default') ;

% Liczba obrazów treningowych na klasę
cnt_train = 70 ;

% Liczba obrazów testowych na klasę
cnt_test = 30;

% Wybrane klasy obiektów
img_classes = {'deli', 'greenhouse', 'bathroom'};

% Liczba cech wybierana na każdym obrazie
feats_det = 100;

% Metoda wyboru cech (true - jednorodnie w całym obrazie, false - najsilniejsze)
feats_uniform = true;

% Wielkość słownika
words_cnt = 30 ;

% Detekcja cech
% Ładowanie pełnego zbioru danych z automatycznym podziałem na klasy
% Zbiór danych pochodzi z publikacji: A. Quattoni, and A.Torralba. <http://people.csail.mit.edu/torralba/publications/indoor.pdf 
% _Recognizing Indoor Scenes_>. IEEE Conference on Computer Vision and Pattern 
% Recognition (CVPR), 2009.
% 
% Pełny zbiór dostępny jest na stronie autorów: <http://web.mit.edu/torralba/www/indoor.html 
% http://web.mit.edu/torralba/www/indoor.html>

imds_full = imageDatastore("../indoor_images/", "IncludeSubfolders", true, "LabelSource", "foldernames");
%countEachLabel(imds_full)

% Wybór przykładowych klas i podział na zbiór treningowy i testowy
[imds, imtest] = splitEachLabel(imds_full, cnt_train, cnt_test, 'Include', img_classes);
%countEachLabel(imds)

% Wyznaczenie punktów charakterystycznych we wszystkich obrazach zbioru treningowego
files_cnt = length(imds.Files);
all_points = cell(files_cnt, 1);
total_features = 0;

for i=1:files_cnt
    I = readImage(imds.Files{i});
    all_points{i} = getFeaturePoints(I, feats_det, feats_uniform);
    total_features = total_features + length(all_points{i});
end

% Przygotowanie listy przechowującej indeksy plików i punktów charakterystycznych
file_ids = zeros(total_features, 2);
curr_idx = 1;
for i=1:files_cnt
    file_ids(curr_idx:curr_idx+length(all_points{i})-1, 1) = i;
    file_ids(curr_idx:curr_idx+length(all_points{i})-1, 2) = 1:length(all_points{i});
    curr_idx = curr_idx + length(all_points{i});
end

% Obliczenie deskryptorów punktów charakterystycznych
all_features = zeros(total_features, 64, 'single');
curr_idx = 1;
for i=1:files_cnt
    I = readImage(imds.Files{i});
    curr_features = extractFeatures(rgb2gray(I), all_points{i});
    all_features(curr_idx:curr_idx+length(all_points{i})-1, :) = curr_features;
    curr_idx = curr_idx + length(all_points{i});
end

% Tworzenie słownika

% Klasteryzacja punktów 
[idx, words, sumd, D] = kmeans(all_features, words_cnt, "MaxIter", 10000);
% Wizualizacja wyliczonych słów

% Wyznaczenie histogramów słów dla każdego obrazu treningowego
file_hist = zeros(files_cnt, words_cnt);
for i=1:files_cnt
    file_hist(i,:) = histcounts(idx(file_ids(:,1) == i), (1:words_cnt+1)-0.5, 'Normalization', 'probability');
end

% Wyznaczenie histogramów słów dla każdego obrazu testowego
test_hist = zeros(length(imtest.Files), words_cnt);
for i=1:length(imtest.Files)
    I = readImage(imtest.Files{i});
    pts = getFeaturePoints(I, feats_det, feats_uniform);
    feats = extractFeatures(rgb2gray(I), pts);
    test_hist(i,:) = wordHist(feats, words);
end

%% Część 2: Klasyfikator SVM - Grid Search i optymalizacja
close all;
rng('default');

% Definicja siatki hiperparametrów
C_vals = logspace(-1, 2, 5); % np. od 0.1 do 100
gamma_vals = logspace(-2, 1, 5); % np. od 0.01 do 10
k = 5; % 5-krotna walidacja krzyżowa (k-fold)

accuracy_matrix = zeros(length(C_vals), length(gamma_vals));

fprintf('Rozpoczynam przeszukiwanie siatki (Grid Search). To może chwilę potrwać...\n');
for i = 1:length(C_vals)
    for j = 1:length(gamma_vals)
        C = C_vals(i);
        gamma = gamma_vals(j);
        
        % Definicja szablonu SVM z jądrem RBF (gaussowskim)
        t = templateSVM('KernelFunction', 'gaussian', 'BoxConstraint', C, 'KernelScale', gamma);
        
        % Uczenie modelu ECOC (wieloklasowego za pomocą SVM one-vs-one)
        model = fitcecoc(file_hist, imds.Labels, 'Learners', t);
        
        % Walidacja krzyżowa w celu oceny tego zestawu parametrów
        modelcv = crossval(model, 'KFold', k);
        cv_err = kfoldLoss(modelcv);
        
        % Zapisanie wyniku (1 - błąd = skuteczność)
        accuracy_matrix(i, j) = 1 - cv_err;
    end
end

% Znalezienie najlepszych parametrów na podstawie walidacji krzyżowej
[max_acc, max_idx] = max(accuracy_matrix(:));
[best_i, best_j] = ind2sub(size(accuracy_matrix), max_idx);
best_C = C_vals(best_i);
best_gamma = gamma_vals(best_j);

fprintf('\nNajlepsze parametry: C = %.3f, Gamma = %.3f\nSkuteczność walidacyjna (CV) = %.2f%%\n', best_C, best_gamma, max_acc*100);

% === GENEROWANIE TABELI WYNIKÓW GRID SEARCH ===

[C_grid, gamma_grid] = meshgrid(C_vals, gamma_vals);

results_table = table( ...
    C_grid(:), ...
    gamma_grid(:), ...
    accuracy_matrix(:) * 100, ...
    'VariableNames', {'C', 'Gamma', 'Accuracy_percent'} ...
);

% Sortowanie malejąco po skuteczności
results_table = sortrows(results_table, 'Accuracy_percent', 'descend');

disp('Tabela wyników Grid Search:');
disp(results_table);
%% Wykres 3D przestrzeni hiperparametrów
figure;
[X, Y] = meshgrid(gamma_vals, C_vals);
surf(X, Y, accuracy_matrix * 100);
set(gca, 'XScale', 'log', 'YScale', 'log');
xlabel('Gamma (\gamma)');
ylabel('C (BoxConstraint)');
zlabel('Skuteczność CV (%)');
title('Skuteczność SVM w zależności od parametrów C i \gamma');
colorbar;

%% Testowanie najlepszego wyznaczonego modelu na ZBIORZE TESTOWYM
final_t = templateSVM('KernelFunction', 'gaussian', 'BoxConstraint', best_C, 'KernelScale', best_gamma);
final_model = fitcecoc(file_hist, imds.Labels, 'Learners', final_t);

predicted_labels = predict(final_model, test_hist);

% Generowanie macierzy pomyłek
figure;
cm = confusionchart(imtest.Labels, predicted_labels);
title('Macierz pomyłek - Zoptymalizowany SVM');

% Obliczanie metryk
conf_mat = cm.NormalizedValues; % Pobranie wartości liczbowych z macierzy

% Mikro-uśredniona skuteczność (zwykłe 'Accuracy' dla całego zbioru)
micro_acc = sum(diag(conf_mat)) / sum(conf_mat(:));

% Makro-uśredniona skuteczność (średnia czułość dla klas)
sensitivities = diag(conf_mat) ./ sum(conf_mat, 2);
macro_acc = mean(sensitivities);

fprintf('\nWyniki na zbiorze testowym:\n');
fprintf('Mikro-uśredniona skuteczność (Micro-Accuracy): %.2f%%\n', micro_acc * 100);
fprintf('Makro-uśredniona skuteczność (Macro-Accuracy): %.2f%%\n', macro_acc * 100);

%% Automatyczna optymalizacja za pomocą wbudowanych narzędzi MATLABa
fprintf('\nPorównanie: Rozpoczynam automatyczną optymalizację MATLABa...\n');
auto_t = templateSVM('KernelFunction', 'gaussian');
auto_model = fitcecoc(file_hist, imds.Labels, 'Learners', auto_t, 'OptimizeHyperparameters', 'auto', ...
    'HyperparameterOptimizationOptions', struct('ShowPlots', false, 'Verbose', 0));

auto_pred = predict(auto_model, test_hist);
auto_acc = sum(auto_pred == imtest.Labels) / length(imtest.Labels);
fprintf('Skuteczność na teście (Auto-optymalizacja): %.2f%%\n', auto_acc * 100);

%% Funkcje pomocnicze

function pts = getFeaturePoints(I, pts_det, pts_uniform)
    if size(I, 3) > 1
        I2 = rgb2gray(I);
    else
        I2 = I;
    end
    
    pts = detectSURFFeatures(I2, 'MetricThreshold', 100);
    if pts_uniform
        pts = selectUniform(pts, pts_det, size(I));
    else
        pts = pts.selectStrongest(pts_det);
    end
end

function h = wordHist(feats, words)
    words_cnt = size(words, 1);
    dis = pdist2(feats, words, 'squaredeuclidean');
    [~, lbl] = min(dis, [], 2);
    h = histcounts(lbl, (1:words_cnt+1)-0.5, 'Normalization', 'probability');
end

% Wczytanie obrazu i przeskalowanie jeśli jest zbyt duży
function I = readImage(path)
    I = imread(path);
    if size(I,2) > 640
        I = imresize(I, [NaN 640]);
    end
end