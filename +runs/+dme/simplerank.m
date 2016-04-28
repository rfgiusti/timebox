function [votes, weights, rankings] = simplerank(dsname, trainclasses, testclasses, labels, distm, basecc, options)
%RUNS.DME.SIMPLERANK   Run a partitioned train/test evaluation of the
%weighted ensemble on a data set, using a simple rank analysis to estimate
%the importance of each nearest-neighbor to weight base classifiers
%   This function is part of the ensemble evaluation set.
%
%   The weight-by-simplerank returns a ranking for each class for each test
%   instance and a weight matrix that depends on the importance of each
%   nearest neighbor. The nearest neighbors's importance are calculated
%   from the ranks assigned to each instance by the SimpleRank anytime
%   classification algorithm.
%
%   Input:
%       dsname          name of the data set compatible with TS.LOAD
%       trainclasses    n-by-1 array of training instance classes
%       testclasses     m-by-1 array of test instance classes
%       labels          c-by-1 array of valid class labels
%       distm           k-by-1 cell of distance matrices
%       basecc          The names of the base classifiers and the
%                       associated distance functions are required
%       options         options set argument. If the simple ranks are
%                       cached, the path to the previously calculated
%                       simple ranks must be informed here. If the
%                       neighborhood size K is to be estimated from
%                       cross-validation, the path to the previously
%                       executed cross-validation runs must be specified as
%                       well
%
%   Output:
%       votes           empty array
%       weights         empty array
%       rankings        k-by-1 cell; each cell element is a c-by-n matrix
%                       where each i-th column is the rank distribution for
%                       the classes of the i-th test instance
%
%   The SimpleRank ensemble requires that each training instance is
%   evaluated for its classification "importance". The assigned importance
%   is related to the rank given by the SimpleRank algorithm without
%   tiebreaking.
%
%   The simple rank of each training instance for a training data set is
%   calculated implicitly by RUNS.DME.AUX.SIMPLERANKPOINTS. This function
%   will returns points for the simple rank (which in a conventional
%   anytime classification would be transformed to ranks). The simple rank
%   points should be calculated for each combination of distance
%   function/time series representation for each data set. It may be cached
%   for further use or calculated on-the-fly.
%
%   If simple ranking cache is enabled, the simple rank files will be
%   searched for in the path specified by "dme::srankpath".
%
%   When ranking classes, a neighborhood for the test sample is
%   established. The simple rank points for training instances of each
%   class are used to calculate that class's rank. The option "dme::nnsize"
%   may be used to determine this neighborhood size. If "dme::nnsize" is
%   set to an array, the ensemble will attempt to choose the best
%   neighborhood size from k-fold cross-validation on the tentative values
%   specified by the array.
%
%   For more information on how ensemble evaluation is implemented in
%   TimeBox, please check RUNS.DME.MAJORITY.
%
%   Options taken by this function:
%       
%       dme::crossvalidation    (default: 0)
%       dme::cvpath             (default: --)
%       dme::nnsize             (default: 5)
%       dme::nntrainsize        (default: 1)
%       dme::match reward       (default: 1)
%       dme::mismatch penalty   (default: -2)
%       dme::srankpath          (default: --)
%       dme::trainindex         (default: --)

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 0.1
numclasses = numel(labels);
numclassifiers = numel(basecc);
testsize = numel(testclasses);

if ~exist('options', 'var')
    options = opts.empty;
end

if opts.has(options, 'dme::srankpath')
    cachepath = opts.get(options, 'dme::srankpath');
else
    cachepath = [];
end

% If there is an option for the value of K, set it accordingly
kcandidate = opts.get(options, 'dme::nnsize', 5);
if numel(kcandidate) == 1
    k = ones(numclassifiers, 1) * kcandidate;
else
    tb.assert(opts.has(options, 'dme::cvpath'), ['Tuning the neighborhood size for simple ranking ensemble ' ...
        'requires the cross-validation cache path to be specified in dme::cvpath']);
    k = findbestk(opts.get(options, 'dme::cvpath'), basecc, kcandidate);
end

% How many neighbors are used to make the ranking
ranking_k = opts.get(options, 'dme::nntrainsize', 1);

% Constant to reward/penalize samples for matching/mismatching neighbors
if opts.has(options, 'dme::match reward') || opts.has(options, 'dme::mismatch penalty')
    match_reward = opts.get(options, 'dme::match reward', 1);
    mismatch_penalty = opts.get(options, 'dme::mismatch penalty', -2);
    matchvalues = [match_reward, mismatch_penalty / (numclasses - 1)];
else
    matchvalues = [];
end

% There are no votes and no weights here
votes = [];
weights = [];

% If running cross-validation, then the weights must be reordered
% according to the index of the training fold
crossvalidation = opts.get(options, 'dme::crossvalidation', 0);
if crossvalidation
    tb.assert(opts.has(options, 'dme::trainindex'), ['When "dme::crossvalidation" is true, an index for the ' ...
        'training instances must be supplied in "dme::trainindex"']);
    trainindex = opts.get(options, 'dme::trainindex');
    tb.assert(numel(trainindex) == numel(trainclasses), ['The training index for this data set and fold ' ...
        'should be have exactly %d elements.'], numel(trainclasses));
end

% Make the actual rankings
rankings = cell(numclassifiers, 1);
for c = 1:numclassifiers
    % Get the simple ranks as weights (getsimplerank returns an inverted ranking: higher rank is
    % better)
    [~, trainweights] = runs.dme.aux.simplerank(dsname, basecc{c}.repname, basecc{c}.distname, trainclasses, ...
        numclasses, ranking_k, matchvalues, cachepath, 0);
    
    % If doing cross-validation, reorder the weights according to the
    % training index
    if crossvalidation
        trainweights = trainweights(trainindex);
    end
    
    % Get the nearest neighbors of each test instances
    [~, index] = sort(distm{c}, 2);
    
    % Get the importance of each neighbor
    neighborhood = index(:, 1:k(c))';
    neighborpoints = trainweights(neighborhood);
    neighborweights = tiedrank(-neighborpoints);
    
    % Sum the weights for each class for all instances
    classweights = zeros(numclasses, testsize);
    for class = 1:numclasses
        classmask = trainclasses(neighborhood) == labels(class);
        relevantweights = neighborweights .* classmask;
        classweights(class, :) = sum(relevantweights, 1);
    end
    
    % Turn the sum into a ranking
    maxweight = max(max(classweights));
    rankings{c} = tiedrank(maxweight - classweights);
end
end


function k = findbestk(cachepath, dsname, basecc, kcandidate)
% Find the best k parameter from previously cached cross-validation runs
error('Not implemented');

k = zeros(numclassifiers, 1);
for c = 1:numclassifiers
    distname = basecc{c}.distname;
    repname = basecc{c}.repname;
    bestk = [];
    bestacc = 0;
    for kvalue = kcandidate
        kfile = sprintf('%s/%s-%s-%s-folds-%d.mat', cachepath, dsname, repname, distname, kvalue);
        filedata = load(kfile);
        if abs(filedata.train_acc - bestacc) < 1e-6
            bestk(end + 1) = kvalue; %#ok<AGROW>
        elseif filedata.train_acc > bestacc
            bestk = kvalue;
            bestacc = filedata.train_acc;
        end
    end
    if numel(bestk) == 1
        k(c) = bestk;
    else
        k(c) = randsample(bestk, 1);
    end
end
end
