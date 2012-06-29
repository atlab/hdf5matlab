function tt = ah_readHDF5info(filename, varargin)

% Read HDF5 data
fp = H5F.open(filename, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Precreate output structure
tt = struct('tstart', [], 'tend', [], 'nbSpikes', [], 'nbBytesPerSpikes', []);

% determine number of spikes
dim = H5Tools.getDatasetDim(fp, 'tt_t');
tt.nbSpikes = dim;

% Read some attributes (e.g., number of Channels)
rootGroup = H5G.open(fp, '/');
if H5Tools.existAttribute(rootGroup, 'tStart') && ...
        H5Tools.existAttribute(rootGroup, 'tEnd')
    
    tt.tstart = H5Tools.readAttribute(rootGroup, 'tStart');
    tt.tend   = H5Tools.readAttribute(rootGroup, 'tEnd');
else
    if any(dim==0) % MS 2012-06-29 - to handle the case of no spikes
        tt.tstart = NaN;
        tt.tend = NaN;
    else
        tt_t = H5Tools.readDataset(fp, 'tt_t', 'index', [1; dim]);
        tt.tstart = tt_t(1);
        tt.tend = tt_t(2);
    end
end
H5G.close(rootGroup);

% try
%     dataset = H5D.open(fp, 'tt_t');
%     dataspace = H5D.get_space(dataset);
%     [foo spaceDims] = H5S.get_simple_extent_dims(dataspace);
%     tt.nbSpikes = prod(spaceDims);
%     H5S.close(dataspace);
%     H5D.close(dataset);
% catch
%     error('Error while determining dimensions of dataset.');
% end

H5F.close(fp);
