function dim = getDatasetDim(fp, name)
% data = getDatasetDim(fp, name)
%
% Equivalent of Matlab's size() function
% for HDF5 datasets

dataset = H5D.open(fp, name);
dataspace = H5D.get_space(dataset);

[foo, dim] = H5S.get_simple_extent_dims(dataspace); %#ok<ASGLU>

H5S.close(dataspace);
H5D.close(dataset);
