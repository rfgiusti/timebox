function d = emanon2(P, Q)
%DISTS.EMANON2   Emanon2 distance between two time series
%   EMANON2(S,Z) returns the Emanon2 distance between time series S and Z.
%
%   This function is based on the work of Sung-Hyuk Cha. "Comprehensive
%   Survey on Distance/Similarity Measures between Probability Density
%   Functions". In: International Journal of Mathematical Models and
%   Methods in Applied Sciences. Issue 4, Volume 1, pp 300-307 (2007).

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 0.1
d = sum(((P - Q).^2) ./ (min(P, Q).^2));
end