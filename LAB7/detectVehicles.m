function [detections, flow, spd, thr] = detectVehicles(frameRGB, opticFlow, ba)

    frameGray = rgb2gray(frameRGB);

    % Optical flow
    flow = estimateFlow(opticFlow, frameGray);

    flowDir = flow.Orientation;
    spd = flow.Magnitude;

    % Threshold motion
    thr = spd > 2;

    % Keep only directions for moving pixels
    filtdir = zeros(size(flowDir));
    filtdir(thr) = flowDir(thr);

    % Blob statistics
    [AREA, CENTROID, BBOX] = step(ba, thr);

    detections = [];

    for i = 1:size(AREA,1)

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
            det.area = AREA(i);

            detections = [detections det];

        end
    end

end