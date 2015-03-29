function [traintrain, testtrain] = calcmatrix(train, test, distfun, options)
%DISTS.CALCMATRIX Calculate distance matrix for a data set.
%   CALCMATRIX(DS) returns an n-by-n matrix containing the Euclidean
%   distance between all pairs of time series in the data set DS, where n
%   is the number of time series.
%
%   CALCMATRIX(DS,[],DIST) returns an n-by-n matrix for the distance
%   between all pairs of time series in DS, according to the distance DIST,
%   which must be a function handle. It is assumed that DIST implements a
%   reflexive and symmetric distance (or similarity). In other words, if S
%   and Z are observations of time series, these are true:
%
%       DIST(S, S) == 0             % reflexivity
%       DIST(S, Z) == DIST(Z, S)    % symmetry
%
%   If your distance function does not guarantee reflexivity or symmetry,
%   this must be specified in an OPTS object.
%
%   [TRAINTRAIN,TESTTRAIN] = CALCMATRIX(TRAIN,TEST,...) does the same as
%   the previous formats, but in addition to calculating the distance
%   between pairs of series in the training data set, returns the distance
%   between each test time series to each training time series. The
%   TESTTRAIN time series is of size m-by-n, when n is the number of
%   training series and m is the number of test series.
%
%   The fourth argument is an optional OPTS object. If not present, this
%   function will use default options. The OPTS object must always be the
%   fourth argument. If TEST or DIST is supplied as [], it is treated as if
%   not supplied. Examples of valid calls including an opts object to this
%   function include: 
%
%       CALCMATRIX(TRAIN,TEST,DIST,OPTS)
%       CALCMATRIX(TRAIN,TEST,[],OPTS)
%       CALCMATRIX(TRAIN,[],DIST,OPTS)
%       CALCMATRIX(TRAIN,[],[],OPTS)
%
%   But not:
%
%       CALCMATRIX(TRAIN,OPTS)          % incorrect!
%       CALCMATRIX(TRAIN,TEST,OPTS)     % incorrect!
%       CALCMATRIX(TRAIN,DIST,OPTS)     % incorrect!
%
%   Options:
%       dists::arg              (default: --)
%       dists::symmetric        (default: 1)
%       dists::reflexive        (default: 1)
%
%   If the "measure arg" option is present, its value is passed as a third
%   argument to the distance function.
if ~exist('test', 'var')
    test = [];
end
if ~exist('options', 'var')
    options = opts.empty;
end
if opts.has(options, 'dists::arg')
    measurehasarg = 1;
    measurearg = opts.get(options, 'dists::arg');
else
    measurehasarg = 0;
    measurearg = [];
end

if exist('distfun', 'var') && ~isempty(distfun)
    symmetric = opts.get(options, 'dists::symmetric', 1);
    reflexive = opts.get(options, 'dists::reflexive', 1);
    
    traintrain = distoftraintrain(train, distfun, symmetric, reflexive, measurehasarg, measurearg);
    if ~isempty(test)
        testtrain = distoftesttrain(train, test, distfun, measurehasarg, measurearg);
    end
else
    % For the Euclidean distance we use the native DIST(X) function, which
    % returns the distance between all pairs of objects in the X matrix.
    % DIST works column-wise, that is, each object is a column. In our data
    % sets, time series are rows, so we have to fix for that
    if isempty(test)
        traintrain = dist(train(:, 2:end)')';
    else
        % If is usually faster to calculate the distance between all
        % possible pairs and then get the relevant parts than running a FOR
        % for test vs. train
        fulldata = [train(:, 2:end); test(:, 2:end)];
        fullmatrix = dist(fulldata')';
        n = size(train, 1);
        traintrain = fullmatrix(1:n, 1:n);
        testtrain = fullmatrix(n+1:end, 1:n);        
    end    
end
end


function traintrain = distoftraintrain(train, distfun, symmetric, reflexive, measurehasarg, measurearg)
%Return the train vs. train distance pairs using a custom distance
n = size(train, 1);
traintrain = zeros(n);
for i = 1:n
    if ~reflexive
        traintrain(i, i) = distfunwrapper(train(i, 2:end), train(i, 2:end), distfun, measurehasarg, measurearg);
    end
    for j = (i + 1):n
        traintrain(i, j) = distfunwrapper(train(i, 2:end), train(j, 2:end), distfun, measurehasarg, measurearg);
        if symmetric
            traintrain(j, i) = traintrain(i, j);
        else
            traintrain(j, i) = distfunwrapper(train(j, 2:end), train(i, 2:end), distfun, measurehasarg, measurearg);
        end
    end
end
end


function testtrain = distoftesttrain(train, test, distfun, measurehasarg, measurearg)
% Return the distance between each test and training objects using a
% custome distance
n = size(train, 1);
m = size(test, 1);
testtrain = zeros(m, n);
for i = 1:m
    for j = 1:n
        testtrain(i, j) = distfunwrapper(test(i, 2:end), train(j, 2:end), distfun, measurehasarg, measurearg);
    end
end
end


function d = distfunwrapper(S, Z, distfun, hasarg, arg)
%Wrapper for distfun(S,Z,arg) or distfun(S,Z)
if hasarg
    d = distfun(S, Z, arg);
else
    d = distfun(S, Z);
end
end