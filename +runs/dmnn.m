function [acc, neighbors, classes] = dmnn(trainclasses, testclasses, distmatrix, options)
%RUNS.DMNN Distance matrix-based partitioned/leave-one-out validation for
%the 1-nearest neighbor classification model.
%   DMNN(T,X,DM) performs a train/test partition validation on a data set
%   whose distances between test and training instances is specified by DM,
%   which must be a matrix of n-by-m dimensions. T is an array of n
%   elements which specifies the classes of the training. X is an array of
%   m elements which specifies the test instances classes. The value
%   returned by DMNN is the estimated accuracy.
%
%   DMNN(T,X,DM,OPTS) takes an OPTS object. If the distance function is
%   actually a similarity function this must be specified as an option.
%
%   DMNN(T,[],DM,...) specifies leave-one-out validation. DM is a n-by-n
%   matrix of distances between pairs on the same data set. T is an array
%   of n elements for the classes of the training instances.
%
%   [ACC,N] = DMNN(T,...) returns the indices of the nearest neighbors (in
%   T) as well as the accuracy.
%
%   [ACC,N,C] = DMNN(T,...) also returns the classes of the nearest
%   neighbors.
%
%   Options:
%       dists::similarity       (default 0)
if ~exist('options', 'var')
    options = opts.empty;
end
% The nearest neighbors are given by the indices the min/max element of
% each row for test-vs-training matrices. For training-vs-training
% matrices, the diagonals are the distance between each instance and
% itself. The quickest way to find the nearest neighbors in
% training-vs-training matrices is to replace the diagonals with NaN; then
% the process is identical to finding neighbors in test-vs-training
% matrices
if isempty(testclasses)
    diagonalstep = size(distmatrix, 1) + 1;
    distmatrix(1:diagonalstep:end) = NaN;
    testclasses = trainclasses;
end
if opts.get(options, 'dists::similarity', 0)
    [~, neighbors] = max(distmatrix, [], 2);
else
    [~, neighbors] = min(distmatrix, [], 2);
end
classes = trainclasses(neighbors);
acc = mean(classes == testclasses);
end