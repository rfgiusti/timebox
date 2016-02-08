function [test_folds, train_folds] = makefolds(ds, nfolds, index)
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
%       [testfolds, trainfolds] = ts.makefolds(train);
%       fold1train = train(trainfolds{1});
%       fold1test = train(testfolds{1});
%       runs.partitioned(fold1train, fold1test)
%
%   MAKEFOLD uses only the first row of DS, therefore it is possible to
%   create indices with only the instance labels. In that case DS must
%   be a row vector, otherwise it will be treated as a data set with a
%   single instance.
%
%   [X,Y] = MAKEFOLDS(DS,k) returns indices for k-fold cross-validation,
%   where k must be a positive integer.
%
%   [X,Y] = MAKEFOLDS(DS,[],I)
%   [X,Y] = MAKEFOLDS(DS,k,I) makes indices for cross-validation on the
%   instances of DS listed in I. This may be used to further partition
%   an already partitioned data set -- e.g., it may be used to create
%   validation sets. The indices in X and Y are still given with respect
%   to the original data set DS.
%
%   Example:
%       train = ts.load('some data set');
%       [X,Y] = ts.makefolds(train, 2);
%
%       % Make 2 folds to validate the training data of the first fold
%       [valX,valY] = ts.makefolds(train, 2, Y{1});
%
%       % Validate first fold
%       acc = zeros(10,1);
%       for i = 1:2
%           validation1train = train(valY{i},:);
%           validation1test = test(valX{i},:);
%           acc(i) = runs.partitioned(validation1train, validation1test);
%       end
%       mean(acc)
if ~exist('nfolds', 'var') || isempty(nfolds)
    nfolds = 10;
end

if exist('index', 'var')
    tb.assert(isequal(class(index),'double') && size(index,1) == 1, '''index'' must be a column vector of double');
    tb.assert(min(index) >= 1, 'Invalid index value: %d', min(index));
    tb.assert(max(index) <= size(ds,1), 'Invalid index value: %d', max(index));
    nseries = numel(index);    
else
    nseries = size(ds, 1);
    index = 1:nseries;
end

if nseries < nfolds
    err = MException('InputChk:NotEnoughSamples', 'Input data set too small');
    throw(err);
end


% Make index of class -> instance number
classes = ds(index, 1);
class_index = [classes, index'];

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