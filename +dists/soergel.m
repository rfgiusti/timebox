function d = soergel(P, Q)
d = sum(abs(P - Q)) / sum(max(P, Q));
end