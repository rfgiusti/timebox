function assert(condition, varargin)
%TB.ASSERT Raise an exception if the assert condition is false.
%  TB.ASSERT(COND, ...) raise a MATLAB exception if the condition is false.
%  Is uses the variadic arguments to assemble an error message and
%  automatically includes a stack trace.

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 1.0
if condition
    return
end
if numel(varargin) > 0
    msg = sprintf(varargin{:});
else
    msg = 'An internal assertion failed. No information was provided.';
end
err = MException('TimeBox:assert', msg);
throw(err);
end