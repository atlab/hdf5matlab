function reader = getParentReader(pr)
% Returns the parent reader (i.e. the one that is packaged by this one).
%   reader = getParentReader(pr)
%
% AE 2011-10-17

reader = pr.reader;
