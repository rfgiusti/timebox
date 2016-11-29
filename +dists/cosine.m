function d = cosine(S,Z)
%DISTS.COSINE   Cosine distance between two time series.
%   COSINE(S,Z) returns the cosine distance between vectors S and Z. It is
%   calculated as 1-COS(a), where a is the inner angle between S and Z.
%   This distance is not defined if S=Z=zero vector.
d = 1 - sum(S.*Z) / (norm(S) * norm(Z));
