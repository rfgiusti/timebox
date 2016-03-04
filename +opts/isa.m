function r = isa(s)
%OPTS.ISA   Check if an object is an OPTS object.
%   ISA(opt) returns 1 if "opt" is an OPTS object.
r = isequal(class(s), 'containers.Map');
end