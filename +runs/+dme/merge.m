function [acc, classes] = merge(votes, weights, rankings, testclasses, numclasses)
%RUNS.DME.MERGE     Evalutes the ensemble output and determines the class
%assigned by the ensemble to each test instance
%   This function is part of the ensemble evaluation set.
%   
%   Each ensemble implementation in the RUNS.DME package returns a data
%   structure that represents the votes of each classifier for every test
%   instance. This function merges the votes into a single class, i.e., it
%   "decides" the label assigned by the ensemble to each test instance.
%
%   The first 3 arguments of MERGE are the same returned by all ensemble
%   functions in RUNS.DME.
%
%   MERGE(V,W,[],T,n) decides for class labeling ensembles, where V and W
%   are the votes and the weight matrices as returned by labeling ensemble
%   functions of RUNS.DME. The third argument may be an empty matrix or an
%   empty cell. The arguments T and n stand for the training classes and
%   number of classes. The output of MERGE is the accuracy of the ensemble
%   on the test data set.
%
%   Usage example:
%
%       % The arguments of RUNS.DME.MAJORITY are ommitted for brevity.
%       % Please refer to the ensemble documentation for details.
%       numclasses = %number of classes for the data set
%       numinstances = %number of test instances in the data set
%       [votes, weights, rankings] = runs.dme.majority(...);
%       merge(votes, weights, rankings, numclasses, numinstances);
%
%   MERGE([],[],R,c,n) decides for label ranking ensembles, where the votes
%   and weight matrices are empty and R is the ranking cell as returned by
%   the label ranking ensembles.
%
%   [a,C] = MERGE(...) works as the two forms above, but also returns the
%   class labels assigned to each test instance in addition to the
%   accuracy as a column vector.
%
%   For more information on how ensemble evaluation is implemented in
%   TimeBox, please check RUNS.DME.MAJORITY.
if isempty(votes)
    % Label ranking. The weight matrix must also be empty and the ranking
    % cell cannot be empty.
    tb.assert(isempty(weights), ['Vote matrix is empty, therefore label ranking ensemble was assumed, ' ...
        'in which case the weight matrix MUST be empty.']);
    tb.assert(~isempty(rankings), ['Vote matrix is empty, therefore label ranking ensemble was assumed, ' ...
        'in which case the ranking cell must NOT be empty.']);
    
    votesperclass = meanranks(rankings, numclasses, numel(testclasses));
else
    % Label assigner. The weight matrix must not be empty and the ranking
    % cell must be empty.
    tb.assert(~isempty(weights), ['Vote matrix is not empty, therefore class labeling ensemble was assumed, ' ...
        'in which case the weight matrix must NOT be empty.']);
    tb.assert(isempty(rankings), ['Vote matrix is NOT empty, therefore CLASS labeling ensemble was assumed, ' ...
        'in which case the ranking cell MUST be empty.']);        
    
    votesperclass = meanvotes(votes, weights, numclasses, numel(testclasses));
end
classes = zeros(numel(testclasses), 1);
for i = 1:numel(testclasses)
    instancevotes = votesperclass(:, i);
    
    % If an ensemble equally favors more than one class, decides randomly
    % among them
    mostvoted = find(instancevotes == max(instancevotes));
    if numel(mostvoted) > 1
        classes(i) = randsample(mostvoted, 1);
    else
        classes(i) = mostvoted;
    end
end        

acc = mean(classes == testclasses);
end


function weightedvotes = meanvotes(votes, weights, numclasses, numinstances)
    weightedvotes = zeros(numclasses, numinstances);
    for class = 1:numclasses
        weightedvotes(class, :) = sum(weights .* (votes == class), 1);
    end
end


function sumofranks = meanranks(rankings, numclasses, numinstances)
    sumofranks = zeros(numclasses, numinstances);
    for c = 1:numel(rankings)
        sumofranks = sumofranks + rankings{c};
    end
    
    % transform rank into points
    sumofranks = max(max(sumofranks)) - sumofranks;
end