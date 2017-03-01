function d = sorensen(P, Q)
%DISTS.SORENSEN   Sorensen distance between two time series
%   SORENSEN(S,Z) returns the Sorensen distance between time series S and
%   Z. Returns NaN if P(:)==Q(:)==0.
%
%   This function is based on the work of Sung-Hyuk Cha. "Comprehensive
%   Survey on Distance/Similarity Measures between Probability Density
%   Functions". In: International Journal of Mathematical Models and
%   Methods in Applied Sciences. Issue 4, Volume 1, pp 300-307 (2007).

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 1.0.0
d = sum(abs(P - Q)) / sum(abs(P) + abs(Q));
end
