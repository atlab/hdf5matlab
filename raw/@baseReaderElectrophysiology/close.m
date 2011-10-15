function varargout = close(br)

if ~isempty(br.fp)
    H5F.close(br.fp);
    br.fp = [];
end
if nargout
    varargout{1} = br;
end
