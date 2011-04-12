function tt=ah_readTetData(filename, varargin)

% This is a wrapper to read data from Ntt files and Htt files (HDF5)

[fPath fFile fExt] = fileparts(filename);

if strcmpi(fExt, '.Htt') || strcmpi(fExt,'.Hsp')
    tt = ah_readHDF5tt(filename, varargin{:});
elseif strcmpi(fExt, '.Ntt')
    % Use MEX file for Ntt files
    if isempty(varargin)
        tt = read_tt(filename, 'all');
    else
        % make sure we don't try to read negative indices since this will
        % give rise to a nasty seg fault in matlab
        if chkidx(varargin)
            error('Index must be positive! Check you index arguments.')
        end
        tt = read_tt(filename, varargin{:});
    end
else 
    error('Unsupported file extension');
end


function err = chkidx(args)

err = false;
for i = 1:numel(args)-1
    if ischar(args{i}) && strcmp(args{i},'index') && any(args{i+1} < 0)
        err = true;
        return
    end
end
