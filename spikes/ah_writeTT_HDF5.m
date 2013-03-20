function ah_writeTT_HDF5(filename, tt, varargin)

params.samplingRate = 32000;
params.version = 1;
params.units = 'unknown';
params.tt_tChunks = 32 * 256;
params.tt_hChunks = 8 * 256;
params.tt_wChunks = 256;
if isfield(tt, 'aligned')
    params.aligned = tt.aligned;
else
    params.aligned = 0;
end

for i=1:2:length(varargin)
    params.(varargin{i}) = varargin{i+1};
end

nbPoints = length(tt.t);
nbChannels = length(tt.w);
nbSamples = size(tt.w{1}, 1);

% convert filename and create file
filename = getLocalPath(filename);
fp = H5Tools.createFile(filename);

if double(fp) < 0
    error(sprintf('Creation of file %s failed.\n', filename));
end

% Save tt information
%=====================
H5Tools.writeDataset(fp, 'tt_t', tt.t, [params.tt_tChunks, 1],{'H5S_UNLIMITED', 1});
H5Tools.writeDataset(fp, 'tt_h', tt.h, [params.tt_hChunks, size(tt.h, 2)],{'H5S_UNLIMITED', size(tt.h, 2)});

% Create group for channel waveforms
waveGroup = H5G.create(fp, '/tt_w', 0);
for ch=1:nbChannels
    datasetName = sprintf('Ch%u', ch);
    H5Tools.writeDataset(waveGroup, datasetName, tt.w{ch}, [size(tt.w{ch}, 1), params.tt_wChunks],{size(tt.w{ch}, 1),'H5S_UNLIMITED'});
end
H5G.close(waveGroup);

% Attributes with recording information
% =====================================
rootGroup = H5G.open(fp, '/');
H5Tools.writeAttribute(rootGroup, 'nbChannels', uint32(nbChannels));
H5Tools.writeAttribute(rootGroup, 'nbWaveformSamples', uint32(nbSamples));
H5Tools.writeAttribute(rootGroup, 'nbSpikes', uint32(nbPoints));
H5Tools.writeAttribute(rootGroup, 'samplingRate', uint32(params.samplingRate));
H5Tools.writeAttribute(rootGroup, 'aligned', uint32(params.aligned));
H5Tools.writeAttribute(rootGroup, 'version', params.version);
H5Tools.writeAttribute(rootGroup, 'units', params.units);
if isfield(tt, 'tstart') && ~isempty(tt.tstart), H5Tools.writeAttribute(rootGroup, 'tStart', tt.tstart); end
if isfield(tt, 'tend') && ~isempty(tt.tend),   H5Tools.writeAttribute(rootGroup, 'tEnd', tt.tend);     end
H5G.close(rootGroup);
H5F.flush(fp, 'H5F_SCOPE_GLOBAL');
H5F.close(fp);
