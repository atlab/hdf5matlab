function [tets, channels] = getRecordedTetrodes(br)
% Returns recorded tetrodes and associated channel indices.
%   [tets, channels] = getRecordedTetrodes(br)
%
% AE 2011-04-12
%
% Read the recorded channel indices from data file and look up the tetrode 
% indices in cmap. -WW2011
%--------------------------------------------------------------------------

tets = [];
channels = {};

%tetrodes and channels specified in map file
[mapTetrodes,mapChannels] = getTetrodes(br);

if ~isempty(br.NSx)
    %read the recorded channel indices.
    recChannels = (br.NSx.MetaTags.ChannelID)';
else %br read the nev file
    recChannels = unique(br.NEV.Data.Spikes.Electrode);
end

%look up the tetrodes
for i = 1 : length(mapTetrodes)
    tetNum = mapTetrodes(i);
    chanNum = mapChannels{i};
    if length(intersect(recChannels,chanNum))==4 %all 4 chans need to be presented.
        tets = [tets tetNum];
        channels{end+1} = sort(chanNum); 
    end
end
    
