function muv = toMuV(~, x)
% Converts digital values to microvolts.
%   muv = toMuV(br, x)

% this applies to LFP recordings
range = 1e6;    % +/- 1 Volt
gain = 3000;    % hardware setting
bits = 12;      % i.e. +/- 11 bits
muv = x * (range / gain / 2 ^ (bits - 1));
