function [test_folds, train_folds] = makefolds(ds, nfolds)
%TS.MAKEFOLDS   Cross-validation indices.
%   [X,Y] = MAKEFOLDS(DS) creates random folds for 10-fold
%   cross-validation of the objects in data set DS. Each output value, X
%   and Y, is a cell of size (10,1). Each element of both X and Y is a
%   column vector for indices of training (X) or test (Y) instances.
%
%   To evaluate a single fold of some data set with 10-fold
%   cross-validation, first generate the indices, then select the
%   relevant objects from the training data set, and run the
%   classification model.
%
%   Example:
%       train = ts.load('some data set');
%       [trainfolds, testfolds] = ts.makefolds(train);
%       fold1train = train(trainfolds{1});
%       fold1test = train(testfolds{1});
%       runs.partitioned(fold1train, fold1test)
%
%   [X,Y] = MAKEFOLDS(DS,k) returns indices for k-fold cross-validation,
%   where k must be a positive integer.
%
%   Limitations: classes must be sequential positive integers.
if ~exist('nfolds', 'var')
    nfolds = 10;
end
nseries = size(ds, 1);

if nseries < nfolds
    err = MException('InputChk:NotEnoughSamples', 'Input data set too small');
    throw(err);
end

% Make index of class -> instance number
classes = ds(:, 1);
class_index = [classes, (1:nseries)'];

% Make empty folds
test_folds = cell(nfolds, 1);
for i = 1:nfolds
    test_folds{i} = [];
end

% Distribute instances of each class into folds
next_fold = 0;
class_values = unique(classes)';
for c = class_values
    % Get indices of instances for class c
    class_index_mask = (class_index(:,1) == c);
    indices = class_index(class_index_mask, 2);
    if numel(indices) > 1
        indices = randsample(indices, numel(indices));
    end
    
    % Sequentially add those indices to each fold
    for next_index = indices'
        next_fold = 1 + mod(next_fold, nfolds);
        test_folds{next_fold} = [test_folds{next_fold} next_index];
    end
end

if nargout == 2
    train_folds = cell(nfolds, 1);
    for to = 1:nfolds
        train_folds{to} = [];
        for from = 1:nfolds
            if from ~= to
                train_folds{to} = [train_folds{to} test_folds{from}];
            end
        end
    end
end
end