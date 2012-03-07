function data = readDatasetForce(fp, name, varargin)

% data = readDataset(fp, name, varargin)
%
% Reads dataset 'name' from file handle fp.
% Parameters (passed via varargin):
% 'index', i   - where i is a [nxd] array that identifies
%                the n data points to read from the d-dimensional
%                matrix stored in the file
% 'range',s,e  - where the d-element vectors identify the (inclusive, 1-based)
%                start and end coordinates of the block to read from the file
% The whole dataset will be read if no further parameters are specified.

dataset = H5D.open(fp, name);
dataspace = H5D.get_space(dataset);
format = 'H5T_STD_I32LE';

% Select datapoints we are interested in
% and create an appropriate memory dataspace
if length(varargin) >= 2 && strcmpi(varargin{1}, 'index')
    dims = size(varargin{2},1);
    H5S.select_elements(dataspace, 'H5S_SELECT_SET', varargin{2}' - 1);
elseif length(varargin) >= 3 && strcmpi(varargin{1}, 'range')
    dims = varargin{3}-varargin{2}+1;
    H5S.select_hyperslab(dataspace, 'H5S_SELECT_SET', varargin{2}-1, [], dims, []);  
else
    [foo dims] = H5S.get_simple_extent_dims(dataspace);
    H5S.select_all(dataspace);
end

if (H5S.select_valid(dataspace) <= 0)
    error('Invalid range or index selection  in readHDF5tt.')
end

% create memory space
maxDims = dims;
maxDims(maxDims == 0) = -1;
memspace = H5S.create_simple(length(dims), dims, maxDims);

% Read data
data = H5D.read(dataset, format, memspace, dataspace, 'H5P_DEFAULT');

H5S.close(memspace);
H5S.close(dataspace);
H5D.close(dataset);
