function [tetrodes, channels, indices] = getTetrodes(br)
% Get recorded tetrodes (and their channels).
%   [tetrodes, channels, indices] = getTetrodes(br) returns the tetrodes
%   and their channels that were recorded. The third output indices
%   contains the physical channel indices in the recording file.
%
% AE 2011-10-15

res = regexp(br.chNames, '^t(\d+)c([1-4]{1})$', 'tokens', 'once');
matches = find(cellfun(@(x) ~isempty(x), res));
tetNos = cellfun(@(x) str2double(x{1}), res(matches));
channelNos = cellfun(@(x) str2double(x{2}), res(matches));

tetrodes = unique(tetNos);
channels = cell(size(tetrodes));
indices = cell(size(tetrodes));
for i = 1:numel(tetrodes)
    channelIdx = find(tetNos == tetrodes(i));
    [channels{i}, sortIdx] = sort(channelNos(channelIdx));
    indices{i} = matches(channelIdx(sortIdx));
end
