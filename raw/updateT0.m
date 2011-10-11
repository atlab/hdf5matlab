function updateT0(fileName, t0)
% Update t0 in HDF5 file.
%   updateT0(fileName, t0) updates t0 in the given file.

fp = H5Tools.openFamily(fileName, 'H5F_ACC_RDWR');
attr = H5A.open_name(fp, 't0');
H5A.write(attr, 'H5ML_DEFAULT', t0);
H5A.close(attr);
H5F.close(fp);
fprintf('Updated t0 in file %s\n', fileName);
