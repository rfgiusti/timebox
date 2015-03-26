function d = shift_euclidean(P, Q)
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