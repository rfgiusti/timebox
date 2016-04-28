function [votes, weights, rankings] = atiya(dsname, trainclasses, testclasses, labels, distm, basecc, options)
%RUNS.DME.ATIYA     Posterior probability-based ensemble classification,
%using the method proposed by Atiya, 2005 as probability estimator.
%   This function is part of the ensemble evaluation set.
%
%   For the information on the posterior probability estimator implemented
%   by this function, please refer to the paper of Amir F. Atiya,
%   "Estimating the Posterior Probabilities Using the K-Nearest Neighbor
%   Rule", in Neural Computation, Vol. 17, Num. 3, 2005.
%
%   Input:
%       dsname          name of the data set compatible with TS.LOAD
%       trainclasses    n-by-1 array of training instance classes
%       testclasses     m-by-1 array of test instance classes
%       labels          c-by-1 array of valid class labels
%       distm           k-by-1 cell of distance matrices
%       basecc          The names of the base classifiers and the
%                       associated distance functions are required
%       options         options set argument. If the weights are cached,
%                       the path to the previously calculated simple ranks
%                       must be informed here
%
%   Output:
%       votes           empty array
%       weights         empty array
%       rankings        k-by-1 cell; each cell element is a c-by-n matrix
%                       where each i-th column is the rank distribution for
%                       the classes of the i-th test instance
%
%   The Atiya ensemble requires that the training data set is evaluated
%   according to the neihgboor distance influence. This method assigns
%   weights to each degree of neighborhood, which are then used to estimate
%   each class probability. The weight w1 is associated with every first
%   neighbor, the weight w2 is associated with every second-nearest
%   neighbor and so forth.
%
%   The neighborhood size determines how many nearest neighbors will be
%   used in the estimate of the class probability. The option "dme::nnsize"
%   can be set to a double that defines this size. This function may also
%   search the best neighborhood size from a list of candidate values using
%   cross-validation on the training data set. If "dme::nnsize" is set to
%   an array of double, then each element of the array is a candidate value
%   for the neighborhood size.
%
%   To estimate the best neighborhood size from k-fold cross-validation,
%   one must first realize several rounds of cross-validation on the
%   training data set for each base classifier. The accuracies should be
%   saved in a directory specified by "dme::atiyapath" with file names in
%   the form "DSNAME-REPNAME-DISTNAME-folds-K.mat", where DSNAME, REPNAME
%   and DISTNAME are, respectivelly, the name of the data set, of the time
%   series representation and of the distance function. K is an integer
%   that specifies the previously evaluated neighborhood size K. Candidate
%   values for K are specified by setting the option "dme::nnsize" to an
%   array of double. Each relevant .mat file must contain a variable named
%   "train_acc" that gives the mean accuracy of the cross-validation for
%   all folds.
%
%   To get the weights for the neighborhood levels, please refer to
%   RUNS.DME.AUX.ATIYA.
%
%   For more information on how ensemble evaluation is implemented in
%   TimeBox, please check RUNS.DME.MAJORITY.
%
%   Options taken by this function:
%
%       dme::atiyapath          (default: --)
%       dme::crossvalidation    (default: 0)
%       dme::nnsize             (default: 5)

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 0.1
if ~exist('options', 'var')
    options = opts.empty;
end
cachepath = opts.get(options, 'dme::atiyapath', []);
numclassifiers = numel(basecc);
numinstances = numel(testclasses);
numclasses = numel(labels);

% runs.dme.aux.atiya must know if this is cross-validation because it
% will require access to the real training data set. In case of
% cross-validation, RUNS.DME.AUX.ATIYA needs the classes of the entire
% training data set
if opts.get(options, 'dme::crossvalidation', 0)
    [trainclasses_p, ~] = ts.loadclasses(dsname);
else
    trainclasses_p = trainclasses;
end

% If there is an option for the value of K, set it accordingly. If k is
% larger than the number of training instances, it is truncated silently
kcandidate = opts.get(options, 'dme::nnsize', 5);
if numel(kcandidate) == 1
    if kcandidate > numel(trainclasses)
        kcandidate = numel(trainclasses);
    end
    k = ones(numclassifiers, 1) * kcandidate;
else
    kcandidate(kcandidate > numel(trainclasses)) = [];
    if isempty(kcandidate)
        kcandidate = numel(trainclasses);
    end
    k = zeros(numclassifiers, 1);
    for c = 1:numclassifiers
        baseccname = basecc{c}.name;
        bestk = [];
        bestacc = 0;
        for kvalue = kcandidate
            kfile = sprintf('results/atiya-%d/%s-%s-folds.mat', kvalue, dsname, baseccname);
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

% Calculate the posterior probability for each class given each instance
rankings = cell(numclassifiers, 1);
for c = 1:numclassifiers
    % Get a matrix where the weights for each neighbor appear in
    % numinstances columns
    kweights = runs.dme.aux.atiya(dsname, basecc{c}.distname, basecc{c}.repname, trainclasses_p, k(c), cachepath);
    kiweights = repmat(kweights(1:end-1)', 1, numinstances);
    
    % Turn into softmax representation
    wsum = sum(exp(kweights));
    softv = exp(kiweights) / wsum;
    
    % What's the probability of each class for each test instance?
    classprob = zeros(numclasses, numinstances);
    
    % Sum the probabilities of each class, considering softv and neighbor classes
    [~, neighborhood] = sort(distm{c}, 2);
    neighboorclasses = trainclasses(neighborhood(:, 1:k(c)))';
    for class = 1:numclasses
        % Copy the softv matrix and remove the neighbors that are not of the desired class
        classv = softv;
        classv(neighboorclasses ~= labels(class)) = 0;
        
        classprob(class, :) = sum(classv);
    end
    
    rankings{c} = tiedrank(1 - classprob);    
end

% There are no votes here
votes = [];
weights = [];
end



