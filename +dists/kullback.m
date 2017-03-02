function d = kullback(P, Q)
%DISTS.KULLBACK   Kullback-Leibler distance between two time series
%   KULLBACK(S,Z) returns the Kullback-Leibler distance between time series
%   S and Z.
%
%   The Kullback-Leibler distance is a measure of dissimilarity between
%   probability distributions. For time series, it is usually best if the
%   series are normalized as if they were histrograms; that is, not only
%   their intervals should be contained to [0,1], but the sum of their
%   observations should be 1---otherwise the distance between series may be
%   negative. TimeBox can normalize time series as if they were histograms
%   with TS.NORMH.
%
%   For probability distributions, the Kullback-Leibler distance may be
%   undefined if the probability of any event is zero. When using as a
%   distance between time-series, if p and q are observations of P and Q at
%   the instant t, then the difference between those observations is fixed
%   to the following:
%
%       d(p,q) = { p               if q == 0
%                { p * log(p/q)    otherwise
%
%   When q ~= 0, p*log(p/q) approaches 0 as p->0. For p > 0, then this
%   factor approaches infinity as q->0. The decision of using the fix above
%   was made with the expectation of maximizing the utility of this
%   distance function for time series classification and may not be
%   compatible with what one would expect from a theoretical point of view.
%
%   This function is based on the work of Sung-Hyuk Cha. "Comprehensive
%   Survey on Distance/Similarity Measures between Probability Density
%   Functions". In: International Journal of Mathematical Models and
%   Methods in Applied Sciences. Issue 4, Volume 1, pp 300-307 (2007).

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 0.1
X = P .* log(P ./ Q);
replacemask = isnan(X) | isinf(X);
X(replacemask) = P(replacemask);
d = sum(X);
