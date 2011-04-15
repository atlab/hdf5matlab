function x = subsref(br, s)
% Subscripting.
%   x = br(samples, channels). channels can be either channel indices or
%   't' for the timestamps in milliseconds.
%
% AE 2011-04-11

% make sure subscripting has the right form
assert(numel(s) == 1 && strcmp(s.type, '()') && numel(s.subs) == 2, ...
    'MATLAB:badsubscript', 'Only subscripting of the form (samples, channels) is allowed!')

% samples and channels
samples = s(1).subs{1};
channels = s(1).subs{2};

% all samples requested?
if iscolon(samples)
    nSamples = br.nbSamples;
else
    % Check for valid range of samples
    assert(all(samples <= br.nbSamples & samples > 0), 'MATLAB:badsubscript', ...
        'Sample index out of range [1 %d]', br.nbSamples);
    nSamples = numel(samples);
end

% time channel requested?
if ischar(channels) && channels == 't'
    if iscolon(samples)
        x = br.t0 + 1000 * (0:br.nbSamples-1)' / br.Fs;
    else
        x = br.t0 + 1000 * (samples(:)-1)' / br.Fs;
    end
else
    
    % all channels requested?
    if iscolon(channels)
        channels = 1:(br.nbChannels);
    else
        % Check for valid range of channels
        assert(all(channels <= br.nbChannels & channels > 0), ...
            'MATLAB:badsubscript', 'Channel index out of range [1 %d]', br.nbChannels);
    end
    nChannels = numel(channels);
    
    % Convert to actual channel numbers in the recording file
    channels = br.chIndices(channels);
    
    x = zeros(nSamples, nChannels);
    
    if iscolon(samples)
        % reading all samples
        for i = 1:nChannels
            x(:,i) = H5Tools.readDataset(br.fp, 'data', 'range', [channels(i), 1], [channels(i), br.nbSamples]);
        end
    elseif length(samples) > 2 && samples(end) - samples(1) == length(samples) - 1 && all(diff(samples) == 1)
        % reading continuous block of samples
        for i = 1:nChannels
            x(:,i) = H5Tools.readDataset(br.fp, 'data', 'range', [channels(i), samples(1)], [channels(i), samples(end)]);
        end
    else        
        % reading arbitrary set of samples
        for i = 1:nChannels
            x(:,i) = H5Tools.readDataset(br.fp, 'data', 'index', [repmat(channels(i), nSamples, 1) , samples(:)]);
        end
    end
    
    % scale to (micro/milli?)volts
    x = x * br.scale;
end



function b = iscolon(x)
b = ischar(x) && isscalar(x) && x == ':';
