function order = getOrder(wf)
% Return filter order.

order = length(wf.b) - 1;
