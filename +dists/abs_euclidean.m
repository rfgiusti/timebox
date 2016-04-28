function d = abs_euclidean(P, Q)
%DISTS.ABS_EUCLIDEAN   Minkowski distance between two time series for p=2
%   ABS_EUCLIDEAN(S,Z) returns the Minkowski distance between time series S
%   and Z using p=2

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 0.1
d = sqrt(sum(abs(P - Q) .^ 2));
end
