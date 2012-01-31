function [x t] = temporal(br, samples, channels)
% Subscripting.
%   [x t] = temporal(br, samples, channels). Returns the voltage and time
%
% JC 2012-01-31

% all samples requested?
if iscolon(samples)
    nSamples = br.nbTemporalSamples;
else
    % Check for valid range of samples
    assert(all(samples <= br.nbTemporalSamples & samples > 0), 'MATLAB:badsubscript', ...
        'Sample index out of range [1 %d]', br.nbTemporalSamples);
    nSamples = numel(samples);
end

% time channel requested?
%assert(br.t0 > 0, 't0 has not been updated in this file!')
if iscolon(samples)
    t = br.t0 + 1000 * (0:br.nbSamples-1)' / br.Fs;
else
    t = br.t0 + 1000 * (samples(:)-1)' / br.Fs;
end

% all channels requested?
if iscolon(channels)
    channels = 1:(br.nbTimeChannels);
else
    % Check for valid range of channels
    assert(all(channels <= br.nbTemporalSamples & channels > 0), ...
        'MATLAB:badsubscript', 'Channel index out of range [1 %d]', br.nbTemporalChannels);
end
nChannels = numel(channels);

% Convert to actual channel numbers in the recording file
channels = br.temporalChIndices(channels);

x = zeros(nSamples, nChannels);

if iscolon(samples)
    % reading all samples
    for i = 1:nChannels
        x(:,i) = -H5Tools.readDataset(br.fp, 'TemporalData', 'range', [channels(i), 1], [channels(i), br.nbSamples]);
    end
elseif length(samples) > 2 && samples(end) - samples(1) == length(samples) - 1 && all(diff(samples) == 1)
    % reading continuous block of samples
    for i = 1:nChannels
        x(:,i) = -H5Tools.readDataset(br.fp, 'TemporalData', 'range', [channels(i), samples(1)], [channels(i), samples(end)]);
    end
else
    % reading arbitrary set of samples
    for i = 1:nChannels
        x(:,i) = H5Tools.readDataset(br.fp, 'TemporalData', 'index', [repmat(channels(i), nSamples, 1) , samples(:)]);
    end
end



function b = iscolon(x)
b = ischar(x) && isscalar(x) && x == ':';
