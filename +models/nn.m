function [neighbor, distance, label, hit] = nn(stack, needle, varargin)
%MODELS.NN Run the 1-Nearest Neighbor for a single instance on a data set.
%   N = NN(DS,S) if S is an array, it is treated as a time series and this
%   will search for the nearest neighbor of S in DS. If S is an integer, it
%   is treated as an index to a time series in DS. NN will attempt to find
%   the nearest neighbor of DS(S) in DS, ignoring DS(S). The returned
%   value, N, is an index to the nearest neighbor in DS.
%
%   N = NN(DS,S,DIST) does the same, but searches for the nearest neighbor
%   using DIST as a function handle to a distance (or similarity) function.
%   If the distance function requires arguments to work, they should be
%   specified by the option "measure arg".
%
%   N = NN(DS,S,OPTS), and
%   N = NN(DS,S,DIST,OPTS) do the same as explained above, exception
%   options are taken from OPTS isntead of default values being used.
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
%   test sample.
%
%   Options:
%       nn::similarity      (default: 0)
%       nn::tie break       (default: 'none')
%       measure arg*        (default: --)
%       epsilon             (default: 1e-10)
%
%   If the "measure arg" option is present, its value is passed as a third
%   argument to the distance function.
narginchk(2, 4);
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
issimilarity = opts.get(options, 'similarity', 0);
if issimilarity
    similarityfix = -1;
else
    similarityfix = 1;
end

% Does the measure take some argument?
if opts.has(options, 'measure arg')
    measuretakesarg = 1;
    measurearg = opts.get(options, 'measure arg');
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
        bestidx = [bestidx; i];
    elseif dist < distance
        bestidx = [i];
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
    end
    
    label = stack(neighbor, 1);
    hit = abs(label - needle(1)) < epsilon;
end
end