function muv = toMuV(br, x)
% Converts values to microvolts.
%   muv = toMuV(br, x)
%
% AE 2011-10-14

muv = x / 2^23 * 317e3;
