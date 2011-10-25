function X = apply(wf, X)

% Check data type
if ~isa(X, 'double') && ~isa(X, 'single')
    X = double(X);
end
X = filtfilt(wf.b, wf.a, X);
