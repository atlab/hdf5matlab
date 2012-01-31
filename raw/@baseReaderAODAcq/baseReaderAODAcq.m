function br = baseReaderAODAcq(fileName)
% Base reader for AODAcq recordings
%   br = baseReaderElectrophysiology(fileName) opens a base reader for the
%   file given in fileName.
%
%   br = baseReaderAODAcq(fileName, channels) opens a reader for
%   only the given channels, where channels is either a numerical vector of
%   channel indices, a string containing a channel name or a cell array of
%   stings containig multiple channel names.
%
%   br = baseReaderAODAcq(fileName, pattern) opens a reader for
%   a group of channels matching the given pattern. Channel groups can be
%   for instance tetrodes. In this case the pattern would be 't10c*'.
%
% JC 2012-01-23

br.fileName = fileName;
br.fp = H5Tools.openFamily(fileName);
% br.fp = H5F.open(fileName, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
sz = H5Tools.getDatasetDim(br.fp, 'ImData');
br.nbImChannels = sz(1);
br.nbImSamples = sz(2);

sz = H5Tools.getDatasetDim(br.fp, 'TemporalData');
br.nbTemporalChannels = sz(1);
br.nbTemporalSamples = sz(2);

channels = 1:br.nbImChannels;
if isnumeric(channels)
    br.imChIndices = channels;
    %br.imChNames = H5Tools.getChannelNames(br.fp, channels);
    br.imChNames = {'green','red'};
else
    error('Unuspported');
    [br.imChIndices, br.imChNames] = H5Tools.matchChannels(br.fp, channels);
end


channels = 1:br.nbTemporalChannels;
if isnumeric(channels)
    br.temporalChIndices = channels;
    br.temporalChNames = {'photodiode','electrophysiology'};
else
    error('Unuspported');
    [br.temporalChIndices, br.temporalChNames] = H5Tools.matchChannels(br.fp, channels);
end



if(H5Tools.existAttribute(br.fp, 't0'))
    br.t0 = H5Tools.readAttribute(br.fp, 't0');
else
    br.t0 = 0;
end

br.Fs = 1;

br = class(br, 'baseReaderAODAcq');
