function out = set(arg1, arg2, arg3)
% OPTS.SET Set an option to an existing OPTS object or create a new OPTS
% object with one option set.
%   OPTS.SET(k, v) creates a new OPTS object and set the value "v" for the
%   option "k".
%
%   OPTS.SET(opt, k, v) adds the option "k" with value "v" to the
%   previously existing OPTS object "opt".
if nargin == 3
    tb.assert(opts.isa(arg1), 'OPTS.SET: when called with three arguments, the first argument must be an OPTS object');
    out = arg1;
    out(arg2) = arg3;
else
    out = containers.Map;
    out(arg1) = arg2;
end
end