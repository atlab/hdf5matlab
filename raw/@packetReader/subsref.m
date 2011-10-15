function B = subsref(pr, S)

% This subsref allows for easy data access via () indexing parentheses.`

% Handle the special case of '.' access
if  strcmp(S(1).type, '.')
    B = pr.reader(S(1).subs);
    return
end

if (length(S) == 2) && strcmp(S(1).type, '()') && strcmp(S(2).type, '.')
    %B = pr.base(S(2).subs)(genIndices(pr, 1, S(1).subs));
    T(1) = S(2);
    T(2).type = '()';
    T(2).subs = {genIndices(pr, 1, S(1).subs{1})};
    if strcmp(S(2).subs, 'indices')
      B = T(2).subs{1};
    else
      B = subsref(pr.reader, T);
    end
    return
end

if length(S) ~= 1 || ~strcmp(S(1).type, '()') || length(S(1).subs) ~= sum(pr.active)
    error('Only subscripting of the form (packetIdx1,packetIdx2,...) is allowed.')
end

selector   = cell(1,length(pr.active));
subscripts = cell(1,length(pr.active));
subscripts(pr.active) = S(1).subs;

for iDim=1:length(pr.active)
    if ~pr.active(iDim) || (ischar(subscripts{iDim}) && strcmpi(subscripts{iDim}, ':'))
        selector{iDim} = ':';
    else
        selector{iDim} = genIndices(pr, iDim, subscripts{iDim});
    end
end

B = pr.reader(selector{:});

function sel = genIndices(pr, iDim, indices)

if ~pr.active(iDim) || (ischar(indices) && strcmpi(indices, ':'))
    sel = ':';
else
    baseSel = repmat(1:pr.stride(iDim), 1, length(indices));
    adders = pr.stride(iDim) * (indices(:)'-1);
    adders = repmat(adders, pr.stride(iDim), 1);
    sel = baseSel + adders(:)';
    if any(indices == pr.nbPackets(iDim))
        sel = sel(sel <= size(pr.reader, iDim));
    end
end
