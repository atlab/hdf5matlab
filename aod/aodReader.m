function br = aodReader(fileName, dataset, varargin)
% Factory method creating an appropriate data reader.
%   br = baseReader(fileName) returns a base reader for the file indicated
%   by fileName. The method automatically detects the file format and
%   selects the appropriate reader.
%
%   br = baseReader(fileName, channels) opens a reader for the given
%   channels. channels is a string or a cell array of strings containing
%   the name(s) of the channels to be opened. 
%
%   br = baseReader(fileName, pattern) opens a reader for the channel group
%   (e.g. tetrode, polytrode, etc.) defined by pattern. The pattern should
%   contain a wildcard (*) for channel numbers (e.g. 't10c*', poly7ch*).
%   This syntax onmly works for a single channel group.
%
% AE 2011-04-11
% JC 2012-02-20

% Some checks on input arguments
assert(nargin > 0, 'aodReader:noFileName', 'No file name provided!')
if nargin > 2
    assert(iscell(varargin{1}) || ischar(varargin{1}), ...
        'baseReader:invalidChannelDef', ...
        'Channels must be specified by names or as a pattern!')
end

% read attribute 'class', which tells us which reader to create. If it
% doesn't exist, we're dealing with a legacy (Hammer) file
% fp = H5F.open(fileName, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
fp = H5Tools.openFamily(fileName);
if H5Tools.existAttribute(fp, 'class')
    cl = H5Tools.readAttribute(fp, 'class');
    cl = reshape(cl,1,[]);
    
    assert(strncmp(cl,'AODAcq',length(cl)-1) == 1, ...
        'aodReader:fileType', 'Wrong file type');
end
H5F.close(fp);   % close opened file

if strcmp(dataset, 'Temporal') == 1
    br = HDF5Helper(fileName, 'TemporalData');
elseif strcmp(dataset, 'Functional') == 1
    br = AodScanReader(fileName);
elseif strcmp(dataset, 'Motion') == 1
    br = AodMotionReader(fileName);
elseif strcmp(dataset, 'Volume') == 1
    br = AodVolumeReader(fileName);
elseif strcmp(dataset, 'HRVolume') ==1
    br = AodHRVolumeReader(fileName,varargin{1});
else
    error('Unknown dataset.  Options are Temporal, Functional,Volume and Motion.');
end
