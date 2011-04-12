function d = getAverageDelay(wf, fmin, fmax, nSteps)

if nargin == 1
    delays = grpdelay(wf.filt, 1, 10, wf.Fs);
    d = mean(delays);
    return
elseif nargin < 3
    error('Please supply fmin and fmax to getAverageDelay')
elseif nargin < 4
    nSteps = 10;
end

fSteps = linspace(fmin, fmax, nSteps);
delays = grpdelay(wf.filt, 1, fSteps, wf.Fs);
d = mean(delays);