function i = end(pr, k, n)

active = find(pr.active);
i = pr.nbPackets(active(k));