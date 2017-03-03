function d = hellinger(P, Q)
%DISTS.HELLINGER   Hellinger distance between two time series
%   HELLINGER(S,Z) returns the Hellinger distance between time series S and
%   Z.
%
%   The Hellinger distance is a distance function based on the
%   Bhattacharyya similarity coefficient between probability distributions
%   P and Q.
%
%   The Bhattacharyya coefficient is bounded in [0,1] for probability
%   distributions. This implementation of the Hellinger distance is given
%   in the form sqrt(1 - BC(S,Z)), where BC is the Bhattacharryya
%   coefficient between S and Z. The Hellinger distance works best if the
%   time series are normalized as if they were histrograms; that is, not
%   only their intervals should be contained to [0,1], but the sum of their
%   observations should be 1. This ensures that the resulting distance will
%   be a metric constrained into [0,1]. If the sum of the observations of
%   the series exceeds one, then the resulting distance may involve
%   imaginary components.
%
%   This function is based on the work of Sung-Hyuk Cha. "Comprehensive
%   Survey on Distance/Similarity Measures between Probability Density
%   Functions". In: International Journal of Mathematical Models and
%   Methods in Applied Sciences. Issue 4, Volume 1, pp 300-307 (2007).

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 0.1
d = 2 * sqrt(1 - sum(sqrt(P .* Q)));
end
