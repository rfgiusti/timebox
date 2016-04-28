function d = manhattan(P, Q)
%DISTS.MANHATTAN   Manhattan distance between two time series (also known
%as "city block" distance, L1-norm, or Minkowski for p=1)
%   MANHATTAN(S,Z) returns the Manhattan distance between time series S and
%   Z.

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 0.1
d = sum(abs(P - Q));
end