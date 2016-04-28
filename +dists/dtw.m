% DTW function. W is half-window size in number of observations.
function dist = dtw(t, r, W)
%This function was deprecated in TimeBox 0.11.9
N = length(t);
M = length(r);

if ~exist('W', 'var')
	W = max(N, M);
end

D = ones(N + 1, M + 1) * inf;

D(1, 1) = 0;

for i = 2 : N+1
    for j = max(2, i - W) : min(M + 1, i + W)
        cost = (t(i - 1) - r(j - 1)) ^ 2;
        D(i, j) = cost + min([D(i - 1, j), D(i - 1, j - 1), D(i, j - 1)]);
    end
end

dist = sqrt(D(N + 1, M + 1));
end
    
