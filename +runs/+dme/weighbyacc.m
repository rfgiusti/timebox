function [votes, weights, rankings] = weighbyacc(dsname, trainclasses, testclasses, ~, distm, basecc, options)
%RUNS.DME.WEIGHBYACC   Run a partitioned train/test evaluation of the
%weighted ensemble on a data set, using accuracy on training data set as
%weight.
%   This function is part of the ensemble evaluation set.
%
%   The weight-by-accuracy ensemble simply returns the classes voted by
%   each classifier and a weight matrix that is based on previously
%   executed cross-validation on the training data set.
%
%   Input:
%       dsname          name of the data set compatible with TS.LOAD
%       trainclasses    n-by-1 array of training instance classes
%       testclasses     m-by-1 array of test instance classes
%       labels          not used by WEIGHBYACC; replace with []
%       distm           k-by-1 cell of distance matrices
%       basecc          The names of the base classifiers are required by
%                       the ensemble to fetch MAT files containing the
%                       accuracy on the training data set
%       options         *required* options argument, which must specify at
%                       least the dme::accpath option with the path for the
%                       accuracy values on the training data set.
%
%   Output:
%       votes           k-by-n matrix of votes
%       weights         k-by-n matrix of related weights
%       rankings        empty cell
%
%   This ensemble requires that each base classifier has been previously
%   evaluated and given a score related to its accuracy on the training
%   data set. The option dme::accpath specifies a directory where the cache
%   files may be found. For the base ensemble named <CC> and data set named
%   <DS>, the cached file will be expected on the path
%
%       <dme::accpath>/<CC>/<DS>-folds.mat
%
%   For instance, if dme::accpath is set to 'results', then when running an
%   ensemble that includes the base classifier named 'time' on the data set
%   'Beef', this function will look for the file
%
%       results/time/Beef-folds.mat
%
%   This file must contain at least the variable "train_acc", which
%   specifies the accuracy obtained by the base classifier on the training
%   data set.
%
%   For more information on how ensemble evaluation is implemented in
%   TimeBox, please check RUNS.DME.MAJORITY.
%
%   Options taken by this function:
%
%       dme::limit      (default: 0)
%       dme::accpath    (default: --)

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 0.1
numclassifiers = numel(distm);
numinstances = numel(testclasses);

votes = zeros(numclassifiers, numinstances);
weights = ones(numclassifiers, numinstances);
rankings = [];

limit = opts.get(options, 'dme::limit', 0);
accpath = opts.get(options, 'dme::accpath', []);
tb.assert(~isempty(accpath), 'Path to accuracy-on-training data is required');

for i = 1:numclassifiers
    filedata = load([accpath '/' basecc{i}.name '/' dsname '-folds.mat']);
    [~, neighbors] = min(distm{i}, [], 2);
    votes(i, :) = trainclasses(neighbors);
    weights(i, :) = filedata.train_acc;
end

if limit >= 1
    if round(limit) ~= limit
        err = MException('ensemble_weightbyacc:InputErr', ['Option `limit'' must be either an ' ...
                'integer or a real in [0, 1]']);
        throw(err);
    end
    if limit > numclassifiers
        err = MException('ensemble_weightbyacc:InputErr', ['Option `limit'' can''t be greater ' ...
                'than the ensemble size']);
        throw(err);
    end
    [~, weightmask] = sort(weights(:, 1), 'descend');
    weights(weightmask(limit+1:end), :) = 0;
elseif limit
    maxweight = max(weights(:, 1));
    weights(maxweight - weights > limit) = 0;
end
end