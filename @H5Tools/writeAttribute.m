function writeAttribute(fp, name, data, maxDims)

attrType  = H5Tools.getHDF5Type(data);

dataDims = size(data);
% Special treatment for strings
if ischar(data)
    dataDims(1) = 1;
end
if length(dataDims) > 1
    dataDims = fliplr(dataDims);
end

if all(dataDims == 0) && (length(maxDims) ~= length(dataDims))
    % We are intentionally creating an empty dataset
    dataDims = zeros(1, length(maxDims));
end

if all(dataDims == 1)
    attrSpace = H5S.create('H5S_SCALAR');
else
    dataDims = dataDims(dataDims ~= 1);
    nbDims = length(dataDims);
    if nargin <= 3
        attrSpace = H5S.create_simple(nbDims, dataDims, []);
    else
        maxDims = fliplr(maxDims);
        attrSpace = H5S.create_simple(nbDims, dataDims, maxDims);
    end
end

attr  = H5A.create(fp, name, attrType, attrSpace, 'H5P_DEFAULT');
if ~isempty(data)
    H5A.write(attr, 'H5ML_DEFAULT', data);
end

H5A.close(attr);
H5S.close(attrSpace);
H5T.close(attrType);
