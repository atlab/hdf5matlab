function tt=ah_readTetInfo(filename, varargin)

% This is a wrapper to read data from Ntt files and Htt files (HDF5)

[fPath fFile fExt] = fileparts(filename);

if strcmpi(fExt, '.Htt')
    tt = ah_readHDF5info(filename, varargin{:});
    tt.indLow = 1;
    tt.indHigh= tt.nbSpikes;
else
    % Use MEX file for Ntt files
    tt = ah_read_tt_info(filename, varargin{:});
    tt.indLow = 0;
    tt.indHigh= tt.nbSpikes-1;
end
