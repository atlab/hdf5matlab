function x = subsref(br, s)
% Subscripting.
%   x = br(samples, channels). channels can be either channel indices or
%   't' for the timestamps in milliseconds.
%
% AE 2011-04-11
%
% modified for blackrock data reader WW2011
% samples -- ':' for all samples
%         -- or a vector of sample indices. If samples is an arbitrary set, 
%            the largest block(min(samples):max(samples)) will be read and 
%            filtered with sample indices afterwards.
%       

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
    
%     fprintf('baseReaderBlackrock: Reading Data %.2f (MB) ... \n', nSamples*nChannels*4/1E6);
        
    x = zeros(nSamples, nChannels);
    %
    
    if iscolon(samples)
        readIdx = [1,nSamples]; %read all samples.
    elseif isblock(samples)
        readIdx = [samples(1),samples(end)]; %read block of continuous samples
    else
        %openN* functions read in blocks.  the arbitrary set of samples will be selected after reading the full set.
        readIdx = [min(samples),max(samples)];
    end
        
    switch br.fileType
        case 'NEV'
            %readPortion = sprintf('t:%f:%f',readIdx(1)/br.nbSamples,readIdx(end)/br.nbSamples);
            s = openNEV(br.fileName,'read','nowrite','nowave');
            for i = 1 : nChannels
                data = (s.Data.Spikes.TimeStamp(s.Data.Spikes.Electrode == channels(i)))'; %read the full set
                if iscolon(samples) || isblock(samples)
                    x(:,i) = data(readIdx(1):readIdx(2));
                else
                    x(:,i) = data(samples);
                end
            end
        case 'NSx'
            for i = 1 : nChannels
                %need to translate the channel indices to the recording indices
                chID = channels(i);
                s = openNSx(br.fileName,'read','channels',chID,'duration',readIdx); %read a continuous block with specified position.
                data = s.Data';
                if iscolon(samples) || isblock(samples)
                    x(:,i) = data;
                else
                    x(:,i) = data(samples-readIdx(1)+1); %select by sample indices.
                end
            end
    end
end


function b = iscolon(x)
b = ischar(x) && isscalar(x) && x == ':';

function b = isblock(x) 
b = length(x) > 2 && x(end) - x(1) == length(x) - 1 && all(diff(x) == 1) ;
