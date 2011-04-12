function varargout = size(fr, dim)

sz = [fr.nbSamples, fr.nbChannels];
if (nargout == 1) && (nargin > 1)
    varargout{1} = sz(dim);
elseif (nargout > 1)
    varargout = num2cell( sz(1:nargout) );
else
    varargout{1} = sz;
end