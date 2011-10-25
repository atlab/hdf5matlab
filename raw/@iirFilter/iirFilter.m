function wf = iirFilter(b, a)

if nargin == 1 && isa(cutoff, 'iirFilter')
    wf = cutoff;
    return
end

assert(nargin == 2, 'Inputs must be filter coefficients b, a!')
wf.b = b;
wf.a = a;

wf = class(wf, 'iirFilter');
