function d = kulczynski(P, Q)
d = sum(abs(P - Q)) ./ min(P, Q);
end