function tt = ah_readHDF5tt(filename, varargin)
% Read spike file.
%   tt = ah_readHDF5tt(filename) will read the entire file.
%
%   tt = ah_readHDF5tt(filename,'tstart',tstart,'tend',tend) will read all
%   spikes between tstart and tend (inclusive).
%
%   tt = ah_readHDF5tt(filename,'istart',istart,'iend',iend) will read all
%   spikes with indices between istart and iend (inclusive, 1-based).
%
%   tt = ah_readHDF5tt(filename,'index',indices) will read all spikes with
%   given indices.
%
% initial: AH
% update: AE 2009-03-30

params.istart = NaN;
params.iend = NaN;
params.tstart = NaN;
params.tend = NaN;
params.index = NaN;

i=1;
while i < length(varargin)
    if strcmpi(varargin{i}, 'all')
        [params.tstart, params.tend, params.index] = deal([]);
        i = i+1;
    else
        params.(varargin{i}) = varargin{i+1};
        i = i+2;
    end
end

% Read HDF5 data
fp = H5F.open(filename, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Precreate output structure
tt = struct('t', [], 'w', [], 'h', [], 'tstart', [], 'tend', [], 'aligned', [0]);

% Read some attributes (e.g., number of Channels)
rootGroup = H5G.open(fp, '/');
nbChannels = H5Tools.readAttribute(rootGroup, 'nbChannels');
if H5Tools.existAttribute(rootGroup, 'tStart') && H5Tools.existAttribute(rootGroup, 'tEnd')
    tt.tstart = H5Tools.readAttribute(rootGroup, 'tStart');
    tt.tend   = H5Tools.readAttribute(rootGroup, 'tEnd');
end
if H5Tools.existAttribute(rootGroup, 'aligned')
    tt.aligned = H5Tools.readAttribute(rootGroup, 'aligned');
end
if H5Tools.existAttribute(rootGroup, 'units')
    tt.units = H5Tools.readAttribute(rootGroup, 'units');
else
    tt.units = 'unknown';
end
if H5Tools.existAttribute(rootGroup, 'version')
    tt.version = H5Tools.readAttribute(rootGroup, 'version');
else
    tt.version = 1;
end
H5G.close(rootGroup);

% find out number of spikes in the file
ttInfo = ah_readTetInfo(filename);

% deal with start and end indices if specified
if ~isnan(params.istart) || ~isnan(params.iend)
    a = 1;
    b = ttInfo.nbSpikes;
    if ~isnan(params.istart)
        a = params.istart;
    end
    if ~isnan(params.iend)
        b = params.iend;
    end
    params.index = a:b;
end

% any time range specified?
if ~isnan(params.tstart) || ~isnan(params.tend)
    tt.t = H5Tools.readDataset(fp, 'tt_t');
    a = 1;
    b = ttInfo.nbSpikes;
    if ~isnan(params.tstart)
        a = find(tt.t >= params.tstart,1);
    end
    if ~isnan(params.tend)
        b = find(tt.t <= params.tend,1,'last');
    end
    params.index = a:b;
end

% empty index set needs to be dealt with separately
if isempty(params.index)
    tt.t = [];
    tt.w = cell(1,nbChannels);
    tt.h = zeros(0,nbChannels);
    tt.tstart = [];
    tt.tend = [];
    return
end

% estimate what is faster: load entire file and select indices then or load
% indices one by one
if ~isnan(params.index(1))
    mbPerSec = 20;      % MB/sec loading time
    secPerNdx = 0.003;  % sec/spike loading time
    kbPerSpike = 1;     % kb/spike file size
    index = reshape(params.index, [], 1);
    isBlock = length(index) > 2 && (index(end) - index(1)) == (length(index) - 1)  && all(diff(index) == 1);
    loadAll = ~isBlock && (numel(params.index) * secPerNdx) > (ttInfo.nbSpikes * kbPerSpike / mbPerSec / 1000);
end

% load entire file?
if isnan(params.index(1)) || loadAll
    tt.t = H5Tools.readDataset(fp, 'tt_t');
    tt.h = H5Tools.readDataset(fp, 'tt_h');
    for ch = 1:nbChannels
        tt.w{ch} = H5Tools.readDataset(fp, sprintf('tt_w/Ch%u', ch));
    end
    if ~isnan(params.index)
        tt = ah_ttSubset(tt, params.index);
    end
else
    hdim = H5Tools.getDatasetDim(fp, 'tt_h');
    wdim = H5Tools.getDatasetDim(fp, 'tt_w/Ch1');

    % are indices a block?
    if isBlock

        tt.t = H5Tools.readDataset(fp, 'tt_t', 'range', index(1), index(end));
        tt.h = H5Tools.readDataset(fp, 'tt_h', 'range', [1 index(1)], [hdim(1) index(end)]);
        tt.w = cell(1, nbChannels);
        for ch = 1:nbChannels
            tt.w{ch} = H5Tools.readDataset(fp, sprintf('tt_w/Ch%u', ch), 'range', [index(1) 1], [index(end) wdim(2)]);
        end
    else
        tt.t = H5Tools.readDataset(fp, 'tt_t', 'index', index);

        [i,j] = meshgrid(1:hdim(1),index);
        tt.h = reshape(H5Tools.readDataset(fp, 'tt_h', 'index', [i(:) j(:)]), [], hdim(1));

        [i,j] = meshgrid(index,1:wdim(2));
        tt.w = cell(1,nbChannels);
        for ch = 1:nbChannels
            tt.w{ch} = reshape(H5Tools.readDataset(fp, sprintf('tt_w/Ch%u', ch), ...
                'index', [i(:) j(:)]), wdim(2), []);
        end
        
%         tt.w = repmat({zeros(wdim(2),numel(index))},1,double(nbChannels));
%         for ch = 1:nbChannels
%             dataset = H5D.open(fp, sprintf('tt_w/Ch%u', ch));
%             dataspace = H5D.get_space(dataset);
%             H5S.select_none(dataspace);
%             for i = 1:numel(index)
%                 H5S.select_hyperslab(dataspace, 'H5S_SELECT_OR', [index(i)-1 0], [], [1 wdim(2)], []);
%             end
%             rangeExtent = [numel(index) wdim(2)];
%             memspace = H5S.create_simple(length(rangeExtent), rangeExtent, rangeExtent);
%             tt.w{ch} = H5D.read(dataset, 'H5ML_DEFAULT', memspace, dataspace, 'H5P_DEFAULT');
% 
%             H5S.close(memspace);
%             H5S.close(dataspace);
%             H5D.close(dataset);
%         end
    end
end

H5F.close(fp);
