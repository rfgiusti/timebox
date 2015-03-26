function d = max_symmetric_chi(P, Q)
PQds = (P - Q).^ 2;
d = max(PQds ./ P, PQds ./ Q);
end