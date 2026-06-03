function [tracks, vehicleCount, nextTrackId] = ...
    updateTracks( ...
        detections, ...
        tracks, ...
        vehicleCount, ...
        nextTrackId, ...
        maxDistance)

    assignedTracks = false(1,length(tracks));

    for d = 1:length(detections)

        detPos = detections(d).cc;

        bestTrack = 0;
        bestDist = inf;

        % znajdź najbliższy istniejący track
        for t = 1:length(tracks)

           
            if t <= length(assignedTracks)
            
                if assignedTracks(t)
                    continue
                end
            
            end

            dist = norm(detPos - tracks(t).centroid);

            if dist < bestDist

                bestDist = dist;
                bestTrack = t;

            end
        end

        % znaleziono istniejący pojazd
        if bestDist < maxDistance

            tracks(bestTrack).centroid = detPos;

            tracks(bestTrack).path = ...
                [tracks(bestTrack).path;
                 detPos];

            tracks(bestTrack).bbox = ...
                detections(d).bb;

            tracks(bestTrack).invisible = 0;

            assignedTracks(bestTrack) = true;

        % nowy pojazd
        else

            track.id = nextTrackId;

            track.centroid = detPos;

            track.path = detPos;

            track.bbox = detections(d).bb;

            track.invisible = 0;

            tracks = [tracks track];
            
            assignedTracks(end+1) = true;
            
            nextTrackId = nextTrackId + 1;
            
            vehicleCount = vehicleCount + 1;

        end
    end

    % zwiększ licznik niewidocznych klatek
    for t = 1:length(tracks)

        if t > length(assignedTracks)

            tracks(t).invisible = ...
                tracks(t).invisible + 1;

        elseif ~assignedTracks(t)

            tracks(t).invisible = ...
                tracks(t).invisible + 1;

        end
    end

end