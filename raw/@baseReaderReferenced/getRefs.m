function [refs, indices] = getRefs(br)
% Get recorded references.
%   [refs, indices] = getRefs(br) returns the references that were recorded
%   and their physical channel indices in the recording file.
%
% JC 2013-05-08

[refs, indices] = getRefs(br.reader);
