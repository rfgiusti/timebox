function d = jeffrey(P, Q)
%DISTS.JEFFREY   Jeffrey distance between two time series
%   JEFFREY(S,Z) returns the Jeffrey distance between time series S and Z.
%
%   The Jeffrey's distance is a symmetric variant of the Kullback-Leibler
%   distance between probability distributions. For time series, the
%   Jeffrey's distance is usually better when they series are either
%   normalized into the [0,1] interval or when they are normalized as
%   histograms; that is, not only their intervals should be contained to
%   [0,1], but the sum of their observations should be 1. TimeBox can
%   normalize time series as if they were histograms with TS.NORMH.
%
%   For probability distributions, the Jeffrey's distance may be undefined
%   if the probability of any event is zero. When using as a distance
%   between time-series, whenever the observations of either P or Q are
%   zero, this distance function ignores that term.
%
%   This function is based on the work of Sung-Hyuk Cha. "Comprehensive
%   Survey on Distance/Similarity Measures between Probability Density
%   Functions". In: International Journal of Mathematical Models and
%   Methods in Applied Sciences. Issue 4, Volume 1, pp 300-307 (2007).

%   This file is part of TimeBox. Copyright 2015-17 Rafael Giusti
%   Revision 1.0.0

% Find places where either P or Q is zero
PQ = P .* Q;
X = ((P - Q) .* log(P ./ Q));

% Fix instances where either P or Q was zero
X(PQ == 0) = 0;
d = sum(X);
end
