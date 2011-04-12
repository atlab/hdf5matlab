function idx = binary_search(collection, value, range, comparator)

% binary_search(collection, value, range, comparator)
% Binary search:
% Searches for 'value' in 'collection'. The latter can be a vector
% or a function that returns a scalar when supplied with a 1-based index as
% parameter.
% range = [min max] or empty to limit the search to part of the collection
% comparator(x,y) must return 0 if equal, >0 if x > y and <0 if x < y
% By default, comparator = @minus
% 
% If collection is an array, then range can be empty

if (nargin <4)
    comparator = @minus;
end
if (nargin < 3) || isempty(range)
    if isnumeric(collection)
        range = [1 length(collection)];
    else
        error('Range must be specified if ''collection'' is not a vector')
    end
end


low = uint32(range(1) - 1);
high = uint32(range(2) + 1);
idx = -1;           % Default return value for not found

while (high - low) > 1
    probe = bitshift(high + low, -1);
    compVal = comparator(collection(probe), value);
    if  compVal > 0
        high = probe;
    elseif compVal < 0
        low = probe;
    else
        idx = probe;
        return
    end
end

    
