function br = baseReaderElectrophysiology(fileName, channels)
% Base reader for electrophysiology recordings
%   br = baseReaderElectrophysiology(fileName) opens a base reader for the
%   file given in fileName.
%
%   br = baseReaderElectrophysiology(fileName, channels) opens a reader for
%   only the given channels, where channels is either a numerical vector of
%   channel indices, a string containing a channel name or a cell array of
%   stings containig multiple channel names.
%
%   br = baseReaderElectrophysiology(fileName, pattern) opens a reader for
%   a group of channels matching the given pattern. Channel groups can be
%   for instance tetrodes. In this case the pattern would be 't10c*'.
%
% AE 2011-04-11

br.fileName = fileName;
br.fp = H5Tools.openFamily(fileName);
% br.fp = H5F.open(fileName, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
sz = H5Tools.getDatasetDim(br.fp, 'data');
br.nbChannels = sz(1);
br.nbSamples = sz(2);
if nargin < 2
    channels = 1:br.nbChannels;
end
if isnumeric(channels)
    br.chIndices = channels;
    br.chNames = H5Tools.getChannelNames(br.fp, channels);
else
    [br.chIndices, br.chNames] = H5Tools.matchChannels(br.fp, channels);
end
br.Fs = H5Tools.readAttribute(br.fp, 'Fs');
br.t0 = H5Tools.readAttribute(br.fp, 't0');

br = class(br, 'baseReaderElectrophysiology');
