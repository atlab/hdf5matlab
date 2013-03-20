function channelNames = getChannelNames(br)
% Returns the channels names recorded in the file.
%   channelNames = getChannelNames(br)
%
% AE 2011-10-13

channelNames = H5Tools.getChannelNames(br.fp);
