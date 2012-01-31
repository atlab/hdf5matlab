function chIndices = getChannelIndices(br,chNames)
%return channel indices for channel name in string 't1c2' or cell array of
%strings {'t1c2','t1c1',...}
%return orignal channel index if channel name is 't0c*'.
%return 0 if not found in channel map file.
%

if ischar(chNames) %single string
    chNames = {chNames};
end

n = length(chNames);
chIndices = zeros(size(chNames));

[tets, chans] = getTetrodes(br);

for i = 1 : n
    [tok, ~] = regexpi(chNames{i},'^t([0-9]+)c([0-9]+)$','tokens','match');
    tetID = str2double(tok{1}{1});
    chID  = str2double(tok{1}{2});
    if any(tetID == tets)
        chIndices(i) = chans{tetID == tets}(chID);
    end
    if tetID ==0 && chID > 0 %return orignal index
        chIndices(i) = chID;
    end
end
