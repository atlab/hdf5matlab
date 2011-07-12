function fp = openFamily(fname, flags)

if nargin < 2
    flags = 'H5F_ACC_RDONLY';
end

fapl = H5P.create('H5P_FILE_ACCESS');
if (strmatch(flags, 'H5F_ACC_RDWR'))
    H5P.set_fapl_family(fapl, 2147483648, 'H5P_DEFAULT');
else
    H5P.set_fapl_family(fapl, 0, 'H5P_DEFAULT');
end
fp = H5F.open(fname, flags, fapl);
H5P.close(fapl);
