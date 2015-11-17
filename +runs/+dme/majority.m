function [votes, weights, rankings] = majority(~, trainclasses, testclasses, distm, ~, ~, ~)
%RUNS.DME.MAJORITY  Run a partitioned train/test evaluation of the majority
%ensemble on a data set.
%   This function is part of the ensemble evaluation set.
%
%   The majority ensemble simply returns the classes voted by each base
%   classifier and a weight matrix entirely composed of ones. Use
%   RUNS.DME.MERGE to get the actual ensemble classification.
%
%   Input:
%       dsname          not used by MAJORITY; replace with []
%       trainclasses    n-by-1 array of training instance classes
%       testclasses     m-by-1 array of test instance classes
%       distm           k-by-1 cell of distance matrices
%       basecc          not used by MAJORITY
%       options         not used by MAJORITY
%
%   Output:
%       votes           k-by-n matrix of votes
%       weights         k-by-n matrix of ones
%       rankings        empty cell
%
%   RUNS.DME.MAJORITY is one of the ensemble assessment functions from the
%   RUNS.DME package. This package offers a series of functions that
%   implement a standard interface to assess the performance of ensemble
%   strategies. The ensembles are assessed over the distance matrices of the base
%   classifiers.
%
%   Ensembles are divided into two groups. The "class labeling" ensembles
%   assume each base classifier is a label classifier that returns a single
%   class label for each test instance. The "label ranker" ensembles assume
%   each base classifier is a label ranker that returns a ranking for each
%   class for each test instance.
%
%   Each ensemble function takes as input some out of an homogeneous list
%   of arguments, which are:
%
%       dsname          name of the data set compatible with TS.LOAD (not
%                       required by a few ensembles)
%       trainclasses    n-by-1 array of training instance classes
%       testclasses     m-by-1 array of test instance classes
%       distm           k-by-1 cell of distance matrices
%       basecc          if required by the ensemble, this must be a k-by-1
%                       cell. Each cell element must be a structure with
%                       three CHAR fiels:
%                       - "name" with the name of the base classifier 
%                       - "distname" with the name of the distance function
%                          associated to each base classifier
%                       - "repname" with the name of the time series
%                          representation associated to each base
%                          classifier
%                       These names are identifiers used by the ensembles to
%                       fetch additional information from files or TimeBox
%                       functions. Please refer to the documentation of
%                       each ensemble for an explanation on what these
%                       names should be
%       options         unless required by the ensemble, this is an
%                       optional options set argument
%
%   (k is the number of base classifiers)
%
%   Each ensemble function defines what arguments are optional. Please
%   refer to their individual documentation for more information.
%
%   Each ensemble function outputs three values:
%
%       votes       for ranking ensembles, "votes" is an empty array; for
%                   non-ranking ensembles, "votes" is a k-by-n matrix. Each
%                   (i,j) element is the class from the i-th base
%                   classifier for the j-th instance
%       weights     for ranking ensembles, "weights" is an empty array; for
%                   non-ranking ensembles, "votes" si a k-by-n matrix. Each
%                   (i,j) element is the weight associated by the i-th base
%                   classifier to the j-th instance
%       rankings    for non-ranking ensembles, "ranking" is an empty cell.
%                   For ranking ensembles, "votes" is a k-by-1 cell. Each
%                   cell element is a c-by-n matrix where each i-th column
%                   is the rank distribution for the classes of the i-th
%                   instance
%
%   The ensemble functions simply gather the votes, weights, and ranks for
%   each instance. Use RUNS.DME.MERGE to get the actual ensemble
%   classification.
numclassifiers = numel(distm);
numinstances = numel(testclasses);

votes = zeros(numclassifiers, numinstances);
weights = ones(numclassifiers, numinstances);
rankings = {};

for i = 1:numclassifiers
    [~, neighbors] = min(distm{i}, [], 2);
    votes(i, :) = trainclasses(neighbors);
end
end