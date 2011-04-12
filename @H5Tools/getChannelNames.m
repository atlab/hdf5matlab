function chans = getChannelNames(fp, channels)
% Read channel names.
%   chans = getChannelNames(fp) returns the channels names for the file fp
%   points to.
%
%   chans = getChannelNames(fp, channels) returns the channel names only
%   for the specified channels.
%
% AE 2011-04-11

if H5Tools.existAttribute(fp, 'channelNames') % new recording API
    str = H5Tools.readAttribute(fp, 'channelNames');
    chans = textscan(str, '%s', 'delimiter', ',');
    chans = chans{1}';
    if nargin > 1
        chans = chans(channels);
    end
elseif H5Tools.existDataset(fp, '/channel names')   % Hammer-based data
    chans = H5Tools.readDataset(fp, '/channel names');
    chans = cellstr(chans');
    chans = regexp(chans, '([^\x0]*)', 'match', 'once');
else
    warning('H5Tools:noChannelNames', 'HDF5 file does not contain channel names.')
    chans = {};
end
