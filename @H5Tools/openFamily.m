function fp = openFamily(fname, flags)

if nargin < 2
    flags = 'H5F_ACC_RDONLY';
end

fapl = H5P.create('H5P_FILE_ACCESS');
H5P.set_fapl_family(fapl, 2147483647, 'H5P_DEFAULT');
fp = H5F.open(fname, flags, fapl);
H5P.close(fapl);
