function out = has(option, key)
%OPTS.HAS Check for existence of key in an OPTS object.
%   OPTS.HAS(options, k) returns 1 if "options" is an OPTS object and it
%   contains a vlaue for the key "k"; returns 0 otherwise.
out = opts.isa(option) && option.isKey(key);