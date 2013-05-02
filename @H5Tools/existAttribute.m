function e = existAttribute(fp, name)
% e = existAttribute(fp, name)
%
% Returns true if 'name' is a attribute in the file
% associated with file handle fp.

try
    root = H5G.open(fp, '/');
    attribute = H5A.open_name(root, name);
    H5A.close(attribute);
    e = true;
catch %#ok
    e = false;
    return
end

H5G.close(root);
