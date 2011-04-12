function pr=packetReader(varargin)

% Creates a packetReader
% Example:
% packetReader(base, 1, 'stride', 2000)
% packetReader(base, [1 2], 'nbPackets', [100 20])

if length(varargin)==1 && isa(varargin{1}, 'packetReader')
    pr = varargin{1};
    return;
end

% Default values for class members
pr.reader = [];
pr.stride = 0;
pr.nbPackets = 0;
pr.active = false;
   

% Actual parameters were supplied
if length(varargin) == 4 
    pr.reader    = varargin{1};
    pr.stride    = zeros(1, ndims(pr.reader));
    pr.active    = false(1, ndims(pr.reader));
    pr.nbPackets = ones(1, ndims(pr.reader));
    
    if ~issorted(varargin{2})
        error('Please specify the dimensions to packetize in ascending order.');
    end
    pr.active(varargin{2}) = true;    
    
    if strcmpi(varargin{3}, 'stride')
        pr.stride = size(varargin{1});
        pr.stride(varargin{2}) = varargin{4};
        pr.nbPackets = ceil(size(pr.reader) ./ pr.stride);
    elseif strcmpi(varargin{3}, 'nbPackets')
        pr.nbPackets( varargin{2} ) = varargin{4};
        pr.stride = ceil( size(pr.reader) ./ pr.nbPackets );
    else
        error('Second argument in packetReader() call must be ''stride'' or ''nbPackets''.')
    end
end        
 
pr = class(pr, 'packetReader');
