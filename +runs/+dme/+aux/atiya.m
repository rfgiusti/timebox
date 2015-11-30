function weights = atiya(dsname, distname, repname, trainclasses, k, cachepath)
%RUNS.DME.AUX.ATIYA     Get the weights for the training instances of a
%data set according to the algorithm for posterior class probability
%estimation proposed by Atiya, 2005
%   This function is an auxiliary function for the implementation of the
%   Atiya ensemble method. For more information, please refer to
%   RUNS.DME.ATIYA.
%
%   ATIYA(DSNAME,DISTNAME,REPNAME,C,k) calculates the weights
%   for the Atiya ranking ensemble on the data set named DSNAME, with
%   respect to time series representation REPNAME and distance function
%   DISTNAME. C must be a column vector where each C(i) is the class of the
%   i-th training instance. The neighborhood size k is required. The output
%   is a column vector of k+1 weights, not k, because the implemented
%   method includes an extra, "virtual" neighbor in each run.
%
%   The iterative method that estimates the neighborhood weights is
%   implemented as a MEX file, which should be compiled from the Matlab
%   shell. For instance,
%
%       BASEPATH = %root directory of TimeBox (e.g., '~/timebox')
%       cd([BASEPATH '/+runs/+dme/+aux']);
%       mex atiya_Mex.c
%
%   The weight estimation can be quite expensive computationally. To avoid
%   repetitions of this process, this function can cache each weight set.
%   When called in the form ATIYA(DSNAME,DISTNAME,REPNAME,C,k,PATH), this
%   function will use PATH as the directory for caches, as specified by
%   "dme::atiyapath" for RUNS.DME.ATIYA.
if exist('cachepath', 'var') && ~isempty(cachepath)
    cachefile = sprintf('%s/%s-%s-%s-%d.mat', cachepath, dsname, repname, distname, k);

    if exist(cachefile, 'file')
        filedata = load(cachefile);
        weights = filedata.weights;
        return
    end
else
    cachepath = [];
end

tic;

fprintf('Running atiya for %s/%s/%s\n', dsname, distname, repname);

% Get train X train matrix
[traintrain, ~] = dists.cached(dsname, distname, repname);

% Get distance to k-closest neighbors + distance to itself for every training instance
[~, neighbors] = sort(traintrain, 2);

% Get classes of closest neighbors (ignore self reference)
neighborclasses = trainclasses(neighbors(:, 2:k+1));

% Count number of unique classes
nclasses = numel(unique(trainclasses));

[weights, iterations] = runs.dme.aux.atiya_Mex(trainclasses, neighborclasses, k, size(trainclasses, 1), ...
    nclasses); %#ok<NASGU>

weight_optimization_time = toc; %#ok<NASGU>

if ~isempty(cachepath)
    save(cachefile, 'weights', 'iterations', 'weight_optimization_time', 'k', 'repname', 'distname', '-mat');
end
end