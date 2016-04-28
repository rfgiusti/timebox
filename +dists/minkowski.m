function d = minkowski(P, Q, p)
%DISTS.MINKOWSKI   Minkowski distance between two time series, also known
%as the Lp norm
%   MINKOWSKI(S,Z,p) returns the Minkowski-p distance between time series S
%   and Z.
%
%   The Minkowski distance defines a family of metrics. For instance, the
%   famous Euclidean distance is given by the Minkowski-2 function:
%
%       MINKOWSKI(S,Z,2)
%
%   And when p=1, this is the Manhattan distance. For p=infinity, the
%   Chebyshev distance is obtained. Use DISTS.CHEBYSHEV to calculate the
%   Chebyshev distance between two series.

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 0.1
d = sum(abs(P - Q) .^ p) ^ (1/p);
end
