function data = readDataset(fp, name, varargin)

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

% Catch 3-byte integers. Neural files written by Hammer store the 24-bit
% data as 3-byte integers. Until at least R2007b Matlab converted those to
% regular 4-byte integers when reading as 'H5ML_DEFAULT' but this behavior
% stopped with R2011b (or possibly earlier). We now have to use the n-bit
% filter to expand the 3-byte integer into a regular 4-byte integer, then
% divide by 2^8 to restore the original scale.
tp = H5D.get_type(dataset);
if H5T.get_class(tp) == H5ML.get_constant_value('H5T_INTEGER') && H5T.get_size(tp) == 3
    datatype = H5T.copy('H5T_NATIVE_INT');
    H5T.set_precision(datatype, 24);
    H5T.set_offset(datatype, 8);
    H5T.set_pad(datatype, 'H5T_PAD_ZERO', 'H5T_PAD_ZERO');
    data = H5D.read(dataset, datatype, memspace, dataspace, 'H5P_DEFAULT') / 2^8;
    H5T.close(datatype);
else
    data = H5D.read(dataset, 'H5ML_DEFAULT', memspace, dataspace, 'H5P_DEFAULT');
end

H5T.close(tp);
H5S.close(memspace);
H5S.close(dataspace);
H5D.close(dataset);
