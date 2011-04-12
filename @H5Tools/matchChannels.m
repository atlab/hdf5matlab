function [indices, names] = matchChannels(fp, channels)
% Get channel indices.
%   [indices, names] = matchChannels(fp, channels) 
%
% AE 2011-04-11

% read channel names
str = H5Tools.readAttribute(fp, 'channelNames');
names = regexp(str, ',', 'split');

if ischar(channels) && any(channels == '*')
    % channels are given as a pattern
    channels = ['^' strrep(channels, '*', '([0-9]+)') '$'];
    matches = regexp(names, channels, 'tokens', 'once');
    indices = find(cellfun(@(x) ~isempty(x), matches));
    ch = cellfun(@(x) str2double(x{1}), matches(indices));
    % sort channels 
    [foo, order] = sort(ch, 'ascend'); %#ok<ASGLU>
    indices = indices(order);
else
    % channel(s) given by name(s)
    [foo, indices] = ismember(channels, names); %#ok<ASGLU>
    assert(all(indices > 0), 'H5Tools:noSuchChannel', ...
        'No channel with name ''%s''!', channels{find(~indices, 1)});
end

if nargout > 1
    names = names(indices);
end
