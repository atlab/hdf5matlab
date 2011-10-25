function filt = createBandpassIIR(order, cutoffLow, cutoffHigh, Fs)

[b, a] = butter(order, [cutoffLow, cutoffHigh] / Fs * 2);
filt = iirFilter(b, a);
