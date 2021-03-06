function d = max_symmetric_chi(P, Q)
%DISTS.MAX_SYMMETRIC_CHI   Maximum Symmetric Chi-Squared distance between
%two time series
%   MAX_SYMMETRIC_CHI(S,Z) returns the Maximum Symmetric Chi-Squared
%   distance between time series S and Z.
%
%   This function is based on the work of Sung-Hyuk Cha. "Comprehensive
%   Survey on Distance/Similarity Measures between Probability Density
%   Functions". In: International Journal of Mathematical Models and
%   Methods in Applied Sciences. Issue 4, Volume 1, pp 300-307 (2007).

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 0.1
PQds = (P - Q).^ 2;
d = max(PQds ./ P, PQds ./ Q);
end