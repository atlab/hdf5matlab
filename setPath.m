function setPath
    % Add subfolders for HDF5 access to the path
    addpath(fileparts(mfilename('fullpath')))
    addpath(fullfile(fileparts(mfilename('fullpath')), 'raw'))
    addpath(fullfile(fileparts(mfilename('fullpath')), 'spikes'))
    addpath(fullfile(fileparts(mfilename('fullpath')), 'aod'))
end
