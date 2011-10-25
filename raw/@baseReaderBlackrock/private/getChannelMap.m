function br = getChannelMap(br,cmapFile)
%read in the blackrock channel map file. 
%WW2011

if nargin < 2
    cmapFile = [];
end
fprintf('Load the blackrock channel map file --- %s \n',cmapFile);
cmap = KTUEAMapFile(cmapFile); %File UI will pop up if map file is not given

br.cmap = cmap;

