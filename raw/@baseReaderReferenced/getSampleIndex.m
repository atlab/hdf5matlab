function idx = getSampleIndex(br, t)
% idx = getSampleIndex(br, t)
% Returns the sample indices 'idx' for the vector of timestamps 't'.

idx = getSampleIndex(br.reader, t)
