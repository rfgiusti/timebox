function d = chebyshev(P, Q)
%DISTS.CHEBYSHEV   Chebyshev distance between two time series.
%   CHEBYSHEV(S,Z) returns the Chebyshev distance between time series S and
%   Z. The Chebyshev distance is the Minkowski distance when p->infinity.

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 0.1
d = max(abs(P - Q));
end