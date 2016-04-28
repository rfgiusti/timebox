function d = intersection(P, Q)
%DISTS.INTERSECTION   Intersection distance between two time series
%   INTERSECTION(S,Z) returns the Intersection distance between time series
%   S and Z.
%
%   This function is based on the work of Sung-Hyuk Cha. "Comprehensive
%   Survey on Distance/Similarity Measures between Probability Density
%   Functions". In: International Journal of Mathematical Models and
%   Methods in Applied Sciences. Issue 4, Volume 1, pp 300-307 (2007).

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 0.1
d = 0.5 * sum(abs(P - Q));
end