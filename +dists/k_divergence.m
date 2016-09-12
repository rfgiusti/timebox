function d = k_divergence(P, Q)
%DISTS.K_DIVERGENCE   K divergence between two time series
%   K_DIVERGENCE(S,Z) returns the K divergence between time series S and Z.
%
%   This function is based on the work of Sung-Hyuk Cha. "Comprehensive
%   Survey on Distance/Similarity Measures between Probability Density
%   Functions". In: International Journal of Mathematical Models and
%   Methods in Applied Sciences. Issue 4, Volume 1, pp 300-307 (2007).

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 0.1
d = sum(P .* log((2 * P) ./ (P + Q)));
end