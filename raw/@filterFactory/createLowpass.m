function filt = createLowpass(cutOffStart, cutOffEnd, Fs, varargin)

params.attenuation = 65;        % 65db att
params.passRipple  = 0.002;     % 0.002 db ripple in the pass band

for i=1:2:length(varargin)
    params.(varargin{i}) = varargin{i+1};
end

ampStop = getAttFromDB(params.attenuation);
ampPass = getPassFromDB(params.passRipple);

[N,F,A,W] = firpmord([cutOffStart, cutOffEnd], [1 0], [ampPass ampStop], Fs);
filterCoeffs = firpm(N,F,A,W);
filt = waveFilter(filterCoeffs, Fs);