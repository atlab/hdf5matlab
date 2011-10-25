function chNames = getChannelNames(br,channels)
%Input : channels is a vector of channel indices.
%Output: 
%  return the tetrode channel name in the form of 't(i)c(j)' where i,j are tetrode
%  (1:24) and channel indices.(1:4)  
%
%  analog channels (128< x <=144) will be formated as 't0ci' where i is the original channel
%  number. e.g, analog ch9 has the name 't0c137'
%
%  single channels (<=128) will be formated in the same way as analog
%  channels 't0ci' where i <= 128
%
%  if channel is out of range, return 't0c0'
%WW2011

n = length(channels);
%tetrode and channel indices defined in cmap.
[tets,chans] = getTetrodes(br);
%number of all tetrodes
m = length(tets); 

tetID = zeros(size(channels));
chID  = tetID;

%find the tetrode number and corresponding channel number
for i = 1 : n
    for j = 1 : m
    if any(chans{j} == channels(i))
        tetID(i) = j;
        chID(i) = find(chans{j} == channels(i));
        break; %
    end
    end
end

chNames = cell(1,n);

for i = 1 : n
    chNames{i} = sprintf('t%dc%d',tetID(i),chID(i));
    %rename single and analog channels if they are in range.(1~144)
    if tetID(i)==0 && (channels(i)>0 && channels(i) < 145)  
        chNames{i} = sprintf('t%dc%d',0,channels(i));
    end
end
    