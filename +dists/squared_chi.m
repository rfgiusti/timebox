function d = squared_chi(P, Q)
%DISTS.SQUARE_CHI   Squared Chi-Squared distance between two time series
%   SQUARE_CHI(S,Z) returns the Squared Chi-Squared distance between time
%   series S and Z.
%
%   The Squared Chi-Squared distance is a symmetrical variant of the
%   Pearsons's chi-squared test statistics. When used to test the distance
%   between time series, it is best if the series are normalized to the
%   interval [0,1] rather than being z-normalized.
%
%   The distance between observations P(t) and Q(t) is normalized by the
%   magnitude of P(t) and Q(t); when P(t) + Q(t) == 0, the distance between
%   P(t) and Q(t) is given by the difference between the terms. In other
%   words, if p and q are observations of P and Q at instance t, then
%
%       dist(p, q) = { (p - q)^2 / (p + q),  if p + q ~= 0
%                    { (p - q)^2,            otherwise
%
%   Disclaimer: this function is based on the work of Sung-Hyuk Cha.
%   "Comprehensive Survey on Distance/Similarity Measures between
%   Probability Density Functions". In: International Journal of
%   Mathematical Models and Methods in Applied Sciences. Issue 4, Volume 1,
%   pp 300-307 (2007).

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 1.0.0
PQsum = P + Q;
PQsum(PQsum == 0) = 1;
d = sum(((P - Q).^ 2) ./ PQsum);
end
