function br = getBaseReader(pr)
% Get baseReader this packetReader was derived from.
%   br = getBaseReader(pr)
% 
% AE 2011-10-15

if ~isempty(regexp(class(pr.reader), 'baseReader*', 'once'))
    br = pr.reader;
else
    br = getBaseReader(pr.reader);
end
