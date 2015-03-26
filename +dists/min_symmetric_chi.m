function d = min_symmetric_chi(P, Q)
PQds = (P - Q).^ 2;
d = min(PQds ./ P, PQds ./ Q);
end