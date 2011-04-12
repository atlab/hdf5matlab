function close(br)

if ~isempty(br.fp)
    H5F.close(br.fp);
    br.fp = [];
end
