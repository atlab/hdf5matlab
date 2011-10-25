function br = close(br)

if ~isempty(br.fp)
    %H5F.close(br.fp);
    fclose(br.fp); %file is actually handled in openNSx/NEV functions.
    br.fp = [];
end
