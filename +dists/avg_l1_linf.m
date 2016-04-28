function d = avg_l1_linf(P, Q)
%DISTS.AVG_L1_LINF   Average of Manhattan and Chebyshev distances for time
%series S and Z.
%   AVG_L1_LINF(S,Z) returns the average Manhattan and Chebyshev distances
%   for between time series S and Z. This is the same as:
%
%       (dists.manhattan(S,Z) + dists.chebyshev(S,Z)) / 2
%
%   This function is based on the work of Sung-Hyuk Cha. "Comprehensive
%   Survey on Distance/Similarity Measures between Probability Density
%   Functions". In: International Journal of Mathematical Models and
%   Methods in Applied Sciences. Issue 4, Volume 1, pp 300-307 (2007).

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 0.1
d = (sum(abs(P - Q)) + max(abs(P - Q))) / 2;
end