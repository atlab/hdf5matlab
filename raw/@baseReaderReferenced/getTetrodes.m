function [tetrodes, channels, indices] = getTetrodes(br)
% Get recorded tetrodes (and their channels).
%   [tetrodes, channels, indices] = getTetrodes(br) returns the tetrodes
%   and their channels that were recorded. The third output indices
%   contains the physical channel indices in the recording file.
%
% JC 2013-05-08

[tetrodes, channels, indicies] = getTetrodes(br.reader);
