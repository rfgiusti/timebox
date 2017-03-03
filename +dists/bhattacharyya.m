function d = bhattacharyya(P, Q)
%DISTS.BHATTACHARYYA   Bhattacharyya distance between time series
%   BHATTACHARYYA(S,Z) returns the Bhattacharyya distance between the time
%   series S and Z.
%
%   The Bhattacharyya distance is a distance function based on the
%   Bhattacharyya similarity coefficient between probability distributions
%   P and Q.
%
%   The Bhattacharyya coefficient is bounded in [0,1] for probability
%   distributions. This implementation of the Bhattacharyya distance is
%   usually best if the series are normalized as if they were histrograms;
%   that is, not only their intervals should be contained to [0,1], but the
%   sum of their observations should be 1. This ensures that the resulting
%   distance will be positive, approaching infinity only when the two time
%   series approach the zero vector. If the observations of the series sum
%   to a value greater than one, then the Bhattacharyya distance may be
%   negative.
%
%   This function is based on the work of Sung-Hyuk Cha. "Comprehensive
%   Survey on Distance/Similarity Measures between Probability Density
%   Functions". In: International Journal of Mathematical Models and
%   Methods in Applied Sciences. Issue 4, Volume 1, pp 300-307 (2007).

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 0.1.0
d = -log(sum(sqrt(P .* Q)));
