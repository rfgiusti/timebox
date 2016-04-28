function [neighbor, distance, label, hit] = nn1euclidean(stack, needle, options)
%MODELS.NN1EUCLIDEAN    Run the 1-Nearest Neighbor classification model
%for a single instance on a data set using Euclidean distance. Has
%similar behavior to MODELS.NN with @DISTS.EUCLIDEAN, but much faster.
%   NN1EUCLIDEAN(DS,S) where DS is an n-by-m matrix of double representing
%   a data set (in format according to TS.LOAD and TS.SAVE) and S is a
%   1-by-m column vector of double representing a single instance returns
%   the index of the nearest neighbor of S in DS.
%
%   NN1EUCLIDEAN(DS,S,options) does the same as explained above, however
%   options are taken from "options", which must be a valid OPTS object as 
%   returned by OPTS.BUILD or OPTS.SET. If options are missing or no
%   OPTS object is supplied, default values are used whenever required.
%
%   [N,P] = NN1EUCLIDEAN(DS,S,...) returns the index of the nearest
%   neighbor and the distance from the test sample to the nearest neighbor.
%
%   [N,P,C] = NN1EUCLIDEAN(DS,S,...) returns the same as above, and also a
%   label for the class of the nearest neighbor.
%
%   [N,P,C,H] = NN1EUCLIDEAN(DS,S, ...) returns the same as above, and also
%   a flag indicating if the nearest neighbor belongs to the same class as
%   the test sample (1 or 0).
%
%   Options:
%       nn::tie break       (default: 'first')
%       epsilon             (default: 1e-10)

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 1.0
if exist('options', 'var')
    tb.assert(opts.isa(options), 'Third argument must be non-existent or an OPTS object');
else
    options = opts.empty;
end

tiebreak = opts.get(options, 'nn::tie break', 'first');
epsilon = opts.get(options, 'epsilon', 1e-10);

if numel(needle) == 1
    skipindex = needle;
    needle = stack(needle, :);
else
    skipindex = -1;
end

[bestidx, distance] = models.nn1_mex(stack', needle, skipindex, epsilon);

% If we got more than one nearest neighbor, we need to decide on one of
% them, depending on the tie break strategy. Unless we are set to not
% perform any tie break at all. In that case we just return what we got
if isequal(tiebreak, 'none')
    neighbor = bestidx;
else
    if length(bestidx) == 1 || isequal(tiebreak, 'first')
        neighbor = bestidx(1);
    elseif isequal(tiebreak, 'random')
        neighbor = randsample(bestidx, 1);
    else
        error(['MODELS.NN: bad tie break options: ' tiebreak]);
    end
    
    label = stack(neighbor, 1);
    hit = abs(label - needle(1)) < epsilon;
end
end
