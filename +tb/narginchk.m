function narginchk(numargs, minargs, maxargs)
%TB.NARGINCHECK Syntax sugar to check the number of input arguments passed
%to a function.
%  TB.NARGINCHK(NARGIN,a,b) raises a MATLAB exception if the number of
%  arguments received by the caller does not fall in the interval [a,b].
%  This function mimics the behavior of narginchk, which is not
%  available in Matlab 2010

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 1.0
if numargs < minargs || numargs > maxargs
    err = MException('TimeBox:assert', ['Function called with wrong number of arguments (should be ' ... 
            'between %d and %d)'], minargs, maxargs);
    throw(err);
end
end