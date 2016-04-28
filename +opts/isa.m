function r = isa(s)
%OPTS.ISA   Check if an object is an OPTS object.
%   ISA(opt) returns 1 if "opt" is an OPTS object.

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 1.0
r = isequal(class(s), 'containers.Map');
end