function br = set(br,p,v)
%
if nargin < 3;return;end
if isfield(br,p)
    br.(p) = v;
else
    fprintf('Warning: property not exist --- "%s" \n\n',p);
end


