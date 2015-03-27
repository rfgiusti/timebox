function [acc, indices, classes] = partitioned(train, test, varargin)
%RUNS.PARTITIONED Run a classification model over a partitioned data set.
%   ACC = PARTITIONED(TRAIN,TEST) tests each instance of the test data set
%   on the training data set and return the estimated accuracy. Without
%   further options, the classification model is the 1-NN classifier.
%
%   ACC = PARTITIONED(TRAIN,TEST,DIST) does the same as above, but the
%   distance function is specified by DIST, which must be a function
%   handle. The DIST argument may not be accepted by the classification
%   model if this is not the nearest-neighbors classifier.
%
%   ACC = PARTITIONED(TRAIN,TEST,OPTS) or
%   ACC = PARTITIONED(TRAIN,TEST,DIST,OPTS) does the same as the two above,
%   except that options are taken from OPTS instead of default values.
%
%   [ACC,IDX] = PARTITIONED(...) returns both the accuracy and an array of
%   indices for the nearest neighbors. The array IDX may be empty if the
%   classification model is not instance-based.
%
%   [ACC,IDX,CLASSES] = PARTITIONED(...) returns the output arguments
%   specified above, and also an array of classes assigned to each test
%   instance.
%
%   Options:
%       runs::model     (default: @models.nn)
narginchk(2, 4);
if nargin <= 2
    options = opts.empty;
elseif nargin == 3
    if opts.isa(varargin{1})
        options = varargin{1};
    else
        options = opts.empty;
    end
else
    tb.assert(~opts.isa(varargin{1}));
    tb.assert(opts.isa(varargin{2}));
    options = varargin{2};
end

modelfun = opts.get(options, 'runs::model', @models.nn);

numtestinstances = size(test, 1);
classes = zeros(1, numtestinstances);
indices = zeros(1, numtestinstances);

hits = 0;
for i = 1:numtestinstances
    indices(i) = modelfun(train, test(i,:), varargin{:});
    classes(i) = train(indices(i), 1);
    if tb.sameclass(classes(i), test(i, 1), options)
        hits = hits + 1;
    end
end
acc = hits / numtestinstances;
end