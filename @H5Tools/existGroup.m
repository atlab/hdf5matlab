function e = existGroup(fp, name)

% e = existDataset(fp, name)
%
% Returns true if 'name' is a dataset in the file
% associated with file handle fp.

try
    group = H5G.open(fp, name);
    H5G.close(group);
    e = true;
catch
    e = false;
end
