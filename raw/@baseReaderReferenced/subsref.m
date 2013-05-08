function x = subsref(br, s)
% Subscripting.
%   x = br(samples, channels). channels can be either channel indices or
%   't' for the timestamps in milliseconds.
%
% JC 2013-05-08

x = subsref(br.reader, s);

% for getting time, no reference is used
if ischar(s(1).subs{2}) && (s(1).subs{2} == 't')
    return;
end

% only want the first channel for the reference
s(1).subs{2} = 1;

% remove the reference from all the channels
ref = subsref(br.reference, s);
x = bsxfun(@minus, x, ref);