function [tetrodes, channels, indices] = getTetrodes(br)
% Get recorded tetrodes (and their channels).
%   [tetrodes, channels, indices] = getTetrodes(br) returns the tetrodes
%   and their channels that were recorded. The third output indices
%   contains the physical channel indices in the recording file.
%
% AE 2011-10-15

tetrodes = br.tetrode;
channels = br.chNames;
indices = 1;
