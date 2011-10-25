function filt = createHighpassIIR(order, cutoff, Fs)

[b, a] = butter(order, cutoff / Fs * 2, 'high');
filt = iirFilter(b, a);
