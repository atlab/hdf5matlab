function tt = ah_ttSubset(tt, selector)

nbChannels = length(tt.w);
for ch=1:nbChannels
    tt.w{ch} = tt.w{ch}(:, selector);
end

if isfield(tt, 'h')
    tt.h = tt.h(selector,:);
end
if isfield(tt, 't')
    tt.t = tt.t(selector);
end
