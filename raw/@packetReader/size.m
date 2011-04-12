function varargout = size(br, dim)

sz = br.nbPackets(br.active);
if length(sz)==1
    sz = [sz 1];
end
if (nargin > 1)
    varargout{1} = sz(dim);
elseif (nargout > 1)
    varargout = num2cell( sz(1:nargout) );
else    
    varargout{1} = sz;
end