% Read in a video file.
vidReader = VideoReader('visiontraffic.avi');

videoPlayer = vision.VideoPlayer();

% Create optical flow object.
opticFlow = opticalFlowFarneback;

% skip first still frames
for i=1:90
    frame = readFrame(vidReader);
end

% initialize optical flow
frameGray = rgb2gray(frame);

% estimate optical flow for the first frame (eliminates the noise for the
% actual first detection)
flow = estimateFlow(opticFlow,frameGray); 

ba = vision.BlobAnalysis;

figure(1);
tiledlayout(2,2, 'Padding', 'none', 'TileSpacing', 'compact'); 

% list of tracked objects
tracks = [];

nextTrackId = 1;
vehicleCount = 0;

maxDistance = 50;
maxInvisibleFrames = 10;

colors = lines(200);

% Estimate the optical flow of objects in the video.
while hasFrame(vidReader)

    frameRGB = readFrame(vidReader);
    


    frameGray = rgb2gray(frameRGB);

    % estimate optical flow
    flow = estimateFlow(opticFlow,frameGray); 
    
    % show motion vectors
    nexttile(1)
    imshow(frameRGB * 0.3) 
    hold on
    plot(flow,'DecimationFactor',[15 15],'ScaleFactor',5)
    hold off 
    
    % calculate speed and direction from Vx and Vy
    dir = flow.Orientation;
    spd = flow.Magnitude;
    
    % show speed map
    nexttile(2)
    imshow(spd, [0, 10]);
    colormap(gca, 'jet');
    
    
    % threshold optical flow for speeds over 2
    nexttile(3)
    thr = spd > 2;
    imshow(thr);
    
    % remove all measurements for speeds lower than 2
    filtdir = zeros(size(dir));
    filtdir(thr) = dir(thr);
    
    % calculate region statistics for thresholded image
    [AREA,CENTROID,BBOX] = step(ba, thr);
    
    % analyze found regions
    detections = [];






    for i=1:size(AREA, 1)
        % leave only regions bigger than 2000 px
        if AREA(i) > 2000
            det = struct;
        
            det.bb = BBOX(i,:);
        
            x = round(BBOX(i,1));
            y = round(BBOX(i,2));
            w = round(BBOX(i,3));
            h = round(BBOX(i,4));
        
            x = max(1,x);
            y = max(1,y);
        
            w = min(w, size(filtdir,2)-x+1);
            h = min(h, size(filtdir,1)-y+1);
        
            dirbb = filtdir(y:y+h-1, x:x+w-1);
        
            if any(dirbb(:) ~= 0)
                det.dir = mean(dirbb(dirbb ~= 0));
            else
                det.dir = 0;
            end
        
            spdbb = spd(y:y+h-1, x:x+w-1);
        
            if any(spdbb(:) > 2)
                det.spd = mean(spdbb(spdbb > 2));
            else
                det.spd = 0;
            end
        
            det.cc = CENTROID(i,:);
            det.lbl = '';
        
            detections = [detections, det];
        end
    end






    % ---------------------------------------
    % TRACKING
    % ---------------------------------------
    assignedTracks = false(1,length(tracks));
    
    for d = 1:length(detections)
    
        detPos = detections(d).cc;
    
        bestTrack = 0;
        bestDist = inf;
    
        for t = 1:length(tracks)
    
            dist = norm(detPos - tracks(t).centroid);
    
            if dist < bestDist
                bestDist = dist;
                bestTrack = t;
            end
        end
    
        if bestDist < maxDistance
    
            tracks(bestTrack).centroid = detPos;
    
            tracks(bestTrack).path = [
                tracks(bestTrack).path;
                detPos
            ];
    
            tracks(bestTrack).bbox = detections(d).bb;
    
            tracks(bestTrack).invisible = 0;
    
            assignedTracks(bestTrack) = true;
    
            detections(d).id = tracks(bestTrack).id;
    
        else
    
            track.id = nextTrackId;
            track.centroid = detPos;
            track.path = detPos;
            track.bbox = detections(d).bb;
            track.invisible = 0;
    
            tracks = [tracks track];
    
            detections(d).id = nextTrackId;
    
            nextTrackId = nextTrackId + 1;
            vehicleCount = vehicleCount + 1;
        end
    end






for t = 1:length(tracks)

    if t > length(assignedTracks)
        tracks(t).invisible = tracks(t).invisible + 1;
    elseif ~assignedTracks(t)
        tracks(t).invisible = tracks(t).invisible + 1;
    end
end

keep = [];

for t = 1:length(tracks)

    if tracks(t).invisible < maxInvisibleFrames
        keep = [keep t];
    end
end

tracks = tracks(keep);
    
    % draw annotations (bounding boxes with the segment area)
    ann = frameRGB;
    
    for t = 1:length(tracks)
    
        ann = insertObjectAnnotation( ...
            ann, ...
            'rectangle', ...
            tracks(t).bbox, ...
            sprintf('ID %d', tracks(t).id), ...
            'TextBoxOpacity',0.9, ...
            'FontSize',18);
    end
    
    % show the annotated image
    nexttile(4)
    imshow(ann);
    hold on;
    
for t = 1:length(tracks)

    p = tracks(t).path;

    if size(p,1) > 1

        c = colors(mod(tracks(t).id-1,size(colors,1))+1,:);

        plot( ...
            p(:,1), ...
            p(:,2), ...
            '-', ...
            'Color', c, ...
            'LineWidth', 2);

        plot( ...
            p(end,1), ...
            p(end,2), ...
            'o', ...
            'Color', c, ...
            'MarkerSize', 6, ...
            'MarkerFaceColor', c);
    end
end


    % draw the average direction vector
    for i=1:length(detections)
        det = detections(i);

        x1 = det.cc(1);
        y1 = det.cc(2);
        x2 = x1 + 5*det.spd*cos(det.dir);
        y2 = y1 + 5*det.spd*sin(det.dir);
        
        line([x1 x2], [y1 y2], 'LineWidth', 3);
    end

text(20,20,...
    sprintf('Vehicles: %d',vehicleCount),...
    'Color','yellow',...
    'FontSize',16,...
    'FontWeight','bold',...
    'BackgroundColor','black');

   
    hold off;
    pause(10^-2)
end
