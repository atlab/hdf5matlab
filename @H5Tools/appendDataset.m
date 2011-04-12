function appendDataset(fp, name, data, dim)
% Append data to a dataset.
%   H5Tools.appendDataset(fp, dataset, data, extendDim) appends data to the
%   dataset along the specified dimension extendDim. Note that only
%   two-dimensional data is supported at the moment.
%
% AE 2009-04-03

% make sure data is 2d
assert(numel(size(data)) == 2,'H5Tools:invalidDataDim','Data must be vector or 2d matrix!')
assert(ismember(dim,1:2),'H5Tools:invalidDim','Dimension must be 1 or 2!')

% convert to row-major order
appendSize = fliplr(size(data));
dim = 3 - dim;

% make sure data to be appended matches in size to what is already in there
oldSize = H5Tools.getDatasetDim(fp, name)';
if isscalar(oldSize)
    assert(isvector(data),'H5Tools:invalidDim','data must be a vector to append to this dataset!')
    appendSize = length(data);
    newSize = oldSize + appendSize;
    startIndex = oldSize;
else
    assert(appendSize(3-dim) == oldSize(3-dim),'H5Tools:invalidDim','Size of existing data and data to be appended don''t match!')
    newSize = oldSize;
    newSize(dim) = oldSize(dim) + appendSize(dim);
    startIndex = zeros(1,2);
    startIndex(dim) = oldSize(dim);
end

% Extend dataset
dataset = H5D.open(fp, name);
H5D.extend(dataset, newSize)

% Select appended part of the dataset
dataspace = H5D.get_space(dataset);
H5S.select_hyperslab(dataspace, 'H5S_SELECT_SET', startIndex, [], appendSize, []);

% Create a memory dataspace of equal size.
memspace = H5S.create_simple(numel(newSize), appendSize, []);

% And write the data
H5D.write(dataset, 'H5ML_DEFAULT', memspace, dataspace, 'H5P_DEFAULT', data);

% Clean up
H5S.close(memspace);
H5S.close(dataspace);
H5D.close(dataset);
