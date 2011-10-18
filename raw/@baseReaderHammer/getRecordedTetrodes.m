function [tets, channels] = getRecordedTetrodes(br)
% Returns recorded tetrodes and associated channel indices.
%   [tets, channels] = getRecordedTetrodes(br)
%
% AE 2011-04-12

chans = H5Tools.getChannelNames(br.fp);
tetNos = regexp(chans, '^t(\d+)c([1-4]{1})$', 'tokens', 'once');     % Extract tet and channel numbers
tetNos = str2double(vertcat(tetNos{:}));                      % Convert to numerical values
if ~isempty(tetNos)
    [tets] = unique(tetNos(:,1))';
    channels = cell(1,max(tets));
    for t=tets
        channelIdx = find(tetNos(:,1) == t);
        channelNos = tetNos(channelIdx, 2);
        [foo sortIdx] = sort(channelNos); %#ok<ASGLU>
        channels{t} = channelIdx(sortIdx);
    end
else
    tets = [];
    channels = {};
end
