function [refs, indices] = getRefs(br)
% Get recorded references.
%   [refs, indices] = getRefs(br) returns the references that were recorded
%   and their physical channel indices in the recording file.
%
% AE 2011-10-15

res = regexp(getChannelNames(br), '^ref(\d+)$', 'once', 'tokens');
indices = find(cellfun(@(x) ~isempty(x), res));
[refs, order] = sort(cellfun(@(x) str2double(x{1}), res(indices)));
indices = indices(order);
