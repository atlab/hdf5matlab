function fr=filteredReader(varargin)

if length(varargin)==1 && isa(varargin{1}, 'filteredReader')
    fr = varargin{1};
    return;
end

% Default values for class members
fr.reader = [];
fr.filter = [];
fr.delay = 0;
fr.nbChannels = 0;
fr.nbSamples = 0;
   

% Actual parameters were supplied, i.e. a basic reader
if isValidBaseReader(varargin{1}) && isa(varargin{2}, 'waveFilter')
    fr.reader = varargin{1};
    fr.filter = varargin{2};
    % Get some basic data about the datastream
    [nbSamples nbChannels] = size(fr.reader);
    % and the filter
    fr.delay = getAverageDelay(fr.filter);
    fr.nbSamples = max(0, nbSamples - getFilterLength(fr.filter));
    fr.nbChannels = nbChannels;
else
    error('Please initialize filteredReader with a baseReader and a waveFilter object as parameters.')
end
fr = class(fr, 'filteredReader');



function valid = isValidBaseReader(reader)

cl = class(reader);
valid = strcmp(cl(1:10), 'baseReader') || isa(reader, 'tpElChannel') || isa(reader, 'tpMaskReader');

