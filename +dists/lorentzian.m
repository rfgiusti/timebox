function d = lorentzian(P, Q)
%DISTS.LORENTZIAN   Lorentzian distance between two time series
%   LORENTZIAN(S,Z) returns the Lorentzian distance between time series S
%   and Z.

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 0.1
d = sum(log(1 + abs(P - Q)));
end