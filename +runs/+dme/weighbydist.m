function [votes, weights, rankings] = weighbydist(dsname, trainclasses, testclasses, ~, distm, basecc, ~)
%RUNS.DME.WEIGHTBYDIST   Run a partitioned train/test evaluation of the
%weighted ensemble on a data set, using distance from the test sample to
%the nearest neighbor as a measure of classification confidence
%   This function is part of the ensemble evaluation set.
%
%   The weight-by-distance ensemble simply returns the classes voted by
%   each classifier and a weight matrix that is based on the distances from
%   the test samples to their respective nearest neighbors.
%
%   Input:
%       dsname          name of the data set compatible with TS.LOAD
%       trainclasses    n-by-1 array of training instance classes
%       testclasses     m-by-1 array of test instance classes
%       labels          not used by WEIGHBYDIST; replace with []
%       distm           k-by-1 cell of distance matrices
%       basecc          The names of the distance functions and of the time
%                       series representations are required for the
%                       ensemble to fetch trainXtrain dinstance matrices
%                       (read below on how this ensemble uses the training
%                       data to estimate the "size" of the decision space).
%                       The names must be compatible with DISTS.CACHED. If
%                       the distance matrix was not cached for some base
%                       classifier, an exception will be raised
%       options         not used by WEIGHTBYDIST; ommit or replace with []
%
%   Output:
%       votes           k-by-n matrix of votes
%       weights         k-by-n matrix of accuracy-related weights
%       rankings        empty cell
%
%   Because distance measures could vary in orders of magnitude, this
%   ensemble attempts to normalize the distances by means of a simple
%   analysis of the training space. It will take the largest distance
%   between pairs of training instances as the "size" of the decision
%   space, and use it as a normalization factor. 
%
%   For more information on how ensemble evaluation is implemented in
%   TimeBox, please check RUNS.DME.MAJORITY.
numclassifiers = numel(basecc);
numinstances = numel(testclasses);

votes = zeros(numclassifiers, numinstances);
weights = ones(numclassifiers, numinstances);
rankings = [];

for i = 1:numclassifiers
    maxdist = estimatespacesize(dsname, basecc{i}.distname, basecc{i}.repname);
    
    % Get the nearest neighbors and their distances from the test instances
    [neighborsdist, neighborsidx] = min(distm{i}, [], 2);
    
    % Transform distance into similarity, normalized by the search space size
    neighborsdist = maxdist * (ones(numinstances, 1) ./ neighborsdist);
    
    % Votes are neighbors classes, weights are distance ratios
    votes(i, :) = trainclasses(neighborsidx);
    weights(i, :) = neighborsdist;
end
end


function maxdist = estimatespacesize(dsname, distname, repname)
[traintrain, testtrain] = dists.cached(dsname, distname, repname);
trainspacesize = max(max(traintrain));    
testspacesize = max(max(testtrain));
maxdist = max(trainspacesize, testspacesize);
end