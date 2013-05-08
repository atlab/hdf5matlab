function varargout = size(br, varargin)

[varargout{1:nargout}] = size(br.reader, varargin{:});
