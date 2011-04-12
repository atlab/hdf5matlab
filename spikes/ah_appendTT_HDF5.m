function ah_appendTT_HDF5(filename, tt)
% Append tt structure to already existing file.
%   ah_appendTT_HDF5(filename, tt) appends the tt structure to the given
%   file.
%
% AE 2009-04-03

% is there anything to append?
if isempty(tt.t)
    return
end

% open file for writing
filename = getLocalPath(filename);
fp = H5F.open(filename, 'H5F_ACC_RDWR', 'H5P_DEFAULT');
if double(fp) < 0
    error('appendTT:couldNotOpen', 'Could not open file %s.\n', filename);
end

% check for consistency
dims = H5Tools.getDatasetDim(fp, 'tt_w/Ch1');
assert(dims(2) == size(tt.w{1}, 1), 'appendTT:inconsistentSize', ...
    'Waveform segment length inconsistent with existing file!')

% Append tt information
H5Tools.appendDataset(fp, 'tt_t', tt.t, 1);
H5Tools.appendDataset(fp, 'tt_h', tt.h, 1);
for ch = 1:length(tt.w)
    datasetName = sprintf('tt_w/Ch%u', ch);
    H5Tools.appendDataset(fp, datasetName, tt.w{ch}, 2);
end

% update end time?
if isfield(tt, 'tend') && ~isempty(tt.tend)
    rootGroup = H5G.open(fp, '/');
    H5Tools.writeAttribute(rootGroup, 'tEnd', tt.tend);
    close(rootGroup)
end

% clean up
close(fp);
