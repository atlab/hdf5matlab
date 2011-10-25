function br = baseReader(fileName, varargin)
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

% Some checks on input arguments
assert(nargin > 0, 'baseReader:noFileName', 'No file name provided!')
if nargin > 1
    assert(iscell(varargin{1}) || ischar(varargin{1}), ...
        'baseReader:invalidChannelDef', ...
        'Channels must be specified by names or as a pattern!')
end

% Catch blackrock files and open the approperiate reader. -WW2011
alienExt = {'.nev','.ns1','.ns2','.ns3','.ns4','.ns5'}; % blackrock file extensions
[~, ~, ext] = fileparts(fileName);
if any(strcmpi(ext, alienExt))
    br = baseReaderBlackrock(fileName, varargin{:});
    return
end

classMapping = {'BehaviorData', 'Electrophysiology'};

% read attribute 'class', which tells us which reader to create. If it
% doesn't exist, we're dealing with a legacy (Hammer) file
% fp = H5F.open(fileName, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
fp = H5Tools.openFamily(fileName);
if H5Tools.existAttribute(fp, 'class')
    cl = H5Tools.readAttribute(fp, 'class');
    cl = reshape(cl,1,[]);
    [found index] = ismember(cl,classMapping(:,1));
    
    % if defined map this class to a particular reader, otherwise use its
    % name
    if(~found)
        br = feval(['baseReader' cl], fileName, varargin{:});
    else
        br = feval(['baseReader' classMapping{index,2}], fileName, varargin{:});
    end
else
    br = getHammerReader(fileName, varargin{:});
end

% close opened file
H5F.close(fp)



function br = getHammerReader(fileName, channels)
% Create a reader for files written by Hammer

if nargin < 2
    br = baseReaderHammer(fileName);
else
    if ischar(channels) 
        if any(channels == '*')
            % expand and convert pattern to a cell array of channels
            assert(~isempty(regexp(channels, '^t[0-9]+c\*$', 'once')), ...
                'baseReader:invalidChannelDef', ...
                'Only patterns of type t1c*, t2c* etc. are supported for Hammer-based data!')
            channels = arrayfun(@(i) strrep(channels, '*', num2str(i)), 1:4, 'UniformOutput', false);
        else
            % single channel, convert to cell array
            channels = {channels};
        end
    end
    br = baseReaderHammer(fileName, channels);
end
