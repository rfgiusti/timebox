function yes = sameclass(class1, class2, epsilonoroptions)
%TB.SAMECLASS Return 1 if classes are the same considering an epsilon.
%   SAMECLASS(C1,C2) returns 1 if C1 equals C2 considering that C1 and C2
%   may be floating-point numbers.
%
%   SAMECLASS(C1,C2,E) where E is a double uses E as an epsilon for the
%   comparison. By default, E is 1e-4.
%
%   SAMECLASS(C1,C2,OPTS) where OPTS is an options object uses OPTS to read
%   a "epsilon" options.
DEFAULT_EPSILON = 1e-4;

if exist('epsilonoroptions', 'var')
    if isreal(epsilonoroptions)
        epsilon = epsilonoroptions;
    else
        epsilon = opts.get(epsilonoroptions, 'epsilon', DEFAULT_EPSILON);
    end
else
    epsilon = DEFAULT_EPSILON;
end

yes = abs(class1 - class2) < epsilon;
end