function data = readAttribute(fp, name)
% Read attribute.
%   data = readAttribute(fp, name) reads attribute 'name' from file handle
%   fp.

attr = H5A.open_name(fp, name);
sp = H5A.get_space(attr);
[nbDims, dims] = H5S.get_simple_extent_dims(sp);
if nbDims == 0 || any(dims ~= 0)
    data = H5A.read(attr, 'H5ML_DEFAULT');
else
    data = [];
end
H5S.close(sp);
H5A.close(attr);
