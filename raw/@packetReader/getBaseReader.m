function br = getBaseReader(pr)
% Get baseReader this packetReader was derived from.
%   br = getBaseReader(pr)
% 
% AE 2011-10-15

br = getBaseReader(pr.reader);
