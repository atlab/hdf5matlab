function br = channelFilter(br,Flags)
%channel selection filter -WW2011

if ~isempty(Flags.chFilter)
    try
        switch lower(Flags.chFilter)
            case 'ac' %keep 'ac' and remove neural channels 'tc' and 'sc'
                br.channels(br.channels <= 128) =[];
                br.tetrode(br.tetrode>0) = [];
                br.chNames(br.chIndices <= 128) = [];
                br.chIndices(br.chIndices <= 128) = [];
            
            case 'tc' %remove analog channel 'ac' and single channel 'sc'
                %'ac' and 'sc' are named as 't0c*'. '*' is the original channel
                %index. e.g, Analog ch 9 has the name 't0c137'
                [tet,chan]=getTetChanIndices(br,br.channels); %filter the recorded channels
                br.channels(tet==0 & chan>0) =[]; %
                br.tetrode(br.tetrode==0) = []; %
                [tet,chan]=getTetChanIndices(br,br.chIndices); %filter the returned channels
                br.chNames(tet==0 & chan>0) = [];
                br.chIndices(tet==0 & chan>0) = [];
                
            case 'sc'
                [tet,chan]=getTetChanIndices(br,br.channels); %filter the recorded channels
                br.channels((tet==0 & chan>128) | tet>0) =[]; %
                br.tetrode(br.tetrode>0) = []; %
                [tet,chan]=getTetChanIndices(br,br.chIndices); %filter the returned channels
                br.chNames((tet==0 & chan>128) | tet>0) = [];
                br.chIndices((tet==0 & chan>128) | tet>0) = [];
        end
     
                
    catch
        disp('Channel selction filter: '); 
        disp('-----------------------------------------');
        rethrow(lasterror);
        disp('-----------------------------------------');
    end
end

%update the nbChannels after filtering.
br.nbChannels = length(br.chIndices);


function [tet,chan] = getTetChanIndices(br,channels)
%return tetrode index 'i' and channel index 'j' in 't(i)c(j)' for given channel index
%Input: 'channels' is a vector of channel indices or cell array of channel
%       names
%
if isnumeric(channels)
    channels = getChannelNames(br,channels);
end

nChan = length(channels);
tet = zeros(1,nChan);
chan = tet;

for i = 1 : nChan
    [tok,mat]=regexp(channels{i},'t([0-9]+)c([0-9]+)','tokens','match');
    tetID = str2num(tok{1}{1});
    chID  = str2num(tok{1}{2});
    if ~isempty(tetID); tet(i) = tetID; end
    if ~isempty(chID); chan(i) = chID;  end
end



