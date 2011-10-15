function [chunk, sample] = getSampleIndex(pr, t)
% Returns the chunk and sample index for a given timestamp.
%   [chunk, sample] = getSampleIndex(pr, t)
%
% AE 2011-10-14

sample = getSampleIndex(pr.reader, t);
chunk = fix(sample / pr.stride(1)) + 1;
sample = rem(sample, pr.stride(1));
