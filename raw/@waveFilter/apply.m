function X = apply(wf, X)

if isempty(wf.filt)
    warning('No filter supplied to waveFilter object before calling apply()')
else
    % Check data type
    if ~isa(X, 'double') && ~isa(X, 'single')
        X = double(X);
    end
    X = fftfilt(wf.filt, X);
end