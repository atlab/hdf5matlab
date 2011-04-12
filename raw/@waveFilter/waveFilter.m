function wf=waveFilter(varargin)

if length(varargin)==1 && isa(varargin{1}, 'waveFilter')
    wf = varargin{1};
    return;
end

% Default values for class members
wf.filt = [];
wf.Fs = 0;
 

% Actual parameters were supplied, i.e. a filename
if (length(varargin) == 2) && isnumeric(varargin{1}) && isscalar(varargin{2})
    wf.filt = varargin{1};
    wf.Fs = varargin{2};
end
wf = class(wf, 'waveFilter');
