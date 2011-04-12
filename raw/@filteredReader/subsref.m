function B = subsref(fr, S)

% This subsref allows for easy data access via () indexing parentheses.
nFiltLen = getFilterLength(fr.filter);
if strcmp(S(1).type, '.') && strcmp(S(1).subs, 't')
    if (length(S) == 2) && strcmp(S(2).type, '()')
        T = S(2);
        T.subs = [T.subs 't'];
        B = subsref(fr, T);
    else
        T.type = '()';
        T.subs = {':', 't'};
        B = subsref(fr, T);
    end
    return
end

if length(S) ~= 1 || ~strcmp(S(1).type, '()') || length(S(1).subs) ~= 2
    error('Only subscripting of the form (samples, channels) is allowed.')
end

samples = S(1).subs{1}; 
channels = S(1).subs{2};

if ischar(samples) && (samples == ':')
    samples = 1:(fr.nbSamples);
end
if ischar(channels) && (channels == ':')
    channels = 1:(fr.nbChannels);
end

% Signal channels or time channels requested?
if isnumeric(channels)
    if (length(samples) == 1) || (length(samples) > 2 && (samples(end) - samples(1)) == (length(samples) - 1)  && all(diff(samples) == 1))
       
       % PHB, 2010-09-17: changed to use the correct samples 
       % before, the signal was shifted by one sample; now we already
       % use the n-th value spit out by the filtering
        B = fr.reader( samples(1):samples(end)+nFiltLen-1, channels );
        B = reshape(B, [], length(channels));
        B = apply(fr.filter, B);
        B = B(nFiltLen:end, :);
    else
       % Cut indices into blocks
       B = zeros(length(samples), length(channels));
       blockEnds = find(diff(samples) > nFiltLen | diff(samples) < 1);
       blockIdx = zeros(length(blockEnds)+1,2);
       blockIdx(1:end-1,2) = blockEnds;
       blockIdx(2:end, 1) = blockEnds+1;
       blockIdx(end,2) = length(samples);
       blockIdx(1,1) = 1;
       blockPos = reshape( samples(blockIdx), [], 2);
       for iBlock = 1:size(blockIdx,1)
           % PHB, 2010-09-17: changed to use the correct samples 
           % before, the signal was shifted by one sample; now we already
           % use the n-th value spit out by the filtering
           temp = fr.reader(blockPos(iBlock,1):blockPos(iBlock,2)+nFiltLen-1, channels );
           temp = apply(fr.filter, temp);
           B(blockIdx(iBlock,1):blockIdx(iBlock,2), :) = temp( nFiltLen + samples(blockIdx(iBlock,1):blockIdx(iBlock,2))-blockPos(iBlock,1), :);
       end
    end
elseif ischar(channels) && (channels == 't')
        B = fr.reader(samples+fr.delay, 't');
end

