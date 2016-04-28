function d = canberra(P, Q)
%DISTS.   distance between two time series
%   (S,Z) returns the distance between time series S and Z

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 0.1
d = sum(abs(P - Q) ./ (P + Q));
end