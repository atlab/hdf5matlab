function hdfType = getHDF5Type(data)

    switch class(data)
    case 'int8'
	hdfType = H5T.copy('H5T_STD_I8LE');
    case 'uint8'
	hdfType = H5T.copy('H5T_STD_U8LE');
    case 'int16'
	hdfType = H5T.copy('H5T_STD_I16LE');
    case 'uint16'
	hdfType = H5T.copy('H5T_STD_U16LE');
    case 'int32'
	hdfType = H5T.copy('H5T_STD_I32LE');
    case 'uint32'
	hdfType = H5T.copy('H5T_STD_U32LE');
    case 'int64'
	hdfType = H5T.copy('H5T_STD_I64LE');
    case 'uint64'
	hdfType = H5T.copy('H5T_STD_U64LE');
    case 'single'
	hdfType = H5T.copy('H5T_IEEE_F32LE');
    case 'double'
	hdfType = H5T.copy('H5T_IEEE_F64LE');
    case 'char'
	hdfType = H5T.copy('H5T_C_S1');
	H5T.set_size(hdfType, size(data,1));
    otherwise
	error('Only integer and floating point datatypes are supported. Argument is of type %s\n', class(data));
    end
