function [x t] = temporal(br, s, channels)
% Subscripting.
%   [x t] = electrical(br, samples). Returns the voltage and time
%
% JC 2012-01-31


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
    assert(br.t0 > 0, 't0 has not been updated in this file!')
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
            x(:,i) = H5Tools.readDataset(br.fp, 'TemporalData', 'range', [channels(i), 1], [channels(i), br.nbSamples]);
        end
    elseif length(samples) > 2 && samples(end) - samples(1) == length(samples) - 1 && all(diff(samples) == 1)
        % reading continuous block of samples
        for i = 1:nChannels
            x(:,i) = H5Tools.readDataset(br.fp, 'TemporalData', 'range', [channels(i), samples(1)], [channels(i), samples(end)]);
        end
    else        
        % reading arbitrary set of samples
        for i = 1:nChannels
            x(:,i) = H5Tools.readDataset(br.fp, 'TemporalData', 'index', [repmat(channels(i), nSamples, 1) , samples(:)]);
        end
    end
    
    % scale to (micro/milli?)volts
end



function b = iscolon(x)
b = ischar(x) && isscalar(x) && x == ':';
