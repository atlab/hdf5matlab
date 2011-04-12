function idx = getSampleIndex(fr, t)
% idx = getSampleIndex(br, t)
% Returns the sample indices 'idx' for the vector of timestamps 't'.

idx = getSampleIndex(fr.reader, t) - fr.delay;
idx(idx < 1) = nan;
idx(idx > fr.nbSamples) = nan;