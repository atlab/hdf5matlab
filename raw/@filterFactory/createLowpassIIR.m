function filt = createLowpassIIR(order, cutoff, Fs)

[b, a] = butter(order, cutoff / Fs * 2, 'low');
filt = iirFilter(b, a);
