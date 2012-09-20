function muv = toMuV(br, x)
% Convert digital values to muV.
%   muv = toMuV(br, x)

muv = x * br.scale;
