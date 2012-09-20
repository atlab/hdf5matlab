function x = subsref(br, s)
% Subscripting.
%   x = br(samples, channels). channels can be either 1 or 't'.
%
%   Samples are returned in muV!
%
% AE 2012-09-04

% make sure subscripting has the right form
assert(numel(s) == 1 && strcmp(s.type, '()') && numel(s.subs) == 2, ...
    'MATLAB:badsubscript', 'Only subscripting of the form (samples, channels) is allowed!')

% samples and channels
samples = s(1).subs{1};
channels = s(1).subs{2};
assert(isscalar(channels) && ((ischar(channels) && channels == 't') || ...
    (isnumeric(channels) && channels == 1)), 'Invalid channel (has to be 1 or t)!')

if ischar(channels) && channels == 't'
    x = br.t(samples(:));
else
    x = br.v(samples(:));
end
