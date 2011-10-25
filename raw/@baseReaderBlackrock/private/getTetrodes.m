function [tets, channels] = getTetrodes(br)
%Returns the full list of tetrodes and channels indices in the cmap.
%the tetrode indices are deduced from the entry indices in map file, i.e,
%the tetrodes are assumed to be arranged in sequential order by map file. 
%WW2011

tets = [];
channels = {};

cmap = br.cmap;
nChan = length(cmap.ChanNum);
nTet = nChan / 4; 

if nTet==0 || mod(nChan,4)~=0 
    disp('Warning: Incorrect Tetrode Map File Used ');
    return;
end

tets = 1 : nTet ; 
channels = mat2cell(cmap.ChanNum,1,repmat(4,1,nTet));
