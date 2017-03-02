function d = pearson(P, Q)
%DISTS.PEARSON   Pearson Chi Square distance between two time series
%   PEARSON(S,Z) returns the Pearson Chi Square distance between time
%   series S and Z.
%
%   The Pearson Chi Square distance is calculated from the chi-square
%   test statistic from the Pearson's chi-squared test.
%
%   When used to test the distance between time series, it is best if the
%   series are normalized to the interval [0,1] rather than being
%   z-normalized.
%
%   The distance between observations P(t) and Q(t) is normalized by Q(t);
%   when Q(t) == 0, the distance between P(t) and Q(t) is solely given by
%   P(t). In other words, if "p" and "q" are observations of P and Q at
%   instant t, then
%
%         d(p,q) = { (p - q)^2 / q,   if q ~= 0
%                  { p,               otherwise
%
%   Disclaimer: this function is based on the work of Sung-Hyuk Cha.
%   "Comprehensive Survey on Distance/Similarity Measures between
%   Probability Density Functions". In: International Journal of
%   Mathematical Models and Methods in Applied Sciences. Issue 4, Volume 1,
%   pp 300-307 (2007).

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 1.0.0
PQ = (P - Q) .^ 2;
Q(Q == 0) = 1;
d = sum(PQ ./ Q);
end
