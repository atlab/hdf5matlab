function B = subsref(br, S)

% This subsref allows for easy data access via () indexing parentheses.`
params.setName = '/data';

if strcmp(S(1).type, '.') && strcmp(S(1).subs, 't')
    if (length(S) == 2) && strcmp(S(2).type, '()')
        T = S(2);
        T.subs = [T.subs 't'];
        B = subsref(br, T);
    else
        T.type = '()';
        T.subs = {':', 't'};
        B = subsref(br, T);
    end
    return
end

if length(S) ~= 1 || ~strcmp(S(1).type, '()') || length(S(1).subs) ~= 2
    error('Only subscripting of the form (samples, channels) is allowed.')
end

% Signal channels or time channels requested?
samples = S(1).subs{1};
channels = S(1).subs{2};

if ischar(samples) && (samples == ':')
    samples = 1:(br.nbSamples);
end
if ischar(channels) && (channels == ':')
    channels = 1:(br.nbChannels);
end

% Check for valid range of samples
if any( (samples > br.nbSamples) | (samples < 1) )
    ndx = find(samples > br.nbSamples,1);
    error('MATLAB:badsubscript', 'Sample index %d out of range (nbSamples = %d)',ndx,br.nbSamples);
end

if isnumeric(channels)
    % Check for valid range of channels
    if any( (channels > br.nbChannels) | (channels < 1) )
        error('MATLAB:badsubscript', 'Channel index out of range.');
    end
    
    % Convert to actual channel numbers in the recording file
    channels = br.channels(channels);
    % Invert sign on tetrode channels
    if isnumeric(br.tetrode) || ~isempty(regexp(br.tetrode{1}, '^t[0-9]+c[1-4]{1}$', 'once'))
        multiplier = -1;
    else
        multiplier = 1;
    end
    
    B = zeros(length(samples), length(channels));
    
    % Check whether samples are a block
    if length(samples) > 2 && (samples(end) - samples(1)) == (length(samples) - 1)  && all(diff(samples) == 1)
        % Maximize performance by reading hyperslabs
        cuts = find(diff(channels) ~= 1);
        nbBlocks = length(cuts) + 1;
        blockRanges = zeros(nbBlocks, 2);
        blockRanges(1:end-1, 2) = channels(cuts);
        blockRanges(2:end, 1) = channels(cuts+1);
        blockRanges(1,1) = channels(1);
        blockRanges(end,2) = channels(end);
        blockLens = blockRanges(:,2) - blockRanges(:,1)+1;
        accumLens = [0 reshape(cumsum(blockLens),1,[])];
        for b=1:nbBlocks
            B(:, accumLens(b)+(1:blockLens(b))) = multiplier .* (H5Tools.readDataset(br.fp, params.setName, 'range', [blockRanges(b,1), samples(1)], [blockRanges(b,2), samples(end)], 'datatype', 'H5T_STD_I32LE'));
        end
    else
        for iCh=1:length(channels)
            ch = channels(iCh);
            B(:, iCh) = multiplier .*  (H5Tools.readDataset(br.fp, params.setName, 'index', [repmat(ch, length(samples), 1) , samples(:)], 'datatype', 'H5T_STD_I32LE'));
        end
    end
elseif ischar(channels) && (channels == 't')
    B = 1000 * (samples(:)-1) / br.samplingRate;
end
end

