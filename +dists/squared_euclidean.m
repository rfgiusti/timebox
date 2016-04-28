function d = squared_euclidean(P, Q)
%DISTS.SQUARED_EUCLIDEAN   Squared Euclidean distance between two time
%series
%   SQUARED_EUCLIDEAN(S,Z) returns the Squared Euclidean distance between
%   time series S and Z.

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 0.1
d = sum((P - Q).^2);
end