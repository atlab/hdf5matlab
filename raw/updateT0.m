function updateT0(fileName, t0)
% Update t0 in HDF5 file.
%   updateT0(fileName, t0) updates t0 in the given file.

assert(isscalar(t0) && t0 > 0, 't0 must be a positive scalar!')

% check if t0 attribute exists
fp = H5Tools.openFamily(fileName, 'H5F_ACC_RDONLY');
if ~H5Tools.existAttribute(fp, 't0')
    H5F.close(fp);
    error('updateT0:attributeNotFound', 'Attribute t0 not found in file %s (empty file or wrong file type?)', fileName)
end
H5F.close(fp);

% update t0
fp = H5Tools.openFamily(fileName, 'H5F_ACC_RDWR');
attr = H5A.open_name(fp, 't0');
H5A.write(attr, 'H5ML_DEFAULT', t0);
fprintf('Updated t0 in file %s\n', fileName);
H5A.close(attr);
H5F.close(fp);
