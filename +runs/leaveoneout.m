function [acc, neighbors, labels] = leaveoneout(ds, varargin)
%RUNS.LEAVEONEOUT Evaluate a data set with leave-one-out partitioning.
%   LEAVONEOUT(DS) evaluates the data set DS with leave-one-out strategy
%   and returns the estimated accuracy. The classification model is assumed
%   to be the 1-NN classifier and Euclidean distance is used.
%
%   To use a custom classification model instead of the 1-NN classifier,
%   set the option "runs::model" to a different function handle. It is
%   important that the custom model is capable of taking at least the same
%   mandatory arguments as MODELS.NN (i.e., the "stack" and the "needle").
%   The optional arguments that MODELS.NN are only necessary for the the
%   custom model if they are supplied to LEAVEONEOUT. The custom model
%   should output at least one argument, which must be an index to the
%   nearest neighbor of the "needle" in the "stack". For an explanation of
%   the "needle/stack" terminology, please see the internal documentation
%   of MODELS.NN.
%
%   LEAVEONEOUT(DS,DIST) does the same as the first call, but using DIST as
%   a function handle to a distance function instead of the Euclidean
%   distance.
%
%   LEAVEONEOUT(DS,OPTS) or
%   LEAVEONEOUT(DS,DISTS,OPTS) do the same as the above variations, but
%   options are taken from OPTS instead of default values.
%
%   [A,N] = LEAVEONEOUT(DS,...) returns both the estimated accuracy and the
%   indices of the nearest neighbors for each test sample.
%
%   [A,N,L] = LEAVEONEOUT(DS,...) also returns the labels of the nearest
%   neighbors.
%
%   Options:
%       runs::model     (default: *)
%
%   *the default value for "runs::model" is "@models::nn" if a distance
%   function is specified as second argument; "@models::nn1euclidean"
%   otherwise. Notice that @models::nn1euclidean, although much faster,
%   requires input values to be of type DOUBLE, so if the input might
%   contain complex numbers, either a distance function must be specified
%   or the classification model must be explicitly specified.
defaultmodel = @models.nn1euclidean;
tb.narginchk(nargin, 1, 3);
if nargin == 1
    options = opts.empty;
elseif nargin == 2
    if opts.isa(varargin{1})
        options = varargin{1};
    else
        options = opts.empty;
        % Since the second argument was not an OPTS object, we assume it is
        % a handle to a distance function
        defaultmodel = @models.nn;        
    end
else
    tb.assert(~opts.isa(varargin{1}));
    tb.assert(opts.isa(varargin{2}));
    options = varargin{2};
    defaultmodel = @models.nn;
end
classifyhandle = opts.get(options, 'runs::model', defaultmodel);

numinstances = size(ds, 1);
labels = zeros(numinstances, 1);
neighbors = zeros(numinstances, 1);

hits = 0;
for i = 1 : numinstances
    neighbors(i) = classifyhandle(ds, i, varargin{:});
    labels(i) = ds(neighbors(i), 1);
    if tb.sameclass(labels(i), ds(i, 1), options)
        hits = hits + 1;
    end    
   
end
acc = hits / numinstances;
end

