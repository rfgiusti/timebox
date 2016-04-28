function d = topsoe(P, Q)
%DISTS.TOPSOE   Topsoe distance between two time series
%   TOPSOE(S,Z) returns the Topsoe distance between time series S and Z.
%
%   This function is based on the work of Sung-Hyuk Cha. "Comprehensive
%   Survey on Distance/Similarity Measures between Probability Density
%   Functions". In: International Journal of Mathematical Models and
%   Methods in Applied Sciences. Issue 4, Volume 1, pp 300-307 (2007).

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 0.1
logPQ = log(P + Q);
d = sum(P .* (log(2*P) - logPQ) + Q .* (log(2 * Q) - logPQ));
end