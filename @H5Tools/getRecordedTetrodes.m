function [tets channels] = getRecordedTetrodes(fp)

chans = H5Tools.getChannelNames(fp);
tetNos = regexp(chans, 't(\d+)c(\d+)', 'tokens', 'once');     % Extract tet and channel numbers
tetNos = str2double(vertcat(tetNos{:}));                      % Convert to numerical values
if ~isempty(tetNos)
    [tets] = unique(tetNos(:,1))';
    channels = cell(1,max(tets));

    for t=tets
	channelIdx = find(tetNos(:,1) == t);
	channelNos = tetNos(channelIdx, 2);
	[foo sortIdx] = sort(channelNos);
	channels{t} = channelIdx(sortIdx);
    end
else
    tets = [];
    channels = {};
end
