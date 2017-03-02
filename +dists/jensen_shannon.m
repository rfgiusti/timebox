function d = jensen_shannon(P, Q)
%DISTS.JENSEN_SHANNON   Jensen-Shannon distance betweeen time series
%   JENSEN_SHANNON(S,Z) returns the Jensen-Shannon distance between time
%   series S and Z.
%
%   The Jensen-Shannon distance is a symmetric variance of the Kullback-Leibler
%   distance and is given by
%
%           0.5 KL(P, M) + 0.5 KL(Q, M)
%
%   where M = (P + Q) / 2.
%
%   The Jensen-Shannon distance is always positive for probability
%   distributions. For time series, it is more useful when the series are
%   normalized to the [0,1] interval or as histograms; that is, not only
%   their intervals should be contained to [0,1], but the sum of their
%   observations should be 1. TimeBox can normalize time series as if they
%   were histograms with TS.NORMH.
%
%   This function is based on the work of Sung-Hyuk Cha. "Comprehensive
%   Survey on Distance/Similarity Measures between Probability Density
%   Functions". In: International Journal of Mathematical Models and
%   Methods in Applied Sciences. Issue 4, Volume 1, pp 300-307 (2007).

%   This file is part of TimeBox. Copyright 2015-17 Rafael Giusti
%   Revision 0.1.0
M = (P + Q) / 2;
d = 0.5 * dists.kullback(P, M) + 0.5 * dists.kullback(Q, M);
