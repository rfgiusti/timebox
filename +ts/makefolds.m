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

classes = ds(:, 1);
class_index = [classes, (1:nseries)'];

class_values = unique(classes)';
if ~isequal(class_values, 1:numel(class_values))
    err = MException('InputChk:InvalidSamples', 'Class numbers must be sequential positive integers');
    throw(err);
end

% Make empty folds
test_folds = cell(nfolds, 1);
for i = 1:nfolds
    test_folds{i} = [];
end

% Distribute instances of each class into folds
which_class = zeros(1, size(ds, 1));
next_fold = 0;
for c = class_values
    class_index_mask = (class_index(:,1) == c);
    indices = class_index(class_index_mask, 2);
    % Shuffle if class has more than one element
    if numel(indices) > 1
        indices = randsample(indices, numel(indices));
    end
    for next_index = indices'
        if which_class(next_index)
            fprintf('Item %d was in class %d and now is also in class %d\n', next_index, ...
                    which_class(next_index), c);
        else
            which_class(next_index) = c;
        end
        
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