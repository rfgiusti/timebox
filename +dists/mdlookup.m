function L = mdlookup(a)
%MDLOOKUP   Return a look-up table for MINDIST of SAX words produced with
%alphabet size a
%   L=MDLOOKUP(a) gives an a-by-a look-up matrix where each L(i,j) is the
%   distance between the i-th and the j-th SAX letters in a SAX alphabet of
%   size a. This matrix may be used with DISTS.MINDIST.
%
%   The look-up table is calculated according to the instructions of the
%   SAX authors. For more information and credits, please view Jessica Lin,
%   Eamonn Keogh,  Li Wei, and Stefano Leonardi. "Experiencing SAX: a novel
%   symbolic representation of time series". In: Data Mining and Knowledge
%   Discovery, Springer US, 2007, 15, 107-144.

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 0.1.0
bp = getbreakpoints(a);
L = zeros(a);
for i = 1:a
    for j = i + 2:a
        L(i, j) = bp(j - 1) - bp(i);
        L(j, i) = L(i, j);
    end
end
end


function breakpoints = getbreakpoints(alphabetsize)
%Return breakpoints attempting to produce equiprobable SAX words for a
%Z-normalized time series
switch alphabetsize
        case 2, breakpoints  = 0;
        case 3, breakpoints  = [-0.43 0.43];
        case 4, breakpoints  = [-0.67 0 0.67];
        case 5, breakpoints  = [-0.84 -0.25 0.25 0.84];
        case 6, breakpoints  = [-0.97 -0.43 0 0.43 0.97];
        case 7, breakpoints  = [-1.07 -0.57 -0.18 0.18 0.57 1.07];
        case 8, breakpoints  = [-1.15 -0.67 -0.32 0 0.32 0.67 1.15];
        case 9, breakpoints  = [-1.22 -0.76 -0.43 -0.14 0.14 0.43 0.76 1.22];
        case 10, breakpoints = [-1.28 -0.84 -0.52 -0.25 0. 0.25 0.52 0.84 1.28];
        case 11, breakpoints = [-1.34 -0.91 -0.6 -0.35 -0.11 0.11 0.35 0.6 0.91 1.34];
        case 12, breakpoints = [-1.38 -0.97 -0.67 -0.43 -0.21 0 0.21 0.43 0.67 0.97 1.38];
    otherwise
        error('transform:sax', 'Alphabet size must be integer in [2, 12]');
end
end
