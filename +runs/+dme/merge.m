function [acc, classes] = merge(votes, weights, rankings, testclasses, labels)
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
%   MERGE(V,W,[],T,L) decides for class labeling ensembles, where V and
%   W are the votes and the weight matrices as returned by labeling
%   ensemble functions of RUNS.DME. The third argument may be an empty
%   matrix or an empty cell. The arguments T and L stand for the
%   training classes assigned with each test instance and the valid
%   label set. The output of MERGE is the accuracy of the ensemble on
%   the test data set. 
%
%   Usage example:
%
%       % The arguments of RUNS.DME.MAJORITY are ommitted for brevity.
%       % Please refer to the ensemble documentation for details.
%       testclasses = %the classes of each test instance
%       labels = %the valid labels for this classification probelm
%       [votes, weights, rankings] = runs.dme.majority(...);
%       merge(votes, weights, rankings, testclasses, labels)
%
%   MERGE([],[],R,T,L) decides for label ranking ensembles, where the
%   votes and weight matrices are empty and R is the ranking cell as
%   returned by the label ranking ensembles. The order of the labels in
%   L must be the same as used to produce the rankings.
%
%   [a,C] = MERGE(...) works as the two forms above, but also returns the
%   class labels assigned to each test instance in addition to the
%   accuracy as a column vector.
%
%   For more information on how ensemble evaluation is implemented in
%   TimeBox, please check RUNS.DME.MAJORITY.

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 0.1
numlabels = numel(labels);
numinstances = numel(testclasses);

if isempty(votes)
    % Label ranking. The weight matrix must also be empty and the ranking
    % cell cannot be empty.
    tb.assert(isempty(weights), ['Vote matrix is empty, therefore label ranking ensemble was assumed, ' ...
        'in which case the weight matrix MUST be empty.']);
    tb.assert(~isempty(rankings), ['Vote matrix is empty, therefore label ranking ensemble was assumed, ' ...
        'in which case the ranking cell must NOT be empty.']);
    
    votesperclass = meanranks(rankings, numlabels, numinstances);
else
    % Label assigner. The weight matrix must not be empty and the ranking
    % cell must be empty.
    tb.assert(~isempty(weights), ['Vote matrix is not empty, therefore class labeling ensemble was assumed, ' ...
        'in which case the weight matrix must NOT be empty.']);
    tb.assert(isempty(rankings), ['Vote matrix is NOT empty, therefore CLASS labeling ensemble was assumed, ' ...
        'in which case the ranking cell MUST be empty.']);        
    
    votesperclass = meanvotes(votes, weights, labels, numlabels, numinstances);
end
classes = zeros(numel(testclasses), 1);
for i = 1:numel(testclasses)
    instancevotes = votesperclass(:, i);
    
    % If an ensemble equally favors more than one class, decides randomly
    % among them
    mostvoted = find(instancevotes == max(instancevotes));
    if numel(mostvoted) > 1
        classes(i) = labels(randsample(mostvoted, 1));
    else
        classes(i) = labels(mostvoted);
    end
end        

acc = mean(classes == testclasses);
end


function weightedvotes = meanvotes(votes, weights, labels, numlabels, numinstances)
    weightedvotes = zeros(numlabels, numinstances);
    for c = 1:numlabels
        weightedvotes(c, :) = sum(weights .* (votes == labels(c)), 1);
    end
end


function sumofranks = meanranks(rankings, numlabels, numinstances)
    sumofranks = zeros(numlabels, numinstances);
    for i = 1:numel(rankings)
        sumofranks = sumofranks + rankings{i};
    end
    
    % transform rank into points
    sumofranks = max(max(sumofranks)) - sumofranks;
end