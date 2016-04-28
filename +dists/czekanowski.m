function d = czekanowski(P, Q)
%DISTS.CZEKANOWSKI   Czekanowski distance between two time series
%   CZEKANOWSKI(S,Z) returns the Czekanowski distance between time series S
%   and Z.
%
%   This function is based on the work of Sung-Hyuk Cha. "Comprehensive
%   Survey on Distance/Similarity Measures between Probability Density
%   Functions". In: International Journal of Mathematical Models and
%   Methods in Applied Sciences. Issue 4, Volume 1, pp 300-307 (2007).

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 0.1
d = sum(abs(P - Q)) / sum(P + Q);
end