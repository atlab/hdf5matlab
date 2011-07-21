function idx = getSampleIndex(br, t)
% idx = getSampleIndex(br, t)
% Returns the sample indices 'idx' for the vector of timestamps 't'.

warning('check me')
idx = round(1e-3 * (t - br.t0) * br.Fs) + 1;
idx(idx < 1) = nan;
idx(idx > br.nbSamples) = nan;
