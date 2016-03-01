function [sorted, index] = sortclasses(dataset)
%TS.SORTCLASSES     Sort the instances of a data set by class values
%   SORTCLASSES(ds) sorts the instances of the data set "ds" by its
%   classes. "ds" must be a valid data set as loaded by TS.LOAD. Instances
%   will be  sorted in a stable manner (the order of the instances within
%   each class will not be modified) such that the first instances will
%   have class value that is numerically smaller than the remaining
%   instances.
%
%   [srt,idx] = SORTCLASSES(ds) will return the sorted data set in "srt"
%   and a class index in "idx", which will be a NC-by-3 array of double
%   when NC is the number of classes in "ds". The first column of "idx"
%   will be a class label, the second and the third columns will be indices
%   to the fist and the last instances in "srt" which that class label.
classes = dataset(:, 1);
classvalues = unique(classes);

sorted = zeros(size(dataset));
index = zeros(numel(classvalues), 3);

last = 0;
for c = 1:numel(classvalues)
    thisclass = classvalues(c);
    mask = classes == thisclass;
    
    first = last + 1;
    last = last + sum(mask);
    
    sorted(first:last, :) = dataset(mask, :);
    index(c,:) = [thisclass, first, last];
end