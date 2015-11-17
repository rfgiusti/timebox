function [ranking, points] = simplerank(dsname, repname, distname, trainclasses, numclasses, ranking_k, matchvalues, ...
    cachepath, norun)
%RUNS.DME.AUX.SIMPLERANK  Rank training instances according to the Simple
%Rank anytime algorithm, without tiebreak strategy.
%   This function is part of the ensemble evaluation set. It is used
%   primarily by RUNS.DME.SIMPLERANK to calculate points for the simple
%   ranking ensemble strategy.
%
%   R = SIMPLERANK(DSNAME,REPNAME,DISTNAME) finds the simple ranking for
%   the training instances of the data set DSNAME on the representation
%   REPNAME considering the distance function DISTNAME. Each of these
%   parameters must be a CHAR compatible with TS.LOAD and DISTS.CACHED. The
%   output value, R, is an array of ranks, not an ordered index of training
%   instance. Each R(i) is the rank of the i-th training instance.
%
%   [R,P] = SIMPLERANK(DSNAME,REPNAME,DISTNAME) returns both the ranks
%   and the points assigned to each instance.
%
%   SIMPLERANK(DSNAME,REPNAME,DISTNAME,C) also receives an array C of class
%   labels. Each C(i) is the class label of the i-th training instance. If
%   C is ommitted or set to the empty array, this function will load the
%   data set with TS.LOAD and extract the classes.
%
%   SIMPLERANK(DSNAME,REPNAME,DISTNAME,C,n) also specifies the number of
%   classes n. This relieves the simple ranking algorithm from having to
%   load the data set to get the number of classes.
%
%   By default, the simple ranking algorithm considers a single neighbor of
%   each training instance to determine associate/enemy instances. In the
%   form SIMPLERANK(DSNAME,REPNAME,DISTNAME,C,n,k), k is a neighborhood
%   size that determines the number of instance to be verified as
%   associates or enemies.
%
%   The simple ranking algorithm rewards associates with 1/(c-1) points,
%   where c is the number of unique class labels, and punishes enemies with
%   -2/(c-1). In the form SIMPLERANK(DSNAME,REPNAME,DISTNAME,C,n,k,M), M is
%   an array such that associates will be rewarded with M(1)/(c-1) points
%   and enemies will be punished with M(2)/(c-1) points.
%
%   If a path p is supplied in the form
%   SIMPLERANK(DSNAME,REPNAME,DISTNAME,C,n,k,M,p), this function will first
%   look for a previously cached execution in the directory specified by p.
%   Cached executions must be .mat files containing the variables "ranking"
%   and "points", which are arrays of doubles for the ranks and points
%   assigned to each training instance. The name of the file is determined
%   by the data set name, the representation name, the distance function
%   name, the size of the neighborhood k, and the matrix M.
%
%   If the matrix M is NOT supplied, the cache file will be in the form:
%
%       <DSNAME>-<REPNAME>-<DISTNAME>-k<k>.mat
%
%   For instance, suppose this particular snippet of code is executed:
%
%       dsname = 'Wafer';
%       repname = 'ps';
%       distname = 'euclidean';
%       [trainclasses, testclasses] = ts.loadclasses(dsname);
%       numclasses = numel(unique([trainclasses; testclasses]));
%       M = [];
%       [ranking, points] = runs.dme.aux.simplerank(dsname, repname, ...
%                               distname, trainclasses, numclasses, 3, M,
%                               'cache'); 
%
%   Then, this function will look for "cache/Wafer-ps-euclidean-k1.mat". If
%   this file is found, the result will be fetched from it. Otherwise, the
%   simple ranking will be calculated on-the-fly.
%
%   If the matrix M is supplied, the cache file will have a name just a bit
%   more complicated. Say <r> is the string form of an integer representing
%   the match reward and <p> is the string form of a 4-decimal precision
%   double representing the match penalty. These may be obtained by
%   sprintf('%d',M(1)) and sprintf(%.4f',M(2)) respectivelly. Then, the
%   file name will be in the form:
%
%       <DSNAME>-<REPNAME>-<DISTNAME>-k<K>p<r><p>.mat
%
%   For instance, assume the previous example is given, but the particular
%   line that assigns M is changed from
%
%       M = [];
%
%   to
%
%       M = [1, -0.25];
%
%   Then, the cache will be expected in
%   "cache/Wafer-ps-euclidean-k1-p1-0.2500.mat". Notice the dash after "p1"
%   is due to M(2) being negative.
%
%   The last invocation form of this function is
%   SIMPLERANK(DSNAME,REPNAME,DISTNAME,C,k,M,p,f). In this case, f is a
%   flag. If set to non-zero, it indicates that simple ranking must not be
%   calculated on-the-fly. If there is no cache file available, then this
%   function will raise an exception.
%
%   For more information on how ensemble evaluation is implemented in
%   TimeBox, please check RUNS.DME.MAJORITY.
if ~exist('ranking_k', 'var') || isempty(ranking_k)
    ranking_k = 1;
end

if ~exist('cachepath', 'var')
    cachepath = [];
end

if exist('matchvalues', 'var') && ~isempty(matchvalues)
    matchvalue = matchvalues(1);
    mismatchvalue = matchvalues(2);
    cachefile = getcachefile(cachepath, dsname, repname, distname, ranking_k, matchvalue, mismatchvalue);
else
    matchvalue = [];
    cachefile = getcachefile(cachepath, dsname, repname, distname, ranking_k);
end
if ~isempty(cachefile) && exist(cachefile, 'file')
    data = load(cachefile);
    ranking = data.ranking;
    points = data.points;
    return
end

if exist('norun', 'var') && norun
    err = MException('getsimplerank:norun', ['Cache file is not pre-computed and `norun'' ' ...
            'parameter is set on']);
    throw(err);
end

if ~exist('trainclasses', 'var') || isempty(trainclasses) || ~exist('numclasses', 'var') || isempty(numclasses)
    [trainclasses, testclasses] = ts.loadclasses(dsname);
    numclasses = numel(unique([trainclasses; testclasses]));    
end

if isempty(matchvalue)
    % The apparent double assignment to this variable has a reason: we need
    % to test if matchvalues exist to get the cache file name. If that
    % cache file exists, we don't want to load data needlessly. Only if the
    % cache file is not found we load the data to count the number of
    % classes and calculate the mismatch penalty.
    matchvalue = 1;
    mismatchvalue = -2 / (numclasses - 1);
end
    
tic;

% Get the nearest neighbors of all. First row is always included to ensure we'll be working with a
% matrix
[traintrain, ~] = dists.cached(dsname, distname, repname);
[~, index] = sort(traintrain, 2);
neighbors = index(:, 2:(ranking_k + 1));

% Process neighbors from nearest to furthest. Add points to each matching k-nearest neighbor,
% removes points from each mismatching k-nearest neighbors
points = zeros(size(trainclasses));
for klevel = 1:ranking_k
    % Get the k-nearest neighbors to simplify indexing below
    kneighbors = neighbors(:, klevel);
    
    % Get the matching and the non-matching k-nearest neighbors
    match = kneighbors(trainclasses(kneighbors) == trainclasses);
    mismatch = kneighbors(trainclasses(kneighbors) ~= trainclasses);

    if ~isempty(match)
        tab = tabulate(match);
        maxidx = size(tab, 1);
        points(1:maxidx) = points(1:maxidx) + matchvalue * tab(:, 2);
    end

    if ~isempty(mismatch)
        tab = tabulate(mismatch);
        maxidx = size(tab, 1);
        points(1:maxidx) = points(1:maxidx) + mismatchvalue * tab(:, 2);
    end
end

ranking = tiedrank(-points);

ranktime = toc; %#ok<NASGU>

if ~isempty(cachepath)
    save(cachefile, 'ranking', 'points', 'ranktime', 'repname', 'distname', '-mat');
end
end 


function filepath = getcachefile(cachepath, dsname, repname, distname, ranking_k, matchvalue, mismatchvalue)
if isempty(cachepath)
    filepath = [];
else
    if exist('matchvalue', 'var')
        filepath = sprintf('%s/%s-%s-%s-k%dp%d%.4f.mat', cachepath, dsname, repname, distname, ranking_k, ...
            matchvalue, mismatchvalue);
    else
        filepath = sprintf('%s/%s-%s-%s-k%d.mat', cachepath, dsname, repname, distname, ranking_k);
    end
end
end