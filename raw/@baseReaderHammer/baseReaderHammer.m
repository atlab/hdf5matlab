function br = baseReaderHammer(varargin)

br.fileName = [];
br.nbSamples = 0;
br.nbChannels = 0;
br.tstart = 0;
br.tend = 0;
br.fp = [];
br.tetrode = 0;
br.samplingRate = 0;
br.channels = [];

if length(varargin) == 1 && isa(varargin{1}, 'baseReaderHammer')
    br = varargin{1};
    return
end

if length(varargin) >= 1 && ischar(varargin{1})
    br.fileName = varargin{1};
    if length(varargin) >= 2
        % br.tetrode = varargin{2}(:)';
        br.tetrode = varargin{2};
    else
        br.tetrode = [];
    end
    % try to load some information from the HDF5 file
    br = getFileInfo(br);
end
br = class(br, 'baseReaderHammer');


function br = getFileInfo(br)

br.fp = H5Tools.openFamily(br.fileName);
% Check actual data matrix
dims = H5Tools.getRecordingDim(br.fp);

br.nbSamples = dims.nbSamples;
br.samplingRate = dims.samplingRate;
br.tstart = 0;
br.tend = 1000 * (br.nbSamples - 1) / br.samplingRate;


if isempty(br.tetrode)
    [tets channels] = H5Tools.getRecordedTetrodes(br.fp);
    chans = H5Tools.getChannelNames(br.fp);
    if length(vertcat(channels{:})) == length(chans)
        br.tetrode = tets;
    else
        br.tetrode = chans;
    end
end

% Figure out which channels to use for our data
if ischar(br.tetrode)
    % Interpret strings as an explicit spec for one channel
    br.tetrode = {br.tetrode};
end
if iscell(br.tetrode)
    % Cell arrays specify several explicit channel definitions, either by string or number
    chans = H5Tools.getChannelNames(br.fp);
    channels = zeros(1, length(chans));
    for c=1:length(br.tetrode)
        if isnumeric(br.tetrode{c})
            channels(c) = fix(br.tetrode{c});
        elseif ischar(br.tetrode{c});
            match = min(strmatch(br.tetrode{c}, chans));
            if ~isempty(match)
                channels(c) = match;
            else
                channels(c) = -1;
            end
        else
            error('Channels must be specified in a numeric format or as strings.');
        end
    end
    validChannels = (channels >= 1) & (channels <= dims.nbRecChannels);
    br.channels = channels(validChannels);
    br.tetrode = br.tetrode(validChannels);
    br.nbChannels = length(br.channels);
elseif isnumeric(br.tetrode)
    [tets channels] = H5Tools.getRecordedTetrodes(br.fp);
    availableTets = intersect(tets, br.tetrode);
    if ~isempty(availableTets)
        br.tetrode = availableTets;
        br.channels = vertcat(channels{br.tetrode})';
        br.nbChannels = length(br.channels);
    else
        error('No data for requested tetrode(s) in recording file %s.', br.fileName);
    end
end
