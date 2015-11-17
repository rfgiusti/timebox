function [votes, weights, rankings] = weighbynn(~, trainclasses, testclasses, distm, ~, options)
%RUNS.DME.WEIGHBYNN   Run a partitioned train/test evaluation of the
%weighted ensemble on a data set, using a simple nearest-neighbors count to
%estimate the posterior probability of the classification as weights
%   This function is part of the ensemble evaluation set.
%
%   The weight-by-nn ensemble simply returns the classes voted by each
%   classifier and a weight matrix that is based on a simple
%   nearest-neighbors count as an estimate of the base classifier's the
%   posterior probability.
%
%   Input:
%       dsname          not used by WEIGHBYNN; replace with []
%       trainclasses    n-by-1 array of training instance classes
%       testclasses     m-by-1 array of test instance classes
%       distm           k-by-1 cell of distance matrices
%       basecc          not used by WEIGHBYNN; replace with []
%       options         optional options set object
%
%   Output:
%       votes           k-by-n matrix of votes
%       weights         k-by-n matrix of related weights
%       rankings        empty cell
%
%   For more information on how ensemble evaluation is implemented in
%   TimeBox, please check RUNS.DME.MAJORITY.
%
%   Options taken by this function:
%
%       dme::limit      (default: 0)
%       dme::nnsize     (default: 3)
%       dme::normalize  (default: 0)
numclassifiers = numel(distm);
numinstances = numel(testclasses);

if ~exist('options', 'var')
    options = opts.empty;
end
neighborhoodsize = min(opts.get(options, 'dme::nnsize', 3), numel(trainclasses));
normalizeweights = opts.get(options, 'dme::normalize', 0);
limit = opts.get(options, 'dme::limit', 0);

votes = zeros(numclassifiers, numinstances);
weights = ones(numclassifiers, numinstances);
rankings = [];

for classifier = 1:numclassifiers
    this_votes = zeros(1, numinstances);
    this_weights = zeros(1, numinstances);
    
    [~, index] = sort(distm{classifier}, 2);
    
    for instance = 1:numel(testclasses)
        % Find the classes of the closest N objects
        neighborhood = trainclasses(index(instance, 1:neighborhoodsize));
        
        % Vote for the closest, weight by the prevalence of the voted class
        this_votes(instance) = neighborhood(1);
        this_weights(instance) = sum(neighborhood == neighborhood(1));
    end
    
    votes(classifier, :) = this_votes;
    weights(classifier, :) = this_weights;
end

if limit
    remove_from = limit + 1;
    for instance = 1:numel(testclasses)
        [~, idx] = sort(weights(:, instance), 'descend');
        weights(idx(remove_from:end), instance) = 0;
    end
end

if normalizeweights
    numclasses = numel(unique(trainclasses));
    for instance = 1:numel(testclasses)
        for c = 1:numclasses
        mask = find(votes(:, instance) == c);
        weights(mask, instance) = weights(mask, instance) / numel(mask);
        end
    end
end
end