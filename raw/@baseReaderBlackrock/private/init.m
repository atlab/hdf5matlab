function br = init(br)
%initialize br with the file header and channel map.
%WW2011

%
readNEVChannel = 1; 
keepSpikes = 0;

switch lower(char(regexp(br.fileName,'\.\w+$','match')))
    case '.nev'
        if readNEVChannel
            %read the channel/electrode info. remove the spikes afterwards. 
            fprintf('Open neural data file\n');
            br.NEV = openNEV(br.fileName,'read','nowave','overwrite');
            fprintf('Done\n\n');
        else
            %or read the header only
            fprintf('Open neural data file for header info\n');
            br.NEV = openNEV(br.fileName);
            fprintf('Done\n\n');
        end

        if ~keepSpikes
            br.NEV.Data.Spikes.Timestamp = [];
            br.NEV.Data.Spikes.Electrode = unique(br.NEV.Data.Spikes.Electrode);
            br.NEV.Data.Spikes.Unit = [];
        end
         
        br.NSx = [];
    case {'.ns1','.ns2','.ns3','.ns4','.ns5'}
        br.NEV = [];
        br.NSx = openNSx(br.fileName);
end

cmapFile = fullfile(fileparts(which('KTUEAMapFile')),'Tetrode_96ch.cmp');
%return cmap
br = getChannelMap(br,cmapFile);