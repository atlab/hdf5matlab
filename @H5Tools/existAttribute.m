function e = existAttribute(fp, name)

% e = existAttribute(fp, name)
%
% Returns true if 'name' is a attribute in the file
% associated with file handle fp.

try
    attribute = H5A.open_name(fp, name);
    H5A.close(attribute);
    e = true;
catch
    e = false;
end
