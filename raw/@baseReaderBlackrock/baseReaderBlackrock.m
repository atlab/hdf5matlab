function br = baseReaderBlackrock(varargin)
% Base reader for blackrock data recordings
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
%
% -------------------------------------------------------------------------
% modified for blackrock data reader -- WW2011
%
% Usage : 
%         br = baseReaderBlackrock(fileName)
%         br = baseReaderBlackrock(fileName,flag)
%
%         br = baseReaderBlackrock(fileName,channels)
%         br = baseReaderBlackrock(fileName,channels,flag) 
%
%         br = baseReaderBlackrock(fileName,pattern)
%         br = baseReaderBlackrock(fileName,pattern,flag)  
%
%         Channel Type Selection Filter: 
%         flag = 'ac' request for only 'analog channels' in the return.
%              = 'tc' request for only 'tetrode channels' in the return.
%              = 'sc' request for only 'single channels',i.e, neural 
%                 channels that are not used in tetrode configuration. 
%         flag can be set to only ONE type as single string input. 
%         multiple types are not supported. 
%         Default : return all recorded channels if not specified.
%
%         Channel Name Format: 't(i)c(j)' 
%         ananlog channel : i = 0, j = orignal channel index. range=[129:144]    
%         tetrode channel : i > 0, j = index in tetrode configuration. range=[1:4]
%         single channel  : i = 0, j = orignal channel index. range=[1:128]
%         invalid channel : i = 0, j = 0
% -------------------------------------------------------------------------

% Class description : 
%     fileName -- blackrock file name
%     fileType -- 'NEV' for neural data file; 'NSx' for continuous data file.
%      tetrode -- tetrode indices for channels. 0 represents the analog channels 
%                 and single channels.
%     channels -- recorded channel indices. It may include both the neural data channels (1-128) 
%                 and the analog input channels (129-144).
%    chIndices -- indices of matched channels
%      chNames -- names of matched channels
%   nbChannels -- number of matched channels
%    nbSamples -- number of data points (in each channel)
% samplingRate -- sampling freqency (HZ) 
%           Fs -- the same as above 
%           t0 -- start time of data (in msec)
%       tstart -- the same as 't0'
%         tend -- end time of data (in msec)
%        scale -- scaling factor for continuous data. 
%           fp -- pointer to data file. (not used) 

%some fields are redundant for compatiblity reason. 
br = struct('fileName',     [],...
            'fileType',     [],...
            'tetrode',      [],...
            'channels',     [],...
            'chIndices',    [],...
            'chNames',      [],...
            'nbChannels',   0,...
            'nbSamples',    0,...
            'samplingRate', 0,...
            'Fs',           0,...
            't0',           0,...
            'tstart',       0,...
            'tend',         0,....
            'scale',        0,...
            'fp',           []);

if length(varargin) == 1 && isa(varargin{1}, 'baseReaderBlackrock')
    br = varargin{1};
    return
end

br.fileName = varargin{1};
% set the file header and channel map
br = init(br);
br = class(br, 'baseReaderBlackrock');

tags = fieldnames(br);
% read file header info
for i = 1 : length(tags)
    br = getFileInfo(br,tags{i});
end

%flag for channel type selection.
Flags = struct;
chFilter = {'ac','tc','sc'};
%parse input
if nargin < 2 
    channels = br.channels;
elseif nargin < 3
    if any(strcmpi(varargin{2},chFilter))
        Flags.chFilter = varargin{2};
        channels = br.channels;
    else
        channels = varargin{2};
    end
else
    channels = varargin{2};
    Flags.chFilter = varargin{3};
end

if ~isfield(Flags,'chFilter')
    Flags.chFilter = []; %return all types of channels by default
else
    Flags.chFilter = chFilter{strcmpi(Flags.chFilter,chFilter)};
end

% find the matching channels
if isnumeric(channels)
    br.chIndices = channels;
    %returns channel name in the format 't*c*'. 
    br.chNames = getChannelNames(br,channels);
else
    if ischar(channels)
        if any(channels == '*')
            % expand and convert pattern to a cell array of channels
            assert(~isempty(regexp(channels, '^t[0-9]+c\*$', 'once')), ...
                'baseReader:invalidChannelDef', ...
                'Only patterns of type t1c*, t2c* etc. are supported for blackrock data!')
            channels = arrayfun(@(x) strrep(channels, '*', num2str(x)), 1:4, 'UniformOutput', false);
            %
            br.chIndices = getChannelIndices(br,channels);
            %
            br.chNames = channels;
        else
            % single channel, convert to cell array
            channels = {channels};
            %
            br.chIndices = getChannelIndices(br,channels);
            %
            if br.chIndices > 0  %valid channel.
                br.chNames = channels; 
            else
                br.chIndices = [];
                br.chNames = [];
            end

        end
    else
        fprintf('Warning: baseReader:baseReaderBlackrock:invalidChannelDef: Only strings are supported\n');
    end

end

%pass through channel selection filter
br = channelFilter(br,Flags);

% br = class(br, 'baseReaderBlackrock');


function br = getFileInfo(br,tag)
%
if ~isempty(br.NEV) %read nev file info
    H = br.NEV.MetaTags;
elseif ~isempty(br.NSx)
    H = br.NSx.MetaTags;
else
    H = struct;
    %return;
end

switch tag
    case 'fileType'
        [dummy dummy ext] = fileparts(br.fileName);
        if isempty(regexp(ext,'[0-9]','once'))
            br.(tag) = 'NEV';
        else
            br.(tag) = 'NSx';
        end
    case 'tetrode'
        br.(tag) = getRecordedTetrodes(br);
    case 'channels' %return recorded channel indices.
        if isfield(H,'ChannelID') %NSx
            %openNSx return 0 in channel id for Spec 2.2 files
%             %read the channels info from .nev file as workaround.
            nevfile = br.fileName;
            nevfile(end-2:end) = 'nev';
            %which openNEV
            header = openNEV(nevfile,'read','nowave','overwrite');
            br.(tag) = unique(header.Data.Spikes.Electrode);
            %replace the NSx header. 
            br.NSx.MetaTags.('ChannelID') = br.(tag);
            clear header;
%             br.(tag) = (H.('ChannelID'))';
        else
            %br.(tag) = []; %NEV contains no channel info.
            br.(tag) = unique(br.NEV.Data.Spikes.Electrode);
        end
       
    case 'nbSamples'
        if isfield(H,'DataPoints') %NSx
            br.(tag) = H.('DataPoints');
        elseif isfield(H,'DataDuration')
            br.(tag) = H.('DataDuration');
        else
            br.(tag) = 0;
        end
    case 'nbChannels'
            br.(tag) = length(br.('chIndices'));
    case {'samplingRate','Fs'}
        if isfield(H,'SamplingFreq') %NSx
            br.(tag) = H.('SamplingFreq');
        elseif isfield(H,'SampleRes') %NEV
            br.(tag) = H.('SampleRes');
        else
            br.(tag) = 0;
        end 
    case {'tstart','t0'}    % in msec 
        br.(tag) = 1000 * 0;
    case 'tend'
        if br.samplingRate > 0
            br.(tag) = br.('tstart') + 1000 * (br.nbSamples - 1) / br.samplingRate ;
        else
            br.(tag) = br.('tstart');
        end
    
    case 'scale'
        br.(tag) = 1; %raw scale.
end

