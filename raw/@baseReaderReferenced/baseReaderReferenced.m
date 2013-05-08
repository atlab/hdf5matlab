function br = baseReaderReferenced(varargin)
% Base reader for referenced electrophysiology recordings
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

if length(varargin)==1 && isa(varargin{1}, 'baseReaderReferenced')
    br = varargin{1};
    return;
elseif length(varargin)>=2 && ...
        isa(varargin{1}, 'baseReaderElectrophysiology') && ...
        (isa(varargin{2}, 'baseReaderElectrophysiology') || ...
         isa(varargin{2}, 'baseReaderHammer'))
    br.reader = varargin{1};
    br.reference = varargin{2};
    
    assert(size(br.reader,1) == size(br.reference,1), ...
        'Size of reference does not match reader');

    assert(getSamplingRate(br.reader) == getSamplingRate(br.reference), ...
        'Sampling rate of reference does not match reader');

    br = class(br, 'baseReaderReferenced');

    return;
else
    error('Inputs do not match.  Pass a reader and a reference');
end

