function d = canberra(P, Q)
%DISTS.   distance between two time series
%   (S,Z) returns the Canberra distance between time series S and Z.
%   Considers 0/0 = 0 and employs the absolute of the sum in the
%   denominator.

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 1.0.0
PQdiff = abs(P - Q);
PQsum = abs(P + Q);
PQsum(PQsum < eps) = 1;
d = sum(PQdiff ./ PQsum);
end
