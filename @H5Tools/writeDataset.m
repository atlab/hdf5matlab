function writeDataset(fp, name, data, chunkSize, maxDims)
% Write HDF5 dataset 
%
% writeDataset(fp, name, data, chunkSize, maxDims)
%     If maxDims are not specified, detects which ones are non
%     singleton.  If maxDims has a 1 in it, those dimensions are also
%     stripped out.  I'm not entirely sure why, but this is maintaining
%     backwards compatibility.
%
% AH (??) - I think (JC)
% JC 2009-09-22 - the code originally gets really creative about selective
%   dataset dimensions in a way that doesn't work when opening the dataset
%   with a single spike.  I'm changing so if maxDims is specified, this
%   will block automatic detection, which just makes sense and hopefully
%   doesn't break anything
% JC 2009-09-28 - for the two photon writing code maxDims is an array instead
%   of a cell array, and seems to use -1 intead of H5S_UNLIMITED.  Seems like
%   this function doesn't have a very strict calling convention.  It might be 
%   better to fix that in the near future than keep adding little hooks.

dataDims = size(data);
% Special treatment for strings
if ischar(data)
    dataDims(1) = 1;
end

dataDims = fliplr(dataDims);
if (nargin >= 4)
    chunkSize = fliplr(chunkSize);
    maxDims = fliplr(maxDims);
end

if all(dataDims == 1) & (nargin < 5 | ~any(strcmp(maxDims,'H5S_UNLIMITED') == 1))
    dataSpace = H5S.create('H5S_SCALAR');
else
    if nargin < 5
        dataDimSel = dataDims ~= 1; 
    else
        if iscell(maxDims)
            dataDimSel = cellfun(@(x) ischar(x) || x ~= 1, maxDims);
        else
            dataDimSel = maxDims ~= 1;
        end
    end
    dataDims = dataDims(dataDimSel);
    if (nargin >= 4) && ~isempty(chunkSize)
        chunkSize = chunkSize(dataDimSel);
        maxDims = maxDims(dataDimSel);
    end

    nbDims = length(dataDims);
    if nargin < 5
        dataSpace = H5S.create_simple(nbDims, dataDims, []);
    else
        dataSpace = H5S.create_simple(nbDims, dataDims, maxDims);
    end

end
dataType = H5Tools.getHDF5Type(data);

setProps = H5P.create('H5P_DATASET_CREATE'); % create property list
if (nargin >= 4) && ~isempty(chunkSize)
%     chunkSize = min(chunkSize, dataDims); % define chunk size
    H5P.set_chunk(setProps, chunkSize); % set chunk size in property list
end
dataSet = H5D.create(fp, name, dataType, dataSpace, setProps);
H5D.write(dataSet, 'H5ML_DEFAULT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', data);

close(setProps);
close(dataSet);
close(dataSpace);
close(dataType);
