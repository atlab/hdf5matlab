function br = baseReaderMPI(fileName, channel)
% Base reader for MPI recordings on Neuralynx Cheetah system
%   br = baseReaderMPI(fileName) opens a base reader for the file given in
%   fileName.
%
%   br = baseReaderMPI(fileNamePattern, channel) opens a base reader for
%   the file given as fileNamePattern (/path/to/CSC%d.Ncs) and channel.
%
% AE 2012-09-04

if nargin > 1 && any(fileName == '%')
    if ischar(channel)
        channel = str2double(channel(2));
    end
    fileName = sprintf(fileName, channel);
end

% read entire file. this is the only way of doing it since the files need
% not be continuous and various functions such as getSampleIndex would not
% work unless we have all data in memory. Since those files are sampled at
% 2 kHz anyway, this is not a big deal (<500 MB files)
br = read_cr(fileName);
br.fileName = fileName;
br.nbChannels = 1;
[~, fname] = fileparts(fileName);
br.tetrode = sscanf(fname, 'CSC%d');
br.chNames = {sprintf('t%dc1', br.tetrode)};
br.nbSamples = numel(br.v);
br.Fs = br.sample_freq;
br = rmfield(br, 'sample_freq');
br.t0 = br.t(1);
br.scale = 2^11 / (1e6 / 3000);
br.v = br.v / br.scale; % convert to muV

br = class(br, 'baseReaderMPI');
