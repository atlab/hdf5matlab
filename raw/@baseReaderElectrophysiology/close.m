function br = close(br)

warning('check me')

if ~isempty(br.fp)
    H5F.close(br.fp);
    br.fp = [];
end
