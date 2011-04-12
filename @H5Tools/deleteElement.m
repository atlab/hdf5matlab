function deleteElement(parent, element)

% deleteElement(parent, 'datasetName')  [2]
%
% Removes group or dataset 'datasetName' from the file.
% 'datasetName' is interpreted relative to the HDF5 group with id 'parent'

H5G.unlink(parent, element)