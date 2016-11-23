function d = mindist(S, Z, L)
%MINDIST   Calculates non-normalized MINDIST distance between SAX words.
%   MINDIST(S,Z) returns a distance value unlinearly correlated with the
%   MINDIST distance between the SAX-transformed time series S and Z,
%   assuming the transformation was performed with an alphabet of size 4.
%
%   This function implements only the "look-up distance" between S and Z,
%   and therefore differs from MINDIST by a factor of sqrt(n/w), where n is
%   the length of the time series and w is the size of the alphabet.
%
%   MINDIST(S,Z,a) where a is an integer operates similarly, but a is used
%   for the alphabet size. The alphabet size must follow the same
%   restrictions as imposed in TRANSFORM.SAX.
%
%   MINDIST(S,Z,L) where L is a look-up matrix appropriate for some
%   alphabet size performs similarly, but the look-up table is not
%   calculated each time the function is called. L=DISTS.MDLOOKUP(a) may be
%   used to retrieve a look-up table apropriate for alphabet size a, and it
%   must be symmetric (i.e., L is equal to L').
%
%   The alphabet size or the look-up table must follow the SAX restrictions
%   for the transformation that produced S and Z. Otherwise, the behavior
%   of this function is undefined.
%
%   CREDITS: this function is based on the work of Jessica Lin, Eamonn
%   Keogh,  Li Wei, and Stefano Leonardi. "Experiencing SAX: a novel
%   symbolic representation of time series". In: Data Mining and Knowledge
%   Discovery, Springer US, 2007, 15, 107-144.

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 0.1.0
if ~exist('L', 'var')
    L = dists.mdlookup(4);
elseif numel(L) == 1
    L = dists.mdlookup(L);
end

% The look-up table is such that L(i,j) is the distance between the i-th
% and the j-th letters. TimeBox transforms a series into SAX by using the
% indices as the final transform. By taking (i-1)*a, where a is the size of
% the alphabet we find the first element of the i-th column. The we shift
% to get the element L(j,i).
letterdist = L((S - 1) * size(L,1) + Z);
d = sqrt(sum(letterdist.^2));