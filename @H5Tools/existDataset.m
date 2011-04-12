function e = existDataset(fp, name)

% e = existDataset(fp, name)
%
% Returns true if 'name' is a dataset in the file
% associated with file handle fp.

try
    dataset = H5D.open(fp, name);
    H5D.close(dataset);
    e = true;
catch
    e = false;
end
