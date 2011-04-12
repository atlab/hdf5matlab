function dim = getRecordingDim(fp)

if ~H5Tools.existDataset(fp, '/data')
    error('Recording file does not contain data matrix ''/data''')
end

dim.tetrodes = H5Tools.getRecordedTetrodes(fp);
dataDim = H5Tools.getDatasetDim(fp, 'data');
dim.nbRecChannels = dataDim(1);
dim.nbSamples     = dataDim(2);
rootGroup = H5G.open(fp, '/');
if H5Tools.existAttribute(rootGroup, 'sample rate')
    dim.samplingRate = H5Tools.readAttribute(rootGroup, 'sample rate');
else
    dim.samplingRate = -1;
    warning('Could not read ''sample rate'' attribute from recording file.');
end
H5G.close(rootGroup);    
dim.duration = 1000 * dim.nbSamples / dim.samplingRate;
