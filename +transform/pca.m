function [trainpca, testpca] = pca(train, test, options)
%TRANSFORM.PCA Performs Principal Component Analysis on the training data
%set and returns observations for the training and test data sets in the
%transformed space.
%   DSPC = PCA(DS) performs principal component analysis on the data set
%   DS, and returns coefficients for the series with respect to the
%   principal components of DS.
%
%   DSPC = PCA(DS,OPTS) does the same, but takes options from OPTS instead
%   of using default values.
%
%   [TRAINPC,TESTPC] = PCA(TRAIN,TEST) takes a data set that has been
%   partitioned into a training set TRAIN and a test set TEST and fins the
%   coefficients for both of them with respect to the principal components
%   of TRAIN.
%
%   Remark: the test data set should be transformed to the same decision
%   space as the training data set (i.e., using the same principal
%   components). The following should be preferred when working with
%   partitioned data sets:
%
%       [train, test] = ts.load('some data set');
%       [trainpc, testpc] = transform.pca(train, test);
%
%   Options:
%       pca::cut            (default: serieslength * 0.25)
%       pca::zero cols      (default: 1)

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 0.2.0
warnobsolete('transform:pca');

cut = 0.25;     % how much % of coefficients to keep?
zerocols = 1;   % should we move columns to mean zero?

% The second parameter may be either a dataset or an options set.
if exist('test', 'var') && ~exist('options', 'var') && opts.isa(test)
    options = test;
    clear test;
end
        
% Check the options
if exist('options', 'var')
    cut = opts.get(options, 'pca::cut', cut);
    zerocols = opts.get(options, 'pca::zero cols', zerocols);
    
    % If cut is in %, move to [0,1] factor
    if cut > 1
        cut = cut / 100;
    end
end

% Apply principal component analysis on partition or dataset
if exist('test', 'var')
    [trainpca, testpca] = twostep(train, test, zerocols, cut);
else
    trainpca = onestep(train, zerocols, cut);
end
end

function dsout = onestep(dsin, zerocols, cut)
% If we have to do things one step, then all we need is to call PRINCOMP.
% When data is supposed to be zero mean, PRINCOMP can be used with default
% configuration. Otherwise, coefficients must be calculated by hand and
% applied to the data.
[classes, obs] = ts.removeclasses(dsin);
if zerocols
    [~, vals] = princomp(obs);
else
    coeff = princomp(obs);
    vals = obs * coeff;
end

% Move cut from % to abs
cut = round(size(vals, 2) * cut);
if cut < 1
    cut = 1;
end

% Add classes back and send'em out
dsout = ts.addclasses(classes, vals(:, 1:cut));
end

function [trainpca, testpca] = twostep(train, test, zerocols, cut)
% If we have a training and a testing set, we need to do things two step.
% That means taking the coefficients from the training dataset and applying
% them on both the training and test dataset.
[trainclasses, trainobs] = ts.removeclasses(train);
[testclasses, testobs] = ts.removeclasses(test);

% Get the loadings
coeff = princomp(trainobs);

% Do we need to zero shift?
if zerocols
    means = mean(trainobs);
else
    means = zero(1, size(trainobs, 2));
end
trainshift = bsxfun(@minus, trainobs, means);
testshift = bsxfun(@minus, testobs, means);

% PCA them
trainvals = trainshift * coeff;
testvals = testshift * coeff;

% Move cut from % to abs
cut = round(size(trainvals, 2) * cut);
if cut < 1
    cut = 1;
end

% Add class back and send'em out
trainpca = ts.addclasses(trainclasses, trainvals(:, 1:cut));
testpca = ts.addclasses(testclasses, testvals(:, 1:cut));
end