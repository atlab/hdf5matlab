function idx = getSampleIndex(br, t)
% idx = getSampleIndex(br, t)
% Returns the sample indices 'idx' for the vector of timestamps 't'.

[d, idx] = min(abs(br.t - t));
if d > 1000 / br.Fs / 2
    idx = NaN;
end
