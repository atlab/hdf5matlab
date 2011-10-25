function r = get(br,p)
%
r = [];
if nargin < 2; return; end
%if isfield(br,p)    
    r = br.(p);
%end

