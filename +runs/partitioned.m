function [acc, indices, classes] = partitioned(train, test, varargin)
%RUNS.PARTITIONED Run a classification model over a partitioned data set.
%   ACC = PARTITIONED(TRAIN,TEST) tests each instance of the test data set
%   on the training data set and return the estimated accuracy (i.e.,
%   percentage of instances correctly classified). Without further options,
%   the classification model is the fast 1-NN classifier
%   MODELS.NN1EUCLIDEAN and the distance function is the Euclidean
%   distance.
%
%   Example:
%
%       [train,test] = ts.load('some data set');
%       runs.partitioned(train,test)
%
%   ACC = PARTITIONED(TRAIN,TEST,DIST) does the same as above, but the
%   distance function is specified by DIST, which must be a function
%   handle. The DIST argument may not be accepted by the classification
%   model if this is not the nearest-neighbors classifier.
%
%   Example:
%
%       [train,test] = ts.load('some data set');
%       runs.partitioned(train,test,@dists.DTW_Cpp)
%
%   ACC = PARTITIONED(TRAIN,TEST,OPTS) or
%   ACC = PARTITIONED(TRAIN,TEST,DIST,OPTS) does the same as the two above,
%   except that options are taken from OPTS instead of default values.
%
%   Example ("@myClassifier" should be a handle to a valid classifier)
%
%       [train,test] = ts.load('some data set');
%       runs.partitioned(train,test, opts.set('runs::model', ...
%                                           @myClassifier))
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
%       runs::model     (default: *)
%
%   *the default value for "runs::model" is "@models::nn" if a distance
%   function is specified as  third argument; "@models::nn1euclidean"
%   otherwise. Notice that @models::nn1euclidean, although much faster,
%   requires input values to be of type DOUBLE, so if the input might
%   contain complex numbers, either a distance function must be specified
%   or the classification model must be explicitly specified.

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 1.0
defaultmodel = @models.nn1euclidean;
tb.narginchk(nargin, 2, 4);
if nargin <= 2
    options = opts.empty;
elseif nargin == 3
    if opts.isa(varargin{1})
        options = varargin{1};
    else
        options = opts.empty;
        % Since the third argument was not an OPTS object, we assume it is
        % a handle to a distance function
        defaultmodel = @models.nn;
    end
else
    tb.assert(~opts.isa(varargin{1}), ['RUNS.PARTITIONED: when called with 4 arguments, the third argument must be ' ...
        'a handle to the distance function']);
    tb.assert(opts.isa(varargin{2}), ['RUNS.PARTITIONED: when called with 4 arguments, the fourth argument must be ' ...
        'an options object -- use OPTS.EMPTY if the associated function takes no options']);
    options = varargin{2};

    defaultmodel = @models.nn;    
end

modelfun = opts.get(options, 'runs::model', defaultmodel);

numtestinstances = size(test, 1);
classes = zeros(numtestinstances, 1);
indices = zeros(numtestinstances, 1);

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