function dim = getRecordingDim(br)

if ~H5Tools.existDataset(br.fp, '/data')
    error('Recording file does not contain data matrix ''/data''')
end

dim.tetrodes = getRecordedTetrodes(br);
dataDim = H5Tools.getDatasetDim(br.fp, 'data');
dim.nbRecChannels = dataDim(1);
dim.nbSamples     = dataDim(2);
rootGroup = H5G.open(br.fp, '/');
if H5Tools.existAttribute(rootGroup, 'sample rate')
    dim.samplingRate = H5Tools.readAttribute(rootGroup, 'sample rate');
else
    dim.samplingRate = -1;
    warning('Could not read ''sample rate'' attribute from recording file.');
end
H5G.close(rootGroup);    
dim.duration = 1000 * dim.nbSamples / dim.samplingRate;
