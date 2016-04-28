function d = euclidean(P, Q)
%DISTS.EUCLIDEAN   Euclidean distance between two time series
%   EUCLIDEAN(S,Z) returns the Euclidean distance between time series S and
%   Z.

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 0.1
d = sqrt(sum((P - Q) .^ 2));
end