function l = length(pr)

firstRel = find(pr.active , 1, 'first');
l = pr.nbPackets(firstRel);