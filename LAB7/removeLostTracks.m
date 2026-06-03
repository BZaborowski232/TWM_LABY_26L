function tracks = removeLostTracks(tracks, maxInvisibleFrames)

    if isempty(tracks)
        return
    end

    keep = [tracks.invisible] < maxInvisibleFrames;

    tracks = tracks(keep);

end