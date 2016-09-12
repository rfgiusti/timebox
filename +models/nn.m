function [neighbor, distance, label, hit] = nn(stack, needle, varargin)
%MODELS.NN Run the 1-Nearest Neighbor classification model for a single
%instance on a data set.
%   NN(DS,S) where DS is an n-by-m matrix of double representing a data set
%   (in format according to TS.LOAD and TS.SAVE) and S is a 1-by-m column
%   vector of double representing a single instance returns the index of
%   the nearest neighbor of S in DS.
%
%   NN(DS,S) where DS is an n-by-m matrix of double and S is a scalar
%   returns the index of the nearest neighbor of the S-th instance of DS in
%   DS.
%
%   NN(DS,S,DIST) does the same as the above two forms, but searches for
%   the nearest neighbor using DIST as a function handle to a distance (or
%   similarity) function. If the distance function requires arguments to
%   work, they should be specified as an OPTS object (see below).
%
%   NN(DS,S,options), and
%   NN(DS,S,DIST,options) do the same as explained above, however options
%   are taken from "options", which must be a valid OPTS object as returned
%   by OPTS.BUILD or OPTS.SET. If options are missing or no OPTS object is
%   supplied, default values are used whenever required.
%
%   [N,P] = NN(DS,S,...) returns the index of the nearest neighbor and the
%   proximity (distance or similarity) from the test sample to the nearest
%   neighbor.
%
%   [N,P,C] = NN(DS,S,...) returns the same as above, and also a label for
%   the class of the nearest neighbor.
%
%   [N,P,C,H] = NN(DS,S, ...) returns the same as above, and also a flag
%   indicating if the nearest neighbor belongs to the same class as the
%   test sample (1 or 0).
%
%   Options:
%       dists::arg*         (default: --)
%       dists::similarity   (default: 0)
%       nn::tie break       (default: 'first')
%       epsilon             (default: 1e-10)
%
%   *about dists::arg
%     This function calls the distance function, DIST, in the following
%     manner:
%
%       DIST(A, B)
%
%     where A and B are the observations of two instances.
%
%     If 'dists::arg' is present in OPTS, then the following call is made
%     instead:
%
%       DIST(A, B, OPTS.GET(options, 'dists::arg'))
%
%     Usage example:
%
%       % Run for a single instance of the data set using the dtw distance
%       % with a Sakoe-Chiba window of width 12
%       models.nn(train, test(1,:), @dists.dtw, opts.set('dists::arg', 12))

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 1.0
tb.narginchk(nargin, 2, 4);
if nargin == 2
    distfun = @dists.euclidean;
    options = opts.empty;
elseif nargin == 3
    if opts.isa(varargin{1})
        distfun = @dists.euclidean;
        options = varargin{1};
    else
        distfun = varargin{1};
        options = opts.empty;
    end
else
    distfun = varargin{1};
    options = varargin{2};
    tb.assert(isequal(class(distfun), 'function_handle'));
    tb.assert(opts.isa(options));
end

% Is this a similarity function?
issimilarity = opts.get(options, 'dists::similarity', 0);
if issimilarity
    similarityfix = -1;
else
    similarityfix = 1;
end

% Does the measure take some argument?
if opts.has(options, 'dists::arg')
    measuretakesarg = 1;
    measurearg = opts.get(options, 'dists::arg');
else
    measuretakesarg = 0;
end

% Do we need tie break? May be "random", "first", or "none".
tiebreak = opts.get(options, 'nn::tie break', 'first');

% What epsilon shall we use?
epsilon = opts.get(options, 'epsilon', 1e-10);

% Is the needle a time series or an index?
if numel(needle) == 1
    skipindex = needle;
    needle = stack(needle, :);
else
    skipindex = -1;
end

% List of best indices and their distances...
bestidx = [];
distance = similarityfix * inf;

numinstances = size(stack, 1);

% Run 1-NN
for i = 1 : numinstances
    % If this is being ran in loco, then skipindex contains the index of
    % the needle in the stack
    if i == skipindex
        continue
    end
    
    % First index of each time series contains class, so series are
    % compared by their [2,end] intervals
    if measuretakesarg
        dist = similarityfix * distfun(stack(i, 2:end), needle(2:end), measurearg);
    else
        dist = similarityfix * distfun(stack(i, 2:end), needle(2:end));
    end
    
    % Is this the closest or just as close as the closest we previously found?
    if abs(dist - distance) < epsilon
        bestidx = [bestidx; i]; %#ok<AGROW>
    elseif dist < distance
        bestidx = i;
        distance = dist;
    end
end

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