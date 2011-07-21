function br = updateT0(br, t0)

br = close(br);
fp = H5Tools.openFamily(br.fileName, 'H5F_ACC_RDWR');

attr = H5A.open_name(fp, 't0');
H5A.write(attr, 'H5ML_DEFAULT', t0);
H5A.close(attr);
H5F.close(fp);

br = baseReaderElectrophysiology(br.fileName, br.chNames);
