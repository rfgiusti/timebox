function [neighbor, distance, label, hit] = nn1fast(stack, needle, options_or_distname)
%MODELS.NN1FAST   Run the 1-Nearest Neighbor classification model for a
%single instance on a data set using a MEX implementation. By default, the
%1-NN uses the Euclidean distance, but a different distance function may be
%specified.
%   NN1FAST(DS,S) where DS is an n-by-m matrix of double representing a
%   data set (in format according to TS.LOAD and TS.SAVE) and S is a 1-by-m
%   column vector of double representing a single instance returns the
%   index of the nearest neighbor of S in DS.
%
%   NN1FAST(DS,S,'manhattan') does the same as explained above, however it
%   uses the Manhattan distance to find the neighborhood. See below for a
%   list of support distance functions.
%
%   NN1FAST([],~,DISTNAME) returns the distance code of DISTNAME as the
%   first output argument if DISTNAME is a supported distance. If DISTNAME
%   is not supported, then the first output argument will be set to the
%   empty array [].
%
%   NN1FAST(DS,S,options) does the same, but options are taken from
%   "options", which must be a valid OPTS object as returned by OPTS.BUILD
%   or OPTS.SET. If options are missing or no OPTS object is supplied,
%   default values are used whenever required.
%
%   [N,P] = NN1FAST(DS,S,...) returns the index of the nearest neighbor and
%   the distance from the test sample to the nearest neighbor.
%
%   [N,P,C] = NN1FAST(DS,S,...) returns the same as above, and also a label
%   for the class of the nearest neighbor. 
%
%   [N,P,C,H] = NN1FAST(DS,S, ...) returns the same as above, and also a
%   flag indicating if the nearest neighbor belongs to the same class as
%   the test sample (1 or 0).
%
%   Options:
%       nn::tie break       (default: 'first')
%       epsilon             (default: 1e-10)
%       nn::distance        (default: 'euclidean')
%
%   The currently accepted distance names are: Euclidean, Manhattan, and
%   Chebyshev.

%   This file is part of TimeBox. Copyright 2015-17 Rafael Giusti
%   Revision 0.2.0
distname = 'euclidean';
if exist('options_or_distname', 'var')
    if opts.isa(options_or_distname)
        options = options_or_distname;
    else
        distname = options_or_distname;
        options = opts.empty;
    end
else
    options = opts.empty;
end
distname = lower(opts.get(options, 'nn::distance', distname));

switch distname
    % L-norm family
    case 'euclidean'
        distcode = 1;
    case 'manhattan'
        distcode = 2;
    case 'chebyshev'
        distcode = 3;
    case 'avg_l1_linf'
        distcode = 9;
        
    % Manhattan-derived family
    case 'canberra'
        distcode = 10;
    case 'lorentzian'
        distcode = 11;
    case 'sorensen'
        distcode = 12;
        
    % Dot product family
    case 'cosine'
        distcode = 20;
    case 'jaccard'
        distcode = 21;
    case 'dice'
        distcode = 22;
        
    % Pearson Chi-Square coefficient family
    case 'pearson'
        distcode = 30;
    case 'squared_chi'
        distcode = 31;
        
    % Kullback-Leibler family
    case 'kullback'
        distcode = 40;
    case 'jeffrey'
        distcode = 41;
    
	% Bhattacharyya coefficient family
    case 'bhattacharyya'
        distcode = 50;
    case 'hellinger'
        distcode = 51;
    otherwise
        if ~isempty(stack)
            error(['Unsupported distance: ' distname]);
        end
        distcode = [];
end

if isempty(stack)
    neighbor = distcode;
    return
end

tiebreak = opts.get(options, 'nn::tie break', 'first');
epsilon = opts.get(options, 'epsilon', 1e-10);

if numel(needle) == 1
    skipindex = needle;
    needle = stack(needle, :);
else
    skipindex = -1;
end

[bestidx, distance] = models.nn1fast_mex(stack', needle, distcode, skipindex, epsilon);

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
