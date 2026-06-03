% ==========================================
% OPTICAL FLOW VEHICLE TRACKING
% ==========================================

clear;
clc;
close all;

% ------------------------------------------
% VIDEO
% ------------------------------------------

vidReader = VideoReader('visiontraffic1.mp4');

% ------------------------------------------
% OPTICAL FLOW
% ------------------------------------------

opticFlow = opticalFlowFarneback;

% pominięcie pierwszych klatek
for i = 1:90

    if hasFrame(vidReader)
        frame = readFrame(vidReader);
    end

end

% inicjalizacja optical flow
frameGray = rgb2gray(frame);
estimateFlow(opticFlow, frameGray);

% ------------------------------------------
% BLOB ANALYSIS
% ------------------------------------------

ba = vision.BlobAnalysis;

% ------------------------------------------
% TRACKING VARIABLES
% ------------------------------------------

tracks = [];

nextTrackId = 1;
vehicleCount = 0;

maxDistance = 50;
maxInvisibleFrames = 10;

colors = lines(200);

% ------------------------------------------
% FIGURE
% ------------------------------------------

figure(1);
tiledlayout(2,2,...
    'Padding','none',...
    'TileSpacing','compact');

% ==========================================
% MAIN LOOP
% ==========================================

while hasFrame(vidReader)

    % --------------------------------------
    % READ FRAME
    % --------------------------------------

    frameRGB = readFrame(vidReader);

    % --------------------------------------
    % VEHICLE DETECTION
    % --------------------------------------

    [detections, flow, spd, thr] = ...
        detectVehicles( ...
            frameRGB, ...
            opticFlow, ...
            ba);

    % --------------------------------------
    % TRACK UPDATE
    % --------------------------------------

    [tracks, vehicleCount, nextTrackId] = ...
        updateTracks( ...
            detections, ...
            tracks, ...
            vehicleCount, ...
            nextTrackId, ...
            maxDistance);

    % --------------------------------------
    % REMOVE LOST TRACKS
    % --------------------------------------

    tracks = removeLostTracks( ...
        tracks, ...
        maxInvisibleFrames);

    % --------------------------------------
    % VISUALIZATION
    % --------------------------------------

    nexttile(1)

    imshow(frameRGB * 0.3)

    hold on

    plot( ...
        flow, ...
        'DecimationFactor',[15 15], ...
        'ScaleFactor',5);

    hold off

    nexttile(2)

    imshow(spd,[0 10]);
    colormap(gca,'jet');

    nexttile(3)

    imshow(thr);

    nexttile(4)

    drawTracks( ...
        frameRGB, ...
        tracks, ...
        vehicleCount, ...
        colors);

    pause(0.01);

end

% ==========================================
% SUMMARY
% ==========================================

fprintf('\n');
fprintf('Detected vehicles: %d\n', vehicleCount);
fprintf('\n');