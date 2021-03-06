function d = shift_euclidean(P, Q)
%DISTS.SHIFT_EUCLIDEAN   Rotation-invariant Euclidean distance between two
%time series
%   SHIFT_EUCLIDEAN(S,Z) returns the rotation-invariant Euclidean distance
%   between time series S and Z. This is the smallest distance between S
%   and Z for all rotations of Z

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 0.1

% circshift rotates columns
if size(P, 1) < size(P, 2)
    P = P';
    Q = Q';
end

d = inf;
for i = 1:numel(P)
    d = min(d, euclidean(P, circshift(Q, i)));
end
end

function d = euclidean(P, Q)
d = sqrt(sum((P - Q) .^ 2));
end